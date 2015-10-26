//
//  TTNewRouteViewController.m
//  TruckRoute
//
//  Created by admin on 9/21/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTDefinition.h"
#import "TTConfig.h"
#import "TTNewRouteViewController.h"
#import "TTFindAddressViewController.h"
#import "TTHistoryViewController.h"
#import "TTVehicleInfoViewController.h"
#import "zip.h"
#import "TTSubscriptionViewController.h"

typedef void(^submitRoute)(NSArray *placemarks, NSError *error);
NSInteger const kCountryCrossOverWarning = 300;

enum ROUTE_TYPE {
    CAR_QUICKEST = 0,
    CAR_SHORTEST = 1,
    CAR_AVOID_FREEWAYS = 2,
    CAR_FREEWAYS = 3,
    TRUCK_FREEWAYS = 4,
    TRUCK_QUICKEST = 5,
    TRUCK_SHORTEST = 6,
};

enum TOLL_TYPE {//conform to server route type protocal
    ALLOW_TOLL = 0,
    MINIMIZE_TOLL = 1,
};

@interface TTNewRouteViewController ()
{
    IBOutlet UIView * routeTypePickerHolderView;
    IBOutlet UIView * routeTypePicketHolder_landscape;
    IBOutlet UIView * tollTypePickerHolderView;
    IBOutlet UIView * tollTypePicketHolder_landscape;
    IBOutlet UIPickerView * routeTypePickerView;
    IBOutlet UIPickerView * routeTypePickerView_landscape;
    IBOutlet UIPickerView * tollTypePickerView;
    IBOutlet UIPickerView * tollTypePickerView_landscape;
    
    
   
    UIView * pickerHolderView;
    UIView * tollTypePickerHolder;
    NSArray * routeTypePickerData;
    NSArray * tollTypePickerData;
    BOOL isPickerViewVisible;
    NSString *userCountry;
    
}
@end

@implementation TTNewRouteViewController
@synthesize responseData;
@synthesize parentVC;
@synthesize labelMode;
@synthesize labelToll;
@synthesize labelMode_landscape,labelToll_landscape;
@synthesize imgCover;
@synthesize isVisible;
-(void) getCurrentOrientation{
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        if (isIpad) {
//            mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960~ipad.png"];
//            [backButton setImage:[UIImage imageNamed:@"Back1~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"CreateRoute1~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"CreateRoute2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
//            mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960-Landscape~ipad"];
//            [backButton setImage:[UIImage imageNamed:@"Back1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"CreateRoute1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            
//            [backButton setImage:[UIImage imageNamed:@"Back2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"CreateRoute2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self getCurrentOrientation];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self getCurrentOrientation];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (!error==0) {
        UIAlertView *errorAlert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"An error as ocurred during the process of retrieving your location. Please Make sure that you have internet and that you have granted the app with authorization to get your location." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [errorAlert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPAD) {
        topView.layer.cornerRadius=15.0;
        topView.clipsToBounds=YES;
        centerLeftView.layer.cornerRadius=15.0;
        centerLeftView.clipsToBounds=YES;
        centerRightView.layer.cornerRadius=15.0;
        centerRightView.clipsToBounds=YES;
        bottomView.layer.cornerRadius=15.0;
        bottomView.clipsToBounds=YES;
        self.carModeVehicleInfoViewPotrait.layer.cornerRadius = 15.0;

    }
    else{
        topView.layer.cornerRadius=7.0f;
        topView.clipsToBounds=YES;
        centerLeftView.layer.cornerRadius=7.0f;
        centerLeftView.clipsToBounds=YES;
        centerRightView.layer.cornerRadius=7.0f;
        centerRightView.clipsToBounds=YES;
        bottomView.layer.cornerRadius=7.0f;
        bottomView.clipsToBounds=YES;

    }
    
    if (_isNotificationOn)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }

    [self getCurrentOrientation];
    //    _utility = [[TTUtilities alloc]init];
    
    //waiting animation
    [self initSpinner];
    /*    imgWaiting.animationImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"direction_start.png"],
     [UIImage imageNamed:@"direction_turnleft.png"],
     [UIImage imageNamed:@"direction_turnright.png"],
     [UIImage imageNamed:@"direction_uturnleft.png"],
     [UIImage imageNamed:@"direction_uturnright.png"],
     [UIImage imageNamed:@"direction_destination.png"], nil];*/
    
    //init location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
        //[locationManager ]
    }
    
    [locationManager startUpdatingLocation];
    
    //check location service here
    CLLocation *currentLocation = [locationManager location];
    if (NO == [CLLocationManager locationServicesEnabled] || nil == currentLocation) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service and also check your internet connection (turn Cellular Data on)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    // Do any additional setup after loading the view.
    [self loadRouteRequest];
    //init labels
    [self updateRouteTypeLabel];
    [self updateTollLabel];
    
    //set mapview vc as parent
    //    UIViewController *current_vc = self.parentViewController.parentViewController;
    //    NSLog(@"Class detail : %@",current_vc.description);
    //    //UIViewController *current_vc = self.presentingViewController;
    //    while (![current_vc isMemberOfClass:[TTMapViewController class]]) {
    //        current_vc = current_vc.presentingViewController;
    //    }
    //    parentVC = (TTMapViewController*)current_vc;


    [self checkRouteTypeSelected];
    [self setupRoutePickerViewData];
     isPickerViewVisible = NO;

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else {
        [(TTNewRouteViewController *)_superViewController  setIsVisible:YES];
        [(TTNewRouteViewController *)_superViewController  viewDidAppear:YES];
        
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self orientationChanged:nil];
//    //init labels
    [self updateRouteTypeLabel];
    [self updateTollLabel];
    [self getCurrentOrientation];
    [self updateStartAddress];
    [self updateEndAddress];
    [self updateVehicleInfo];
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTNewRouteViewController *)_superViewController  setIsVisible:NO];
    }
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //    [responseData release];
    [locationManager setDelegate:nil];
    [labelMode release];
    [labelToll_landscape release];
    [labelMode_landscape release];
    [labelToll release];
    [imgCover release];
    [_labelEndAddress release];
    [_labelEndAddress_landscape release];
    [_labelHeight release];
    [_labelWeight release];
    [_labelLength release];
    [_labelWidth release];
    [_labelHazmat release];
    [_labelHeight_landscape release];
    [_labelWeight_landscape release];
    [_labelLength_landscape release];
    [_labelWidth_landscape release];
    [_labelHazmat_landscape release];
    //    [_utility release];
    [spinner release];
    [pickerHolderView release];
    [tollTypePickerHolder release];
    [userCountry release];
    [super dealloc];
}

- (IBAction)backToMapView:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
     else{
         [self.superViewController.view setAlpha:0];
         [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
         
     }
}

#pragma mark Route creating related methods

- (IBAction)createRoute:(id)sender {
    
    CLGeocoder *ceo = [[CLGeocoder alloc] init];
    
    [ceo reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        userCountry = [[placemarks objectAtIndex:0] country];
        [self createRouteWithRouteInfo:nil];
    }];
    
}

- (void)createRouteWithRouteInfo:(NSDictionary *)routeInfo
{
    CLLocation *currentLocation = [locationManager location];
    //check gps signal
    if (nil == currentLocation) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service and also check your internet connection (turn Cellular Data on)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if ([DEFAULT_ROUTE_REQUEST_ADDRESS_END isEqualToString:_labelEndAddress.text] && routeInfo == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please set destination for create route" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    [self startWaitingAnimation];
    //update start address, speed and bearing
    
    if (_isUserDefinedStartLocation) {
        //do nothing
    }else {
        route_request.start_address = @"Current Location";
        route_request.start_location = currentLocation.coordinate;
    }
    if (currentLocation.speed < 0) {
        route_request.speed = 0;
    }else {
        route_request.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
    }
    if (currentLocation.course < 0) {
        route_request.bearing = -1;
    }else {
        route_request.bearing = currentLocation.course;
    }
    
    if (routeInfo == nil) {
        //end address from the label
        route_request.end_address = [NSString stringWithString:_labelEndAddress.text];

    }
    
    else {
        if ([routeInfo objectForKey:@"lat"] && [routeInfo objectForKey:@"lon"] && [routeInfo objectForKey:@"daddr"]) {
            float latitude = [[routeInfo objectForKey:@"lat"] doubleValue];
            float longitude = [[routeInfo objectForKey:@"lon"] doubleValue];
            [_labelEndAddress setText:[routeInfo objectForKey:@"daddr"]];
            route_request.end_location = CLLocationCoordinate2DMake(latitude, longitude);
        }
        else if ([routeInfo objectForKey:@"daddr"]) {
            NSString *addressFromUrl = [routeInfo objectForKey:@"daddr"];
            [_labelEndAddress setText:addressFromUrl];
            route_request.end_address = [NSString stringWithString:_labelEndAddress.text];
        }
    }
    //    debug //42.426879, -70.984063 to 41.826488, -72.730095
    //    route_request.start_location = CLLocationCoordinate2DMake(42.426879, -70.984063);
    //    route_request.end_location = CLLocationCoordinate2DMake(41.826488, -72.730095);
    
    __block NSString *currentCountry = [userCountry copy];
    
    [self isDestinationInSameCountryWithCompletionBlock:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *destinationPlaceMark = [placemarks objectAtIndex:0];
        if ([destinationPlaceMark.country isEqualToString:currentCountry]) {
            [self saveRouteRequest];
            //set server and submit request
            server_url = SERVER_URL_MAIN;
            [self submitRequest];
        }
        else{
            
            UIAlertView *routingToDifferentCountryAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"You are trying to create a route to %@", destinationPlaceMark.country ] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            [routingToDifferentCountryAlert setTag:kCountryCrossOverWarning];
            [routingToDifferentCountryAlert show];
            [routingToDifferentCountryAlert release];
            [self stopWaitingAnimation];
        }
    }];
}

- (void)createRouteFromUrlInfo:(NSDictionary *)info
{
    if (info == nil) {
        return;
    }
    CLGeocoder *ceo = [[CLGeocoder alloc] init];
    //    [ceo geocodeAddressString:route_request.start_address completionHandler:^(NSArray *placemarks, NSError *error) {
    //
    //    }];
    [ceo reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        userCountry = [[placemarks objectAtIndex:0] country];
        [self createRouteWithRouteInfo:info];
    }];
}

- (IBAction)setEndAddress:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTFindAddressViewController *favc = [storyBoard instantiateViewControllerWithIdentifier:@"FindAddressViewController"];
    [favc setIsDestination:YES];
    [favc setRoute_request:route_request];
    [self presentViewController:favc animated:YES completion:nil];
}

- (IBAction)historyEnd:(id)sender {
    //check if there is history
    NSArray *arrayHistory = nil;
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    arrayHistory = [dataDefault arrayForKey:@"History"];
    if (0 == arrayHistory.count) {
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"no history" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //present history view
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
   // TTHistoryViewController *hvc = [storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    TTHistoryViewController *hvc =nil;
    if (IS_IPAD) {
        hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController_ipad"];
    }
    else{
        hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    }

    [hvc setIsDestination:YES];
    [hvc setIsNotificationOn:YES];
    [hvc setRoute_request:route_request];
    [hvc setMyDelegate:self];
    //[self presentViewController:hvc animated:YES completion:nil];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        [self presentViewController:hvc animated:NO completion:nil];
    else
        [self presentViewController:hvc animated:YES completion:nil];
    
    //[hvc release];

}
-(void)createButtonPressed {
    [self performSelector:@selector(createRoute:) withObject:nil afterDelay:1.0];
}
- (IBAction)info:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTVehicleInfoViewController *vivc=nil;
    if (IS_IPAD) {
        //VehicleInfoViewController_ipad_landscape
        vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController_ipad_landscape"];
    }
    else if (IS_IPHONE_6) {
        vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController6"];
    }
    else if(IS_IPHONE_6P)
    {
        vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController6"];
    }
    else{
        vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController"];
    }
    [vivc setIsNotificationOn:YES];
    [vivc setRoute_request:route_request];
    //[self presentViewController:vivc animated:YES completion:nil];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        [self presentViewController:vivc animated:NO completion:nil];
    else
        [self presentViewController:vivc animated:YES completion:nil];

}

- (IBAction)tapToll:(id)sender {
//    [self toggleToll];
    [self showTollTypeOptions];

}

- (IBAction)swipRouteTypeRight:(id)sender {
    [self nextRouteType];
}

- (IBAction)swipRouteTypeLeft:(id)sender {
    [self preRouteType];
}

- (IBAction)tapRouteType:(id)sender {
   [self showRouteOptions];
    //    [self nextRouteType];
}

- (IBAction)swipeTollRight:(id)sender {
    [self toggleToll];
}

- (IBAction)swipeTollLeft:(id)sender {
    [self toggleToll];
}

- (IBAction)routeSettingInfo:(id)sender {
    NSString *str = nil, *strTitle = nil;
    switch (route_request.route_type) {
        case ROUTE_TYPE_CAR_QUICKEST:
            strTitle = @"Car Quickest";
            str = @"Most economical car route, favors freeways, most commonly used car setting.";
            break;
        case ROUTE_TYPE_CAR_SHORTEST:
            strTitle = @"Car Shortest";
            str = @"Shortest feasible car route, minimizes distance, may result in more turns and slower speed.";
            break;
        case ROUTE_TYPE_CAR_AVOID_FREEWAYS:
            strTitle = @"Car Avoid Freeways";
            str = @"Avoids freeways which could result in a shorter distance but may cause longer travel time. Helpful if attempting to avoid freeway traffic.";
            break;
        case ROUTE_TYPE_CAR_FREEWAYS:
            strTitle = @"Car Freeways";
            str = @"Minimaizes state highways, causing longer routes for shorter distances";
            break;
        case ROUTE_TYPE_TRUCK_FREEWAYS:
            strTitle = @"RV Freeways";
            str = @"Minimizes state highways, causing longer RV routes for shorter distances.";
            break;
        case ROUTE_TYPE_TRUCK_QUICKEST:
            strTitle = @"RV Quickest";
            str = @"Most economical RV route, favors freeways, most commonly used setting.";
            break;
        case ROUTE_TYPE_TRUCK_SHORTEST:
            strTitle = @"RV Shortest";
            str = @"Shortest feasible RV route, minimizes distance, may result in more turns and slower speed.";
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)DimensionInfoClicked:(id)sender
{
    [self showRequiredDimensionInfo];
}


- (void)showRequiredDimensionInfo
{
    if ([self isTruckMode]) {
        
        NSString * strTitle = @"Vehicle Info";
        NSString * str = @"Height, Weight, and Length are for the trailer. These specifications should not include the cab.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

// Return yes if the route type is of truck type.
-(BOOL)isTruckMode
{
    if ((route_request.route_type == ROUTE_TYPE_TRUCK_FREEWAYS) || (route_request.route_type == ROUTE_TYPE_TRUCK_QUICKEST) || (route_request.route_type == ROUTE_TYPE_TRUCK_SHORTEST)) {
     
        return YES;
    }
    return NO;
}


#pragma mark waiting animation
-(void)initSpinner
{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(110, 190, 100, 100);
    spinner.hidesWhenStopped = YES;
    CGAffineTransform transform = CGAffineTransformMakeScale(3, 3);
    [spinner setTransform:transform];
    spinner.color = [UIColor blueColor];
    [self.view addSubview:spinner];
}
-(void)startWaitingAnimation
{
    //lock application
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.view setUserInteractionEnabled:NO];
    
    another_timer = [NSTimer scheduledTimerWithTimeInterval:WAITING_INTERVAL target:self selector:@selector(announceDestination) userInfo:nil repeats:NO];
    [spinner startAnimating];
    [imgCover setHidden:NO];
    
    /*   [imgCover setHidden:NO];
     [imgWaiting setHidden:NO];
     imgWaiting.animationDuration = 1;//total time for one animation
     imgWaiting.animationRepeatCount = 0;
     [imgWaiting startAnimating];*/
}
/*-(void)doWaitingAnimation
 {
 static double radians = 0;
 if (0 == radians) {
 radians = M_PI*2/3;
 }else if (M_PI*2/3 == radians){
 radians = M_PI*4/3;
 }else if (M_PI*4/3 == radians){
 radians = 0;
 }
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:WAITING_ANIMATION_HALF_PERIOD];
 [UIView setAnimationCurve:UIViewAnimationCurveLinear];
 //    [UIView setAnimationRepeatCount:0x1e100f];
 //    [UIView setAnimationBeginsFromCurrentState:NO];
 [imgWaiting setTransform:CGAffineTransformMakeRotation(radians)];
 [UIView commitAnimations];
 }*/
-(void)stopWaitingAnimation
{
    [spinner stopAnimating];
    [imgCover setHidden:YES];
    //unlock application
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self.view setUserInteractionEnabled:YES];
    
    /*    [imgWaiting stopAnimating];
     [imgWaiting setHidden:YES];
     [imgCover setHidden:YES];*/
}

#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"failed: %@", [error localizedDescription]);
    [responseData release];
    
    //try backup server if main server failed
    if ([server_url isEqualToString:SERVER_URL_MAIN]) {
        [self resubmitRequestTo2ndServer];
        return;
    }
    
    [self stopWaitingAnimation];
    
    //notification
    //    NSInteger code = [error code];
    NSString *strErr = nil;
    strErr = [error localizedDescription];
    /*    if (kCFURLErrorCannotConnectToHost == code) {
     //replace msg
     strErr = @"Internet is not accessible.\n Please turn on your WiFi or Cellular Data!";
     }else {
     strErr = [error localizedDescription];
     }*/
    NSString * msgStr=[NSString stringWithFormat:@"%@ Please re-check your internet connection.",[error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"connection failed" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //check
    NSString *string = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]autorelease];
    int routing_code = [string integerValue];
    if (ROUTE_ERROR_SUCCESS == routing_code)
    {
        //succeed, then save result into userdefault
        NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
        [dataDefault removeObjectForKey:@"data"];
        
        //unzip
        if ([route_request.format isEqualToString:@"kmz"])
        {
            
            //            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Get Route Code 0 and format : KMZ" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //            [alertView show];
            //            [alertView release];
            NSData *unzippedData = nil;
            NSRange range;
            range.location = 2;
            range.length = responseData.length - 2;
            unzippedData = [NSData gtm_dataByInflatingData:[responseData subdataWithRange:range]];
            if (unzippedData.length<=0)
            {
                //                if ([server_url isEqualToString:SERVER_URL_MAIN]) {
                //                    [self resubmitRequestTo2ndServer];
                //                    //return;
                //                }
                //                else{
                [self createRoute:nil];
                //}
                //                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Got Response Empty, Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                [alertView show];
                //                [alertView release];
                return;
            }
            [dataDefault setObject:unzippedData forKey:@"data"];
            NSString *str = [[[NSString alloc] initWithData:unzippedData encoding:NSUTF8StringEncoding]autorelease];
            if (str.length < 100000) {
                NSLog(@"%@",str);
            }
            else
            {
                NSLog(@"kml is too big to display");
            }
        }
        else
        {
            //UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Get Route Code 0 and format : XML" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //[alertView show];
            if (string.length<5) {
                [self createRoute:nil];
                return;
            }
            [dataDefault setObject:[[string substringFromIndex:2] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] forKey:@"data"];
            NSLog(@"%@", [string substringFromIndex:2]);
        }
        [dataDefault synchronize];
        //      NSLog(@"Finished receiving route!");
        
        //go to mapview controller
        [parentVC setNeedReload:YES];
        [parentVC setRouteRequest:route_request];
        //switch back to mapview
        //        [self dismissViewControllerAnimated:YES completion:nil];
        UIViewController *vc = self.presentingViewController;
        while (![vc isMemberOfClass:[TTMapViewController class]])
        {
            vc = vc.presentingViewController;
        }
        if(parentVC==nil)
        {
            parentVC=(TTMapViewController *)vc;
            [parentVC setNeedReload:YES];
            [parentVC setRouteRequest:route_request];
        }
        
        //[vc dismissViewControllerAnimated:YES completion:nil];
        if (_isNotificationOn) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [vc dismissViewControllerAnimated:YES completion:nil];
            //[vc dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
        }
    }else {
        UIAlertView *alert = nil;
        NSUserDefaults *userDefaults = nil;
        //error
        NSLog(@"error code: %@", string);
        switch (routing_code) {
            case ROUTE_ERROR_NO_SUBSCRIPTION:
                alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                   message:@"Subscription Verification Required"
                                                  delegate:self
                                         cancelButtonTitle:@"Verify"
                                         otherButtonTitles:@"Cancel", nil];
                [alert setTag:100];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_EXPIRED_SUBSCRIPTION:
                alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                   message:@"Expired subscription!"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:@"Cancel", nil];
                [alert setTag:101];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_ROUTE_FAILED:
                //save route information
                userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults removeObjectForKey:@"route_error_code"];
                [userDefaults setObject:[string substringFromIndex:2]  forKey:@"route_error_code"];
                
                //mantis 2446, alternative notification
                NSString *extra_info = nil;
                NSString *str_tmp = nil;
                switch ([[string substringFromIndex:2] intValue])
            {
                case 24://commercial vehicle
                    str_tmp = @"commercial vehicle";
                    break;
                case 25://hazmat
                    str_tmp = @"hazmat";
                    break;
                case 26://vehicle height
                    str_tmp = @"vehicle height";
                    break;
                case 27://vehicle length
                    str_tmp = @"vehicle length";
                    break;
                case 28://vehicle width
                    str_tmp = @"vehicle width";
                    break;
                case 29://vehicle weight
                    str_tmp = @"vehicle weight";
                    break;
            }
                //notification
                if (str_tmp) {
                    extra_info = [NSString stringWithFormat:@"We cannot create a route as there may be a %@ restriction at your destination. Would you like to email a report of your origin and destination for us to investigate?", str_tmp];
                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                       message:extra_info
                                                      delegate:self
                                             cancelButtonTitle:@"Yes"
                                             otherButtonTitles: @"No", nil];
                }else {
                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                       message:@"This route appears invalid. Please recheck the destination location. Would you like to report this issue?"
                                                      delegate:self
                                             cancelButtonTitle:@"Yes"
                                             otherButtonTitles: @"No", nil];
                }
                [alert setTag:200];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_SERVER_ERROR:
                //try backup server if main server failed
                if ([server_url isEqualToString:SERVER_URL_MAIN]) {
                    [responseData release];
                    [self resubmitRequestTo2ndServer];
                    return;
                }else {
                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                       message:@"1. Try moving a few hundred feet and re-create the route.\n2. Delete the app and re-install, you will not need to pay again."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                break;
                
            case ROUTE_ERROR_MYSQL_ERROR:
                //try backup server if main server failed
                if ([server_url isEqualToString:SERVER_URL_MAIN]) {
                    [responseData release];
                    [self resubmitRequestTo2ndServer];
                    return;
                }else {
                    alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                       message:@"Database has issue!"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                break;
                
            default:
                break;
        }
    }
    
    //release
    [responseData release];
    [self stopWaitingAnimation];
}

#pragma mark ui methods
-(void)updateStartAddress
{
    
}
-(void)updateEndAddress
{
    if (route_request.end_address) {
        NSString *tmpStr = [NSString stringWithString:route_request.end_address];
        //        NSLog(@"test 1: %@", route_request.end_address);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //        NSLog(@"test 1.5: %@", route_request.end_address);
        [userDefaults removeObjectForKey:@"route_request_end_address"];//this messes memory up, i dont know why
        //        NSLog(@"test 2: %@", route_request.end_address);
        [userDefaults setObject:tmpStr forKey:@"route_request_end_address"];
        route_request.end_address = [userDefaults stringForKey:@"route_request_end_address"];
        if(_isNotificationOn){
            [_labelEndAddress setText:route_request.end_address];
            [_labelEndAddress_landscape setText:[route_request.end_address stringByReplacingOccurrencesOfString:@"\n" withString:@", "]];
        }
        else{
            NSString *str=[route_request.end_address stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
            [_labelEndAddress setText:str];
            [_labelEndAddress_landscape setText:str];
        }
        [_labelEndAddress adjustsFontSizeToFitWidthAndHeight];
        [_labelEndAddress_landscape adjustsFontSizeToFitWidthAndHeight];
    }
}
-(void)updateVehicleInfo
{
    NSString *str = nil;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if(isUnitMetric){
        int feet, inches;
        feet = route_request.vehicle_height/100;
        inches = route_request.vehicle_height*12/100 - feet*12 + .5;
        float meter=(feet*12 + inches)/39.3701;
        str = [NSString stringWithFormat:@"Height: %.1f m",meter];
        [_labelHeight setText:str];
        [_labelHeight_landscape setText:str];
        feet = route_request.vehicle_length/100;
        inches = route_request.vehicle_length*12/100 - feet*12 + .5;
        meter=(feet*12 + inches)/39.3701;
        str = [NSString stringWithFormat:@"Length: %.1f m",meter];
        [_labelLength setText:str];
        [_labelLength_landscape setText:str];
        feet = route_request.vehicle_width/100;
        inches = route_request.vehicle_width*12/100 - feet*12 + .5;
        meter=(feet*12 + inches)/39.3701;
        str = [NSString stringWithFormat:@"Width: %.1f m",meter];
        [_labelWidth setText:str];
        [_labelWidth_landscape setText:str];
        int weightInKg=route_request.vehicle_weight*0.453592;
        str = [NSString stringWithFormat:@"Weight: %i kg", weightInKg];
        [_labelWeight setText:str];
        [_labelWeight_landscape setText:str];
        
        str = [NSString stringWithFormat:@"Hazmat: %lu", (unsigned long)route_request.hazmat];
        [_labelHazmat setText:str];
        [_labelHazmat_landscape setText:str];
    }
    else{
    int feet, inches;
        feet = route_request.vehicle_height/100;
        inches = route_request.vehicle_height*12/100 - feet*12 + .5;
        str = [NSString stringWithFormat:@"Height: %d'%d\"", feet, inches];
        [_labelHeight setText:str];
        [_labelHeight_landscape setText:str];
        feet = route_request.vehicle_length/100;
        inches = route_request.vehicle_length*12/100 - feet*12 + .5;
        str = [NSString stringWithFormat:@"Length: %d'%d\"", feet, inches];
        [_labelLength setText:str];
        [_labelLength_landscape setText:str];
        feet = route_request.vehicle_width/100;
        inches = route_request.vehicle_width*12/100 - feet*12 + .5;
        str = [NSString stringWithFormat:@"Width: %d'%d\"", feet, inches];
        [_labelWidth setText:str];
        [_labelWidth_landscape setText:str];
        str = [NSString stringWithFormat:@"Weight: %lu lbs", (unsigned long)route_request.vehicle_weight];
        [_labelWeight setText:str];
        [_labelWeight_landscape setText:str];
        
        str = [NSString stringWithFormat:@"Hazmat: %lu", (unsigned long)route_request.hazmat];
        [_labelHazmat setText:str];
        [_labelHazmat_landscape setText:str];
    }
    [self saveRouteRequest];
}
-(void)updateRouteTypeLabel
{
    switch (route_request.route_type) {
        case ROUTE_TYPE_CAR_QUICKEST:
            [labelMode setText:@"Car Quickest"];
            [labelMode_landscape setText:@"Car Quickest"];
            break;
        case ROUTE_TYPE_CAR_SHORTEST:
            [labelMode setText:@"Car Shortest"];
            [labelMode_landscape setText:@"Car Shortest"];
            break;
        case ROUTE_TYPE_CAR_AVOID_FREEWAYS:
            [labelMode setText:@"Car Avoid Freeways"];
            [labelMode_landscape setText:@"Car Avoid Freeways"];
            break;
        case ROUTE_TYPE_CAR_FREEWAYS:
            [labelMode setText:@"Car Freeways"];
            [labelMode_landscape setText:@"Car Freeways"];
            break;
        case ROUTE_TYPE_TRUCK_FREEWAYS:
            [labelMode setText:@"RV Freeways"];
            [labelMode_landscape setText:@"RV Freeways"];
            break;
        case ROUTE_TYPE_TRUCK_QUICKEST:
            [labelMode setText:@"RV Quickest"];
            [labelMode_landscape setText:@"RV Quickest"];
            break;
        case ROUTE_TYPE_TRUCK_SHORTEST:
            [labelMode setText:@"RV Shortest"];
            [labelMode_landscape setText:@"RV Shortest"];
            break;
    }
}

-(void)updateTollLabel
{
    if (route_request.avoid_toll_road) {
        [labelToll setText:@"Minimize Toll Roads"];
        [labelToll_landscape setText:@"Minimize Toll Roads"];
    }else {
        [labelToll setText:@"Allow Toll Roads"];
        [labelToll_landscape setText:@"Allow Toll Roads"];
    }
}

-(void)toggleToll
{
    if (route_request.avoid_toll_road) {
        //allow toll road
        route_request.avoid_toll_road = NO;
        [labelToll setText:@"Allow Toll Roads"];
        [labelToll_landscape setText:@"Allow Toll Roads"];
    }else {
        //avoid toll road
        route_request.avoid_toll_road = YES;
        
        [labelToll setText:@"Minimize Toll Roads"];
        [labelToll_landscape setText:@"Minimize Toll Roads"];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"Routing is currently set to Minimize Tolls which may result in a significantly longer route. Use of toll roads in some cases may be unavoidable." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    [self saveRouteRequest];
}

-(void)preRouteType
{
    if (route_request.route_type == ROUTE_TYPE_CAR_QUICKEST) {
        route_request.route_type = ROUTE_TYPE_NONE - 1;
    }else if (route_request.route_type == ROUTE_TYPE_TRUCK_SHORTEST){
        route_request.route_type = ROUTE_TYPE_TRUCK_QUICKEST;
    }else if (route_request.route_type == ROUTE_TYPE_TRUCK_FREEWAYS){
        route_request.route_type = ROUTE_TYPE_CAR_FREEWAYS;
    }else {
        route_request.route_type--;
    }
    [self updateRouteTypeLabel];
    [self saveRouteRequest];
    [self checkRouteTypeSelected];
}

-(void)nextRouteType
{
    NSInteger tempTouteType=route_request.route_type;
    if (route_request.route_type == ROUTE_TYPE_NONE - 1) {
        route_request.route_type = ROUTE_TYPE_CAR_QUICKEST;
    }else if (route_request.route_type == ROUTE_TYPE_CAR_FREEWAYS){
        route_request.route_type = ROUTE_TYPE_TRUCK_FREEWAYS;
    }else if (route_request.route_type == ROUTE_TYPE_TRUCK_QUICKEST){
        route_request.route_type = ROUTE_TYPE_TRUCK_SHORTEST;
    }else {
        route_request.route_type++;
    }
    if (tempTouteType>4 && route_request.route_type<=4) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"This product is intended for RV Navigation, are you sure you want to use Car mode?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [self updateRouteTypeLabel];
                [self saveRouteRequest];
            }
            else{
                route_request.route_type=tempTouteType;
            }
        }];
        [alertView release];
    }
    else{

        
        [self updateRouteTypeLabel];
        [self saveRouteRequest];
    }
    
    [self checkRouteTypeSelected];
}

-(void)checkRouteTypeSelected
{
    if ([self isTruckMode]) {
        self.carModeVehicleInfoViewLandscape.hidden = YES;
        self.carModeVehicleInfoViewPotrait.hidden = YES;
        for (UIButton * button in self.vehicleInfoEditButton) {
            button.enabled = YES;
        }
    }
    else {
        self.carModeVehicleInfoViewLandscape.hidden = NO;
        self.carModeVehicleInfoViewPotrait.hidden = NO;
        for (UIButton * button in self.vehicleInfoEditButton) {
            button.enabled = NO;
        }
    }
}

- (void)showCarModeWarningForMode:(NSInteger)routeType
{
    if (![self isTruckMode]) {
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"This product is intended for RV Navigation, are you sure you want to use Car mode?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [self updateRouteTypeLabel];
                [self saveRouteRequest];
            }
        }];
        [alertView release];
    }
}

-(void)enableButton:(UIButton *)sender
{
    sender.enabled = YES;
    
}

-(void)disableButton:(UIButton *)sender
{
    sender.enabled = NO;
}



#pragma mark request operations
-(void)loadRouteRequest
{
    NSString *user_id = nil;
    NSString *start_address = nil;
    NSString *end_address = nil;
    NSString *format = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    user_id = [TTUtilities getSerialNumberString];
    start_address = [userDefaults stringForKey:@"route_request_start_address"];
    end_address = [userDefaults stringForKey:@"route_request_end_address"];
    CLLocationCoordinate2D start, end;
    start.latitude = [userDefaults doubleForKey:@"route_request_start_latitude"];
    start.longitude = [userDefaults doubleForKey:@"route_request_start_longitude"];
    end.latitude = [userDefaults doubleForKey:@"route_request_end_latitude"];
    end.longitude = [userDefaults doubleForKey:@"route_request_end_longitude"];
    NSUInteger route_type = [userDefaults integerForKey:@"route_request_type"];
    BOOL avoid_toll_road = [userDefaults boolForKey:@"route_request_avoid_toll_road"];
    NSUInteger vehicle_height = [userDefaults integerForKey:@"route_request_vehicle_height"];
    NSUInteger vehicle_length = [userDefaults integerForKey:@"route_request_vehicle_length"];
    NSUInteger vehicle_width = [userDefaults integerForKey:@"route_request_vehicle_width"];
    NSUInteger vehicle_weight = [userDefaults integerForKey:@"route_request_vehicle_weight"];
    NSUInteger hazmat = [userDefaults integerForKey:@"route_request_hazmat"];
    NSUInteger speed = [userDefaults integerForKey:@"route_request_speed"];
    NSInteger bearing = [userDefaults integerForKey:@"route_request_bearing"];
    format = [userDefaults stringForKey:@"route_request_format"];
    //    NSLog(@"load from userdefaults, from %@ to %@", start_address, end_address);
    route_request = [[TTRouteRequest alloc] initWithRequestID:1 userID:user_id startAddress:start_address startLocation:start endAddress:end_address endLocation:end routeType:route_type AvoidTollRoad:avoid_toll_road Height:vehicle_height Length:vehicle_length Width:vehicle_width Weight:vehicle_weight Hazmat:hazmat Speed:speed Bearing:bearing Format:format];
    
}
-(void)saveRouteRequest
{
    //cant directly save route_request, so i decide to save the settings one by one
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"route_request_user_id"];
    [userDefaults setObject:route_request.user_id forKey:@"route_request_user_id"];
    [userDefaults removeObjectForKey:@"route_request_start_address"];
    [userDefaults setObject:route_request.start_address forKey:@"route_request_start_address"];
    [userDefaults removeObjectForKey:@"route_request_start_latitude"];
    [userDefaults setDouble:route_request.start_location.latitude forKey:@"route_request_start_latitude"];
    [userDefaults removeObjectForKey:@"route_request_start_longitude"];
    [userDefaults setDouble:route_request.start_location.longitude forKey:@"route_request_start_longitude"];
    [userDefaults removeObjectForKey:@"route_request_end_address"];
    [userDefaults setObject:route_request.end_address forKey:@"route_request_end_address"];
    [userDefaults removeObjectForKey:@"route_request_end_latitude"];
    [userDefaults setDouble:route_request.end_location.latitude forKey:@"route_request_end_latitude"];
    [userDefaults removeObjectForKey:@"route_request_end_longitude"];
    [userDefaults setDouble:route_request.end_location.longitude forKey:@"route_request_end_longitude"];
    [userDefaults removeObjectForKey:@"route_request_type"];
    [userDefaults setInteger:((NSInteger)(route_request.route_type)) forKey:@"route_request_type"];
    [userDefaults removeObjectForKey:@"route_request_avoid_toll_road"];
    [userDefaults setBool:route_request.avoid_toll_road forKey:@"route_request_avoid_toll_road"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_height"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_height)) forKey:@"route_request_vehicle_height"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_length"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_length)) forKey:@"route_request_vehicle_length"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_width"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_width)) forKey:@"route_request_vehicle_width"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_weight"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_weight)) forKey:@"route_request_vehicle_weight"];
    [userDefaults removeObjectForKey:@"route_request_hazmat"];
    [userDefaults setInteger:((NSInteger)(route_request.hazmat)) forKey:@"route_request_hazmat"];
    [userDefaults removeObjectForKey:@"route_request_speed"];
    [userDefaults setInteger:((NSInteger)(route_request.speed)) forKey:@"route_request_speed"];
    [userDefaults removeObjectForKey:@"route_request_bearing"];
    [userDefaults setInteger:route_request.bearing forKey:@"route_request_bearing"];
    [userDefaults removeObjectForKey:@"route_request_format"];
    //route_request.format = @"";
    [userDefaults setObject:route_request.format forKey:@"route_request_format"];
    [userDefaults synchronize];
}
-(void)submitRequest
{
    //send http post here
    //        NSString *url = @"http://smarttruckroute.serveftp.com/truckroutes/request.php";
    //    NSString *url = @"http://50.78.6.246/truckroutes/request.php";
    //    NSString *url = @"http://192.168.1.20/truckroutes/request.php";
    //    NSString *postString = @"userid=android_id&startLatitude=42357722&startLongitude=-71059501&endLatitude=40714554&endLongitude=-74007118&drivingOptions=8&avoidTollRoad=0&vehicleHeight=1350&vehicleLength=5300&vehicleWidth=850&vehicleWeight=8000000&hazmat=0&speed=0&bearing=-1&format=";
    //    NSString *postString = [NSString stringWithFormat:@"userid=%@&startLatitude=%d&startLongitude=%d&endLatitude=%d&endLongitude=%d&drivingOptions=%u&avoidTollRoad=%u&vehicleHeight=%u&vehicleLength=%u&vehicleWidth=%u&vehicleWeight=%u&hazmat=%u&speed=%u&bearing=%d&format=%@&requesttype=n&client=%@&os=i%i", route_request.user_id, (NSInteger)(route_request.start_location.latitude * 1000000), (NSInteger)(route_request.start_location.longitude * 1000000), (NSInteger)(route_request.end_location.latitude * 1000000), (NSInteger)(route_request.end_location.longitude * 1000000), route_request.route_type, route_request.avoid_toll_road?1:0, (NSInteger)(route_request.vehicle_height), (NSInteger)(route_request.vehicle_length), (NSInteger)(route_request.vehicle_width), route_request.vehicle_weight*100, route_request.hazmat, route_request.speed, route_request.bearing, route_request.format,[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"], [[[UIDevice currentDevice] systemVersion] intValue]];
    
    
    NSString *postString = [NSString stringWithFormat:@"userid=%@&startLatitude=%d&startLongitude=%d&endLatitude=%d&endLongitude=%d&drivingOptions=%u&avoidTollRoad=%u&vehicleHeight=%u&vehicleLength=%u&vehicleWidth=%u&vehicleWeight=%u&hazmat=%u&speed=%u&bearing=%d&requesttype=n&client=%@&os=i%i", route_request.user_id, (NSInteger)(route_request.start_location.latitude * 1000000), (NSInteger)(route_request.start_location.longitude * 1000000), (NSInteger)(route_request.end_location.latitude * 1000000), (NSInteger)(route_request.end_location.longitude * 1000000), route_request.route_type, route_request.avoid_toll_road?1:0, (NSInteger)(route_request.vehicle_height), (NSInteger)(route_request.vehicle_length), (NSInteger)(route_request.vehicle_width), route_request.vehicle_weight*100, route_request.hazmat, route_request.speed, route_request.bearing,[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"], [[[UIDevice currentDevice] systemVersion] intValue]];
    
    NSLog(@"%@", server_url);
    NSLog(@"%@", postString);
    NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postVariables length]];
    NSURL *postURL = [NSURL URLWithString:server_url];
    [request setURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postVariables];
    
    //get
    NSURLConnection *connectionResponse = [[[NSURLConnection alloc] initWithRequest:request delegate:self]autorelease];
    if(connectionResponse)
    {
        NSLog(@"Request submitted");
        responseData = [[NSMutableData alloc]init];
    }else {
        NSLog(@"Failed to submit request");
        
        [self stopWaitingAnimation];
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
-(void)resubmitRequestTo2ndServer
{
    //update start address, speed and bearing
    CLLocation *currentLocation = [locationManager location];
    route_request.start_address = @"Current Location";
    route_request.start_location = currentLocation.coordinate;
    if (currentLocation.speed < 0) {
        route_request.speed = 0;
    }else {
        route_request.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
    }
    if (currentLocation.course < 0) {
        route_request.bearing = -1;
    }else {
        route_request.bearing = currentLocation.course;
    }
    server_url = SERVER_URL_BACKUP;
    [self submitRequest];
}

-(void)announceDestination
{
    [another_timer invalidate];
    //announce destination
    
    NSString *str = [NSString stringWithFormat:@"Creating RV route to %@",_labelEndAddress.text];// route_request.end_address];
    if (route_request.route_type<=4) {
        str = [NSString stringWithFormat:@"Creating Car route to %@",_labelEndAddress.text];
    }
    NSRange range = [str rangeOfString:@","];
    if (NSNotFound != range.location) {
        str = [str substringToIndex:range.location];
    }
    
    if(parentVC==nil)
    {
        UIViewController *vc = self.presentingViewController;
        while (![vc isMemberOfClass:[TTMapViewController class]])
        {
            vc = vc.presentingViewController;
        }
        parentVC=(TTMapViewController *)vc;
        [parentVC read:str];
    }
    else{
        [parentVC read:str];
    }
    
}
- (void)viewDidUnload {
    [self setLabelMode:nil];
    [self setLabelToll:nil];
    [self setLabelMode_landscape:nil];
    [self setLabelToll_landscape:nil];
    //    [self setImgWaiting:nil];
    [self setImgCover:nil];
    [self setLabelEndAddress:nil];
    [self setLabelEndAddress_landscape:nil];
    [self setLabelHeight:nil];
    [self setLabelWeight:nil];
    [self setLabelLength:nil];
    [self setLabelWidth:nil];
    [self setLabelHazmat_landscape:nil];
    [self setLabelHeight_landscape:nil];
    [self setLabelWeight_landscape:nil];
    [self setLabelLength_landscape:nil];
    [self setLabelWidth_landscape:nil];
    [self setLabelHazmat_landscape:nil];
    [super viewDidUnload];
}

#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((100 == alertView.tag || 101 == alertView.tag) && 0 == buttonIndex) {
        //switch to subscription view
        //manage subscription
        if (isShowingLandscapeView) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            TTSubscriptionViewController *svc = nil;[storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
            if (IS_IPAD) {
                //SubscriptionViewController_ipad_landscape
                svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController_ipad_landscape"];
            }
            else{
                svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
            }
            //        [svc setParentVC:self];
            [svc setIsNotificationOn:YES];
           // [self.presentedViewController presentViewController:svc animated:YES completion:nil];
            UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
            if (UIDeviceOrientationIsLandscape(deviceOrientation))
                [self presentViewController:svc animated:NO completion:nil];
            else
                [self presentViewController:svc animated:YES completion:nil];

        }else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            TTSubscriptionViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
            //        [svc setParentVC:self];
            [svc setIsNotificationOn:YES];
            //[self presentViewController:svc animated:YES completion:nil];
            UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
            if (UIDeviceOrientationIsLandscape(deviceOrientation))
                [self presentViewController:svc animated:NO completion:nil];
            else
                [self presentViewController:svc animated:YES completion:nil];

        }
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTSubscriptionViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
//        //        [svc setParentVC:self];
//        [svc setIsNotificationOn:YES];
//        [self presentViewController:svc animated:YES completion:nil];
    }
    else if (200 == alertView.tag && 0 == buttonIndex) {
        //report failed route button is clicked
        if ([MFMailComposeViewController canSendMail]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *error_code = [userDefaults objectForKey:@"route_error_code"];
            NSString *subject = [NSString stringWithFormat:@"Route Error #%@", error_code];
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:subject];
            NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
            [mailer setToRecipients:toRecipients];
            //            NSString *postString = [NSString stringWithFormat:@"userid=%@&startLatitude=%d&startLongitude=%d&endLatitude=%d&endLongitude=%d&drivingOptions=%u&avoidTollRoad=%u&vehicleHeight=%u&vehicleLength=%u&vehicleWidth=%u&vehicleWeight=%u&hazmat=%u&speed=%u&bearing=%d&format=%@&requesttype=n&client=1.0&os=i6", route_request.user_id, (NSInteger)(route_request.start_location.latitude * 1000000), (NSInteger)(route_request.start_location.longitude * 1000000), (NSInteger)(route_request.end_location.latitude * 1000000), (NSInteger)(route_request.end_location.longitude * 1000000), route_request.route_type, route_request.avoid_toll_road?1:0, route_request.vehicle_height, route_request.vehicle_length, route_request.vehicle_width, route_request.vehicle_weight, route_request.hazmat, route_request.speed, route_request.bearing, route_request.format];
            
            NSString *body = [NSString stringWithFormat:@"Please enter any additional information below:\n\n\nVersion: %@\nUSER ID: %@\nA: %d, %d\nB: %d, %d\nType: %u\nH: %u, L: %u, W: %u\nWt: %u\n", [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"], route_request.user_id, (NSInteger)(route_request.start_location.latitude * 1000000), (NSInteger)(route_request.start_location.longitude * 1000000), (NSInteger)(route_request.end_location.latitude * 1000000), (NSInteger)(route_request.end_location.longitude * 1000000), route_request.route_type, (NSInteger)(route_request.vehicle_height), (NSInteger)(route_request.vehicle_length), (NSInteger)(route_request.vehicle_width), route_request.vehicle_weight];
            [mailer setMessageBody:body isHTML:NO];
            [self presentViewController:mailer animated:YES completion:nil];
            [mailer release];
        }
    }

    else if (alertView.tag == kCountryCrossOverWarning){
        
        if (buttonIndex == 1) {
            [self startWaitingAnimation];
            [self saveRouteRequest];
            //set server and submit request
            server_url = SERVER_URL_MAIN;
            [self submitRequest];
        }
    }

}

#pragma mark mailcomposecontroller delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
    {
        iPhoneLandscapeMainView.hidden=NO;
        iPhonePortraitMainView.hidden=YES;
        pickerHolderView = routeTypePicketHolder_landscape;
        tollTypePickerHolder = tollTypePicketHolder_landscape;
    }
    else{
        iPhoneLandscapeMainView.hidden=YES;
        iPhonePortraitMainView.hidden=YES;
        pickerHolderView = routeTypePickerHolderView;
        tollTypePickerHolder = tollTypePickerHolderView;
        
    }

//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
//        iPhoneLandscapeMainView.hidden=NO;
//        iPhonePortraitMainView.hidden=YES;
//    }
//    else{
//        iPhoneLandscapeMainView.hidden=YES;
//        iPhonePortraitMainView.hidden=YES;
//
//    }
    [_labelEndAddress adjustsFontSizeToFitWidthAndHeight];
    [_labelEndAddress_landscape adjustsFontSizeToFitWidthAndHeight];

//    if (!self.isVisible)
//    {
//        return;
//    }
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
//    {
//        //TTGasStationInfoViewController tempView=self;
//        //[self dismissViewControllerAnimated:YES completion:nil];
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        //UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTNewRouteViewController *nrvc = nil;
//        if (IS_IPAD) {
//            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad_landscape"];
//        }
//        else{
//            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_landscape"];
//        }
//        [nrvc setParentVC:self.parentVC];
//        [nrvc setIsNotificationOn:NO];
//        nrvc.delegate=self;
//        nrvc.superViewController=self;
//        [self presentViewController:nrvc animated:NO completion:^{self.isVisible=YES;}];
//        isShowingLandscapeView = YES;
//    }
//    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        isShowingLandscapeView = NO;
//    }
}

-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark UIPickerView methods

-(void)setupRoutePickerViewData
{
    routeTypePickerData = [[NSArray alloc] initWithObjects:@"Car Quickest", @"Car shortest", @"Car Avoid Freeways", @"Car Freeways", @"RV Freeways", @"RV Quickest", @"RV Shortest", nil];
    [routeTypePickerView selectRow:[self setSelectedRouteType] inComponent:0 animated:NO];
    [routeTypePickerView_landscape selectRow:[self setSelectedRouteType] inComponent:0 animated:NO];
    tollTypePickerData = [[NSArray alloc] initWithObjects:@"Allow Toll Roads",@"Minimize Toll Roads", nil];
    [tollTypePickerView selectRow:[self setSelectedTollType] inComponent:0 animated:NO];
    [tollTypePickerView_landscape selectRow:[self setSelectedTollType] inComponent:0 animated:NO];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == routeTypePickerView || pickerView == routeTypePickerView_landscape) {
        return routeTypePickerData.count;
    }
    else{
        return tollTypePickerData.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == routeTypePickerView || pickerView == routeTypePickerView_landscape) {
        return routeTypePickerData[row];
    }
    else{
        return tollTypePickerData[row];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == routeTypePickerView || pickerView == routeTypePickerView_landscape) {
        [self setRouteTypeFromPickedOption:row];
    }
    else{
        
        [self setTollTypeFromPickedOption:row];
    }

}

//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UILabel * pickerLabel = (UILabel *)view;
//    
//    if (pickerLabel == nil) {
//        pickerLabel = [[UILabel alloc] init];
//        [pickerLabel setFont:[UIFont fontWithName:@"Helvetica" size:25]];
//        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
//    }
//    pickerLabel.text = pickerData[row];
//    return pickerLabel;
//}

-(void)showRouteOptions
{
    if (!isPickerViewVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
        CGRect rect=pickerHolderView.frame;
        if (self.view.frame.size.height <= rect.origin.y) {
            rect.origin.y -= rect.size.height;
            pickerHolderView.frame=rect;
            [UIView commitAnimations];
            isPickerViewVisible = YES;
        }
    }
}

- (void)showTollTypeOptions
{
    if (!isPickerViewVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
        CGRect rect=tollTypePickerHolder.frame;
        if (self.view.frame.size.height <= rect.origin.y) {
            rect.origin.y -= rect.size.height;
            tollTypePickerHolder.frame=rect;
            [UIView commitAnimations];
            isPickerViewVisible = YES;
        }
    }
}

-(IBAction)pickerDoneButtonClick:(id)sender
{
    [self updateRouteTypeLabel];
    [self saveRouteRequest];
    [self dismissRouteTypePickerView];
    isPickerViewVisible = NO;
    [self checkRouteTypeSelected];
}

- (IBAction)tollTypePickerDoneButtonClicked:(id)sender
{
    [self updateTollLabel];
    [self saveRouteRequest];
    isPickerViewVisible = NO;
    [self dismissTollTypePickerView];
}

- (void)dismissRouteTypePickerView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y += rect.size.height;
    pickerHolderView.frame = rect;
    [UIView commitAnimations];
}

- (void)dismissTollTypePickerView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=tollTypePickerHolder.frame;
    rect.origin.y += rect.size.height;
    tollTypePickerHolder.frame = rect;
    [UIView commitAnimations];
    
}

- (NSInteger)setSelectedRouteType
{
    switch (route_request.route_type) {
        case ROUTE_TYPE_CAR_SHORTEST:
            return CAR_SHORTEST;
            break;
        case ROUTE_TYPE_CAR_AVOID_FREEWAYS:
            return CAR_AVOID_FREEWAYS;
            break;
        case ROUTE_TYPE_CAR_FREEWAYS:
            return CAR_FREEWAYS;
            break;
        case ROUTE_TYPE_CAR_QUICKEST:
            return CAR_QUICKEST;
            break;
        case ROUTE_TYPE_TRUCK_FREEWAYS:
            return TRUCK_FREEWAYS;
            break;
        case ROUTE_TYPE_TRUCK_QUICKEST:
            return TRUCK_QUICKEST;
            break;
        case ROUTE_TYPE_TRUCK_SHORTEST:
            return TRUCK_SHORTEST;
            break;
        default:
            break;
    }
    return 0;
}

- (void)setRouteTypeFromPickedOption:(NSInteger)row
{
    switch (row) {
        case CAR_QUICKEST:
            route_request.route_type = ROUTE_TYPE_CAR_QUICKEST;
            break;
        case CAR_FREEWAYS:
            route_request.route_type = ROUTE_TYPE_CAR_FREEWAYS;
            break;
        case CAR_SHORTEST:
            route_request.route_type = ROUTE_TYPE_CAR_SHORTEST;
            break;
        case CAR_AVOID_FREEWAYS:
            route_request.route_type = ROUTE_TYPE_CAR_AVOID_FREEWAYS;
            break;
        case TRUCK_SHORTEST:
            route_request.route_type = ROUTE_TYPE_TRUCK_SHORTEST;
            break;
        case TRUCK_QUICKEST:
            route_request.route_type = ROUTE_TYPE_TRUCK_QUICKEST;
            break;
            
        case TRUCK_FREEWAYS:
            route_request.route_type = ROUTE_TYPE_TRUCK_FREEWAYS;
            break;
            
        default:
            break;
    }
}

- (void)setTollTypeFromPickedOption:(NSInteger)row
{
    switch (row) {
        case ALLOW_TOLL:
            route_request.avoid_toll_road = NO;
            break;
            case MINIMIZE_TOLL:
            route_request.avoid_toll_road = YES;
        default:
            break;
    }
}

- (NSInteger)setSelectedTollType
{
    if (route_request.avoid_toll_road) {
        return 1;
    }
    else return 0;
}

- (void)isDestinationInSameCountryWithCompletionBlock:(submitRoute)block
{
    
    CLGeocoder *ceo = [[CLGeocoder alloc] init];
    [ceo geocodeAddressString:route_request.end_address completionHandler:^(NSArray *placemarks, NSError *error) {
        block(placemarks, error);
    }];
}

@end
