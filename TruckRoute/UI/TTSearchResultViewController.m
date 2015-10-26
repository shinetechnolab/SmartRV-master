//
//  TTSearchResultViewController.m
//  TruckRoute
//
//  Created by admin on 4/24/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTSearchResultViewController.h"
#import "TTSearchResultCell.h"
#import "TTPOI.h"
#import "TTTruckStopInfoViewController.h"
#import "TTGenericInfoViewController.h"
#import "TTConfig.h"
@interface TTSearchResultViewController ()

@end

@implementation TTSearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) getCurrentOrientation{
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        if (isIpad) {
            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960~ipad.png"];
//            [backButton setImage:[UIImage imageNamed:@"Back1~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"View1~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"View2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
//            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960-Landscape~ipad"];
//            [backButton setImage:[UIImage imageNamed:@"Back1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"View1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"View2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self getCurrentOrientation];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else{
        [(TTSearchResultViewController *)_superViewController  setIsVisible:YES];
        [(TTSearchResultViewController *)_superViewController  viewDidAppear:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTSearchResultViewController *)_superViewController  setIsVisible:NO];
    }
    
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        //  [self orientationChanged:nil];
    }

    
    [self getCurrentOrientation];
	// Do any additional setup after loading the view.
    searchResultTable.layer.cornerRadius=7;
    searchResultTable.clipsToBounds=YES;
    uti = [[TTUtilities alloc]init];
    //init location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    //unit
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isMetric = [userDefaults boolForKey:@"Metric"];
    //process results
    CLLocation *loc = [locationManager location];
    if (loc) {
        for (TTPOI *aPoi in _results) {
            aPoi.distance = [uti distanceFromCoordinate:[locationManager location].coordinate toCoordinate:aPoi.coord];
        }
        _results = [_results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if (((TTPOI*)obj1).distance < ((TTPOI*)obj2).distance) {
                return NSOrderedAscending;
            }else if (((TTPOI*)obj1).distance == ((TTPOI*)obj2).distance) {
                return NSOrderedSame;
            }else {
                return NSOrderedDescending;
            }
        }];
    }
    [_results retain];
}

-(void)dealloc
{
    [locationManager setDelegate:nil];
    [locationManager release];
    [uti release];
    [_results release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"POICell";
    TTSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TTPOI *poi = [_results objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell.name setText:poi.name];
    //distance
//    [cell.distance setText:@"1.5 miles"];
    NSString *retStr = nil;
    double dist_in_meter = poi.distance;
    if (dist_in_meter > 0) {
        if (isMetric) {
            if (dist_in_meter <= 1000) {
                retStr = @"< 1 km";
            }else if (dist_in_meter <= 3000) {
                retStr = [NSString stringWithFormat:@"%.1f km", dist_in_meter/1000.0];
            }else {
                retStr = [NSString stringWithFormat:@"%d km", (int)(dist_in_meter/1000)];
            }
        }else {
            double miles = METERS_TO_MILES(dist_in_meter);
            if (miles < 1) {
                retStr = @"< 1 mile";
            }else if (miles < 5) {
                retStr = [NSString stringWithFormat:@"%.1f miles", miles];
            }else {
                retStr = [NSString stringWithFormat:@"%d mi", (int)(miles)];
            }
        }
    }else {
        retStr = @"";
    }
    
    [cell.distance setText:retStr];
    //address
    if (poi.address) {
        retStr = [NSString stringWithString:poi.address];
    }else {
        retStr = @"";
    }
    if (poi.city) {
        retStr = [retStr stringByAppendingFormat:@"\n%@", poi.city];
    }
    if (poi.state) {
        retStr = [retStr stringByAppendingFormat:@", %@", [TTUtilities getAbbreviation:poi.state]];
    }
    if (poi.zipcode) {
        retStr = [retStr stringByAppendingFormat:@" %@", poi.zipcode];
    }
    [cell.info setText:retStr];
    //image
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",poi.image]];
    if (!img) {
        switch (poi.type) {
            case truck_stop:
                img = [UIImage imageNamed:@"L2002__Truckstop.png"];
                break;
                
            case weighstation:
                img = [UIImage imageNamed:@"Weigh-Station.png"];
                break;
                
            case campgrounds:
                img = [UIImage imageNamed:@"poi_campground_off"];
                break;
                
            case truck_parking:
                img = [UIImage imageNamed:@"L2005__Parking.png"];
                break;
                
            case rest_area:
                img = [UIImage imageNamed:@"Rest Area.png"];
                break;
                
            case truck_dealer:
            default:
                img = [UIImage imageNamed:@"BlueFlag.png"];
                break;
        }
    }
    [cell.image setImage:img];
    cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTTruckStopInfoViewController *tsvc = nil;
    TTGenericInfoViewController *gvc = nil;
//    TTGasStationInfoViewController *gsvc = nil;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    TTPOI *poi = [_results objectAtIndex:indexPath.row];
    switch (poi.type) {
        case truck_stop:
            if (IS_IPAD) {
                tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController_ipad"];
            }else{
                tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController"];
            }
            
//            [tsvc setParentVC:self];
            [tsvc setPoi:poi];
            [tsvc setIsNotificationOn:YES];
            
            if (UIDeviceOrientationIsLandscape(deviceOrientation))
                [self presentViewController:tsvc animated:NO completion:nil];
            else
                [self presentViewController:tsvc animated:YES completion:nil];
            return;
            
/*        case Gas_Station:
            gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"GasStationInfoViewController"];
            [gsvc setParentVC:self];
            [gsvc setPoi:poi];
            [self presentViewController:gsvc animated:YES completion:nil];
            return;*/
        default:
            if (IS_IPAD) {
                gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController_ipad"];
            }else{
                gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController"];
            }
            
//            [gvc setParentVC:self];
            [gvc setIsNotificationOn:YES];
            [gvc setPoi:poi];
            if (UIDeviceOrientationIsLandscape(deviceOrientation))
                [self presentViewController:gvc animated:NO completion:nil];
            else
                [self presentViewController:gvc animated:YES completion:nil];
            //[self presentViewController:gvc animated:YES completion:nil];
            return;
    }
}
- (IBAction)back:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
      //  if (IS_IPAD) {
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
            
//        }else{
//            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.delegate backButtonClick:self];
//        }
        
    }

}

- (IBAction)view:(id)sender {
    UIViewController *vc = self.presentingViewController;
    while (![vc isMemberOfClass:[TTMapViewController class]]) {
        vc = vc.presentingViewController;
    }
    [((TTMapViewController*)vc) addPOISearchResults:_results];
   // [vc dismissViewControllerAnimated:YES completion:nil];
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
         [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        [self dismissViewControllerAnimated:NO completion:nil];
//        [self.delegate backButtonClick:self];
    }

    
}

- (void)orientationChanged:(NSNotification *)notification
{
    if (!self.isVisible)
    {
        return;
    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        //TTGasStationInfoViewController tempView=self;
        //[self dismissViewControllerAnimated:YES completion:nil];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTSearchResultViewController *gsvc = nil;
        if(IS_IPAD){
            gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"SearchResultViewController_ipad_landscape"];
        }
        else{
            gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"SearchResultViewController_landscape"];
        }
//        [gsvc setParentVC:self.parentVC];
//        [gsvc setPoi:self.poi];
        [gsvc setResults:self.results];
        gsvc.delegate=self;
        [gsvc setSuperViewController:self];
        [self presentViewController:gsvc animated:NO completion:^{self.isVisible=YES;}];
        isShowingLandscapeView = YES;
        self.isVisible=YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
    }
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
