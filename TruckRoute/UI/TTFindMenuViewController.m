//
//  TTFindMenuViewController.m
//  TruckRoute
//
//  Created by admin on 4/1/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTFindMenuViewController.h"
#import "TTConfig.h"
#import "TTPOI.h"
#import "TTPOIManager.h"
#import "TTSearchResultViewController.h"
#import "TTFindAddressViewController.h"
#import "TTHistoryViewController.h"

@interface TTFindMenuViewController ()

@end

@implementation TTFindMenuViewController

@synthesize parentVC;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTFindMenuViewController *)_superViewController  setIsVisible:NO];
    }
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    self.isVisible = YES;
    if (_isNotificationOn){
        [self orientationChanged:nil];
    }
    else{
        [(TTFindMenuViewController *)_superViewController  setIsVisible:YES];
        [(TTFindMenuViewController *)_superViewController viewDidAppear:YES];
    }
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    
//}
- (void)viewDidLoad
{
    //[super viewDidLoad];
    isShowingLandscapeView = NO;
    [super viewDidLoad];
    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    
    if (IS_IPAD) {nameView.layer.cornerRadius=15;}else{nameView.layer.cornerRadius=11; nameView_landscape.layer.cornerRadius=11;}
    nameView.layer.borderWidth=0.7;
    nameView_landscape.layer.borderWidth=0.7;
    nameView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    nameView_landscape.layer.borderColor=[UIColor lightGrayColor].CGColor;

    if (IS_IPAD) {typeView.layer.cornerRadius=15;}else{typeView.layer.cornerRadius=11; typeView_landscape.layer.cornerRadius=11;}
    typeView.layer.borderWidth=0.7;
    typeView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    typeView_landscape.layer.borderWidth=0.7;
    typeView_landscape.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
	// Do any additional setup after loading the view.
    //init location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
    [self initSpinner];
    
    //data
    isNearCurrentLocation = YES;
    idxType = 0;
    idxName = 0;
    _poi_condition = [[TTPOI alloc]init];
    _poi_condition.type = truck_stop;
    //ui
    [_imageview setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
    [_labelName setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
    [_labelType setText:[_poiManager.searchable_poi_types objectAtIndex:idxType]];
    [_imageview_landscape setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
    [_labelName_landscape setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
    [_labelType_landscape setText:[_poiManager.searchable_poi_types objectAtIndex:idxType]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [_labelNewAddress setText:[userDefaults objectForKey:@"POI_SEARCH_ADDRESS"]];
    [_labelNewAddress_landscape setText:[userDefaults objectForKey:@"POI_SEARCH_ADDRESS"]];
}

-(void)dealloc
{
    [locationManager setDelegate:nil];
    [locationManager release];
    [_imageview release];
    [_labelType release];
    [_labelName release];
    [_buttonCurrentLocation release];
    [_buttonNewLocation release];
    [_labelNewAddress release];
    [_buttonWifi release];
    [_buttonIdle release];
    [_buttonScale release];
    [_buttonWash release];
    [_buttonService release];
    [_buttonShower release];
    
    [_imageview_landscape release];
    [_labelType_landscape release];
    [_labelName_landscape release];
    [_buttonCurrentLocation_landscape release];
    [_buttonNewLocation_landscape release];
    [_labelNewAddress_landscape release];
    [_buttonWifi_landscape release];
    [_buttonIdle_landscape release];
    [_buttonScale_landscape release];
    [_buttonWash_landscape release];
    [_buttonService_landscape release];
    [_buttonShower_landscape release];
    
    [_poi_condition release];
    [_labelTruckStopSettings release];
    
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
    }
}

- (IBAction)search:(id)sender {
    CLLocationCoordinate2D coord;
    if (isNearCurrentLocation) {
        coord = [locationManager location].coordinate;
    }else {
        coord = _poi_condition.coord;
    }
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(2, 2));
    NSLog(@"region: lat: %f, lon: %f, delta lat: %f, delta lon: %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
//    NSArray *result_array = [_poiManager searchPOIinRegion:region];
    
    NSArray *result_array = [_poiManager searchPOIinRegion2:region withCondition:_poi_condition];
    if (result_array.count) {
        //display
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTSearchResultViewController *srvc = nil;
        if (IS_IPAD) {
            srvc=[storyBoard instantiateViewControllerWithIdentifier:@"SearchResultViewController_ipad"];
        }
        else{
            srvc=[storyBoard instantiateViewControllerWithIdentifier:@"SearchResultViewController"];
        }
        
        [srvc setIsNotificationOn:YES];
        [srvc setResults:result_array];
        //[self presentViewController:srvc animated:YES completion:nil];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation))
        {
            [self presentViewController:srvc animated:NO completion:nil];
        }
        else{
            [self presentViewController:srvc animated:YES completion:nil];
        }

    }else {
        //notify nothing found
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"Not Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
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
-(void)startWaiting
{
    //lock app
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [spinner startAnimating];
}
-(void)stopWaiting
{
    [spinner stopAnimating];
    //unlock application
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (IBAction)tapCurrentLocation:(id)sender {
    if (!isNearCurrentLocation) {
        [_buttonCurrentLocation setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonCurrentLocation_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        isNearCurrentLocation = YES;
        [_buttonNewLocation setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonNewLocation_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }
}
/*- (IBAction)tapNewLocation:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTFindAddressViewController *favc = [storyBoard instantiateViewControllerWithIdentifier:@"FindAddressViewController"];
    [favc setIsFromPOISearch:YES];
    [favc setParentVC:self];
    [self presentViewController:favc animated:YES completion:nil];
}*/
- (IBAction)toggleWifi:(id)sender {
    
    if (_poi_condition.hasWifi) {
        _poi_condition.hasWifi = NO;
        [_buttonWifi setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonWifi_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.hasWifi = YES;
        [_buttonWifi setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonWifi_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
    
}
- (IBAction)toggleIdle:(id)sender {
    
    if (_poi_condition.hasIdle) {
        _poi_condition.hasIdle = NO;
        [_buttonIdle setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonIdle_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.hasIdle = YES;
        [_buttonIdle setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonIdle_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)toggleScale:(id)sender {
    if (_poi_condition.hasScale) {
        _poi_condition.hasScale = NO;
        [_buttonScale setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonScale_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.hasScale = YES;
        [_buttonScale setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonScale_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)toggleWash:(id)sender {
    if (_poi_condition.hasWash) {
        _poi_condition.hasWash = NO;
        [_buttonWash setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonWash_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.hasWash = YES;
        [_buttonWash setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonWash_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)toggleService:(id)sender {
    if (_poi_condition.hasService) {
        _poi_condition.hasService = NO;
        [_buttonService setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonService_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.hasService = YES;
        [_buttonService setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonService_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)toggleShower:(id)sender {
    if (_poi_condition.showers > 0) {
        _poi_condition.showers = 0;
        [_buttonShower setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
        [_buttonShower_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    }else {
        _poi_condition.showers = 1;
        [_buttonShower setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
        [_buttonShower_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)swipeTypeToRight:(id)sender {
    //-
    idxType--;
    if (idxType < 0) {
        idxType = _poiManager.searchable_poi_types.count - 1;
    }else if (idxType == 4)
    {
        //no gas station search for now
        idxType--;
    }
    [self updateType];
}
- (IBAction)swipeTypeToLeft:(id)sender {
    //+
    idxType++;
    if (idxType >= _poiManager.searchable_poi_types.count) {
        idxType = 0;
    }else if (idxType == 4)
    {
        //no gas station search for now
        idxType++;
    }
    [self updateType];
}
- (IBAction)swipeNameToRight:(id)sender {
    //-    
    switch (_poi_condition.type) {
        case truck_stop:
            idxName--;
            if (idxName < 0) {
                idxName = _poiManager.truckstop_names.count - 1;
            }
            [self updateTruckStopName];
            break;
            
        default:
            break;
    }
}

- (IBAction)swipeNameToLeft:(id)sender {
    //+
    switch (_poi_condition.type) {
        case truck_stop:
            idxName++;
            if (idxName >= _poiManager.truckstop_names.count) {
                idxName = 0;
            }
            [self updateTruckStopName];
            break;
            
        default:
            break;
    }
}
- (IBAction)tapNewAddress:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTFindAddressViewController *favc = [storyBoard instantiateViewControllerWithIdentifier:@"FindAddressViewController"];
    [favc setIsFromPOISearch:YES];
    [favc setParentVC:self];
    [self presentViewController:favc animated:YES completion:nil];
}
- (IBAction)historyLocation:(id)sender {
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
    TTHistoryViewController *hvc =nil;
    if (IS_IPAD) {
        hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController_ipad"];
    }
    else{
        hvc=[storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    }
    [hvc setIsNotificationOn:YES];
    [hvc setIsDestination:NO];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:hvc animated:NO completion:nil];
    }
    else{
        [self presentViewController:hvc animated:YES completion:nil];
    }
}

- (IBAction)tapButtonNewLocation:(id)sender {
    if (nil == _labelNewAddress.text) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTFindAddressViewController *favc = [storyBoard instantiateViewControllerWithIdentifier:@"FindAddressViewController"];
        [favc setIsFromPOISearch:YES];
        [favc setParentVC:self];
        [self presentViewController:favc animated:YES completion:nil];
    }else {
        [self updateNewAddress];
    }
}

-(void)updateType
{
//@"Truck Stop", @"Weigh Station", @"Truck Dealer", @"Truck Parking"
    [_labelType setText:[_poiManager.searchable_poi_types objectAtIndex:idxType]];
    [_labelType_landscape setText:[_poiManager.searchable_poi_types objectAtIndex:idxType]];
    idxName = 0;
    _poi_condition.name = nil;
    switch (idxType) {
        case 0://truck stop
            [_labelName setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
            [_labelName_landscape setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
            [_imageview setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
            _poi_condition.type = truck_stop;
            break;
           
        case 1://weigh station
            [_labelName setText:@"Find Any"];
            [_imageview setImage:[UIImage imageNamed:@"Weigh-Station.png"]];
            [_labelName_landscape setText:@"Find Any"];
            [_imageview_landscape setImage:[UIImage imageNamed:@"Weigh-Station.png"]];
            _poi_condition.type = weighstation;
            break;
            
        case 2://truck dealer
            [_labelName setText:@"Find Any"];
            [_imageview setImage:[UIImage imageNamed:@"BlueFlag.png"]];
            [_labelName_landscape setText:@"Find Any"];
            [_imageview_landscape setImage:[UIImage imageNamed:@"BlueFlag.png"]];
            _poi_condition.type = truck_dealer;
            break;
            
        case 3://truck parking
            [_labelName setText:@"Find Any"];
            [_imageview setImage:[UIImage imageNamed:@"L2005__Parking.png"]];
            [_labelName_landscape setText:@"Find Any"];
            [_imageview_landscape setImage:[UIImage imageNamed:@"L2005__Parking.png"]];
            _poi_condition.type = truck_parking;
            break;
            
        case 5://CAT_scale
            [_labelName setText:@"Find Any"];
            [_imageview setImage:[UIImage imageNamed:@"poi_campground_off"]];
            [_labelName_landscape setText:@"Find Any"];
            [_imageview_landscape setImage:[UIImage imageNamed:@"poi_campground_off"]];
            _poi_condition.type = campgrounds;
            break;
            
        case 6://rest area
            [_labelName setText:@"Find Any"];
            [_imageview setImage:[UIImage imageNamed:@"Rest Area.png"]];
            [_labelName_landscape setText:@"Find Any"];
            [_imageview_landscape setImage:[UIImage imageNamed:@"Rest Area.png"]];
            _poi_condition.type = rest_area;
            break;
            
        default:
            break;
    }    
    [self updateTruckStopSettings];
    if (0 == idxType){
        [_labelName setTextColor:[UIColor blackColor]];
        [_labelName_landscape setTextColor:[UIColor blackColor]];
    }else {
        [_labelName setTextColor:[UIColor grayColor]];
        [_labelName_landscape setTextColor:[UIColor grayColor]];
    }
}
-(void)updateTruckStopSettings
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    if (truck_stop == _poi_condition.type) {
        //show
        [_buttonIdle setAlpha:1];
        [_buttonScale setAlpha:1];
        [_buttonService setAlpha:1];
        [_buttonShower setAlpha:1];
        [_buttonWash setAlpha:1];
        [_buttonWifi setAlpha:1];
        [_buttonIdle_landscape setAlpha:1];
        [_buttonScale_landscape setAlpha:1];
        [_buttonService_landscape setAlpha:1];
        [_buttonShower_landscape setAlpha:1];
        [_buttonWash_landscape setAlpha:1];
        [_buttonWifi_landscape setAlpha:1];
        for (UILabel *label in _labelTruckStopSettings) {
            [label setAlpha:1];
        }
        for (UILabel *label in _labelTruckStopSettings_landscape) {
            [label setAlpha:1];
        }
    }else {
        //hide
        [_buttonIdle setAlpha:0];
        [_buttonScale setAlpha:0];
        [_buttonService setAlpha:0];
        [_buttonShower setAlpha:0];
        [_buttonWash setAlpha:0];
        [_buttonWifi setAlpha:0];
        
        [_buttonIdle_landscape setAlpha:0];
        [_buttonScale_landscape setAlpha:0];
        [_buttonService_landscape setAlpha:0];
        [_buttonShower_landscape setAlpha:0];
        [_buttonWash_landscape setAlpha:0];
        [_buttonWifi_landscape setAlpha:0];
        for (UILabel *label in _labelTruckStopSettings) {
            [label setAlpha:0];
        }
        for (UILabel *label in _labelTruckStopSettings_landscape) {
            [label setAlpha:0];
        }
    }
    
    [UIView commitAnimations];
}
-(void)updateTruckStopName
{
//@"Find Any", @"Flying J", @"Love's Travel Stops & Country Stores", @"PETRO Stopping Centers", @"Pilot Travel Centers", @"TravelCenters of America"
    [_labelName setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
    [_labelName_landscape setText:[_poiManager.truckstop_names objectAtIndex:idxName]];
    switch (idxName) {
        case 0://find any
            [_imageview setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"L2002__Truckstop.png"]];
            _poi_condition.name = nil;
            break;
            
        case 1://Flying J
            [_imageview setImage:[UIImage imageNamed:@"LFlyingJ.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"LFlyingJ.png"]];
            _poi_condition.name = @"Flying J";
            break;
            
        case 2://Love's Travel Stops & Country Stores
            [_imageview setImage:[UIImage imageNamed:@"Lloves.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"Lloves.png"]];
//            _poi_condition.name = @"Love's Travel Stops";
            _poi_condition.name = @"Love";
            break;
            
        case 3://PETRO Stopping Centers
            [_imageview setImage:[UIImage imageNamed:@"Lpetro.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"Lpetro.png"]];
            _poi_condition.name = @"PETRO Stopping Centers";
            break;
            
        case 4://Pilot Travel Centers
            [_imageview setImage:[UIImage imageNamed:@"LPilot.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"LPilot.png"]];
//            _poi_condition.name = @"Pilot Travel Centers";
            _poi_condition.name = @"Pilot";
            break;
            
        case 5://TravelCenters of America
            [_imageview setImage:[UIImage imageNamed:@"LTA.png"]];
            [_imageview_landscape setImage:[UIImage imageNamed:@"LTA.png"]];
            _poi_condition.name = @"TravelCenters of America";
            break;
            
        default:
            break;
    }
}
-(void)updateNewAddress
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CLLocationCoordinate2D loc;
    loc.latitude = [userDefaults doubleForKey:@"POI_SEARCH_LOCATION_LAT"];
    loc.longitude = [userDefaults doubleForKey:@"POI_SEARCH_LOCATION_LON"];
    _poi_condition.coord = loc;
    isNearCurrentLocation = NO;
    [_labelNewAddress setText:[userDefaults objectForKey:@"POI_SEARCH_ADDRESS"]];
    [_buttonCurrentLocation setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    [_buttonNewLocation setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
    
    [_labelNewAddress_landscape setText:[userDefaults objectForKey:@"POI_SEARCH_ADDRESS"]];
    [_buttonCurrentLocation_landscape setImage:[UIImage imageNamed:@"m_radio_off.png"] forState:UIControlStateNormal];
    [_buttonNewLocation_landscape setImage:[UIImage imageNamed:@"m_radio_on.png"] forState:UIControlStateNormal];
}
- (void)orientationChanged:(NSNotification *)notification
{
    if (isIpad) {
        if (self.isVisible)
        {
            UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
            if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
            {
                //TTGasStationInfoViewController tempView=self;
                //[self dismissViewControllerAnimated:YES completion:nil];
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                TTFindMenuViewController *fmvc;
                if (IS_IPAD) {
                    fmvc= [storyBoard instantiateViewControllerWithIdentifier:@"TTFindMenuViewController_ipad_landscap"];
                }
                else{
                    fmvc= [storyBoard instantiateViewControllerWithIdentifier:@"TTFindMenuViewController_landscap"];
                }
                fmvc.delegate=self;
                [fmvc setParentVC:parentVC];
                [fmvc setIsNotificationOn:NO];
                [fmvc setPoiManager:self.poiManager];
                [fmvc setSuperViewController:self];
                // [self presentViewController:fmvc animated:YES completion:nil];
                //if(IS_IPAD)
                [self presentViewController:fmvc animated:NO completion:^{self.isVisible=YES;}];
                //            else
                //                [self presentViewController:fmvc animated:YES completion:^{self.isVisible=YES;}];
                
                isShowingLandscapeView = YES;
                self.isVisible=YES;
            }
            else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                isShowingLandscapeView = NO;
            }
        }
    }
    else{
        UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
        if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
        {
            landscapeMainView.hidden=NO;
        }
        else{
            landscapeMainView.hidden=YES;
        }

//        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//        if (UIDeviceOrientationIsLandscape(deviceOrientation))
//        {
//            landscapeMainView.hidden=NO;
//        }
//        else{
//            landscapeMainView.hidden=YES;
//        }

    }
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
