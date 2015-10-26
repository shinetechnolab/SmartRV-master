/*
     File: KMLParser.m 
 Abstract: 
 Implements a limited KML parser.
 The following KML types are supported:
         Style,
         LineString,
         Point,
         Polygon,
         Placemark.
      All other types are ignored
  
  Version: 1.3 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "KMLParser.h"

#import "TTRouteInstruction.h"

// KMLElement and subclasses declared here implement a class hierarchy for
// storing a KML document structure.  The actual KML file is parsed with a SAX
// parser and only the relevant document structure is retained in the object
// graph produced by the parser.  Data parsed is also transformed into
// appropriate UIKit and MapKit classes as necessary.

// Abstract KMLElement type.  Handles storing an element identifier (id="...")
// as well as a buffer for accumulating character data parsed from the xml.
// In general, subclasses should have beginElement and endElement classes for
// keeping track of parsing state.  The parser will call beginElement when
// an interesting element is encountered, then all character data found in the
// element will be stored into accum, and then when endElement is called accum
// will be parsed according to the conventions for that particular element type
// in order to save the data from the element.  Finally, clearString will be
// called to reset the character data accumulator.

// Convert a KML coordinate list string to a C array of CLLocationCoordinate2Ds.
// KML coordinate lists are longitude,latitude[,altitude] tuples specified by whitespace.
static void strToCoords(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut)
{
    NSUInteger read = 0, space = 10;
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * space);
    
    NSArray *tuples = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *tuple in tuples) {
        if (read == space) {
            space *= 2;
            coords = realloc(coords, sizeof(CLLocationCoordinate2D) * space);
        }
        
        double lat, lon;
        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
        BOOL success = [scanner scanDouble:&lon];
        if (success) 
            success = [scanner scanDouble:&lat];
        if (success) {
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
            if (CLLocationCoordinate2DIsValid(c))
                coords[read++] = c;
        }
        [scanner release];
    }
    
    *coordsOut = coords;
    *coordsLenOut = read;
}

@interface UIColor (KMLExtras)

// Parse a KML string based color into a UIColor.  KML colors are agbr hex encoded.
+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString;

@end

@implementation KMLParser

// After parsing has completed, this method loops over all placemarks that have
// been parsed and looks up their corresponding KMLStyle objects according to
// the placemark's styleUrl property and the global KMLStyle object's identifier.
- (void)_assignStyles
{
    for (KMLPlacemark *placemark in _placemarks) {
        if (!placemark.style && placemark.styleUrl) {
            NSString *styleUrl = placemark.styleUrl;
            NSRange range = [styleUrl rangeOfString:@"#"];
            if (range.length == 1 && range.location == 0) {
                NSString *styleID = [styleUrl substringFromIndex:1];
                KMLStyle *style = [_styles objectForKey:styleID];
                placemark.style = style;
            }
        }
    }
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _styles = [[NSMutableDictionary alloc] init];
        _placemarks = [[NSMutableArray alloc] init];
        _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        [_xmlParser setDelegate:self];
    }
    return self;
}

- (id)initWithData:(NSData *)data;
{
    if (self = [super init]) {
        _styles = [[NSMutableDictionary alloc] init];
        _placemarks = [[NSMutableArray alloc] init];
        _xmlParser = [[NSXMLParser alloc] initWithData:data];
        
        [_xmlParser setDelegate:self];
    }
    return self;
}

- (NSMutableArray *)getAllPlacemarks
{
    return _placemarks;
}

- (void)dealloc
{
    [_styles release];
    [_placemarks release];
    [_xmlParser release];
    
    [super dealloc];
}

- (void)parseKML
{
    [_xmlParser parse];
    [self _assignStyles];
}

// Return the list of KMLPlacemarks from the object graph that contain overlays
// (as opposed to simply point annotations).
- (NSArray *)overlays
{
//    if (_placemarks.count==0) {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"_Placemarcks Array Empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//    }
//    else{
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!!" message:@"_Placemarcks Array Filled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//    }
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        id <MKOverlay> overlay = [placemark overlay];
        if (overlay)
            [overlays addObject:overlay];
    }
    return [overlays autorelease];
}

// Return the list of KMLPlacemarks from the object graph that are simply
// MKPointAnnotations and are not MKOverlays.
- (NSArray *)points
{
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        id <MKAnnotation> point = [placemark point];
        if (point)
            [points addObject:point];
    }
    return [points autorelease];
}
-(NSArray *)getSpeedLimitData
{
    return speedLimitData;
}
- (NSArray *)instructions//
{
    NSMutableArray *instructons = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        TTRouteInstruction *instructionObject = [placemark getInstruction];
        if (instructionObject)
            [instructons addObject:instructionObject];
    }
    return [instructons autorelease];
}

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point
{
    // Find the KMLPlacemark object that owns this point and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        if ([placemark point] == point)
            return [placemark annotationView];
    }
    return nil;
}

- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay
{
    // Find the KMLPlacemark object that owns this overlay and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        if ([placemark overlay] == overlay)
            return [placemark overlayView];
    }
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"viewForOverlay return nill" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    alert.tag=1111;
//    [alert show];
//    [alert release];
    return nil;
}

- (MKOverlayRenderer *)rendererForOverlay:(id <MKOverlay>)overlay
{
    for (KMLPlacemark *placemark in _placemarks) {
        if ([placemark overlay] == overlay)
            return [placemark overlayRenderer];
    }
    //    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"viewForOverlay return nill" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    alert.tag=1111;
    //    [alert show];
    //    [alert release];
    return nil;
}

#pragma mark NSXMLParserDelegate

#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    NSLog(@"Attribute : %@",elementName);
    NSString *ident = [attributeDict objectForKey:@"id"];
    
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark beginStyleWithIdentifier:ident];
        } else if (ident != nil) {
            _style = [[KMLStyle alloc] initWithIdentifier:ident];
        }
    } else if (ELTYPE(PolyStyle)) {
        [style beginPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style beginLineStyle];
    } else if (ELTYPE(color)) {
        [style beginColor];
    } else if (ELTYPE(width)) {
        [style beginWidth];
    } else if (ELTYPE(fill)) {
        [style beginFill];
    } else if (ELTYPE(outline)) {
        [style beginOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        _placemark = [[KMLPlacemark alloc] initWithIdentifier:ident];
        [_placemark beginInstruction];//for instructions
    } else if (ELTYPE(Name)) {
        [_placemark beginName];
    } else if (ELTYPE(Description)) {
        [_placemark beginDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark beginStyleUrl];
    } else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark beginGeometryOfType:elementName withIdentifier:ident];         
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates)) {
        [_placemark.geometry beginCoordinates];
    }
    else if (ELTYPE(tt:speedsigns)) {
        [_placemark beginInstruction];
    }
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon beginOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon beginInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon beginLinearRing];
    }
    // TeleType Route Instruction Info sub-elements
    else if(ELTYPE(tt:targetName)) {
        [_placemark beginInstruction];
    }
    else if (ELTYPE(tt:direction)) {
        [_placemark beginInstruction];
    }
    else if (ELTYPE(tt:distToDest)) {
        [_placemark beginInstruction];
    } else if(ELTYPE(tt:timeToDest)) {
        [_placemark beginInstruction];
    }else if(ELTYPE(tt:laneInfo)) {
        [_placemark beginInstruction];
    } else if (ELTYPE(MultiGeometry)) {
        [_placemark endInstruction];//not for instruction
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    NSLog(@"element : %@",elementName);
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark endStyle];
        } else if (_style) {
            [_styles setObject:_style forKey:_style.identifier];
            [_style release];
            _style = nil;
        }
    } else if (ELTYPE(PolyStyle)) {
        [style endPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style endLineStyle];
    } else if (ELTYPE(color)) {
        [style endColor];
    } else if (ELTYPE(width)) {
        [style endWidth];
    } else if (ELTYPE(fill)) {
        [style endFill];
    } else if (ELTYPE(outline)) {
        [style endOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        if (_placemark) {
            [_placemark endInstruction];//for instructions
            [_placemarks addObject:_placemark];
            [_placemark release];
            _placemark = nil;
        }
    } else if (ELTYPE(Name)) {
        [_placemark endName];
        [_placemark setName];
    } else if (ELTYPE(Description)) {
        [_placemark endDescription];
        [_placemark setDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark endStyleUrl];
    } else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark endGeometry];            
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates)) {
        [_placemark.geometry endCoordinates];
        [_placemark setCoordinate];
    }
    else if (ELTYPE(tt:speedsigns)) {
        [_placemark setSpeedLimit];
    }
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon endOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon endInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon endLinearRing];
    }
    // TeleType Route Instruction Info sub-elements
    else if (ELTYPE(tt:targetName)) {
        [_placemark setTargetName];
    }
    else if (ELTYPE(tt:direction)) {
        [_placemark setDirection];
//        NSLog(@"check point: setDirection");
    }
    else if (ELTYPE(tt:distToDest)) {
        [_placemark setDistToDest];
        //NSLog(@"check point 1");
    }
    else if(ELTYPE(tt:timeToDest)) {
        [_placemark setTimeToDest];
        //NSLog(@"check point 2");
    }
    else if(ELTYPE(tt:laneInfo)) {
        [_placemark setLaneinfo];
        //NSLog(@"check point 2");
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    KMLElement *element = _placemark ? (KMLElement *)_placemark : (KMLElement *)_style;
    [element addString:string];
}

@end

// Begin the implementations of KMLElement and subclasses.  These objects
// act as state machines during parsing time and then once the document is
// fully parsed they act as an object graph for describing the placemarks and
// styles that have been parsed.

@implementation KMLElement

@synthesize identifier;

- (id)initWithIdentifier:(NSString *)ident
{
    if (self = [super init]) {
        identifier = [ident retain];
    }
    return self;
}

- (void)dealloc
{
    [identifier release];
    [accum release];
    [super dealloc];
}

- (BOOL)canAddString
{
    return NO;
}

- (void)addString:(NSString *)str
{
    if ([self canAddString]) {
        if (!accum)
            accum = [[NSMutableString alloc] init];
        [accum appendString:str];
//        NSLog(@"added string: %@", accum);
    }
}

- (void)clearString
{
//    NSLog(@"clearing string: %@", accum);
    [accum release];
    accum = nil;
}

@end

@implementation KMLStyle 

- (BOOL)canAddString
{
    return flags.inColor || flags.inWidth || flags.inFill || flags.inOutline;
}

- (void)beginLineStyle
{
    flags.inLineStyle = YES;
}
- (void)endLineStyle
{
    flags.inLineStyle = NO;
}

- (void)beginPolyStyle
{
    flags.inPolyStyle = YES;
}
- (void)endPolyStyle
{
    flags.inPolyStyle = NO;
}

- (void)beginColor
{
    flags.inColor = YES;
}
- (void)endColor
{
    flags.inColor = NO;
    
    if (flags.inLineStyle) {
        [strokeColor release];
        strokeColor = [[UIColor colorWithKMLString:accum] retain];
    } else if (flags.inPolyStyle) {
        [fillColor release];
        fillColor = [[UIColor colorWithKMLString:accum] retain];
    }
    
    [self clearString];
}

- (void)beginWidth
{
    flags.inWidth = YES;
}
- (void)endWidth
{
    flags.inWidth = NO;
    strokeWidth = [accum floatValue];
    [self clearString];
}

- (void)beginFill
{
    flags.inFill = YES;
}
- (void)endFill
{
    flags.inFill = NO;
    fill = [accum boolValue];
    [self clearString];
}

- (void)beginOutline
{
    flags.inOutline = YES;
}
- (void)endOutline
{
    stroke = [accum boolValue];
    [self clearString];
}

- (void)applyToOverlayPathView:(MKOverlayPathView *)view
{
    view.strokeColor = strokeColor;
    view.fillColor = fillColor;
   // view.lineWidth =strokeWidth+5;
}

@end

@implementation KMLGeometry

- (BOOL)canAddString
{
    return flags.inCoords;
}

- (void)beginCoordinates
{
    flags.inCoords = YES;
}

- (void)endCoordinates
{
    flags.inCoords = NO;
}

- (MKShape *)mapkitShape
{
    return nil;
}

- (MKOverlayPathView *)createOverlayView:(MKShape *)shape
{
    return nil;
}

@end

@implementation KMLPoint

@synthesize point;

- (void)endCoordinates
{
    flags.inCoords = NO;
    
    CLLocationCoordinate2D *points = NULL;
    NSUInteger len = 0;
    
    strToCoords(accum, &points, &len);
    if (len == 1) {
        point = points[0];
    }
    free(points);
    
    [self clearString];
}

- (MKShape *)mapkitShape
{
    // KMLPoint corresponds to MKPointAnnotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = point;
    return [annotation autorelease];
}

// KMLPoint does not override createOverlayView: because there is no such
// thing as an overlay view for a point.  They use MKAnnotationViews which
// are vended by the KMLPlacemark class.

@end

@implementation KMLPolygon

- (void)dealloc
{
    [outerRing release];
    [innerRings release];
    [super dealloc];
}

- (BOOL)canAddString
{
    return polyFlags.inLinearRing && flags.inCoords;
}

- (void)beginOuterBoundary
{
    polyFlags.inOuterBoundary = YES;
}
- (void)endOuterBoundary
{
    polyFlags.inOuterBoundary = NO;
    outerRing = [accum copy];
    [self clearString];
}

- (void)beginInnerBoundary
{
    polyFlags.inInnerBoundary = YES;
}
- (void)endInnerBoundary
{
    polyFlags.inInnerBoundary = NO;
    NSString *ring = [accum copy];
    if (!innerRings) {
        innerRings = [[NSMutableArray alloc] init];
    }
    [innerRings addObject:ring];
    [ring release];
    [self clearString];
}

- (void)beginLinearRing
{
    polyFlags.inLinearRing = YES;
}
- (void)endLinearRing
{
    polyFlags.inLinearRing = NO;
}

- (MKShape *)mapkitShape
{
    // KMLPolygon corresponds to MKPolygon
    
    // The inner and outer rings of the polygon are stored as kml coordinate
    // list strings until we're asked for mapkitShape.  Only once we're here
    // do we lazily transform them into CLLocationCoordinate2D arrays.
    
    // First build up a list of MKPolygon cutouts for the interior rings.
    NSMutableArray *innerPolys = nil;
    if (innerRings) {
        innerPolys = [[NSMutableArray alloc] initWithCapacity:[innerPolys count]];
        for (NSString *coordStr in innerRings) {
            CLLocationCoordinate2D *coords = NULL;
            NSUInteger coordsLen = 0;
            strToCoords(coordStr, &coords, &coordsLen);
            [innerPolys addObject:[MKPolygon polygonWithCoordinates:coords count:coordsLen]];
            free(coords);
        }
    }
    // Now parse the outer ring.
    CLLocationCoordinate2D *coords = NULL;
    NSUInteger coordsLen = 0;
    strToCoords(outerRing, &coords, &coordsLen);
    
    // Build a polygon using both the outer coordinates and the list (if applicable)
    // of interior polygons parsed.
    MKPolygon *poly = [MKPolygon polygonWithCoordinates:coords count:coordsLen interiorPolygons:innerPolys];
    free(coords);
    [innerPolys release];
    return poly;
}

- (MKOverlayPathView *)createOverlayView:(MKShape *)shape
{
    // KMLPolygon corresponds to MKPolygonView
    
    MKPolygonView *polyView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)shape];
    return [polyView autorelease];
}

@end

@implementation KMLLineString

@synthesize points, length;

- (void)dealloc
{
    if (points)
        free(points);
    [super dealloc];
}

- (void)endCoordinates
{
    flags.inCoords = NO;
    
    if (points)
        free(points);
    
    strToCoords(accum, &points, &length);
    
    [self clearString];
}

- (MKShape *)mapkitShape
{
    // KMLLineString corresponds to MKPolyline
    return [MKPolyline polylineWithCoordinates:points count:length];
}

- (MKOverlayPathView *)createOverlayView:(MKShape *)shape
{
    // KMLLineString corresponds to MKPolylineView
    MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)shape];
    return [lineView autorelease];
}

@end

@implementation KMLPlacemark

@synthesize style, styleUrl, geometry, name, placemarkDescription;

- (void)dealloc
{
    [style release];
    [geometry release];
    [name release];
    [placemarkDescription release];
    [styleUrl release];
    [mkShape release];
    [overlayView release];
    [annotationView release];
    [targetName release];
    [instruction release];
    [super dealloc];
}

- (BOOL)canAddString
{
    return flags.inName || flags.inStyleUrl || flags.inDescription || flags.inInstruction;
}

- (void)addString:(NSString *)str
{
    if (flags.inStyle)
        [style addString:str];
    else if (flags.inGeometry)
        [geometry addString:str];
    else
        [super addString:str];
}

- (void)beginName
{
    flags.inName = YES;
    [self clearString];
}
- (void)endName
{
    flags.inName = NO;
    [name release];
    name = [accum copy];
    [self clearString];
}

- (void)beginDescription
{
    flags.inDescription = YES;
    [self clearString];
}
- (void)endDescription
{
    flags.inDescription = NO;
    [placemarkDescription release];
    placemarkDescription = [accum copy];
    [self clearString];
}

- (void)beginStyleUrl
{
    flags.inStyleUrl = YES;
}
- (void)endStyleUrl
{
    flags.inStyleUrl = NO;
    [styleUrl release];
    styleUrl = [accum copy];
    [self clearString];
}

- (void)beginInstruction
{
    flags.inInstruction = YES;
    if (!instruction) 
    {
        instruction = [[TTRouteInstruction alloc]retain];
    }
    [self clearString];
}

- (void)endInstruction
{
    flags.inInstruction = NO;
}

// TeleType Route Instruction Info
- (void)setDirection
{
//    NSLog(@"direction: %d", [accum intValue]);
    [instruction setDirection:[accum intValue]];    
    [self clearString];
}
- (void)setTimeToDest
{
    [instruction setTimeToDest:[accum doubleValue]];
    [self clearString];
}
- (void)setLaneinfo
{
    [instruction setLaneInfo:accum];
    [self clearString];
}
- (void)setDistToDest
{
    [instruction setDistToDest:[accum intValue]];
    [self clearString];                              
}
-(void)setSpeedLimit
{
    speedLimitData=[[NSArray alloc] initWithArray:[accum componentsSeparatedByString:@" "]];
}
- (void)setCoordinate
{
    if(flags.inInstruction)
    {
        [instruction setCoord:[(KMLPoint*)geometry point]];
    }
}
- (void)setName
{
    if(flags.inInstruction)
    {
        [instruction setInfo:name];
    }
}
- (void)setDescription
{
    if(flags.inInstruction)
    {
        [instruction setDistanceInfo:placemarkDescription];
    }
}
- (void)setTargetName
{
    if(flags.inInstruction)
    {
        [targetName release];
        targetName = [accum copy];
        [instruction setTargetName:targetName];
//        [instruction setTargetName:[accum copy]];
//        instruction.targetName = [accum copy];
        [self clearString];
    }
}

- (void)beginStyleWithIdentifier:(NSString *)ident
{
    flags.inStyle = YES;
    [style release];
    style = [[KMLStyle alloc] initWithIdentifier:ident];
}
- (void)endStyle
{
    flags.inStyle = NO;
}

- (void)beginGeometryOfType:(NSString *)elementName withIdentifier:(NSString *)ident
{
    flags.inGeometry = YES;
    if (ELTYPE(Point))
        geometry = [[KMLPoint alloc] initWithIdentifier:ident];
    else if (ELTYPE(Polygon))
        geometry = [[KMLPolygon alloc] initWithIdentifier:ident];
    else if (ELTYPE(LineString))
        geometry = [[KMLLineString alloc] initWithIdentifier:ident];
}
- (void)endGeometry
{
    flags.inGeometry = NO;
}

- (KMLGeometry *)geometry
{
    return geometry;
}

- (KMLPolygon *)polygon
{
    return [geometry isKindOfClass:[KMLPolygon class]] ? (id)geometry : nil;
}

- (void)_createShape
{
    if (!mkShape) {
        mkShape = [[geometry mapkitShape] retain];
        mkShape.title = name;
        // Skip setting the subtitle for now because they're frequently
        // too verbose for viewing on in a callout in most kml files.
//        mkShape.subtitle = placemarkDescription;
    }else{
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"MKshape is nil" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
    }
}

- (id <MKOverlay>)overlay
{
    [self _createShape];
    
    if ([mkShape conformsToProtocol:@protocol(MKOverlay)])
    {
        return (id <MKOverlay>)mkShape;
    }
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"MKOverlay protocol not found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
//    [alert release];
    
    return nil;
}

- (id <MKAnnotation>)point
{
    [self _createShape];
    
    // Make sure to check if this is an MKPointAnnotation.  MKOverlays also
    // conform to MKAnnotation, so it isn't sufficient to just check to
    // conformance to MKAnnotation.
    if ([mkShape isKindOfClass:[MKPointAnnotation class]])
        return (id <MKAnnotation>)mkShape;
    
    return nil;
}

- (TTRouteInstruction *)getInstruction
{
    return instruction;
}

- (MKOverlayView *)overlayView
{
//    if (!overlayView) {
//        id <MKOverlay> overlay = [self overlay];
//        if (overlay) {
//            overlayView = [[geometry createOverlayView:overlay] retain];
//            [style applyToOverlayPathView:overlayView];
//        }
//    }
//    return overlayView;
    //return [self overlay];
    if (!overlayView) {
        id <MKOverlay> overlay = [self overlay];
        if (overlay)
        {
            
            
            
            overlayView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay] autorelease];
            //overlayView.fillColor = [UIColor colorWithKMLString:@"7fff0055"];
//            overlayView.strokeColor = [UIColor colorWithKMLString:@"7fff0055"];
           // overlayView.strokeColor = [UIColor colorWithRed:253/255.0 green:67/255.0 blue:242/255.0 alpha:0.5];
            overlayView.strokeColor =[UIColor colorWithRed:107/255.0 green:0/255.0 blue:253/255.0 alpha:0.45];

            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                overlayView.lineWidth = 30;
            } else {
                overlayView.lineWidth = 35;
            }
            
//            overlayView = [[geometry createOverlayView:overlay] retain];
//            if(style)
//            {
//                [style applyToOverlayPathView:overlayView];
//            }else
//            {
//                //add default styles to view
//                overlayView.strokeColor = [UIColor colorWithKMLString:@"7fff0055"];
//                overlayView.fillColor = [UIColor colorWithKMLString:@"7f000055"];
//                //overlayView.lineWidth = 30;//default
//                //overlayView.
//            }
            
        }
    }
    return overlayView;
}



- (MKOverlayRenderer *)overlayRenderer
{
    
    if (!overlayView) {
        id <MKOverlay> overlay = [self overlay];
        if (overlay)
        {
            /*
            overlayRenderer = [[[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay] autorelease];
            overlayRenderer.strokeColor = [UIColor colorWithKMLString:@"7fff0055"];
            
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                overlayRenderer.lineWidth = 15;
            } else {
                overlayRenderer.lineWidth = 35;
            }*/
            
            //Nikunj Code
            MKPolygon *polygon = [self convertPolylineToPolygon:overlay];
            overlayRenderer = [[MKPolygonRenderer alloc]initWithPolygon:polygon];
            overlayRenderer.strokeColor = [UIColor colorWithKMLString:@"7fff0055"];
            overlayRenderer.lineWidth = 1.0;
            overlayRenderer.fillColor = [UIColor colorWithKMLString:@"7fff0055"];
            
            // Amit Code
//            MKPolygon *polygon = [self convertPolylineToPolygon:overlay];
//            overlayRenderer = [[MKPolygonRenderer alloc]initWithPolygon:polygon];
//             overlayRenderer.strokeColor = [UIColor colorWithRed:107/255.0 green:0/255.0 blue:253/255.0 alpha:0.45];
//            overlayRenderer.lineWidth = 15.0;
//            overlayRenderer.fillColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.1];
                       //return pg_renderer;
            
        }
    }
    return overlayRenderer;
}


- (MKPolygon *)convertPolylineToPolygon:(MKPolyline *)polyline
{
    NSUInteger pt_count = polyline.pointCount;
    NSUInteger pg_pt_count = pt_count*2 - 2;
    MKMapPoint MPs[pg_pt_count];
    MPs[0].x = polyline.points[0].x;
    MPs[0].y = polyline.points[0].y;
    MPs[pt_count - 1].x = polyline.points[pt_count - 1].x;
    MPs[pt_count - 1].y = polyline.points[pt_count - 1].y;
    
    for (NSUInteger i=1; i<pt_count - 1; i++) {
        MPs[i].x = polyline.points[i].x - 30;
        MPs[i].y = polyline.points[i].y;
        MPs[pg_pt_count - i].x = polyline.points[i].x + 30;
        MPs[pg_pt_count - i].y = polyline.points[i].y;
    }
    
    MKPolygon *polygon = [MKPolygon polygonWithPoints:MPs count:pg_pt_count];
    return polygon;
}



- (MKAnnotationView *)annotationView
{
    if (!annotationView) {
        id <MKAnnotation> annotation = [self point];
        if (annotation) {
            MKPinAnnotationView *pin =
                [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            pin.canShowCallout = YES;
            pin.animatesDrop = YES;
            annotationView = pin;
        }
    }
    return annotationView;
}

@end

@implementation UIColor (KMLExtras)

+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:kmlColorString];
    unsigned color = 0;
    [scanner scanHexInt:&color];
    
    unsigned a = (color >> 24) & 0x000000FF;
    unsigned b = (color >> 16) & 0x000000FF;
    unsigned g = (color >> 8) & 0x000000FF;
    unsigned r = color & 0x000000FF;
    
    CGFloat rf = (CGFloat)r / 255.f;
    CGFloat gf = (CGFloat)g / 255.f;
    CGFloat bf = (CGFloat)b / 255.f;
    CGFloat af = (CGFloat)a / 255.f;
    
    [scanner release];
    return [UIColor colorWithRed:rf green:gf blue:bf alpha:0.30];
}

@end


