/*
     File: KMLParser.h
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

#import <MapKit/MapKit.h>
//#import "TTDefinition.h"
#import "TTRouteInstruction.h"
NSArray *speedLimitData;
@class KMLPlacemark;
@class KMLStyle;

@interface KMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarks;
    
    KMLPlacemark *_placemark;
    KMLStyle *_style;
    
    NSXMLParser *_xmlParser;
}

- (id)initWithURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (NSMutableArray *)getAllPlacemarks;
- (void)parseKML;
- (NSArray *)getSpeedLimitData;
@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) NSArray *instructions;//

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;
- (MKOverlayRenderer *)rendererForOverlay:(id <MKOverlay>)overlay;

@end

@interface KMLElement : NSObject {
    NSString *identifier;
    NSMutableString *accum;
}

- (id)initWithIdentifier:(NSString *)ident;

@property (nonatomic, readonly) NSString *identifier;

// Returns YES if we're currently parsing an element that has character
// data contents that we are interested in saving.
- (BOOL)canAddString;
// Add character data parsed from the xml
- (void)addString:(NSString *)str;
// Once the character data for an element has been parsed, use clearString to
// reset the character buffer to get ready to parse another element.
- (void)clearString;

@end

// Represents a KML <Style> element.  <Style> elements may either be specified
// at the top level of the KML document with identifiers or they may be
// specified anonymously within a Geometry element.
@interface KMLStyle : KMLElement {    
    UIColor *strokeColor;
    CGFloat strokeWidth;
    UIColor *fillColor;
    
    BOOL fill;
    BOOL stroke;
    
    struct { 
        int inLineStyle:1;
        int inPolyStyle:1;
        
        int inColor:1;
        int inWidth:1;
        int inFill:1;
        int inOutline:1;
    } flags;
}

- (void)beginLineStyle;
- (void)endLineStyle;

- (void)beginPolyStyle;
- (void)endPolyStyle;

- (void)beginColor;
- (void)endColor;

- (void)beginWidth;
- (void)endWidth;

- (void)beginFill;
- (void)endFill;

- (void)beginOutline;
- (void)endOutline;

- (void)applyToOverlayPathView:(MKOverlayPathView *)view;

@end

@interface KMLGeometry : KMLElement {
    struct {
        int inCoords:1;
    } flags;
}

- (void)beginCoordinates;
- (void)endCoordinates;

// Create (if necessary) and return the corresponding Map Kit MKShape object
// corresponding to this KML Geometry node.
- (MKShape *)mapkitShape;

// Create (if necessary) and return the corresponding MKOverlayPathView for
// the MKShape object.
- (MKOverlayPathView *)createOverlayView:(MKShape *)shape;

@end

// A KMLPoint element corresponds to an MKAnnotation and MKPinAnnotationView
@interface KMLPoint : KMLGeometry {
    CLLocationCoordinate2D point;
}

@property (nonatomic, readonly) CLLocationCoordinate2D point;

@end

// A KMLPolygon element corresponds to an MKPolygon and MKPolygonView
@interface KMLPolygon : KMLGeometry {
    NSString *outerRing;
    NSMutableArray *innerRings;
    
    struct {
        int inOuterBoundary:1;
        int inInnerBoundary:1;
        int inLinearRing:1;
    } polyFlags;
}

- (void)beginOuterBoundary;
- (void)endOuterBoundary;

- (void)beginInnerBoundary;
- (void)endInnerBoundary;

- (void)beginLinearRing;
- (void)endLinearRing;

@end

@interface KMLLineString : KMLGeometry {
    CLLocationCoordinate2D *points;
    NSUInteger length;
}

@property (nonatomic, readonly) CLLocationCoordinate2D *points;
@property (nonatomic, readonly) NSUInteger length;

@end

@interface KMLPlacemark : KMLElement {
    KMLStyle *style;
    KMLGeometry *geometry;
    
    NSString *name;
    NSString *placemarkDescription;
    
    NSString *styleUrl;
    
    MKShape *mkShape;
    
    MKAnnotationView *annotationView;
    MKOverlayPathView *overlayView;
    MKOverlayPathRenderer *overlayRenderer;
    
    struct {
        int inName:1;
        int inDescription:1;
        int inStyle:1;
        int inGeometry:1;
        int inStyleUrl:1;
        //instruction flag
        int inInstruction:1;
    } flags;
    
    // TeleType Route Instruction Info 
    TTRouteInstruction *instruction;
    
    NSString *targetName;
}

- (void)beginName;
- (void)endName;

- (void)beginDescription;
- (void)endDescription;

- (void)beginStyleWithIdentifier:(NSString *)ident;
- (void)endStyle;

- (void)beginGeometryOfType:(NSString *)type withIdentifier:(NSString *)ident;
- (void)endGeometry;

- (void)beginStyleUrl;
- (void)endStyleUrl;

// TeleType Route Instruction Info
- (void)beginInstruction;
- (void)endInstruction;
- (void)setDirection;
- (void)setTimeToDest;
- (void)setLaneinfo;
- (void)setDistToDest;
- (void)setCoordinate;
- (void)setName;
- (void)setDescription;
- (void)setTargetName;
- (void)setSpeedLimit;
// Corresponds to the title property on MKAnnotation
@property (nonatomic, readonly) NSString *name; 
// Corresponds to the subtitle property on MKAnnotation
@property (nonatomic, readonly) NSString *placemarkDescription;

@property (nonatomic, readonly) KMLGeometry *geometry;
@property (nonatomic, readonly) KMLPolygon *polygon;

@property (nonatomic, retain) KMLStyle *style;
@property (nonatomic, readonly) NSString *styleUrl;

- (id <MKOverlay>)overlay;
- (id <MKAnnotation>)point;
- (TTRouteInstruction *)getInstruction;
- (MKOverlayRenderer *)overlayRenderer;
- (MKOverlayView *)overlayView;
- (MKAnnotationView *)annotationView;

@end
