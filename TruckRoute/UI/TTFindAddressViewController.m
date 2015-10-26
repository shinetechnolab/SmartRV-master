//
//  TTFindAddressViewController.m
//  TruckRoute
//
//  Created by admin on 10/4/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTUtilities.h"
#import "TTConfig.h"
#import "TTFindAddressViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface TTFindAddressViewController ()

@end

@implementation TTFindAddressViewController
@synthesize route_request;
@synthesize isDestination;
@synthesize isTableViewHidden;
@synthesize forwardGeocoder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setBottomButtonImage
{
    if (isIpad)
    {
        [backButton setImage:[UIImage imageNamed:@"n_back_btn~ipad.png"] forState:UIControlStateNormal];
        [createRouteButton setImage:[UIImage imageNamed:@"n_search_btn~ipad.png"] forState:UIControlStateNormal];
    }
    else{
        [backButton setImage:[UIImage imageNamed:@"n_back_btn.png"] forState:UIControlStateNormal];
        [createRouteButton setImage:[UIImage imageNamed:@"n_search_btn.png"] forState:UIControlStateNormal];
    }
}
-(void) getCurrentOrientation{
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        if (isIpad) {
            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960~ipad.png"];
            [backButton setImage:[UIImage imageNamed:@"Back1~ipad.png"] forState:UIControlStateNormal];
            [createRouteButton setImage:[UIImage imageNamed:@"OK1~ipad.png"] forState:UIControlStateNormal];
            [backButton setImage:[UIImage imageNamed:@"Back2~ipad.png"] forState:UIControlStateHighlighted];
            [createRouteButton setImage:[UIImage imageNamed:@"OK2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960-Landscape~ipad"];
            [backButton setImage:[UIImage imageNamed:@"Back1-Landscape~ipad.png"] forState:UIControlStateNormal];
            [backButton setImage:[UIImage imageNamed:@"Back2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
            [createRouteButton setImage:[UIImage imageNamed:@"OK1-Landscape~ipad.png"] forState:UIControlStateNormal];
            [createRouteButton setImage:[UIImage imageNamed:@"OK2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[self getCurrentOrientation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[self getCurrentOrientation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _myTableView.layer.cornerRadius=7;
    //[self getCurrentOrientation];
	// Do any additional setup after loading the view.
    resultArray = [[NSMutableArray alloc]init];
    
    self.mapView.showsUserLocation = NO;//jim 07/29/13
	self.mapView.delegate = self;
	self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    idxSelected = -1;
    isTableViewHidden = YES;
    
    _geoCoder = [[CLGeocoder alloc]init];
    
    if (IS_IPAD) {
        
        CGRect rectTable=_myTableView.frame;
        rectTable.origin.y-=160;
        rectTable.size.height+=100;
        _myTableView.frame=rectTable;
        
        CGRect rectBack=backButton.frame;
        rectBack.size.width=370;
        rectBack.size.height=110;
        rectBack.origin.y-=60;
        rectBack.origin.x=10;
        backButton.frame=rectBack;
        
        CGRect rectCreate=createRouteButton.frame;
        rectCreate.size.width=370;
        rectCreate.size.height=110;
        rectCreate.origin.y-=60;
        rectCreate.origin.x=389;
        createRouteButton.frame=rectCreate;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ok:(id)sender {
    if (idxSelected == -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"please select an address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    //add selected result into history
    [self updateHistory];
    
    //update route_request
    [self updateAddress];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [_mapView release];
    [forwardGeocoder release];
    [_searchBar release];
    [_myTableView release];
    [resultArray release];
    [_geoCoder release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMapView:nil];
    [self setSearchBar:nil];
    [self setMyTableView:nil];
    [super viewDidUnload];
}
#pragma mark - BSForwardGeocoderDelegate methods

- (void)forwardGeocoderConnectionDidFail:(BSForwardGeocoder *)geocoder withErrorMessage:(NSString *)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:errorMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder *)geocoder withResults:(NSArray *)results
{
    //clear previous annotations
    NSArray *annotations_old = [_mapView annotations];
    [_mapView removeAnnotations:annotations_old];
    
    //clear result table view
    [resultArray removeAllObjects];
    
    //region for display
    MKMapRect tmpRect = MKMapRectNull;//this is a temporary buffer to store all result locations, not really a MKMapRect
    MKMapRect tmppointRect;//so as above
    
    // Add placemarks for each result
    for (int i = 0, resultCount = [results count]; i < resultCount; i++)
    {
        BSKmlResult *place = [results objectAtIndex:i];
        
        //update table view data source
        //fast check if name is duplicated in address
        NSRange range = [place.address rangeOfString:place.name];
        if (NSNotFound == range.location) {
            [resultArray addObject:[NSString stringWithFormat:@"%@, %@\n%.6f,%.6f", place.name, place.address, place.latitude, place.longitude]];
        }else {
            [resultArray addObject:[NSString stringWithFormat:@"%@\n%.6f,%.6f", place.address, place.latitude, place.longitude]];
        }        
        
        // Add a placemark on the map
        CustomPlacemark *placemark = [[[CustomPlacemark alloc] initWithRegion:place.coordinateRegion] autorelease];
        placemark.title = place.address;
        placemark.subtitle = place.countryName;
        placemark.indexCell = i;
        [_mapView addAnnotation:placemark];
        
        //update region
        tmppointRect = MKMapRectMake((double)(place.longitude), (double)(place.latitude), 0, 0);
        if (MKMapRectIsNull(tmpRect)) {
            tmpRect = tmppointRect;
        } else {
            tmpRect = MKMapRectUnion(tmpRect, tmppointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    if ([results count] == 1) {
        BSKmlResult *place = [results objectAtIndex:0];
        // Zoom into the location
        [_mapView setRegion:place.coordinateRegion animated:YES];
    }else {
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(tmpRect.origin.y + tmpRect.size.height/2, tmpRect.origin.x + tmpRect.size.width/2);
        MKCoordinateSpan span = MKCoordinateSpanMake(tmpRect.size.height*1.2, tmpRect.size.width);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        [_mapView setRegion:region animated:YES];
    }
    
    // Dismiss the keyboard
    [self.searchBar resignFirstResponder];
    
    //reload table view
    if (resultArray.count) {
        [_myTableView reloadData];
        [self resultAnimation:NO];
    }else {
        [self resultAnimation:YES];
    }
}

- (void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage
{
    NSString *message = @"";
    
    switch (errorCode) {
        case G_GEO_BAD_KEY:
            message = @"The API key is invalid.";
            break;
            
        case G_GEO_UNKNOWN_ADDRESS:
            message = [NSString stringWithFormat:@"Could not find %@", @"searchQuery"];
            break;
            
        case G_GEO_TOO_MANY_QUERIES:
            message = @"Too many queries has been made for this API key.";
            break;
            
        case G_GEO_SERVER_ERROR:
            message = @"Server error, please try again.";
            break;
            
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}
/*#pragma mark clgeocoder completionhandler
// display a given NSError in an UIAlertView
- (void)displayError:(NSError*)error
{
    NSString *message;
    switch ([error code])
    {
        case kCLErrorGeocodeFoundNoResult:
            message = @"kCLErrorGeocodeFoundNoResult";
            break;
        case kCLErrorGeocodeCanceled:
            message = @"kCLErrorGeocodeCanceled";
            break;
        case kCLErrorGeocodeFoundPartialResult:
            message = @"kCLErrorGeocodeFoundNoResult";
            break;
        default:
            message = [error description];
            break;
    }
    UIAlertView *alert =  [[[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil] autorelease];;
    [alert show];
}
// display the results
- (void)displayPlacemarks:(NSArray *)results
{
    //clear previous annotations
    NSArray *annotations_old = [_mapView annotations];
    [_mapView removeAnnotations:annotations_old];
    
    //clear result table view
    [resultArray removeAllObjects];
    
    //region for display
    MKMapRect tmpRect = MKMapRectNull;//this is a temporary buffer to store all result locations, not really a MKMapRect
    MKMapRect tmppointRect;//so as above
    
    // Add placemarks for each result
    for (int i = 0, resultCount = [results count]; i < resultCount; i++)
    {
        CLPlacemark *place = [results objectAtIndex:i];
        NSDictionary *dictionary = place.addressDictionary;
        NSLog(@"%@",dictionary);
        NSString *name = place.name;
        
        //update table view data source
        [resultArray addObject:[NSString stringWithFormat:@"%@\n%.6f,%.6f", name, place.location.coordinate.latitude, place.location.coordinate.longitude]];
        
        // Add a placemark on the map
        CLLocationDegrees degrees = DEGREES_TO_RADIANS(place.region.radius);
        MKCoordinateRegion region = MKCoordinateRegionMake(place.location.coordinate, MKCoordinateSpanMake(degrees, degrees));
        CustomPlacemark *placemark = [[[CustomPlacemark alloc] initWithRegion:region] autorelease];
        placemark.title = name;
        placemark.indexCell = i;
        [_mapView addAnnotation:placemark];
        
        //update region
        tmppointRect = MKMapRectMake((double)(place.location.coordinate.longitude), (double)(place.location.coordinate.latitude), 0, 0);
        if (MKMapRectIsNull(tmpRect)) {
            tmpRect = tmppointRect;
        } else {
            tmpRect = MKMapRectUnion(tmpRect, tmppointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    if ([results count] == 1) {
        CLPlacemark *place = [results objectAtIndex:0];
        CLLocationDegrees degrees = DEGREES_TO_RADIANS(place.region.radius);
        MKCoordinateRegion region = MKCoordinateRegionMake(place.location.coordinate, MKCoordinateSpanMake(degrees, degrees));
        // Zoom into the location
        [_mapView setRegion:region animated:YES];
    }else {
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(tmpRect.origin.y + tmpRect.size.height/2, tmpRect.origin.x + tmpRect.size.width/2);
        MKCoordinateSpan span = MKCoordinateSpanMake(tmpRect.size.height*1.2, tmpRect.size.width);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        [_mapView setRegion:region animated:YES];
    }
    
    // Dismiss the keyboard
    [self.searchBar resignFirstResponder];
    
    //reload table view
    if (resultArray.count) {
        [_myTableView reloadData];
        [self resultAnimation:NO];
    }else {
        [self resultAnimation:YES];
    }
}*/
#pragma mark - SEARCHBAR delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
	NSLog(@"Searching for: %@", self.searchBar.text);
    
/*    [_geoCoder geocodeAddressString:_searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"geocodeAddressString:completionHandler: Completion Handler called!");
        if (error)
        {
            NSLog(@"Geocode failed with error: %@", error);
            [self displayError:error];
            return;
        }        
        NSLog(@"Received placemarks: %@", placemarks);
        [self displayPlacemarks:placemarks];
    }];*/
    
    
	if (forwardGeocoder == nil) {
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
    //fix some searching issue
    NSString *temp_str = [NSString stringWithString:self.searchBar.text];
    temp_str = [temp_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([temp_str integerValue] != 0) {
        temp_str = [NSString stringWithFormat:@"0%@", temp_str];
    }
	// Forward geocode!
#if NS_BLOCKS_AVAILABLE
    [self.forwardGeocoder forwardGeocodeWithQuery:temp_str/*self.searchBar.text*/ regionBiasing:nil success:^(NSArray *results) {
        [self forwardGeocodingDidSucceed:self.forwardGeocoder withResults:results];
    } failure:^(int status, NSString *errorMessage) {
        if (status == G_GEO_NETWORK_ERROR) {
            [self forwardGeocoderConnectionDidFail:self.forwardGeocoder withErrorMessage:errorMessage];
        }
        else
        {
            [self forwardGeocodingDidFail:self.forwardGeocoder withErrorCode:status andErrorMessage:errorMessage];
        }
    }];
#else
    [self.forwardGeocoder forwardGeocodeWithQuery:self.searchBar.text regionBiasing:nil];
#endif
    
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self resultAnimation:NO];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self resultAnimation:YES];
}
#pragma mark - mapview delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
	
	if ([annotation isKindOfClass:[CustomPlacemark class]]) {
		MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
		newAnnotation.pinColor = MKPinAnnotationColorGreen;
		newAnnotation.animatesDrop = YES;
		newAnnotation.canShowCallout = YES;
		newAnnotation.enabled = YES;
		
		
		NSLog(@"Created annotation at: %f %f", ((CustomPlacemark*)annotation).coordinate.latitude, ((CustomPlacemark*)annotation).coordinate.longitude);
		
		[newAnnotation addObserver:self
						forKeyPath:@"selected"
						   options:NSKeyValueObservingOptionNew
						   context:@"GMAP_ANNOTATION_SELECTED"];
		
		[newAnnotation autorelease];
		
		return newAnnotation;
	}
	
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context{
	
	NSString *action = (NSString*)context;
	
    CustomPlacemark *place = nil;
	// We only want to zoom to location when the annotation is actaully selected. This will trigger also for when it's deselected
	if([[change valueForKey:@"new"] intValue] == 1 && [action isEqualToString:@"GMAP_ANNOTATION_SELECTED"])  {
		if ([((MKAnnotationView*) object).annotation isKindOfClass:[CustomPlacemark class]]) {
			place = ((MKAnnotationView*) object).annotation;
			
			// Zoom into the location
			[self.mapView setRegion:place.coordinateRegion animated:TRUE];
			NSLog(@"annotation selected: %f %f", ((MKAnnotationView*) object).annotation.coordinate.latitude, ((MKAnnotationView*) object).annotation.coordinate.longitude);
		}
	}
    
    //select the tableview cell
    if (place) {
        NSIndexPath *ip = [_myTableView indexPathForSelectedRow];
        [_myTableView deselectRowAtIndexPath:ip animated:NO];
        ip = [NSIndexPath indexPathForRow:place.indexCell inSection:0];
        [_myTableView selectRowAtIndexPath:ip animated:NO scrollPosition:0];
        [_myTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        idxSelected = place.indexCell;
/*        NSUInteger *idx = malloc(sizeof(NSUInteger)*2);
        idx[0] = 0;
        idx[1] = place.indexCell;
        NSIndexPath *ip1 = [NSIndexPath indexPathWithIndexes:idx length:2];
        UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:ip1];
        [cell setSelected:YES];
        [_myTableView scrollToRowAtIndexPath:ip1 atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        free(idx);  */      
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
}
#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    //#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return resultArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return 80;
    }
    else{
        return 60;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *string = [resultArray objectAtIndex:[indexPath row]];
    NSArray *str_array = [string componentsSeparatedByString:@"\n"];
    //    [cell.textLabel setText:string];
    [cell.textLabel setText:[str_array objectAtIndex:0]];
    [cell.detailTextLabel setText:[str_array objectAtIndex:1]];
    if (IS_IPAD) {
        cell.textLabel.font=[UIFont boldSystemFontOfSize:30];
    }
    else{
        cell.textLabel.font=[UIFont boldSystemFontOfSize:20];
    }
    
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    //bgColorView.layer.cornerRadius = 10;
    [cell setSelectedBackgroundView:bgColorView];
    [bgColorView release];
    UIView *bgView=[[UIView alloc] init];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundView:bgView];
    [bgView release];
    cell.backgroundColor=[UIColor clearColor];
    //if only one result, select it
    if (1 == resultArray.count) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        idxSelected = 0;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    idxSelected = [indexPath row];
//    NSString *string = [resultArray objectAtIndex:[indexPath row]];
//    NSArray *str_array = [string componentsSeparatedByString:@"\n"];
    //find annotation
    NSArray *annotations = [_mapView annotations];
    for (id annotation in annotations){
        CustomPlacemark *place = annotation;
//        if([place.title isEqualToString:[str_array objectAtIndex:0]])
        if (idxSelected == place.indexCell)
        {
            //zoom to the annotation
            [_mapView setRegion:[annotation coordinateRegion]animated:YES];
            return;
        }
    }
}
#pragma mark - ui function
-(void)resultAnimation:(BOOL)isHidden
{
    if (isHidden == isTableViewHidden) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:RESULT_ANIMATION_DURATION];
    
    //CGRect frame = [_mapView frame];
//    CGRect bounds = [_mapView bounds];
    if (isHidden) {        
      //  frame.size.height += 140;
        [_myTableView setHidden:YES];
        [self setIsTableViewHidden:YES];
    }else {
      //  frame.size.height -= 140;
        [_myTableView setHidden:NO];
        [self setIsTableViewHidden:NO];
    }
   // [_mapView setFrame:frame];
//    [_mapView setBounds:bounds];
    
    [UIView commitAnimations];
}
#pragma mark - data management
-(void)updateHistory
{
    if(resultArray.count > 0 && idxSelected < resultArray.count)
    {
        //retrieve the saved location array, then insert the new location and save the array
        NSArray *arrayHistory = nil;
        NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
        arrayHistory = [dataDefault arrayForKey:@"History"];
        NSLog(@"%@",arrayHistory);
        //check if the result already exists
        for (id record in arrayHistory) {
            NSString *recordString = [record objectForKey:@"LocationString"];
            if ([[resultArray objectAtIndex:idxSelected] isEqual:recordString]) {
                //no change
                return;
            }
        }
        NSMutableArray *arrayNew = [[NSMutableArray alloc]init];
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setValue:[NSString stringWithFormat:@"%@",[resultArray objectAtIndex:idxSelected]] forKey:@"LocationString"];
        [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
        [arrayNew addObject:tempDict];
        for(id object in arrayHistory)
            [arrayNew addObject:object];
        [dataDefault removeObjectForKey:@"History"];
        [dataDefault setObject:arrayNew forKey:@"History"];
        // Update data on the iCloud
        [[NSUbiquitousKeyValueStore defaultStore] setArray:arrayNew forKey:@"HistoryNew"];
//        [arrayHistory release];
        [arrayNew release];
    }
}
-(void)updateAddress
{
    //update route_request
    NSString *string = [resultArray objectAtIndex:idxSelected];
    NSArray *str_array = [string componentsSeparatedByString:@"\n"];
    NSArray *coord = [[str_array objectAtIndex:1] componentsSeparatedByString:@","];
    CLLocationCoordinate2D loc;
    loc.latitude = [[coord objectAtIndex:0] doubleValue];
    loc.longitude = [[coord objectAtIndex:1] doubleValue];
    if (_isFromPOISearch) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"POI_SEARCH_ADDRESS"];
        [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LAT"];
        [userDefaults removeObjectForKey:@"POI_SEARCH_LOCATION_LON"];
        [userDefaults setObject:[NSString stringWithString:[str_array objectAtIndex:0]] forKey:@"POI_SEARCH_ADDRESS"];
        [userDefaults setDouble:loc.latitude forKey:@"POI_SEARCH_LOCATION_LAT"];
        [userDefaults setDouble:loc.longitude forKey:@"POI_SEARCH_LOCATION_LON"];
        [_parentVC updateNewAddress];
    }else {
        if (isDestination) {
            //update end address and end location
            [route_request setEnd_address:[NSString stringWithString:[str_array objectAtIndex:0]]];
            [route_request setEnd_location:loc];
        }else {
            //update start address and start location
            [route_request setStart_address:[NSString stringWithString:[str_array objectAtIndex:0]]];
            [route_request setStart_location:loc];
        }
    }
}
@end