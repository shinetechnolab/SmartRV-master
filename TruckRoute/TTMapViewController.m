//
//  TTMapViewController.m
//  TruckRoute_NavigatorController
//
//  Created by admin on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#import <objc/runtime.h>
#import "UIBarButtonItem+WEPopover.h"
#import <CoreGraphics/CoreGraphics.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "TTMapViewController.h"
//#import "TTRouteMenuViewController.h"
#import "TTConfig.h"
#import "TTUtilities.h"
#import "TTNewRouteViewController.h"
#import "TTSettingsViewController2.h"
#import "TTRouteDetailsViewController.h"
#import "TTHelpViewController.h"
#import "zip.h"
#import "TTTruckStopInfoViewController.h"
#import "TTPOIAnnotation.h"
#import "TTFindMenuViewController.h"
#import "TTGenericInfoViewController.h"
#import "TTGasStationInfoViewController.h"
#import "TTMyPointViewController.h"

@interface TTMapViewController ()<AVSpeechSynthesizerDelegate>


@end
static char fooKey;
@implementation TTMapViewController
@synthesize synthesizer;
@synthesize popoverController;
//@synthesize simuButton;
@synthesize northUpButton;
//@synthesize accountButton;
//@synthesize instructionButton;
@synthesize navButton;
@synthesize menuPanel;
@synthesize menuButton;
@synthesize lowerPanel;
@synthesize upperPanel;
@synthesize graphPanel;
@synthesize splitLine;
@synthesize leftArrowsImg;
@synthesize rightArrowsImg;
@synthesize directionImg;
@synthesize labelInstruction;
@synthesize labelGraph;
@synthesize labelTripInfo1;
@synthesize labelTripInfo2;
@synthesize labelTripInfo3;
@synthesize labelTripTitle1;
@synthesize labelTripTitle2;
@synthesize labelTripTitle3;
@synthesize labelTripFoot1;
@synthesize labelTripFoot2;
@synthesize labelTripFoot3;
@synthesize btnTripPanel1;
@synthesize btnTripPanel2;
@synthesize btnTripPanel3;
@synthesize labelTripFoot1_iphone,labelTripFoot2_iphone,labelTripInfo1_iphone,labelTripInfo2_iphone,labelTripTitle1_iphone,labelTripTitle2_iphone;

@synthesize btnMenu;
@synthesize imgMainMenuPanel;
@synthesize viewMainMenuPanel;
@synthesize btnNewRoute;
@synthesize isNavigating;
@synthesize isSimulating;
@synthesize isAutoReroute;
@synthesize isTravelAlerts;
@synthesize isWeighScaleAlerts;
@synthesize isAutoZoom;
@synthesize isPerspective;
@synthesize isShowBuildings;
@synthesize isNorthUp;
@synthesize isMainMenuShown;
@synthesize needReload;
@synthesize dZoomLevel;
@synthesize last_zoom_level;
@synthesize isMenuHidden;
@synthesize isPanelHidden;
@synthesize tripInfo_panel1;
@synthesize tripInfo_panel2;
@synthesize btnFind;
@synthesize btnSettings;
@synthesize btnHelp;
@synthesize btnClearRoute;
@synthesize imgCover;
@synthesize btnZoomIn;
@synthesize btnZoomOut;
@synthesize btn3DView;
@synthesize nOffRouteCount;
@synthesize responseData;


@synthesize speedMinButton,speedPlusButton;
@synthesize travelAlertsButton;
//@synthesize fliteController;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }*/

-(void) viewWillAppear:(BOOL)animated
{
    lastZoomLevel=0.0;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
    }
    
    NSString *imgName=[[NSUserDefaults standardUserDefaults] objectForKey:@"cursorImage"];
    _imgNavCursor.image=[UIImage imageNamed:imgName];
    
    
    travel_speed=30; // set default travelling speed for simulator.
    [self loadNavSettings];
    
    if (isTravelAlerts)
    {
        travelAlertsButton.hidden=NO;
    }
    else
    {
        travelAlertsButton.hidden=YES;
    }
    
    if(needReload)
    {
        [self clearRoute];
        
        [self loadKML];
        if([routeAnalyzer hasRoute])
        {
            _mapView.camera.centerCoordinate=[locationManager location].coordinate;
            //[self updateView];
        }
        //show nav button
        [navButton setHidden:NO];
    }
    else{
    
    }
#ifdef __IPHONE_7_0
    
    [_mapView setShowsBuildings:isShowBuildings];
    //[_mapView setPitchEnabled:isPerspective];
    [_mapView setPitchEnabled:YES];
    [self make3DMapView:nil];
    
#endif
    //check if setting changed
    [self updateNorthUpButton];
    if (_mapType != [_mapView mapType]) {
        [_mapView setMapType:_mapType];
    }
    [routeAnalyzer setIsMetric:_isUnitMetric];
    [routeAnalyzer setIs24Hour:_is24Hour];
    
    [self updateMenuButtons];
    
    //odometer
    if (_isOdometerOn) {
        if (![timer_odo isValid]) {
            timer_odo = [NSTimer scheduledTimerWithTimeInterval:ODOMETER_INTERVAL target:self selector:@selector(updateOdometer) userInfo:nil repeats:YES];
        }
    }else {
        if ([timer_odo isValid]) {
            [timer_odo invalidate];
            timer_odo = nil;
        }
    }
}
-(void)getDestinationTimeZone:(NSString *)string
{
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/timezone/json?location=%@&timestamp=1331161200",string];
    NSString *response=[NSString stringWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] encoding:nil error:nil];
    if (response) {
        NSDictionary *dict=[response JSONValue];
        NSLog(@"Response : %@",dict);
        if ([dict objectForKey:@"timeZoneId"]) {
            destinationTimeZone=[[NSString alloc]initWithString:[dict objectForKey:@"timeZoneId"]];
        }
    }
}
-(NSString *)timeWithDastinationTimeZone:(NSString *)time
{
    NSDateFormatter* dateF = [[[NSDateFormatter alloc] init] autorelease];
    [dateF setTimeZone:[NSTimeZone localTimeZone]];
    [dateF setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate=[dateF stringFromDate:[NSDate date]];
    NSString *dateNTime=[NSString stringWithFormat:@"%@ %@",currentDate,time];
    NSLog(@"Date N Time : %@",dateNTime);
    NSDateFormatter* gmtDf = [[[NSDateFormatter alloc] init] autorelease];
    [gmtDf setTimeZone:[NSTimeZone localTimeZone]];
    [gmtDf setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSDate* gmtDate = [gmtDf dateFromString:dateNTime];
    NSLog(@"%@",gmtDate);
    
    NSDateFormatter* estDf = [[[NSDateFormatter alloc] init] autorelease];
    [estDf setTimeZone:[NSTimeZone timeZoneWithName:destinationTimeZone]];
    [estDf setDateFormat:@"hh:mm a"];
    NSLog(@"Correct Time : %@",[estDf stringFromDate:gmtDate]);
    return [estDf stringFromDate:gmtDate];

}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    if (isNavigating) {
        [self stopNavigating];
        [navButton setHidden:NO];
    }
    
    //poi
    if ([timer_poi isValid]) {
        [timer_poi invalidate];
        timer_poi = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    //calculate zoom
    [self calculateZoom];
    CGRect instructionDiscloserViewRect=instructionDiscloserView.frame;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (IS_IPAD) {
        //instructionDiscloserViewRect.size.height+=50;
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            instructionDiscloserViewRect.origin.x=115;
            instructionDiscloserViewRect.size.width=799;
        }
        else{
            instructionDiscloserViewRect.origin.x=110;
            instructionDiscloserViewRect.size.width=548;
        }
    }
    else{
        CGRect screenRect=[UIScreen mainScreen].bounds;
        float w=0,h=0;
        if (screenRect.size.width>screenRect.size.height) {
            h=screenRect.size.width;
            w=screenRect.size.height;
        }
        else{
            h=screenRect.size.height;
            w=screenRect.size.width;
        }
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            //  NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
            instructionDiscloserViewRect.origin.x=77;
            instructionDiscloserViewRect.size.width=h- 154;
        }
        else{
            instructionDiscloserViewRect.origin.x=7;
            instructionDiscloserViewRect.size.width=w-14;
        }
        instructionDiscloserView.frame=instructionDiscloserViewRect;
    }
    
    instructionDiscloserView.frame=instructionDiscloserViewRect;
// _pickerData = @[@"ETA",@"DTG",@"HEADING",@"SPEED",@"TIME",@"TTD",@"NEXT TURN",@"ALTITUDE"];
    
    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:instructionDiscloserSubView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(7.0,7.0)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = instructionDiscloserSubView.bounds;
//    maskLayer.path  = maskPath.CGPath;
//    instructionDiscloserSubView.layer.mask = maskLayer;

//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: instructionDiscloserSubView.bounds
//                                                   byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
//                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
//    
//    CALayer *roundedLayer = [CALayer layer];
//    [roundedLayer setFrame:instructionDiscloserSubView.bounds];
//    //[roundedLayer setContents:(id)theImage.CGImage];
//    [roundedLayer setContents:instructionDiscloserSubView];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    [maskLayer setFrame:instructionDiscloserSubView.bounds];
//    [maskLayer setPath:maskPath.CGPath];
//    
//    roundedLayer.mask = maskLayer;
//    
//    // Add these two layers as sublayers to the view
//    [instructionDiscloserSubView.layer addSublayer:roundedLayer];
    
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = instructionDiscloserSubView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    instructionDiscloserSubView.layer.mask = maskLayer;
//    [instructionDiscloserSubView setNeedsDisplay];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(directionImgTap)];
    singleTap.numberOfTapsRequired = 1;
    directionImg.userInteractionEnabled = YES;
    [directionImg addGestureRecognizer:singleTap];
    
    //poi
    //start timer_poi
    if ([timer_poi isValid]) {
        [timer_poi invalidate];
        timer_poi = nil;
    }
    last_region.span.latitudeDelta = 0;//trigger reload
    timer_poi = [NSTimer scheduledTimerWithTimeInterval:POI_UPDATE_INTERVAL target:self selector:@selector(updatePOIs) userInfo:nil repeats:YES];
}
-(void)setGlowBorder:(UIView *)sView
{
    sView.layer.bounds=sView.bounds;
    sView.layer.shadowColor = [UIColor whiteColor].CGColor;
    sView.layer.shadowOpacity = 0.7f;
    sView.layer.shadowOffset = CGSizeMake(3, -3);
    //sView.layer.shadowRadius = 5.0f;
    sView.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:sView.bounds];
    sView.layer.shadowPath = path.CGPath;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //northUpButton.autoresizingMask=UIViewAutoresizingNone;
    if (IS_IPAD) {
        CGRect rect=btnZoomIn.frame;
        rect.origin.y-=30;
        rect.size.height*=2;
        rect.size.width*=2;
        btnZoomIn.frame=rect;
        
        CGRect rect1=btnZoomOut.frame;
        rect1.origin.y-=30;
        rect1.size.height*=2;
        rect1.size.width*=2;
        btnZoomOut.frame=rect1;
        
        CGRect rect2=btnMenu.frame;
        rect2.origin.y-=30;
        rect2.size.height*=2;
        rect2.size.width*=2;
        btnMenu.frame=rect2;
        
        CGRect rect3=northUpButton.frame;
        rect3.size.height*=2;
        rect3.size.width*=2;
        rect3.origin.x-=rect3.size.width/2;
        northUpButton.frame=rect3;
        
        CGRect rect4=_btnReroute.frame;
        rect4.origin.y-=30;
        rect4.size.height*=2;
        rect4.size.width*=2;
        rect4.origin.x-=rect4.size.width/2;
        _btnReroute.frame=rect4;
        
        CGRect rect5=_btnReport.frame;
        rect5.origin.y-=30;
        rect5.size.height*=2;
        rect5.size.width*=2;
        rect5.origin.x-=rect5.size.width/2;
        _btnReport.frame=rect5;
        
        CGRect viewMainMenuPanelRect=viewMainMenuPanel.frame;
        viewMainMenuPanelRect.size.width*=1.5;
        viewMainMenuPanelRect.size.height*=1.5;
       // viewMainMenuPanelRect.origin.x-=rect5.size.width/2;
        viewMainMenuPanelRect.origin.y-=rect5.size.height;
        viewMainMenuPanel.frame=viewMainMenuPanelRect;

        CGRect routeDetailViewRect=routeDetailView.frame;
        //routeDetailViewRect.size.height+=40;
        //routeDetailViewRect.origin.y-=40;
        routeDetailViewRect.origin.x+=40;
        routeDetailViewRect.size.width-=40;
        routeDetailView.frame=routeDetailViewRect;
//
//        //labelInstruction.font=[UIFont fontWithName:@"Helvetica Neue Bold" size:40];
//        labelInstruction.font=[UIFont boldSystemFontOfSize:40.0];
//
        firstInstructionLbl.font=[UIFont boldSystemFontOfSize:37.0];
        firstSubInstructionLbl.font=[UIFont boldSystemFontOfSize:25.0];
        secondInstructionLbl.font=[UIFont boldSystemFontOfSize:37.0];
        secondSubInstructionLbl.font=[UIFont boldSystemFontOfSize:25.0];
//        firstInstructionLbl
//        firstSubInstructionLbl
//        secondInstructionLbl
//        secondSubInstructionLbl
        CGRect instructionDiscloserViewRect=instructionDiscloserView.frame;
        instructionDiscloserViewRect.size.height+=50;
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            instructionDiscloserViewRect.origin.x=115;
            instructionDiscloserViewRect.size.width=799;
        }
        else{
            instructionDiscloserViewRect.origin.x=110;
            instructionDiscloserViewRect.size.width=548;
        }
        instructionDiscloserView.frame=instructionDiscloserViewRect;
        
        CGRect instructionDiscloserSubViewRect=instructionDiscloserSubView.frame;
        instructionDiscloserSubViewRect.size.height+=50;
        instructionDiscloserSubViewRect.origin.y=0;
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            //instructionDiscloserViewRect.origin.x=115;
            instructionDiscloserSubViewRect.size.width=799;
        }
        else{
            //instructionDiscloserViewRect.origin.x=110;
            instructionDiscloserSubViewRect.size.width=548;
        }

        instructionDiscloserSubView.frame = instructionDiscloserSubViewRect;
//
        CGRect directionInfoViewRect=directionInfoView.frame;
        directionInfoViewRect.size.width+=40;
        directionInfoView.frame=directionInfoViewRect;
//
//        CGRect navInfoViewForiPadRect=navInfoViewForiPad.frame;
//        //navInfoViewForiPadRect.size.height+=30;
//        //navInfoViewForiPadRect.origin.y-=30;
//        navInfoViewForiPadRect.size.width-=30;
//        navInfoViewForiPadRect.origin.x+=30;
//        navInfoViewForiPad.frame=navInfoViewForiPadRect;
//        labelGraph.font=[UIFont boldSystemFontOfSize:30];
//        //speedLimitView
//        
        CGRect speedLimitViewRect=speedLimitView.frame;
        speedLimitViewRect.origin.y-=20;
        speedLimitView.frame=speedLimitViewRect;

        labelInstruction.font=[UIFont boldSystemFontOfSize:45];
        labelGraph.font=[UIFont boldSystemFontOfSize:35];
    }
    else if (IS_IPHONE_6 || IS_IPHONE_6P)
    {
        CGRect rect=btnZoomIn.frame;
        rect.size.height*=1.3;
        rect.size.width*=1.3;
        //rect.origin.y=_btnReport.frame.origin.y;
        btnZoomIn.frame=rect;
        
        CGRect rect1=btnZoomOut.frame;
        rect1.size.height*=1.3;
        rect1.size.width*=1.3;
        //rect1.origin.y=northUpButton.frame.origin.y;
        btnZoomOut.frame=rect1;
        
        CGRect rect2=btnMenu.frame;
        rect2.size.height*=1.3;
        rect2.size.width*=1.3;
        //rect2.origin.y=_btnReroute.frame.origin.y;
        btnMenu.frame=rect2;
        
        CGRect screenRect=[UIScreen mainScreen].bounds;
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        CGRect instructionDiscloserViewRect=instructionDiscloserView.frame;
        float w=0,h=0;
        if (screenRect.size.width>screenRect.size.height) {
            h=screenRect.size.width;
            w=screenRect.size.height;
        }
        else{
            h=screenRect.size.height;
            w=screenRect.size.width;
        }
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            //  NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
            instructionDiscloserViewRect.origin.x=77;
            instructionDiscloserViewRect.size.width=h- 154;
        }
        else{
            instructionDiscloserViewRect.origin.x=7;
            instructionDiscloserViewRect.size.width=w-14;
        }
        instructionDiscloserView.frame=instructionDiscloserViewRect;


    }
    if (!IS_IPAD) {
        float screenHeight=_mapView.frame.size.height;
        float screenWidth=_mapView.frame.size.width;
        navInfoViewForiPhone.frame=CGRectMake(0,screenHeight-55,screenWidth,55);
    }
    
    directionInfoView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    directionInfoView.layer.borderWidth=1.0;
    // _pickerData = @[@"ETA",@"DTG",@"HEADING",@"SPEED",@"TIME",@"TTD",@"NEXT TURN",@"ALTITUDE"];
    /*
     speed,
     estimated_time_arrival,
     distance_to_go,
     heading,
     time_current,
     time_to_destination,
     time_to_next_turn,
     altitude,
     trip_info_type_none
     */
    _pickerData=[[NSArray alloc] initWithObjects:@"SPEED",@"ETA",@"DTG",@"HEADING",@"TIME",@"TTD",@"NEXT TURN",@"ALTITUDE", nil];
    [self setGlowBorder:directionInfoView];
    [self setGlowBorder:routeDetailView];
    
    northUpButton.clipsToBounds=YES;
    
    //routeDetailView.backgroundColor=[UIColor yellowColor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //        CGRect rect=_imgNavCursor.frame;
        //        rect.size.height+=rect.size.height/2;
        //        rect.size.width+=rect.size.width/2;
        //        rect.origin.x-=_imgNavCursor.frame.size.width/4;
        //        rect.origin.y-=_imgNavCursor.frame.size.height/4;
        //        _imgNavCursor.frame=rect;
    }
    if (IS_IPHONE_6) {
        CGRect rect=speedLimitView.frame;
        //rect.origin.x=15;
        //rect.origin.y+=20;
        speedLimitView.frame=rect;
    }
    
    CGPoint origin = CGPointMake(0.0,self.view.frame.size.height+580);
    bannerView_ = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin]autorelease];
    bannerView_.adUnitID = @"a1536238caf2662";
    //bannerView_.delegate = self;
    [bannerView_ setRootViewController:self];
    [self.view addSubview:bannerView_];
    //bannerView_.center =CGPointMake(self.view.center.x, bannerView_.center.y);
    [bannerView_ loadRequest:[GADRequest request]];
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"warn_weigh_station"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    popoverClass = [WEPopoverController class];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    self.synthesizer.delegate = self;
   
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(audioRouteChanged:)
               name:AVAudioSessionInterruptionNotification
             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    //weightStation = [[TTWeightStationAlert alloc] init];
   // weightStation.delegate=self;
    
    routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)];
    routeView.userInteractionEnabled = NO;
    [_mapView addSubview:routeView];
    
    
    
    
    routeAnalyzer = [[TTRouteAnalyzer alloc]retain];
    
    _utility = [[TTUtilities alloc]init];
    
    // Do any additional setup after loading the view.
    //waiting animation
    [self initSpinner];
    /*    _imgWaiting.animationImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"direction_start.png"],
     [UIImage imageNamed:@"direction_turnleft.png"],
     [UIImage imageNamed:@"direction_turnright.png"],
     [UIImage imageNamed:@"direction_uturnleft.png"],
     [UIImage imageNamed:@"direction_uturnright.png"],
     [UIImage imageNamed:@"direction_destination.png"], nil];*/
    [self setNeedReload:NO];
    [self setIsNavigating:NO];
    isAnnotationAdded = NO;
    [_mapView setDelegate:self];
#ifdef __IPHONE_7_0
    //ios7 map camera
    //    camera = _mapView.camera;
#endif
    
    [self initAbbreviationDictionary];
    
    //instruction annotation array
    annotationsIns = [[NSMutableArray alloc]init];
    annotationviewsIns = [[NSMutableArray alloc]init];
    
    //poi
    poiManager = [[TTPOIManager alloc] init];
    [poiManager initializeDB2];
    
    poiResults = [[NSMutableArray alloc]init];
    
    /*enum TTPOI_TYPE {
     truck_stop,9522
     weighstation,9710
     truck_dealer,9719
     truck_parking,9720-1
     Gas_Station,
     CAT_scale,0
     rest_area,9720-2
     all_poi
     };
     NSString *csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"9522.csv"];
     [poiManager importCSVFile:csvPath asType:0];
     csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"9710.csv"];
     [poiManager importCSVFile:csvPath asType:1];
     csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"9719.csv"];
     [poiManager importCSVFile:csvPath asType:2];
     csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"9720_nonrestarea.csv"];
     [poiManager importCSVFile:csvPath asType:3];
     csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"catscale.csv"];
     [poiManager importCSVFile:csvPath asType:5];
     csvPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"9720_restarea.csv"];
     [poiManager importCSVFile:csvPath asType:6];*/
    //    [poiManager displayAll];
    
    
    annotationsPOIs = [[NSMutableArray alloc]init];
    annotationviewsPOIs = [[NSMutableArray alloc]init];
    annotationsGas = [[NSMutableArray alloc]init];
    annotationviewsGas = [[NSMutableArray alloc]init];
    
    //init location manager
    locationManager = [[CLLocationManager alloc]init];
    
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.delegate = self;
    locationManager.distanceFilter =  kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    else {
        // [locationManager startUpdatingLocation];
    }
    //
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    //load preference
    [self loadNavSettings];
    _mapView.showsUserLocation=YES;
    
#ifdef __IPHONE_7_0
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(make3DMapView:) userInfo:nil repeats:NO];
#else
    //set mapview's bounds to ensure it is big enough when rotating
    CGRect rectBounds = [_mapView bounds];
    CGFloat max = MAX(rectBounds.size.height, rectBounds.size.width) * sqrt(2);
    rectBounds.size.height = max;
    rectBounds.size.width = max;
    [_mapView setBounds:rectBounds];
#endif
    [_mapView setMapType:_mapType];
    
    //    CLLocation *location=[[CLLocation alloc]initWithLatitude: longitude:];
    //    _mapView.camera.centerCoordinate=
    //DEBUG
    /*    UIView *rootView = [[mapView subviews] objectAtIndex:0];
     UIView *vkmapView = [rootView.subviews objectAtIndex:0];
     CALayer *rootlayer = [vkmapView layer];
     NSString *name = nil;
     for (CALayer *sublayer in [rootlayer sublayers]) {
     //        [sublayer setTransform:CGAffineTransformMakeRotation(M_PI)];
     }*/
    
    //init end annotation
    annotationEnd = [[MKPointAnnotation alloc]init];
    [annotationEnd setCoordinate:CLLocationCoordinate2DMake(0, 0)];
    
    annotationNavCursor = [[MKPointAnnotation alloc]init];
    [annotationNavCursor setCoordinate:CLLocationCoordinate2DMake(0, 0)];
    //init nav cursor
    //    navCursor = [[MKPointAnnotation alloc] init];
    //    [navCursor setCoordinate:CLLocationCoordinate2DMake(0, 0)];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"navCursor" ofType:@"png"];
    //    navCursorImg = [[UIImage alloc]initWithContentsOfFile:path];
    
    //hide nav panel
    [self navPanelAnimation:YES];
    
    //hide button menu
    [_svMenu setContentSize:CGSizeMake(575, 60)];
    [self buttonMenuAnimation:YES first:YES];
    
    //hide nav button
    [navButton setHidden:YES];
    
    //hide menu
    //    [self mainMenuAnimation:YES];
    
    //init zoom level
    [self setTrackingMode];
    
    [self resetFlags];
    
    data_gas_station = [[NSMutableData alloc]init];
    
#ifdef DEBUG
    // [_labelZoom setHidden:YES];
    [_labelLocation setHidden:YES];
#endif
    
    //poi search
    isSearchOn = NO;
    
    //#ifdef __IPHONE_7_0
#ifndef __IPHONE_7_0
    [_mapView setRotateEnabled:YES];
    [_mapView setShowsBuildings:isShowBuildings];
    
#else
    //legal link
    UIView *legalView = nil;
    for (UIView *subview in _mapView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            legalView = subview;
        }
    }
    legalView.frame = CGRectMake(180, 200, legalView.frame.size.width, legalView.frame.size.height);
#endif
    
    [self print_free_memory];
}
-(void)update3D
{
    [self make3DMapView:nil];
}

- (void)checkStateChange {
    if (isNavigating) {
        if (isSimulating) {
            if ([oldState isEqualToString:@""]) {
                oldState = [_utility getStateWithCoord:[routeAnalyzer getNextSimulationLocation:travel_speed].coordinate];
            }
            newState = [_utility getStateWithCoord:[routeAnalyzer getNextSimulationLocation:travel_speed].coordinate];
        }
        else {
            if ([oldState isEqualToString:@""]) {
                oldState = [_utility getStateWithCoord:locationManager.location.coordinate];
            }
            newState = [_utility getStateWithCoord:locationManager.location.coordinate];
        }
        
        
//        NSString *newStateString0 = @"";
//        if (![newState isEqualToString:@"UNKNOWN_STATE"]) {
//            newStateString0 = [newState substringFromIndex:3];
//        }
//        else{
//            return;
//        }
        //  UIAlertView *alertState = [[UIAlertView alloc] initWithTitle:@"Current State" message:[NSString stringWithFormat:@"%@",[TTUtilities getStateName:newStateString0]] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        //        [alertState show];
        if (![oldState isEqualToString:newState]) {
            NSString *oldStateString = @"";
            NSString *newStateString = @"";
            if (![oldState isEqualToString:@"UNKNOWN_STATE"]) {
                oldStateString = [oldState substringFromIndex:3];
            }
            if (![newState isEqualToString:@"UNKNOWN_STATE"]) {
                newStateString = [newState substringFromIndex:3];
            }
            if (oldStateString.length>0 && newStateString.length>0) {
                NSString *alertText=[NSString stringWithFormat:@"State Border Crossed\n%@ to %@",[TTUtilities getStateName:oldStateString],[TTUtilities getStateName:newStateString]];
                UIAlertView *alertStateChange = [[UIAlertView alloc] initWithTitle:alertText message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alertStateChange show];
            }
            oldState = newState;
        }
        
    }
}

- (void)viewDidUnload
{
    //   [self setMapView:nil];
    //    [self setMenuButton:nil];
    [self setMenuPanel:nil];
    //    [self setSimuButton:nil];
    [self setLowerPanel:nil];
    [self setUpperPanel:nil];
    [self setGraphPanel:nil];
    [self setSplitLine:nil];
    [self setLeftArrowsImg:nil];
    [self setRightArrowsImg:nil];
    [self setDirectionImg:nil];
    [self setNorthUpButton:nil];
    [self setLabelInstruction:nil];
    //    [self setAccountButton:nil];
    //    [self setInstructionButton:nil];
    [self setNavButton:nil];
    [self setLabelGraph:nil];
    [self setLabelTripInfo1:nil];
    [self setLabelTripInfo2:nil];
    [self setLabelTripTitle1:nil];
    [self setLabelTripTitle2:nil];
    [self setLabelTripFoot1:nil];
    [self setLabelTripFoot2:nil];
    [self setBtnTripPanel1:nil];
    [self setBtnTripPanel2:nil];
    [self setBtnMenu:nil];
    [self setImgMainMenuPanel:nil];
    [self setViewMainMenuPanel:nil];
    [self setBtnNewRoute:nil];
    [self setBtnFind:nil];
    [self setBtnSettings:nil];
    [self setBtnHelp:nil];
    [self setImgCover:nil];
    [self setBtnZoomIn:nil];
    [self setBtnZoomOut:nil];
    [self setBtnReroute:nil];
    [self setBtnAnnounce:nil];
    [self setBtnRouteDetails:nil];
    [self setImgNavCursor:nil];
    
    [self setSpeedMinButton:nil];
    [self setSpeedPlusButton:nil];
    [self.synthesizer release];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    //    [navCursorView release];
    //    [navCursorImg release];
    //    [navCursor release];
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 //    return (interfaceOrientation != UIInterfaceOrientationPortrait);
 //    if(interfaceOrientation == UIDeviceOrientationPortrait)
 //        return YES;
 //    else
 return NO;
 }*/

- (void)dealloc {
    [_mapView release];
    [locationManager setDelegate:nil];
    
    //[menuButton release];
    [menuPanel release];
    //[simuButton release];
    [lowerPanel release];
    [upperPanel release];
    [graphPanel release];
    [splitLine release];
    [leftArrowsImg release];
    [rightArrowsImg release];
    [directionImg release];
    [northUpButton release];
    [labelInstruction release];
    //    [accountButton release];
    //    [instructionButton release];
    [navButton release];
    [labelGraph release];
    [labelTripInfo1 release];
    [labelTripInfo2 release];
    [labelTripTitle1 release];
    [labelTripTitle2 release];
    [labelTripFoot1 release];
    [labelTripFoot2 release];
    [btnTripPanel1 release];
    [btnTripPanel2 release];
    [btnMenu release];
    [imgMainMenuPanel release];
    [viewMainMenuPanel release];
    [btnNewRoute release];
    [btnFind release];
    [btnSettings release];
    [btnHelp release];
    [btnClearRoute release];
    [imgCover release];
    [btnZoomIn release];
    [btnZoomOut release];
    [_btnReroute release];
    [_btnAnnounce release];
    [_btnRouteDetails release];
    [_imgNavCursor release];
    [annotationEnd release];
    [annotationviewEnd release];
    
    [annotationNavCursor release];
    [annotationviewNavCursor release];
    
    [abbDictionary release];
    
    [speedPlusButton release];
    [speedMinButton release];
    
    [self clearInstructionAnnotations];
    [annotationsIns release];
    [annotationviewsIns release];
    
    [poiManager deinitializeDB];
    [poiManager release];
    [self clearPOIAnotations];
    [annotationsPOIs release];
    [annotationviewsPOIs release];
    [self clearGasStations];
    [annotationsGas release];
    [annotationviewsGas release];
    
    [spinner release];
    
    [routeAnalyzer release];
    [kmlParser release];
    
    if (laneassistView) {
        [laneassistView release];
    }
    
    [_utility release];
    
    [self clearPOIResults];
    [poiResults release];
    
    [_menuButtonTruckStop release];
    [_menuButtonWeighStation release];
    [_menuButtonTruckDealer release];
    [_menuButtonTruckParking release];
    [_menuButtonGasStation release];
    
    [data_gas_station release];
    
    [_labelZoom release];
    [_svMenu release];
    [_menuButtonRestArea release];
    [_menuButtonCatScale release];
    [_menuButtonSearch release];
    [_labelLocation release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self print_free_memory];
}
- (void)make3DMapView:(id)sender
{
    //[self initMoveLocation];
    
#ifdef __IPHONE_7_0
    //#ifndef __IPHONE_7_0
    // [_mapView setPitchEnabled:YES];
    
    // UIButton *btn=(UIButton *)sender;
    if (!isPerspective)
    {
        [_imgNavCursor setTransform:CGAffineTransformMakeRotation(0)];
        //btn.selected=NO;
        _mapView.camera.pitch=0;
        CGRect rect=self.imgNavCursor.frame;
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            rect.size.height=64;
        }
        else{
            rect.size.height=64;
        }
        
        self.imgNavCursor.frame=rect;
    }
    else
    {
        [_imgNavCursor setTransform:CGAffineTransformMakeRotation(0)];
        CGRect rect=self.imgNavCursor.frame;
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            rect.size.height=40;
        }
        else{
            rect.size.height=40;
        }
        self.imgNavCursor.frame=rect;
        
        //btn.selected=YES;
        //_mapView.camera.pitch=[self pitchValueBaseOnZoom];//_mapView.camera.pitch;
        
        
        MKMapCamera *newCamera = [[_mapView camera] copy];
//        [newCamera setPitch:45.0];
//        [newCamera setHeading:90.0];
//        [newCamera setAltitude:500.0];
        [_mapView setCamera:newCamera animated:NO];
    }
    // _mapView.camera.centerCoordinate=_mapView.camera.centerCoordinate;
    //[_mapView setPitchEnabled:NO];
#endif
}
-(NSInteger)pitchValueBaseOnZoom
{
    if (_mapView.camera.altitude>=3000) {
        return 52;
    }
    else if (_mapView.camera.altitude>=2500) {
        return 54;
    }
    else if (_mapView.camera.altitude>2000) {
        return 55;
    }
    else if (_mapView.camera.altitude>=1500) {
        return 56;
    }
    else if (_mapView.camera.altitude>=1000) {
        return 57;
    }
    else if (_mapView.camera.altitude>=950) {
        return 60;
    }
    else if (_mapView.camera.altitude>900) {
        return 61;
    }
    else if (_mapView.camera.altitude>800) {
        return 61;
    }
    else if (_mapView.camera.altitude>700) {
        return 64;
    }
    else if (_mapView.camera.altitude>600) {
        return 65;
    }
    else if (_mapView.camera.altitude>550) {
        return 66;
    }
    else if (_mapView.camera.altitude>500) {
        return 67;
    }
    else if (_mapView.camera.altitude>400) {
        return 68;
    }
    else if (_mapView.camera.altitude>300) {
        return 71;
    }
    else if (_mapView.camera.altitude>200) {
        return 72;
    }
    else if (_mapView.camera.altitude>100){
        return 75;
    }
    else{
        return 78;
    }
}
- (IBAction)zoomOut:(id)sender
{
    [self calculateZoom];
    dZoomLevel = dZoomLevel + 1;
    if (dZoomLevel > MAX_ZOOM)
    {
        dZoomLevel = MAX_ZOOM;
    }
    //if (!isNavigating) {
    [self updateZoom];
    // }
}
-(void)dismissAlert
{
    [alertView close];
    //[alertView release];
}

- (IBAction)zoomIn:(id)sender {
    [self calculateZoom];
    
    if (isPerspective) {
        dZoomLevel = dZoomLevel - 1;
        if (dZoomLevel > 16) {
            dZoomLevel = dZoomLevel - 1;//due to mapview issue
        }
        if (dZoomLevel < 0.0) {
            dZoomLevel = -0.0;
        }
    }
    else{
        dZoomLevel = dZoomLevel - 1;
        if (dZoomLevel > 16) {
            dZoomLevel = dZoomLevel - 1;//due to mapview issue
        }
        if (dZoomLevel < MIN_ZOOM) {
            dZoomLevel = MIN_ZOOM;
        }
    }
    [self updateZoom];
}

/*- (IBAction)toggleSimulation:(id)sender {
 UIImage *img = nil;
 isSimulating = ~isSimulating;
 if(isSimulating)
 {
 img = [UIImage imageNamed:@"Simulator.png"];
 }else {
 img = [UIImage imageNamed:@"Simulator_Disabled.png"];
 }
 [simuButton setImage:img forState:UIControlStateNormal];
 }*/

- (IBAction)toggleNorthUp:(id)sender {
    if (isNorthUp) {
        isNorthUp = NO;
    }else {
        isNorthUp = YES;
    }
    //save settings
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"NorthUp"];
    [userDefault setBool:isNorthUp forKey:@"NorthUp"];
    [userDefault synchronize];
    //set usertracking mode with or without heading if it is not in navigation mode
    if (!isNavigating) {
        [self setTrackingMode];
    }
    
    [self updateNorthUpButton];
}

- (IBAction)toggleMenu:(id)sender {
    if (isMenuHidden) {
        [self buttonMenuAnimation:NO first:NO];
    }else {
        [self buttonMenuAnimation:YES first:NO];
    }
}

- (IBAction)checkRouteInstruction:(id)sender {
}

- (IBAction)navigate:(id)sender {
    
    instructionDiscloserView.hidden=NO;
    [self mainMenuAnimation:YES];
    [self startNavigating];
    [navButton setHidden:YES];
    
    /*    if(isNavigating)
     {
     [self stopNavigating];
     }else {
     [self startNavigating];
     }*/
}

- (IBAction)tapScreen:(id)sender {
    //hide main menu
    if (isMainMenuShown) {
        [self mainMenuAnimation:YES];
    }
    //stop navigating
    if (isNavigating) {
        if (isAutoZoom) {
            [self stopNavigating];
            [navButton setHidden:NO];
        }
    }
}

- (IBAction)incrementTripPanel1Type:(id)sender {
    typePickerView.tag=1;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y-=206;
    pickerHolderView.frame=rect;
    [UIView commitAnimations];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    //int type = [userDefaults integerForKey:@"trip_info_panel1"];
//    NSInteger type=[userDefaults integerForKey:@"trip_info_panel1"];
//    if (++type >= MAX_TRIP_PANEL_TYPE) {
//        type = 0;
//    }
//    [userDefaults removeObjectForKey:@"trip_info_panel1"];
//    [userDefaults setInteger:type forKey:@"trip_info_panel1"];
//    [userDefaults synchronize];
//    //  NSLog(@"set panel1 %d", type);
//    [self setTripPanelAtIndex:1];
}

- (IBAction)incrementTripPanel2Type:(id)sender
{
    
    typePickerView.tag=2;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y-=206;
    pickerHolderView.frame=rect;
    [UIView commitAnimations];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSInteger type = [userDefaults integerForKey:@"trip_info_panel2"];
//    if (++type >= MAX_TRIP_PANEL_TYPE) {
//        type = 0;
//    }
//    [userDefaults removeObjectForKey:@"trip_info_panel2"];
//    [userDefaults setInteger:type forKey:@"trip_info_panel2"];
//    [userDefaults synchronize];
//    //    NSLog(@"set panel2 %d", type);
//    [self setTripPanelAtIndex:2];
}
- (IBAction)incrementTripPanel3Type:(id)sender {
    typePickerView.tag=3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y-=206;
    pickerHolderView.frame=rect;
    [UIView commitAnimations];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSInteger type = [userDefaults integerForKey:@"trip_info_panel3"];
//    if (++type >= MAX_TRIP_PANEL_TYPE) {
//        type = 0;
//    }
//    [userDefaults removeObjectForKey:@"trip_info_panel3"];
//    [userDefaults setInteger:type forKey:@"trip_info_panel3"];
//    [userDefaults synchronize];
//    //    NSLog(@"set panel2 %d", type);
//    [self setTripPanelAtIndex:3];
}


- (IBAction)showMenu:(id)sender {
    if (isNavigating) {
        [self stopNavigating];
        [navButton setHidden:NO];
    }
    if (isMainMenuShown) {
        [self mainMenuAnimation:YES];
    }else {
        [self mainMenuAnimation:NO];
    }
}

- (IBAction)newRoute:(id)sender {
    [self createRouteWithRouteInfo:nil];
}

- (IBAction)find:(id)sender {
    /*    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
     message:@"Not implemented yet"
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles: nil];
     [alert show];
     [alert release];
     [self mainMenuAnimation:YES];*/
    [self mainMenuAnimation:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTFindMenuViewController *fmvc = nil;
    if (IS_IPAD) {
        fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"FindMenuViewController_ipad"];
    }
    else{
       fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"FindMenuViewController"];
    }
    
    [fmvc setParentVC:self];
    [fmvc setIsNotificationOn:YES];
    [fmvc setPoiManager:poiManager];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:fmvc animated:NO completion:nil];
    }
    else
    {
        [self presentViewController:fmvc animated:YES completion:nil];
    }
}

- (IBAction)setup:(id)sender {
    
    [self mainMenuAnimation:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //    TTSettingsViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    TTSettingsViewController2 *svc =nil;// [storyBoard instantiateViewControllerWithIdentifier:@"SettingsViewController2"];
    if(IS_IPAD){
        svc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsViewController2_ipad"];
    }
    else{
        svc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsViewController2"];
    }
    [svc setParentVC:self];
    [self presentViewController:svc animated:YES completion:nil];
}

- (IBAction)help:(id)sender {
#ifdef DEBUG
    /*NSString *str = [NSString stringWithFormat:@"Build Number: %@\nUUID: %@\nBundle ID: %@", [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"], [TTUtilities getSerialNumberString], [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleIdentifier"]];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Build Info"
     message:str
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles: nil];
     [alert show];
     [alert release];
     [self mainMenuAnimation:YES];*/
#endif
    NSURL *url = [NSURL URLWithString:@"http://www.smarttruckroute.com/iPhone-FAQ.htm"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    /*    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
     TTHelpViewController *hvc = [storyBoard instantiateViewControllerWithIdentifier:@"HelpViewController"];
     [self presentViewController:hvc animated:YES completion:nil];*/
}

- (IBAction)rerouteManually:(id)sender {
    CLLocation *currentLocation = [locationManager location];
    //check gps signal
    if (nil == currentLocation) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service and also check your internet connection (turn Cellular Data on)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //hide nav button
    [navButton setHidden:YES];
    //clear route
    //[self clearRoute];
    //get current location
    //    CLLocation *currentLocation = [locationManager location];
    routeRequest.request_type = @"m";
    routeRequest.start_address = @"Current Location";
    routeRequest.start_location = currentLocation.coordinate;
    if (currentLocation.speed < 0) {
        routeRequest.speed = 0;
    }else {
        routeRequest.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
    }
    if (currentLocation.course < 0) {
        routeRequest.bearing = -1;
    }else {
        routeRequest.bearing = currentLocation.course;
    }
    
    //start waiting animation
    [self startWaiting];
    //submit
    server_url = SERVER_URL_MAIN;
    [self submitRerouteRequest];
}

- (IBAction)repeatInstruction:(id)sender {
    NSString *str = [[[NSString alloc]init]autorelease];
    
    //announce instuction info
    str = [str stringByAppendingString:[navInfo current_instruction]];
    
    if (navInfo.next_instruction) {
        str = [str stringByAppendingFormat:@" then %@ ", [navInfo next_instruction]];
    }
    
    [self read:str];
}

- (IBAction)routeDetails:(id)sender {
    //pause navigating
    [self stopNavigating];
    [navButton setHidden:NO];
    //call details view
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    TTRouteDetailsViewController *rdvc = [storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_landscape"];
//    if(UIDeviceOrientationIsLandscape(deviceOrientation))
//    {
        if (IS_IPAD) {
            rdvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_ipad_landscape"];
        }
//        else{
//            rdvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_landscape"];
//        }
//    }
    [rdvc setRouteAnalyzer:routeAnalyzer];//readonly
    [rdvc setIsNotificationOn:YES];
    [rdvc setParentVC:self];
    //[self presentViewController:rdvc animated:YES completion:nil];
    //UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    NSDictionary * nextStateCrossingInfo = [routeAnalyzer returnNextStateCrossingInfo];
    int distance = [nextStateCrossingInfo[@"distanceToNextStateCrossing"] intValue];
    NSString * distString =  [routeAnalyzer returnRoundedDistInMetersToText:distance metric:_isUnitMetric];
    NSString * nextStateCrossingText = nil;
    NSString *currentState = nextStateCrossingInfo[@"currentState"];
    NSString *nextState = nextStateCrossingInfo[@"nextState"];
    if ([currentState isEqualToString:nextState]) {
        nextStateCrossingText = [NSString stringWithFormat:@"Route stays within %@", nextStateCrossingInfo[@"currentState"]];
    } else {
        nextStateCrossingText = [NSString stringWithFormat:@"%@ Border in %@", [NSString stringWithFormat:@"%@-%@",nextStateCrossingInfo[@"currentState"], nextStateCrossingInfo[@"nextState"]], distString];
    }
    rdvc.stateBorderInfoText = nextStateCrossingText;

    
    
    // Indexpath of the current instruction, use this to scroll the table view of route details view controller to the current instruction.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:navInfo.idxTargetInstruction - 1 inSection:0];
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:rdvc animated:NO completion:nil];
    }
    else{
        [self presentViewController:rdvc animated:YES completion:nil];
    }
    [rdvc scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop];
  }


- (IBAction)pinchMapView:(id)sender {
    [self calculateZoom];
    [self updateInstructionAnnotations];
    //update poi results
    //    [self updatePOIResults];
}

- (IBAction)longpressMapView:(id)sender {
    UIGestureRecognizer *gesture = sender;
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    NSLog(@"long press");
    //get current location
    CGPoint touchLocation = [gesture locationInView:_mapView];
    coord_press = [_mapView convertPoint:touchLocation toCoordinateFromView:_mapView];
    NSString *str = [NSString stringWithFormat:@"Latitude: %.4f, Longitude: %.4f", coord_press.latitude, coord_press.longitude];
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]initWithTitle:str delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Route To the Location", @"Route From the Location", @"Add the Location Into History",@"Report feedback for this location",nil]autorelease];
    [actionSheet showInView:self.view];
    
    /*
     //save to user defaults
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     [userDefaults removeObjectForKey:@"route_request_start_address"];
     [userDefaults removeObjectForKey:@"route_request_start_latitude"];
     [userDefaults removeObjectForKey:@"route_request_start_longitude"];
     [userDefaults setObject:@"User Defined Location" forKey:@"route_request_start_address"];
     [userDefaults setDouble:start.latitude forKey:@"route_request_start_latitude"];
     [userDefaults setDouble:start.longitude forKey:@"route_request_start_longitude"];
     
     //call new route view with start location
     [self mainMenuAnimation:YES];
     UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
     TTNewRouteViewController *nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
     [nrvc setParentVC:self];
     [nrvc setIsUserDefinedStartLocation:YES];
     [self presentViewController:nrvc animated:YES completion:nil];*/
}

- (IBAction)rotateMapView:(id)sender {
#ifdef __IPHONE_7_0
    //    NSLog(@"ROTATEMAPVIEW gets called, camera heading: %f", camera.heading);
    UIRotationGestureRecognizer *gesture = (UIRotationGestureRecognizer *)sender;
    double radians = M_PI*2 - DEGREES_TO_RADIANS(_mapView.camera.heading);
    radians += gesture.rotation;
    [northUpButton setTransform:CGAffineTransformMakeRotation(radians)];
    //INS annotation views if any
    for (MKAnnotationView *insView in annotationviewsIns) {
        [insView setTransform:CGAffineTransformMakeRotation(radians)];
    }
#endif
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toRouteMenu"])
    {
        //        TTRouteMenuViewController *rmvc = [segue destinationViewController];
        //        [rmvc setMapViewController:self];
    }
}
#pragma mark - locationmanagerdelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //[self initMoveLocation];
    
    for (CLLocation *loc in locations) {
        // NSLog(@"++ lat: %f, lon: %f, time stamp: %@", loc.coordinate.latitude, loc.coordinate.longitude, loc.timestamp);
        NSDate *date=loc.timestamp;
        NSDateFormatter *frm=[[[NSDateFormatter alloc]init] autorelease];
        //[frm dateFromString:@"HH:mm:ss"];
        [frm setDateFormat:@"h:mm:ss"];
        // NSLog(@"Time : %@",[frm stringFromDate:date]);
        locUpdateTime.text=[frm stringFromDate:date];
    }
    // NSLog(@"~~ %d loc updated", locations.count);
#ifdef DEBUG
    static int update_count = 0;
    //[_labelZoom setText:[NSString stringWithFormat:@"%d", update_count++]];
#endif
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated");
    //    NSDate *date=newLocation.timestamp;
    //    NSDateFormatter *frm=[[NSDateFormatter alloc]init];
    //    [frm dateFromString:@"hh:mm:ss"];
    //    locUpdateTime.text=[frm stringFromDate:date];
}

#pragma mark MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (fabs(dZoomLevel - last_zoom_level)>.01) {
        last_zoom_level = dZoomLevel;
        if (!isAutoZoom || !isNavigating) {
            [self updatePOIResults];
        }
        [self updateInstructionAnnotations];
    }
#ifdef __IPHONE_7_0
    if (isNorthUp && mapView.camera.heading != 0) {
        isNorthUp = NO;
        //save settings
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"NorthUp"];
        [userDefault setBool:isNorthUp forKey:@"NorthUp"];
        [userDefault synchronize];
        [self updateNorthUpButton];
    }
    /*    if (!isNorthUp) {
     double radians = M_PI*2 - DEGREES_TO_RADIANS(camera.heading);
     [northUpButton setTransform:CGAffineTransformMakeRotation(radians)];
     //INS annotation views if any
     for (MKAnnotationView *insView in annotationviewsIns) {
     [insView setTransform:CGAffineTransformMakeRotation(radians)];
     }
     NSLog(@"REGIONDIDCHANGE, HEADING: %f", camera.heading);
     }*/
#endif
    
    //[self updateRouteView];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (!error==0) {
        UIAlertView *errorAlert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"An error as ocurred during the process of retrieving your location. Please Make sure that you have internet and that you have granted the app with authorization to get your location." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [errorAlert show];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKAnnotationView* annotationView = [mapView viewForAnnotation:userLocation];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
#ifdef __IPHONE_7_0
    [self calculateZoom];
    //[self make3DMapView:nil];
    if (!isNavigating && !isNorthUp) {
        double radians = M_PI*2 - DEGREES_TO_RADIANS(_mapView.camera.heading);
        [northUpButton setTransform:CGAffineTransformMakeRotation(radians)];
        //INS annotation views if any
        for (MKAnnotationView *insView in annotationviewsIns) {
            [insView setTransform:CGAffineTransformMakeRotation(radians)];
        }
    }
#else
    if (!isNavigating && !isNorthUp)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:WAITING_ANIMATION_HALF_PERIOD];
        
        double radians = M_PI*2 - DEGREES_TO_RADIANS(userLocation.heading.trueHeading);
        [northUpButton setTransform:CGAffineTransformMakeRotation(radians)];
        [annotationviewEnd setTransform:CGAffineTransformMakeRotation(-radians)];
        //poi annotation views if any
        for (MKAnnotationView *poiView in annotationviewsPOIs) {
            [poiView setTransform:CGAffineTransformMakeRotation(-radians)];
        }
        [UIView commitAnimations];
        //gas station views
        for (MKAnnotationView *view in annotationviewsGas) {
            [view setTransform:CGAffineTransformMakeRotation(-radians)];
        }
    }
#endif
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *str = [NSString stringWithFormat:@"%@, %@ \nLatitude: %.4f, Longitude: %.4f",view.annotation.title,view.annotation.subtitle,view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
    coord_press=view.annotation.coordinate;
    if ([view.annotation.title isEqualToString:@"Current Location"])
    {
        actionSheet2 = [[[UIActionSheet alloc]initWithTitle:str delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Route From the Location",@"Add the Location Into History",nil]autorelease];
        [actionSheet2 showInView:self.view];
    }
    else{
        actionSheet1 = [[[UIActionSheet alloc]initWithTitle:str delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Route To the Location", @"Route From the Location",nil]autorelease];
        [actionSheet1 showInView:self.view];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (view.annotation == historyAnnotaion)
        NSLog(@"Click On History AnnotationView");
    else
        NSLog(@"Click On Other AnnotationView");
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [kmlParser viewForOverlay:overlay];
}
// This code cause crash on display long route. and show double line when full zoom in
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
//{
//    return [kmlParser rendererForOverlay:overlay];
//    /*
//    MKPolygonRenderer *pg_renderer = [[MKPolygonRenderer alloc]initWithPolygon:overlay];
//    pg_renderer.strokeColor = [UIColor blueColor];
//    pg_renderer.lineWidth = .05;
//    pg_renderer.fillColor = [UIColor yellowColor];
//    return pg_renderer;
//    */
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(annotation == annotationNavCursor)
    {
        return [self viewForNavCursor];
    }
    else if(annotation == annotationEnd)
    {
        return [self viewForDestination];
    }
    else if(annotation == notificationAnnotaion)
    {
        if([annotation isKindOfClass:[MKUserLocation class]])
            return nil;
        static NSString *busStopViewIdentifier = @"notificationViewIdentifier";
        
        //the result of the call is being cast (MKPinAnnotationView *) to the correct
        //view class or else the compiler complains
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:busStopViewIdentifier];
        if(annotationView == nil)
        {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:busStopViewIdentifier] autorelease];
        }
        annotationView.image=[UIImage imageNamed:@"notification_icon2.png"];
        return annotationView;
    }
    else if (annotation == historyAnnotaion)
    {
        static NSString *busStopViewIdentifier = @"historyViewIdentifier";
        
        //the result of the call is being cast (MKPinAnnotationView *) to the correct
        //view class or else the compiler complains
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:busStopViewIdentifier];
        if(annotationView == nil)
        {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:busStopViewIdentifier] autorelease];
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
            annotationView.rightCalloutAccessoryView = rightButton;
        }
        annotationView.canShowCallout=YES;
        //annotationView.image=[UIImage imageNamed:@"location_icon.png"];
        return annotationView;
        
    }
    else {
        MKAnnotationView *result_view = [self viewForInstruction:annotation];
        if (result_view) {
            return result_view;
        }
        else
        {
            result_view = [self viewForPOI:annotation];
            if (!result_view) {
                result_view = [self viewForGasStation:annotation];
            }
        }
        //return nil;//it will display as default annotation if return nil here
        return result_view;
    }
}

-(MKAnnotationView *)viewForPOI:(id <MKAnnotation>)annotation
{
    for (int i=0; i<annotationsPOIs.count; i++)
    {
        if ([annotationsPOIs objectAtIndex:i] == annotation) {
            MKAnnotationView *view = [annotationviewsPOIs objectAtIndex:i];
            [view setTransform:CGAffineTransformMakeRotation(.001)];//iOS6 BUG workaround
            return view;
        }
    }
    return nil;
}
-(MKAnnotationView *)viewForGasStation:(id <MKAnnotation>)annotation
{
    for (int i=0; i<annotationsGas.count; i++) {
        if ([annotationsGas objectAtIndex:i] == annotation) {
            MKAnnotationView *view = [annotationviewsGas objectAtIndex:i];
            [view setTransform:CGAffineTransformMakeRotation(.001)];//iOS6 BUG workaround
            //            NSLog(@"viewforgasstation %d", i);
            return view;
        }
    }
    return nil;
}
-(MKAnnotationView *)viewForNavCursor
{
    //if (![_mapView dequeueReusableAnnotationViewWithIdentifier:@"NavCursor"])
    {
        MKAnnotationView *view = [[[MKAnnotationView alloc]initWithAnnotation:annotationNavCursor reuseIdentifier:@"NavCursor"] autorelease];
        
        UIImage *img =_imgNavCursor.image; //[UIImage imageNamed:@"tankeryellow.png"];
        /*UIGraphicsBeginImageContext(img.size);
         [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
         CGContextRef ctx = UIGraphicsGetCurrentContext();
         CGContextRotateCTM(ctx, DEGREES_TO_RADIANS(90));
         CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, img.size.width, img.size.height), img.CGImage);
         //[boddy drawInRect:CGRectMake(0, 0, size.width, size.height)];
         UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         MKAnnotationView *view = [[MKAnnotationView alloc]init];
         view.image = result;*/
        
        [view setImage:img];
        CGPoint point, anchorPoint;
        point.x = 24;
        point.y = -24;
        CGSize size = img.size;
        anchorPoint.x = .5 - point.x/size.width;
        anchorPoint.y = .5 - point.y/size.height;
        //[view.layer setAnchorPoint:anchorPoint];
        
        annotationviewNavCursor = view;
    }
    [annotationviewNavCursor setTransform:CGAffineTransformMakeRotation(.001)];//iOS6 BUG workaround
    return annotationviewNavCursor;
}
- (MKAnnotationView *)viewForDestination
{
    //if(!annotationviewEnd)
    if (![_mapView dequeueReusableAnnotationViewWithIdentifier:@"Destination"])
    {
        MKAnnotationView *view = [[MKAnnotationView alloc]initWithAnnotation:annotationEnd reuseIdentifier:@"Destination"];
        
        UIImage *img = [UIImage imageNamed:@"Flag.png"];
        /*UIGraphicsBeginImageContext(img.size);
         [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
         CGContextRef ctx = UIGraphicsGetCurrentContext();
         CGContextRotateCTM(ctx, DEGREES_TO_RADIANS(90));
         CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, img.size.width, img.size.height), img.CGImage);
         //[boddy drawInRect:CGRectMake(0, 0, size.width, size.height)];
         UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         MKAnnotationView *view = [[MKAnnotationView alloc]init];
         view.image = result;*/
        
        [view setImage:img];
        CGPoint point, anchorPoint;
        point.x = 24;
        point.y = -30;
        CGSize size = img.size;
        anchorPoint.x = .5 - point.x/size.width;
        anchorPoint.y = .5 - point.y/size.height;
        [view.layer setAnchorPoint:anchorPoint];
        
        annotationviewEnd = view;
    }
    [annotationviewEnd setTransform:CGAffineTransformMakeRotation(.001)];//iOS6 BUG workaround
    return annotationviewEnd;
}
- (MKAnnotationView *)viewForInstruction:(id <MKAnnotation>)annotation
{
    for (int i=0; i<annotationsIns.count; i++) {
        if ([annotationsIns objectAtIndex:i] == annotation) {
            MKAnnotationView *view = [annotationviewsIns objectAtIndex:i];
            [view setTransform:CGAffineTransformMakeRotation(.001)];//iOS6 BUG workaround
#ifdef __IPHONE_7_0
            double radians = M_PI*2 - DEGREES_TO_RADIANS(_mapView.camera.heading);
            //INS annotation views if any
            [view setTransform:CGAffineTransformMakeRotation(radians)];
#endif
            return view;
        }
    }
    return nil;
}


- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    NSLog(@"Map View Start Rendering Map View");
}
- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    NSLog(@"Map View FullyRendered Map View");
    // [self make3DMapView:nil];
}

#pragma mark navigating
-(void)loadKML
{
    //weightStationAlert=YES;
    //clear previous mapView
    NSArray *overlays_old = [kmlParser overlays];
    [_mapView removeOverlays:overlays_old];
    [_mapView removeAnnotations:annotationsIns];
    
    //init and parse latest kml file
    NSMutableData *kmlData = [[[NSMutableData alloc] init] autorelease];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [kmlData setData:[userDefault objectForKey:@"data"]];
    NSLog(@"Length : %d",[kmlData length]);
    if([kmlData length] > 0)
    {
        kmlParser = [[KMLParser alloc] initWithData:kmlData];
    }
    else
    {
        NSData *dta=[[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
        NSString *str = [[[NSString alloc] initWithData:dta encoding:NSUTF8StringEncoding]autorelease];
        if (str.length>0) {
            kmlParser = [[KMLParser alloc] initWithData:dta];
        }
        return;
    }
    
    [kmlParser parseKML];
    NSArray *overlays = [kmlParser overlays];//shapes
    NSArray *instructions = [kmlParser instructions];//instructions
    _speedLimitArray=[kmlParser getSpeedLimitData];
    //NSLog(@"Speed Limit Array : %i : %i",speedLimitData.count,[[overlays objectAtIndex:0] pointCount]);
    //    if(overlays.count==0)
    //    {
    //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"Overlays Array Empty" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Mail Responce For Support", nil];
    //        alert.tag=1111;
    //        [alert show];
    //        [alert release];
    //    }
    //    else{
    //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!!" message:@"Overlays Array is filled!!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    //        alert.tag=1111;
    //        [alert show];
    //        [alert release];
    //    }
    //    if(overlays.count==0)
    //    {
    //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!!" message:@"instructions Array Empty" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Mail Responce For Support", nil];
    //        alert.tag=1111;
    //        [alert show];
    //        [alert release];
    //    }
    
    //load into mapview
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    [_mapView addOverlays:overlays];
    //[_mapView setVisibleMapRect:]
    
    //_mapView.SetVisibleMapRect(overlays.BoundingMapRect, true);
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays) {
        if (MKMapRectIsNull(flyTo))
        {
            flyTo = [overlay boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
    }
    // Position the map so that all overlays and annotations are visible on screen.
    double ratio = 1.5;
    double deltaW = flyTo.size.width*(ratio - 1);
    double deltaH = flyTo.size.height*(ratio - 1);
    flyTo.origin.x -= deltaW/2;
    flyTo.origin.y -= deltaH/2;
    flyTo.size.width *= ratio;
    flyTo.size.height *= ratio;
    _mapView.visibleMapRect = flyTo;
    
    //load into route analyzer
    [routeAnalyzer initWithRouteRequest:routeRequest shapes:[overlays objectAtIndex:0] instructions:instructions];
    if (routeAnalyzer) {
        [self prepareInstructionAnnotations:routeAnalyzer.instructions];
        [self updateInstructionAnnotations];
    }
    
    //add destination annotation
    CLLocationCoordinate2D cordinat=[routeAnalyzer destinationCoordinate];
    NSString *str=[NSString stringWithFormat:@"%f,%f",cordinat.latitude,cordinat.longitude];
    [self getDestinationTimeZone:str];
    [annotationEnd setCoordinate:[routeAnalyzer destinationCoordinate]];
    [_mapView addAnnotation:(id<MKAnnotation>)annotationEnd];
    
    //set flag
    [self setNeedReload:NO];
    [self setIsNavigating:NO];
    //show reroute button
    [_btnReroute setHidden:NO];
    // [self calculateZoom];
    dZoomLevel=1.00;
    [self updateZoom];
    
    //    if (!_btnReroute.hidden) {
    //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!!" message:@"Reroute is shown" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        alert.tag=1111;
    //        [alert show];
    //        [alert release];
    //    }
    //test
    //    [self.fliteController say:@"route loaded, turn right on washington street." withVoice:@"cmu_us_slt"];
}

-(void)prepareInstructionAnnotations:(NSArray *)instructions
{
    MKPointAnnotation *cur_annotation = nil;
    MKAnnotationView *cur_annotationview = nil;
    TTRouteInstruction *cur_ins = nil;
    //clear
    [self clearInstructionAnnotations];
    
    for (int i=1; i<instructions.count - 2; i++) {//the first 2 and last 3 instructions are not in use
        cur_ins = [instructions objectAtIndex:i];
        cur_annotation = [[MKPointAnnotation alloc]init];
        cur_annotation.coordinate = cur_ins.coord;
        cur_annotation.title = cur_ins.info;
        [annotationsIns addObject:cur_annotation];
        CGSize size = CGSizeMake(50,50);//CGSizeMake(96,96);//CGSizeMake(48,48);
        UIImage *arrow = [UIImage imageNamed:@"Arrow1.png"];
        UIImage *boddy = [UIImage imageNamed:@"arrow2.png"];
        UIGraphicsBeginImageContext(size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, size.width/2, size.height/2);
        CGContextRotateCTM(ctx, M_PI + DEGREES_TO_RADIANS(cur_ins->nEdgeDegrees[1]));
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-size.width/2, -size.height/2, size.width, size.height), arrow.CGImage);
        CGContextRotateCTM(ctx, M_PI + DEGREES_TO_RADIANS(cur_ins->nEdgeDegrees[0] - cur_ins->nEdgeDegrees[1]));
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-size.width/2, -size.height/2, size.width, size.height), boddy.CGImage);
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cur_annotationview = [[MKAnnotationView alloc]initWithAnnotation:cur_annotation reuseIdentifier:nil] ;
        cur_annotationview.image = result;
        cur_annotationview.canShowCallout = YES;
        
        [annotationviewsIns addObject:cur_annotationview];
        
    }
    //add first
    /*    [self calculateZoom];
     if (dZoomLevel < ZOOM_THRESHOLD_FOR_TURNS)
     {
     [mapView addAnnotations:annotationsIns];
     isAnnotationAdded = YES;
     }else {
     isAnnotationAdded = NO;
     }*/
}
-(void)clearInstructionAnnotations
{
    for (MKPointAnnotation *cur_annotation in annotationsIns) {
        [cur_annotation release];
    }
    for (MKAnnotationView *cur_annotationview in annotationviewsIns) {
        [cur_annotationview release];
    }
    
    [annotationsIns removeAllObjects];
    [annotationviewsIns removeAllObjects];
}
-(void)setRouteRequest:(TTRouteRequest *)aRequest
{
    routeRequest = aRequest;
}
-(void)startNavigating
{
    isSpeedLimitAlert=NO;
    _imgNavCursor.alpha=0;
    if([routeAnalyzer hasRoute])
    {
        isSpeedZero=YES;
        //disable mapview tracking mode
        //        [mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
        if([CLLocationManager locationServicesEnabled])
        {
            [_mapView setShowsUserLocation:NO];
        }
        
        //start timer
        if([timer isValid])
        {
            [timer invalidate];
            timer = nil;
        }
        //[annotationEnd setCoordinate:[routeAnalyzer destinationCoordinate]];
        [_mapView addAnnotation:(id<MKAnnotation>)annotationNavCursor];
        timer = [NSTimer scheduledTimerWithTimeInterval:NAVIGATOR_INTERVAL target:self selector:@selector(doNavigating) userInfo:nil repeats:YES];
        
        if (![timer_state isValid]) {
            timer_state = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkStateChange) userInfo:nil repeats:YES];
        }
        //      timer = [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(doNavigating) userInfo:nil repeats:YES];
        
        //start location manager
        //        [locationManager startUpdatingLocation];
        [self setIsNavigating:YES];
        
        //show nav panel
        [self navPanelAnimation:NO];
        
        //add nav cursor
        [_imgNavCursor setHidden:NO];
        //[menuButton setHidden:YES];
        //        [mapView addAnnotation:(id <MKAnnotation>)navCursor];
        
        //zoom buttons
        if (isAutoZoom)
        {
            //hide
            [btnZoomIn setAlpha:0];
            [btnZoomOut setAlpha:0];
        }
        else
        {
            dZoomLevel=1.0;
            [self updateZoom];
            lastZoomLevel=0.0;
        }
        
        //goto current location without animation
        [_mapView setCenterCoordinate:[locationManager location].coordinate animated:NO];
        
        //zoom in mapview
        if (isAutoZoom)
        {
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            region.center = _mapView.region.center;
            span.latitudeDelta = .002;
            span.longitudeDelta = .002;
            region.span = span;
            [_mapView setRegion:region animated:NO];
        }
        NSLog(@"Navigating started...");
    }
    if (lastZoomLevel>0) {
        dZoomLevel=lastZoomLevel;
        [self updateZoom];
        lastZoomLevel=0.0;
    }
}
-(void)stopNavigating
{
    if ([speedAlertTimer isValid]) {
        [speedAlertTimer invalidate];
        speedAlertTimer=nil;
    }
    isSpeedLimitAlert=NO;
    _imgNavCursor.alpha=1.0;
    menuButton.hidden=NO;
    if([CLLocationManager locationServicesEnabled])
    {
        [_mapView setShowsUserLocation:YES];
    }
    //    [_mapView setShowsUserLocation:YES];
    //stop location manager
    //    [locationManager stopUpdatingLocation];
    
    //release timer
    if([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [self setIsNavigating:NO];
    
    NSLog(@"Navigating stopped...");
    
#ifdef __IPHONE_7_0
#else
    //rotate map back
    [_mapView setTransform:CGAffineTransformMakeRotation(0)];
    [annotationviewEnd setTransform:CGAffineTransformMakeRotation(0)];
    //poi annotation views if any
    for (MKAnnotationView *poiView in annotationviewsPOIs)
    {
        [poiView setTransform:CGAffineTransformMakeRotation(0)];
    }
    for (MKAnnotationView *view in annotationviewsGas)
    {
        [view setTransform:CGAffineTransformMakeRotation(0)];
    }
    [northUpButton setTransform:CGAffineTransformMakeRotation(0)];
#endif
    
    //go to current location
    //    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    //hide nav panel
    [self navPanelAnimation:YES];
    
    //zoom buttons
    [btnZoomIn setAlpha:1];
    [btnZoomOut setAlpha:1];
    
    //hide nav cursor
    [_imgNavCursor setHidden:YES];
    [_mapView removeAnnotation:(id <MKAnnotation>)annotationNavCursor];
    
    [self clearLaneAssist];
}
-(void)suspendNavigating
{
    if (isNavigating) {
        [timer invalidate];
        timer = nil;
    }
}
-(void)resumeNavigating
{
    if (isNavigating && ![timer isValid]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:NAVIGATOR_INTERVAL target:self selector:@selector(doNavigating) userInfo:nil repeats:YES];
    }
}
-(void)resetFlags
{
    nOffRouteCount = 0;
}
//settings
-(void)loadNavSettings
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    isNorthUp = [userDefault boolForKey:@"NorthUp"];
    isSimulating = [userDefault boolForKey:@"Simulating"];
    isAutoReroute = [userDefault boolForKey:@"AutoReroute"];
    isTravelAlerts = [userDefault boolForKey:@"TravelAlerts"];
    isWeighScaleAlerts=[userDefault boolForKey:@"WeighScaleAlerts"];
    isAutoZoom = [userDefault boolForKey:@"AutoZoom"];
    isShowBuildings=[userDefault boolForKey:@"ShowBuildings"];
    isPerspective=[userDefault boolForKey:@"Perspective"];
    _mapType = [userDefault integerForKey:@"MapType"];
    _isVoiceOn = [userDefault boolForKey:@"Voice"];
    _pitchValue =[userDefault floatForKey:@"pitchValue"];
    _rateValue = [userDefault floatForKey:@"rateValue"];
    _isUnitMetric = [userDefault boolForKey:@"Metric"];
    _is24Hour = [userDefault boolForKey:@"24Hour"];
    _isOdometerOn = [userDefault boolForKey:@"Odometer"];
    _isUserTips =[userDefault boolForKey:@"usertips"];
    _isSpeedWarning =[userDefault boolForKey:@"speedwarning"];
    //load panel settings
    [self setTripPanelAtIndex:1];
    [self setTripPanelAtIndex:2];
    [self setTripPanelAtIndex:3];
}
///////////////////////////////////////////////////////////////
-(void)doNavigating
{
    //  NSLog(@"Navigating...");
    timeValue++;
    _imgNavCursor.hidden=YES;
    CLLocation *location;
    
    //  [self print_free_memory];
    //  check if it is simulation
    if(isSimulating)
    {
        [navInfo setSpeed:travel_speed];
        location = [routeAnalyzer getNextSimulationLocation:travel_speed];
        //routeAnalyzer.instructions;
        //TTRouteInstruction *route_instruction=[[routeAnalyzer instructions] objectAtIndex:timeValue];
        //route_instruction.direction;
        // NSLog(@"Direction : %u",route_instruction.direction);
    }else {
        //get current location/heading
        location = [locationManager location];
        
    }
    /*if(isWeighScaleAlerts)
    {
        if (weightStationAlert)
        {
            [weightStation findWeightStationWithinMile:location];
        }
    }*/
    //analyse
    navInfo = [routeAnalyzer analyseWithLocation:location];
    
    if (navInfo)
    {
//      if (navInfo.idxTargetInstruction>3) {
//          navInfo.isOffRoute=YES;
//      }
//      update view
        [self updateView];
        
        //update nav panels based on navinfo
        [self updateNavPanel];
        //
        [self updateSpeedLimit];
        //debug
        [self updateLaneAssist];
        
        if (newFunction) {
            newFunction=NO;
            if ([self shouldReroute]) {
                
            }
            lastZoomLevel=dZoomLevel;
            //trigger reroute
            //clear route
            //[self clearRoute];
           
            //get current location
            CLLocation *currentLocation = [locationManager location];
            routeRequest.request_type = @"r";
            routeRequest.start_address = @"Current Location";
            routeRequest.start_location = currentLocation.coordinate;
            if (currentLocation.speed < 0) {
                routeRequest.speed = 0;
            }else{
                routeRequest.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
            }
            
            if (currentLocation.course < 0){
                routeRequest.bearing = -1;
            }else{
                routeRequest.bearing = currentLocation.course;
            }
            
            //start waiting animation
            [self startWaiting];
            //submit
            server_url = SERVER_URL_MAIN;
            [self submitRerouteRequest];
            
            //dZoomLevel=lastZoomLevel;
            
        }
        else
        {
            if (navInfo.isOffRoute)
            {
                if (isAutoReroute && [self shouldReroute] && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] !=NotReachable)
                {
                    lastZoomLevel=dZoomLevel;
                    //trigger reroute
                    //clear route
                    //[self clearRoute];
                    //get current location
                    [self stopNavigating];
                    CLLocation *currentLocation = [locationManager location];
                    routeRequest.request_type = @"r";
                    routeRequest.start_address = @"Current Location";
                    routeRequest.start_location = currentLocation.coordinate;
                    if (currentLocation.speed < 0) {
                        routeRequest.speed = 0;
                    }else{
                        routeRequest.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
                    }
                    if (currentLocation.course < 0){
                        routeRequest.bearing = -1;
                    }else{
                        routeRequest.bearing = currentLocation.course;
                    }
                    
                    //start waiting animation
                    [self startWaiting];
                    //submit
                    server_url = SERVER_URL_MAIN;
                    [self submitRerouteRequest];
                    
                    //dZoomLevel=lastZoomLevel;
                    return;
                }
                //
            }else {
                nOffRouteCount = 0;//clear
            }
        }
        //check announcement
        [self announce];
    }
}

-(void)updateSpeedLimit
{
    if (!_isSpeedWarning) {
        speedLimitView.hidden=YES;
        return;
    }
    int speedLMT=0;
    
    if (_speedLimitArray.count>navInfo.idxShape) {
        speedLMT=[[_speedLimitArray objectAtIndex:navInfo.idxShape] intValue];
    }
    
    if(speedLMT==0)
    {
        speedLimitView.hidden=YES;
        isSpeedLimitAlert=NO;
        speedLimitLbl.text=@"NON";
    }
    else if(speedLMT > 0)
    {
        speedLimitView.hidden=NO;
        if (speedLMT+5 <= navInfo.speed) {
            speedLimitBg.image=[UIImage imageNamed:@"speedlimit_o.png"];
            if (!isSpeedLimitAlert && speedLMT+8 <= navInfo.speed) {
                isSpeedLimitAlert=YES;
                [self read:@"speed limit exceeded"];
                speedAlertTimer=[NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(speedLimitAlertAgain:) userInfo:nil repeats:NO];
            }
        }
        else{
            if(speedAlertTimer)
            {
                [speedAlertTimer invalidate];
                speedAlertTimer=nil;
            }
            isSpeedLimitAlert=NO;
            speedLimitBg.image=[UIImage imageNamed:@"speedlimit.png"];
        }
        speedLimitLbl.text=[NSString stringWithFormat:@"%@",[_speedLimitArray objectAtIndex:navInfo.idxShape]];
    }
    else{
        speedLimitView.hidden=NO;
        speedLMT=abs([[_speedLimitArray objectAtIndex:navInfo.idxShape] intValue]);
        if (speedLMT < navInfo.speed)
        {
            speedLimitBg.image=[UIImage imageNamed:@"speedlimit_o.png"];
            if (!isSpeedLimitAlert)
            {
                isSpeedLimitAlert=YES;
                [self read:@"speed limit exceeded"];
                speedAlertTimer=[NSTimer scheduledTimerWithTimeInterval:50.0 target:self selector:@selector(speedLimitAlertAgain:) userInfo:nil repeats:NO];
            }
        }
        else
        {
            if(speedAlertTimer)
            {
                [speedAlertTimer invalidate];
                 speedAlertTimer=nil;
            }
            isSpeedLimitAlert=NO;
            speedLimitBg.image=[UIImage imageNamed:@"speedlimit.png"];
        }
        speedLimitLbl.text=[NSString stringWithFormat:@"%i",speedLMT];
    }
}

-(void)speedLimitAlertAgain:(id)sender
{
    isSpeedLimitAlert=NO;
    //[self read:@"speed limit exceeded"];
}

/*-(void)getWeightStationWithin7Miles:(TTPOI *)poi
{
    NSArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:@"warn_weigh_station"];
    NSMutableArray *mutArray=[NSMutableArray arrayWithArray:array];
    [mutArray addObject:[NSString stringWithFormat:@"%i",poi.identifier]];
    [[NSUserDefaults standardUserDefaults] setObject:mutArray forKey:@"warn_weigh_station"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //weightStationAlert=NO;
    [self playWarningSound];
    [self read:@"Weigh Station within 7 miles"];
    alertView=[[CustomIOS7AlertView alloc] init];
    [alertView show];
    alertView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin |
                                  UIViewAutoresizingFlexibleHeight |
                                  UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:alertView];
    //[NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
}*/

//-(void)dismissWithClickedButtonIndex:(NSTimer *)timer1
//{
//
//}

-(IBAction)clearRouteButtonClicked:(id)sender
{
    if([routeAnalyzer hasRoute])
    {
        UIAlertView *alertView1=[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure want to clear route?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alertView1.tag=110;
        [alertView1 show];
        
    }
    else{
        UIAlertView *alertView1=[[UIAlertView alloc] initWithTitle:@"" message:@"Use Clear Route to remove an existing route. Currently you have no route created." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView1 show];
        [alertView1 release];
    }
}

-(void)clearRoute
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"warn_weigh_station"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([CLLocationManager locationServicesEnabled])
    {
        [_mapView setShowsUserLocation:YES];
    }
    //[_mapView setShowsUserLocation:YES];
    //clear mapview annotations
    NSArray *overlays_old = [kmlParser overlays];
    [_mapView removeOverlays:overlays_old];
    //    NSArray *annotations_old = [kmlParser points];
    //    [mapView removeAnnotations:annotations_old];
    [_mapView removeAnnotations:annotationsIns];
    //clear destination view
    [_mapView removeAnnotation:annotationEnd];
    [_mapView removeAnnotation:annotationNavCursor];
    
    [self stopNavigating];
    
    //clear route in route analyzer
    [routeAnalyzer clearRoute];
    
    [self resetFlags];
    
    //hide reroute button
    [_btnReroute setHidden:YES];
    
    [self clearInstructionAnnotations];
    
    [self clearLaneAssist];
    
    [self clearNavPanel];
}

-(BOOL)shouldReroute
{
    if(++nOffRouteCount > REROUTE_THRESHOLD_OFFROUTE_COUNT && navInfo.speed > REROUTE_THRESHOLD_SPEED && navInfo.dist_to_destination > REROUTE_THRESHOLD_DISTANCE_TO_DESTINATION)
    {
        return YES;
    }else
        return NO;
}
-(void)submitRerouteRequest
{
    //submit reroute request
    
    //send http post here
    //        NSString *url = @"http://smarttruckroute.serveftp.com/truckroutes/request.php";
    //NSString *url = @"http://50.78.6.246/truckroutes/request.php";
    //    NSString *url = @"http://192.168.1.20/truckroutes/request.php";
    //    NSString *postString = @"userid=android_id&startLatitude=42357722&startLongitude=-71059501&endLatitude=40714554&endLongitude=-74007118&drivingOptions=8&avoidTollRoad=0&vehicleHeight=1350&vehicleLength=5300&vehicleWidth=850&vehicleWeight=8000000&hazmat=0&speed=0&bearing=-1&format=";
    //    NSString *postString = [NSString stringWithFormat:@"userid=%@&startLatitude=%d&startLongitude=%d&endLatitude=%d&endLongitude=%d&drivingOptions=%u&avoidTollRoad=%u&vehicleHeight=%u&vehicleLength=%u&vehicleWidth=%u&vehicleWeight=%u&hazmat=%u&speed=%u&bearing=%d&format=%@&requesttype=n&client=%@&os=i%i", routeRequest.user_id, (NSInteger)(routeRequest.start_location.latitude * 1000000), (NSInteger)(routeRequest.start_location.longitude * 1000000), (NSInteger)(routeRequest.end_location.latitude * 1000000), (NSInteger)(routeRequest.end_location.longitude * 1000000), routeRequest.route_type, routeRequest.avoid_toll_road?1:0, (NSInteger)(routeRequest.vehicle_height), (NSInteger)(routeRequest.vehicle_length), (NSInteger)(routeRequest.vehicle_width), routeRequest.vehicle_weight*100, routeRequest.hazmat, routeRequest.speed, routeRequest.bearing, routeRequest.format,[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"],[[[UIDevice currentDevice] systemVersion] intValue]];
    
    NSString *postString = [NSString stringWithFormat:@"userid=%@&startLatitude=%d&startLongitude=%d&endLatitude=%d&endLongitude=%d&drivingOptions=%u&avoidTollRoad=%u&vehicleHeight=%u&vehicleLength=%u&vehicleWidth=%u&vehicleWeight=%u&hazmat=%u&speed=%u&bearing=%d&requesttype=n&client=%@&os=i%i", routeRequest.user_id, (NSInteger)(routeRequest.start_location.latitude * 1000000), (NSInteger)(routeRequest.start_location.longitude * 1000000), (NSInteger)(routeRequest.end_location.latitude * 1000000), (NSInteger)(routeRequest.end_location.longitude * 1000000), routeRequest.route_type, routeRequest.avoid_toll_road?1:0, (NSInteger)(routeRequest.vehicle_height), (NSInteger)(routeRequest.vehicle_length), (NSInteger)(routeRequest.vehicle_width), routeRequest.vehicle_weight*100, routeRequest.hazmat, routeRequest.speed, routeRequest.bearing, [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"],[[[UIDevice currentDevice] systemVersion] intValue]];
    
    NSLog(@"%@", server_url);
    NSLog(@"Post Data :%@", postString);
    NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postVariables length]];
    NSURL *postURL = [NSURL URLWithString:server_url];
    [request setURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postVariables];
    
    //get
    NSURLConnection *connectionResponse = [[[NSURLConnection alloc] initWithRequest:request delegate:self]autorelease];
    if(connectionResponse){
        NSLog(@"Request submitted");
        responseData = [[NSMutableData alloc]init];
    }
    else{
        NSLog(@"Failed to submit request");
        [self stopWaiting];
        //unlock application
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    //  check speed and bearing for debug
    //  NSString *str = [NSString stringWithFormat:@"speed is %.1f mph.  heading is %d degree", routeRequest.speed/100.0, routeRequest.bearing];
    //  [self read:str];
}
#pragma mark announcement
-(void)announce//if necessary
{
    NSInteger nDistToNextTurn = [navInfo dist_to_next_turn];
    NSInteger nTimeToNextTurn = [navInfo time_to_next_turn];
    
    if(direction_end == [navInfo direction])
    {
        if(nDistToNextTurn < THRESHOLD_DISTANCE_TO_DESTINATION)
        {
            [self read:@"destination approached"];
            [self clearRoute];
        }
        else if(nTimeToNextTurn < THRESHOLD_TIME_ANNOUNCE)
        {
            if (![navInfo isAnnounced])
            {
                //NSString *string=[NSString stringWithFormat:@"Destination nearby, %@  remaining.",navInfo.text_distance_to_go];
                NSString *string=[NSString stringWithFormat:@"Destination in %@.",navInfo.text_distance_to_go];
                //[self read:@"near destination"];
                [self read:string];
                [navInfo setIsAnnounced:YES];
            }
        }
    }
    else
    {
        if(nTimeToNextTurn < THRESHOLD_TIME_WARN)
        {
            if (![navInfo isWarned])
            {
                [self playWarningSound];
                [navInfo setIsWarned:YES];
            }
        }
        if (![navInfo isAnnounced]) {
            if (nTimeToNextTurn < THRESHOLD_TIME_ANNOUNCE) {
                NSString *str = [[[NSString alloc]init]autorelease];
                if(![navInfo isWarned])
                    [self playRemindingSound];
                if (nDistToNextTurn > THRESHOLD_DISTANCE_OMIT_DIST_INFO) {
                    //annouce distance info
                    //str = [str stringByAppendingFormat:@"in %.1f miles, ", METERS_TO_MILES(nDistToNextTurn)];
                    str = [str stringByAppendingFormat:@"in %@ ", [routeAnalyzer convertDistToText:nDistToNextTurn forDisplay:NO metric:_isUnitMetric]];
                }
                //announce instuction info
                if((str!=nil && ![str isKindOfClass:[NSNull class]]) && ([navInfo current_instruction]!=nil && ![[navInfo current_instruction] isKindOfClass:[NSNull class]]))
                {
                    if ([navInfo current_instruction].length>0) {
                        str = [str stringByAppendingString:[navInfo current_instruction]];
                    }
                    
                }
                //announce next instruction if it is too close to current one
                if (navInfo.next_instruction && navInfo.dist_between_targetWP_and_nextWP < THRESHOLD_DIST_NEXT_TWO_INSTRUCTIONS)
                {
                    str = [str stringByAppendingFormat:@" then %@ ", [navInfo next_instruction]];
                }
                [self read:str];
                [navInfo setIsAnnounced:YES];
            }
            else if(nTimeToNextTurn < THRESHOLD_TIME_REMIND)
            {
                if (![navInfo isReminded]) {
                    [self playRemindingSound];
                    switch ([navInfo direction])
                    {
                        case direction_turn_left:
                            [self read:@"prepair to turn left"];
                            break;
                            
                        case direction_turn_right:
                            [self read:@"prepair to turn right"];
                            break;
                            
                        case direction_exit:
                        case direction_ramp:
                            if([navInfo turning_degrees] < 180)
                                [self read:@"prepair to take exit on the left"];
                            else {
                                [self read:@"prepair to take exit on the right"];
                            }
                            break;
                            
                        case direction_exit_left:
                            [self read:@"prepair to take exit on the left"];
                            break;
                            
                        case direction_exit_right:
                            [self read:@"prepair to take exit on the right"];
                            break;
                            
                        default:
                            break;
                    }
                    [navInfo setIsReminded:YES];
                }
            }
        }
    }
}
-(void)directionImgTap
{
    NSInteger nDistToNextTurn = [navInfo dist_to_next_turn];
    NSInteger nTimeToNextTurn = [navInfo time_to_next_turn];
    NSString *str = [[[NSString alloc]init]autorelease];
    if(![navInfo isWarned])
        [self playRemindingSound];
    if (nDistToNextTurn > THRESHOLD_DISTANCE_OMIT_DIST_INFO) {
        //annouce distance info
        //str = [str stringByAppendingFormat:@"in %.1f miles, ", METERS_TO_MILES(nDistToNextTurn)];
        str = [str stringByAppendingFormat:@"in %@ ", [routeAnalyzer convertDistToText:nDistToNextTurn forDisplay:NO metric:_isUnitMetric]];
    }
    //announce instuction info
    str = [str stringByAppendingString:[navInfo current_instruction]];
    //announce next instruction if it is too close to current one
    if (navInfo.next_instruction && navInfo.dist_between_targetWP_and_nextWP < THRESHOLD_DIST_NEXT_TWO_INSTRUCTIONS)
    {
        str = [str stringByAppendingFormat:@" then %@ ", [navInfo next_instruction]];
    }
    [self read:str];
}
-(void)playWarningSound
{
    // sleep(1);
    
    NSString *sound_file;
    if ((sound_file = [[NSBundle mainBundle] pathForResource:@"warn" ofType:@"wav"]))
    {
        NSURL *url = [[NSURL alloc] initFileURLWithPath:sound_file];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        audioPlayer.delegate = self;
        [url release];
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
    
    //    NSError *error;
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"warn" ofType:@"wav"];
    //    AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error] autorelease];
    //    player.numberOfLoops = 1;
    //    player.volume = 1.0;
    //    player.delegate = self;
    //    [player prepareToPlay];
    //
    //    if (player == nil)
    //		NSLog([error description]);
    //    else
    //		[player play];
    //  [player play];
    //  [player release];
}
-(void)playRemindingSound
{
    //sleep(1);
    
    NSString *sound_file;
    if ((sound_file = [[NSBundle mainBundle] pathForResource:@"announce" ofType:@"wav"]))
    {
        NSURL *url = [[NSURL alloc] initFileURLWithPath:sound_file];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        audioPlayer.delegate = self;
        [url release];
        
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"announce" ofType:@"wav"];
    //    AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL] autorelease];
    //    player.numberOfLoops = 1;
    //    player.volume = 1.0;
    //    player.delegate = self;
    //    [player prepareToPlay];
    //    [player play];
    //    [player release];
}
-(void)read:(NSString *)str
{

    if (!_isVoiceOn) {
        return;
    }
    //    if (self.synthesizer) {
    //        [self.synthesizer release];
    //    }
    NSLog(@"Old String : %@",str);
    NSString *new_str = [self checkAbbreviation:str];
    new_str=[new_str stringByReplacingOccurrencesOfString:@"/" withString:@"  "];
    //AVSpeechSynthesizer *synthesizer1 = nil;// = [[[AVSpeechSynthesizer alloc] init] autorelease];
    
    NSLog(@"New String : %@",new_str);
    if (self.synthesizer.speaking == NO)
    {
        
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        NSError *activationError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionDuckOthers error:&setCategoryError];
        [audioSession setActive:YES error:&activationError];
        
        
            //AVSpeechUtterance *utterance = [[[AVSpeechUtterance alloc] initWithString:new_str] autorelease];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:new_str];
        utterance.rate =_rateValue; //self.rateSlider.value; //AVSpeechUtteranceMinimumSpeechRate; //0.3;
        utterance.pitchMultiplier=_pitchValue; //self.pitchSlider.value;//1.5;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];

        [self.synthesizer speakUtterance:utterance];
        
    }
    
    //    AVSpeechUtterance *utterance1=[AVSpeechUtterance speechUtteranceWithString:new_str];
    //    NSLog(@"%@",str);
    //    NSString *new_str = [self checkAbbreviation:str];
    //    new_str=[new_str stringByReplacingOccurrencesOfString:@"/" withString:@"slash"];
    //
    //    self.fliteController.duration_stretch = 1.3; // Change the speed
    //	self.fliteController.target_mean = 1.4; // Change the pitch
    //	self.fliteController.target_stddev = 0.2; // Change the variance
    //    [self.fliteController say:new_str withVoice:@"cmu_us_slt"];//cmu_us_slt_arctic_hts,cmu_us_rms
    
    //debug
    //    new_str = [self  checkAbbreviation:@" us mt arpt st us-33 us blvd S Co bus expy mt SQ"];
    //    NSLog(@"%@", new_str);
}

- (void) audioInputDidBecomeAvailable
{
    NSLog(@"Stop Speeking ..........");
}
- (void) audioSessionInterruptionDidBegin // There was an interruption.
{
    NSLog(@"Stop Speeking ..........");
}
- (void) audioSessionInterruptionDidEnd // The interruption ended.
{
    NSLog(@"Stop Speeking ..........");
}
- (void) audioInputDidBecomeUnavailable // The input became unavailable.
{
    NSLog(@"Stop Speeking ..........");
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute // The audio route changed.
{
    NSLog(@"Stop Speeking ..........");
}



-(void)initAbbreviationDictionary
{
    /* put static dictionary here for now
     abb   ->  full
     n         north
     ne        north east
     e         east
     se        south east
     s         south
     sw        south west
     w         west
     nw        north west
     arpt      airport
     assn      association
     ave       avenue      //flite default
     bia       b i a
     blvd      boulevard
     brg       bridge
     bus       business
     cir       circle
     co        company
     ct        court
     ctr       center
     dr        drive
     expy      expressway
     fwy       freeway
     hwy       highway
     immclt    immaculate
     intl      international
     ln        lane
     mt        mount
     pky       parkway
     pkwy      parkway
     tpke      turnpike
     pl        place
     plz       plaza
     pt        point
     rd        road        //flite default
     rt        route
     rte       route
     skwy      skyway
     sq        square
     st        street      //flite default
     svc       service
     ter       terrace
     thwy      throughway
     trl       trail
     us        u s
     wp        waypoint
     */
    abbDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@" north ",@" N ",@" northeast ",@" NE ",@" east ",@" E ",@" southeast ",@" SE ",@" south ",@" S ",@" southwest ",@" SW ",@" west ",@" w ",@" northwest ",@" NW ",@" airport ",@" arpt ",@" association ",@" assn ",@" b i a ",@" bia ",@" boulevard ",@" blvd ",@" bridge ",@" brg ",@" business ",@" bus ",@" circle ",@" cir ",@" company ",@" co ",@" court ",@" ct ",@" center ",@" ctr ",@" drive ",@" Dr.",@" drive ",@" Dr ",@" drive ",@" Dr. ",@" drive ",@" dr ",@" expressway ",@" expy ",@" freeway ",@" fwy ",@" highway ",@" hwy ",@"immaculate",@" immclt ",@" international ",@" intl ",@" lane ",@" ln ",@" mount ",@" mt ",@" parkway ",@" pky ",@" parkway ",@" pkwy ",@" turnpike ",@" tpke ",@" place ",@" pl ",@" plaza ",@" plz ",@" point ",@" pt ",@" road ",@" Rd ",@" route ",@" rt ",@" route ",@" rt-",@" route ",@" rte ",@" skyway ",@" skwy ",@" square ",@" sq ",@" service ",@" svc ",@" terrace ",@" ter ",@" throughway ",@" thwy ",@" trail ",@" trl ",@" u-s ",@" us ",@" u-s-route ",@" us-",@" waypoint ",@" wp ",@" and ",@" & ",@" Avenue ",@" av ",@" Avenue ",@" ave ",@" avenue ",@" Ave",@"Connecticut Route 5",@"CT-5",@" first ",@" 1st ",@" second ",@" 2nd ",@" third ",@" 3rd ",@" fourth ",@" 4th ",@" fifth ",@" 5th ",@" sixth ",@" 6th ",@" seventh ",@" 7th ",@" eighth ",@" 8th ",@" ninth ",@" 9th ",@"Turnpike",@"Tpke",@"Turnpike",@"tpk",nil];//av=avenue and ave=avenue
    // Turnpike (Tpke also Tpk)
}

-(NSString *)checkAbbreviation:(NSString *)str
{
    NSLog(@"Old Sring : %@",str);
    NSString *new_str = [NSString stringWithFormat:@"%@ ", str];
    NSRange range;
    range.location = 0;
    NSEnumerator *enumerator = [abbDictionary keyEnumerator];
    for (id key in enumerator) {
        range.length = [new_str length];
        new_str = [new_str stringByReplacingOccurrencesOfString:key withString:[abbDictionary objectForKey:key] options:NSCaseInsensitiveSearch range:range];
        NSLog(@"New Sring : %@ , Key : %@",new_str,key);
    }
    NSLog(@"New Sring : %@",new_str);
    return new_str;
}

#pragma mark lane assist
-(void)updateLaneAssist
{
    if (navInfo.lane_info_isChanged) {
        if (laneassistView) {
            //hide current lane assist then release it
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.5];
            instructionDiscloserView.hidden=NO;
            [laneassistView setAlpha:0];
            [UIView commitAnimations];
            [laneassistView release];
            laneassistView = nil;
        }
        if (navInfo.isAnnounced) {
            navInfo.lane_info_isChanged = NO;
            //make and display lane assist
            NSLog(@"lane: %d, %d, %d", navInfo.lane_info_total, navInfo.lane_info_start, navInfo.lane_info_end);
            //fast check
            BOOL bLeft = NO, bRight = NO, bCenter = NO;
            if (navInfo.lane_info_start == 1) {
                bLeft = YES;
            }
            if (navInfo.lane_info_end == navInfo.lane_info_total) {
                bRight = YES;
            }
            if (bLeft && bRight) {
                //something wrong, ignore
                return;
            }else if (!bLeft && !bRight){
                bCenter = YES;
            }
            int x = ([UIScreen mainScreen].bounds.size.width - navInfo.lane_info_total*50)/2;
            int width = navInfo.lane_info_total*50;
            if (width>0) {
                
                width+=20;
                CGRect rect=instructionDiscloserView.frame;
                CGRect rect1=instructionDiscloserSubView.frame;
                if (rect.size.height>50) {
                    rect.size.height-=rect1.size.height;
                    instructionDescloserBtn.selected=YES;
                    
                    //rect.origin.y+=106;
                }
                instructionDiscloserView.frame=rect;
                instructionDiscloserView.hidden=YES;
            }
            else{
                instructionDiscloserView.hidden=NO;
            }
            UIImage *img = nil;
            CGRect frame = CGRectMake(x,routeDetailView.frame.origin.y+ routeDetailView.frame.size.height+5, width, 60);
            if (IS_IPAD) {
                x = ([UIScreen mainScreen].bounds.size.width - navInfo.lane_info_total*80)/2;
                width = navInfo.lane_info_total*80;
                frame = CGRectMake(x,routeDetailView.frame.origin.y+ routeDetailView.frame.size.height+5, width, 90);
            }
            laneassistView = [[UIView alloc] initWithFrame:frame];
            laneassistView.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
            UIImageView *bgView=[[UIImageView alloc] initWithFrame:laneassistView.bounds];
            bgView.backgroundColor=[UIColor colorWithRed:3.0/255.0 green:176.0/255 blue:31.0/255 alpha:1.0];
            bgView.alpha=0.6;
            [laneassistView addSubview:bgView];
            [bgView release];
            laneassistView.clipsToBounds=YES;
            laneassistView.layer.cornerRadius=7;
            
            for (int i=1; i<=navInfo.lane_info_total; i++) {
                frame = CGRectMake(((i-1)*50)+10, 5, 50, 50);
                if (IS_IPAD) {frame = CGRectMake(((i-1)*80)+10, 5, 80, 80);}
                
                if (i<navInfo.lane_info_start) {
                    if (bCenter) {
                        //gray left turn arrow
                        img = [UIImage imageNamed:@"lane_assist_left_no.png"];
                    }else {
                        //gray continue arrow
                        img = [UIImage imageNamed:@"lane_assist_continue_no.png"];
                    }
                }else if (i >= navInfo.lane_info_start && i <= navInfo.lane_info_end) {
                    if (bLeft) {
                        //white left turn arrow
                        img = [UIImage imageNamed:@"lane_assist_left_yes.png"];
                    }else if (bCenter) {
                        //white continue arrow
                        img = [UIImage imageNamed:@"lane_assist_continue_yes.png"];
                    }else {
                        //white right turn arrow
                        img = [UIImage imageNamed:@"lane_assist_right_yes.png"];
                    }
                }else {
                    if (bLeft) {
                        //grey continue arrow
                        img = [UIImage imageNamed:@"lane_assist_continue_no.png"];
                    }else {
                        //grey right turn arrow
                        img = [UIImage imageNamed:@"lane_assist_right_no.png"];
                    }
                }
                UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
                [imgView setFrame:frame];
                [laneassistView addSubview:imgView];
                [imgView release];
            }
            [laneassistView setAlpha:1.0];
            [self.view addSubview:laneassistView];
        }
    }
    /*    if (navInfo.lane_info_isChanged) {
     if (0 == navInfo.lane_info_total) {
     //hide lane assist
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:.5];
     [laneassistView setAlpha:0];
     [UIView commitAnimations];
     [laneassistView release];
     laneassistView = nil;
     }else{
     //release current view
     if (laneassistView) {
     [laneassistView setHidden:YES];
     [laneassistView release];
     laneassistView = nil;
     }
     //make and display lane assist
     NSLog(@"lane: %d, %d, %d", navInfo.lane_info_total, navInfo.lane_info_start, navInfo.lane_info_end);
     //fast check
     BOOL bLeft = NO, bRight = NO, bCenter = NO;
     if (navInfo.lane_info_start == 1) {
     bLeft = YES;
     }
     if (navInfo.lane_info_end == navInfo.lane_info_total) {
     bRight = YES;
     }
     if (bLeft && bRight) {
     //something wrong, ignore
     return;
     }else if (!bLeft && !bRight){
     bCenter = YES;
     }
     int x = (320 - navInfo.lane_info_total*50)/2;
     int width = navInfo.lane_info_total*50;
     UIImage *img = nil;
     CGRect frame = CGRectMake(x, 80, width, 50);
     laneassistView = [[UIView alloc] initWithFrame:frame];
     for (int i=1; i<=navInfo.lane_info_total; i++) {
     frame = CGRectMake((i-1)*50, 0, 50, 50);
     if (i<navInfo.lane_info_start) {
     if (bCenter) {
     //gray left turn arrow
     img = [UIImage imageNamed:@"lane_assist_left_no.png"];
     }else {
     //gray continue arrow
     img = [UIImage imageNamed:@"lane_assist_continue_no.png"];
     }
     }else if (i >= navInfo.lane_info_start && i <= navInfo.lane_info_end) {
     if (bLeft) {
     //white left turn arrow
     img = [UIImage imageNamed:@"lane_assist_left_yes.png"];
     }else if (bCenter) {
     //white continue arrow
     img = [UIImage imageNamed:@"lane_assist_continue_yes.png"];
     }else {
     //white right turn arrow
     img = [UIImage imageNamed:@"lane_assist_right_yes.png"];
     }
     }else {
     if (bLeft) {
     //grey continue arrow
     img = [UIImage imageNamed:@"lane_assist_continue_no.png"];
     }else {
     //grey right turn arrow
     img = [UIImage imageNamed:@"lane_assist_right_no.png"];
     }
     }
     UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
     [imgView setFrame:frame];
     [laneassistView addSubview:imgView];
     [imgView release];
     }
     [laneassistView setAlpha:.8];
     [self.view addSubview:laneassistView];
     }
     }
     */
}
-(void)clearLaneAssist
{
    if (laneassistView) {
        //hide current lane assist then release it
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [laneassistView setAlpha:0];
        [UIView commitAnimations];
        [laneassistView release];
        laneassistView = nil;
    }
}
#pragma mark update nav panel

-(NSString *)getDirectionImage:(enum DIRECTION)direction1
{
    NSString *name = nil;
    switch (direction1) {
        case direction_start:
        case direction_start_head:
        case direction_start_from:
            name = @"direction_start.png";
            break;
            
        case direction_turn_left:
        case direction_turn_left_only:
        case direction_turn_left_towards:
            name = @"direction_turnleft.png";
            break;
            
        case direction_bear_left:
        case direction_bear_left_only:
        case direction_bear_left_towards:
            name = @"direction_bearleft.png";
            break;
            
        case direction_turn_right:
        case direction_turn_right_only:
        case direction_turn_right_towards:
            name = @"direction_turnright.png";
            break;
            
        case direction_bear_right:
        case direction_bear_right_only:
        case direction_bear_right_towards:
            name = @"direction_bearright.png";
            break;
            
        case direction_exit:
        case direction_exit_only:
        case direction_ramp:
        case direction_ramp_only:
        case direction_ramp_left:
        case direction_ramp_right:
        case direction_rotary:
            name = @"direction_exit.png";//will work on this later
            break;
            
        case direction_exit_left:
            name = @"direction_exitleft.png";
            break;
            
        case direction_exit_right:
            name = @"direction_exitright.png";
            break;
            
        case direction_merge:
            name = @"direction_merge.png";
            break;
            
        case direction_merge_to_left:
            name = @"direction_mergeright.png";
            break;
            
        case direction_merge_to_right:
            name = @"direction_mergeleft.png";
            break;
            
        case direction_continue:
            name = @"direction_continue.png";
            break;
            
        case direction_u_turn_left:
            name = @"direction_uturnleft.png";
            break;
            
        case direction_u_turn_right:
            name = @"direction_uturnright.png";
            break;
            
        case direction_end:
            name = @"direction_destination.png";
            break;
            
        default:
            break;
    }
    return name;
}

-(IBAction)instructionDescloserButtonClick:(id)sender
{
    CGRect rect=instructionDiscloserView.frame;
    CGRect rect1=instructionDiscloserSubView.frame;
    if (rect.size.height>50) {
        rect.size.height-=rect1.size.height;
        instructionDescloserBtn.selected=YES;
        //rect.origin.y+=106;
    }
    else{
        rect.size.height+=rect1.size.height;
        instructionDescloserBtn.selected=NO;
        //rect.origin.y-=106;
    }
    instructionDiscloserView.frame=rect;
}

-(void)updateNavPanel
{
    if (isPanelHidden){
        return;
    }
    NSArray *instructions = [routeAnalyzer instructions];
    //NSLog(@"Instructions ")
    if (instructions.count-1>navInfo.idxTargetInstruction+1) {
        TTRouteInstruction *next_one_instruction = [instructions objectAtIndex:navInfo.idxTargetInstruction + 1];
        firstDirectionImage.image=[UIImage imageNamed:[self getDirectionImage:next_one_instruction.direction]];
        if (next_one_instruction.targetName.length==0) {
            firstInstructionLbl.text=next_one_instruction.info;
            NSLog(@"First Instruction : %@",next_one_instruction.info);
        }
        else{
            firstInstructionLbl.text=next_one_instruction.targetName;
        }
        //firstInstructionLbl.text=next_one_instruction.targetName;//next_one_instruction.info;
        if (IS_IPAD) {
            firstInstructionLbl.text=next_one_instruction.info;
        }
        firstSubInstructionLbl.text=next_one_instruction.distanceInfo;
    }
    else{
        instructionDiscloserView.hidden=YES;
        firstDirectionImage.image=nil;
        firstInstructionLbl.text=@"";
        firstSubInstructionLbl.text=@"";
    }
    if (instructions.count-1>navInfo.idxTargetInstruction+2) {
        TTRouteInstruction *next_two_instruction = [instructions objectAtIndex:navInfo.idxTargetInstruction + 2];
        secondDirectionImage.image=[UIImage imageNamed:[self getDirectionImage:next_two_instruction.direction]];
        if (next_two_instruction.targetName.length==0) {
            secondInstructionLbl.text=next_two_instruction.info;
        }
        else{
            secondInstructionLbl.text=next_two_instruction.targetName;
        }
        //secondInstructionLbl.text=next_two_instruction.targetName;//next_two_instruction.info;
        if (IS_IPAD) {
            secondInstructionLbl.text=next_two_instruction.info;
        }
        secondSubInstructionLbl.text=next_two_instruction.distanceInfo;
    }
    else{
        secondInstructionLbl.text=@"";
        secondSubInstructionLbl.text=@"";
        secondDirectionImage.image=nil;
    }
    
    //graph panel
    NSString *name=[self getDirectionImage:navInfo.direction];
    UIImage *img = [UIImage imageNamed:name];
    [directionImg setImage:img];
    //dist to next instruction
    [labelGraph setText:navInfo.text_dist_to_next_turn];
    
    //instruction panel
    [labelInstruction setText:navInfo.current_instruction];
    //[labelInstruction adjustsFontSizeToFitWidthAndHeight];
    
    //trip info panels
    [self updateTripInfoPanelAtIndex:1];
    [self updateTripInfoPanelAtIndex:2];
    [self updateTripInfoPanelAtIndex:3];
    //    [labelTripInfo1 setText:[NSString stringWithFormat:@"%d", tripInfo_panel1]];
    //    [labelTripInfo2 setText:[NSString stringWithFormat:@"%d", tripInfo_panel2]];
}
-(void)navPanelAnimation:(BOOL)isHiding
{
    //check if necessary to do the action
    if ((isPanelHidden && isHiding) || (!isPanelHidden && !isHiding)) {
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect instructionViewFrame=instructionDiscloserView.frame;
    CGRect rect1=instructionDiscloserSubView.frame;
    CGRect directionViewFrame=[directionInfoView frame];
    CGRect routeDetailViewFrame=[routeDetailView frame];
    CGRect speedLimitFrame = [speedLimitView frame];
    CGRect infoViewFrame;
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        infoViewFrame=navInfoViewForiPhone.frame;
        navInfoViewForiPad.hidden=YES;
    } else {
        infoViewFrame=navInfoViewForiPad.frame;
        navInfoViewForiPhone.hidden=YES;
    }
    
    if (isHiding){
        [self setIsPanelHidden:YES];
        instructionViewFrame.origin.y+=1000;
        if (instructionViewFrame.size.height>50) {
            //instructionViewFrame.origin.y+=106;
        }
        instructionViewFrame.size.height=37;
        instructionDescloserBtn.selected=YES;
        
        directionViewFrame.origin.x-=200;
        routeDetailViewFrame.origin.x+=1024;
        speedLimitFrame.origin.x-=200;
        infoViewFrame.origin.y+=1100;

        [speedMinButton setAlpha:0];
        [speedPlusButton setAlpha:0];
    }
    else{
        [self setIsPanelHidden:NO];
        instructionViewFrame.origin.y-=1000;
        directionViewFrame.origin.x+=200;
        routeDetailViewFrame.origin.x-=1024;
        speedLimitFrame.origin.x+=200;
        infoViewFrame.origin.y-=1100;
        
        if (isSimulating){
            [speedMinButton setAlpha:1];
            [speedPlusButton setAlpha:1];
        }
    }
    [instructionDiscloserView setFrame:instructionViewFrame];
    [directionInfoView setFrame:directionViewFrame];
    [routeDetailView setFrame:routeDetailViewFrame];
    [speedLimitView setFrame:speedLimitFrame];
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        navInfoViewForiPhone.frame=infoViewFrame;
    } else {
        navInfoViewForiPad.frame=infoViewFrame;
    }
 
    [UIView commitAnimations];
}
-(void)setTripPanelAtIndex:(int)index
{
    //panel index is 1-based, my bad!
    //load from userdefault
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger value=[userDefaults integerForKey:@"trip_info_panel1"];
        switch (index) {
            case 1:
                
                [self setTripInfo_panel1:(int)value];
                //            NSLog(@"panel1: %d", [userDefaults integerForKey:@"trip_info_panel1"]);
                break;
                
            case 2:
                [self setTripInfo_panel2:(int)[userDefaults integerForKey:@"trip_info_panel2"]];
                //            NSLog(@"panel2: %d", [userDefaults integerForKey:@"trip_info_panel2"]);
                break;
                
            default:
                return;
        }
    }
    else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger value=[userDefaults integerForKey:@"trip_info_panel1"];
        switch (index) {
            case 1:
                
                [self setTripInfo_panel1:(int)value];
                //            NSLog(@"panel1: %d", [userDefaults integerForKey:@"trip_info_panel1"]);
                break;
                
            case 2:
                [self setTripInfo_panel2:(int)[userDefaults integerForKey:@"trip_info_panel2"]];
                //            NSLog(@"panel2: %d", [userDefaults integerForKey:@"trip_info_panel2"]);
                break;
            case 3:
                [self setTripInfo_panel3:(int)[userDefaults integerForKey:@"trip_info_panel3"]];
            default:
                return;
        }
        
    }
}
-(void)labelTap:(id)sender
{
    UILabel *lbl=(UILabel *)sender;
    if ([lbl.text isEqualToString:@""]) {
        UIAlertView *alertView1=[[UIAlertView alloc] initWithTitle:@"Notice" message:@"Estimated Time of Arrival (ETA) is dipslayed in local time. A yellow triangle indicates that there is a time zone change." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView1 show];
        [alertView1 release];
    }
}
-(void)updateTripInfoPanelAtIndex:(int)index
{
    enum TT_TRIP_INFO_TYPE type;
    
    UILabel *destMain, *destTitle = nil, *destFoot;
    destTitle.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
    [destTitle addGestureRecognizer:tapGesture];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        switch (index)
        {
            case 1:
                destMain = labelTripInfo1_iphone;
                destTitle = labelTripTitle1_iphone;
                destFoot = labelTripFoot1_iphone;
                type = [self tripInfo_panel1];
                break;
                
            case 2:
                destMain = labelTripInfo2_iphone;
                destTitle = labelTripTitle2_iphone;
                destFoot = labelTripFoot2_iphone;
                type = [self tripInfo_panel2];
                break;
                
            default:
                return;
        }
    }
    else{
        switch (index)
        {
            case 1:
                destMain = labelTripInfo1;
                destTitle = labelTripTitle1;
                destFoot = labelTripFoot1;
                type = [self tripInfo_panel1];
                break;
                
            case 2:
                destMain = labelTripInfo2;
                destTitle = labelTripTitle2;
                destFoot = labelTripFoot2;
                type = [self tripInfo_panel2];
                break;
            case 3:
                destMain = labelTripInfo3;
                destTitle = labelTripTitle3;
                destFoot = labelTripFoot3;
                type = [self tripInfo_panel3];
                break;
                
            default:
                return;
        }
        
    }
    
    NSString *str = nil, *strTitle = nil, *strFoot = nil;
    NSArray *str_array = nil;
    switch (type) {
            //    odometer1,
            //    odometer2,
            //    time_sunrise,
            //    time_sunset,
            //    street_current,
            
        case estimated_time_arrival://eta
            if ([destinationTimeZone isEqualToString:[[NSTimeZone localTimeZone] name]]) {
                strTitle = @"ETA";
                str_array = [navInfo.text_time_arrivel componentsSeparatedByString:@" "];
                str = [str_array objectAtIndex:0];
                if (str_array.count > 1) {
                    strFoot = [str_array objectAtIndex:1];
                }
            }
            else{
                strTitle = @"ETA ⚠";
                NSLog(@"Time Arrivel : %@",navInfo.text_time_arrivel);
                NSString *timeString=[self timeWithDastinationTimeZone:navInfo.text_time_arrivel];
                str_array = [timeString componentsSeparatedByString:@" "];
                str = [str_array objectAtIndex:0];
                if (str_array.count > 1) {
                    strFoot = [str_array objectAtIndex:1];
                }
            }
            
            break;
            
        case distance_to_go://dtg
            strTitle = @"DTG";
            str_array = [navInfo.text_distance_to_go componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            break;
            
        case heading:
            strTitle = @"HEADING";
            str_array = [navInfo.heading_string componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            break;
            
        case speed:
            strTitle = @"SPEED";
            str_array = [navInfo.text_speed componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            else{
                strFoot = [str_array lastObject];
            }
            break;
            
        case time_current:
            strTitle = @"TIME";
            str_array = [navInfo.text_time_current componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            break;
            
        case time_to_destination:
            strTitle = @"TTD";
            str_array = [navInfo.text_timer_to_destination componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            if (str_array.count==4) {
                str=[NSString stringWithFormat:@"%@:%@",str,[str_array objectAtIndex:2]];
                strFoot=[NSString stringWithFormat:@"%@:%@",strFoot,[str_array objectAtIndex:3]];
            }
            else{
                str=[NSString stringWithFormat:@"%@:00",str];
                strFoot=[NSString stringWithFormat:@"%@:min",strFoot];
            }
            
            
            break;
            
        case time_to_next_turn:
            strTitle = @"NEXT TURN";
            str_array = [navInfo.text_timer_to_next_turn componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            break;
            
        case altitude:
            strTitle = @"ALTITUDE";
            str_array = [navInfo.text_altitude componentsSeparatedByString:@" "];
            str = [str_array objectAtIndex:0];
            if (str_array.count > 1) {
                strFoot = [str_array objectAtIndex:1];
            }
            break;
            
        default:
            return;
    };
    
    [destMain setText:str];
    [destTitle setText:strTitle];
    [destFoot setText:strFoot];
}
-(void)clearNavPanel
{
    [labelTripInfo1 setText:@""];
    [labelTripTitle1 setText:@""];
    [labelTripFoot1 setText:@""];
    [labelTripInfo2 setText:@""];
    [labelTripTitle2 setText:@""];
    [labelTripFoot2 setText:@""];
    [directionImg setImage:nil];
    [labelInstruction setText:@""];
    [labelGraph setText:@""];
}

#pragma mark main menu
-(void)mainMenuAnimation:(BOOL)isHiding
{
    //check
    if ((isMainMenuShown && !isHiding) || (!isMainMenuShown && isHiding)) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    
    if (isHiding) {
        [imgCover setHidden:YES];
        [imgMainMenuPanel setAlpha:0];
        [viewMainMenuPanel setAlpha:0];
        [btnNewRoute setAlpha:0];
        [btnFind setAlpha:0];
        [btnHelp setAlpha:0];
        [btnClearRoute setAlpha:0];
        [btnSettings setAlpha:0];
        [btnZoomIn setAlpha:1];
        [btnZoomOut setAlpha:1];
        [self setIsMainMenuShown:NO];
    }else {
        if([routeAnalyzer hasRoute])
        {
            [btnClearRoute setBackgroundImage:[UIImage imageNamed:@"n_clearRoute_btn.png"] forState:UIControlStateNormal];
        }
        else{
            [btnClearRoute setBackgroundImage:[UIImage imageNamed:@"n_clear_grayout_btn.png"] forState:UIControlStateNormal];
        }
        [imgCover setHidden:NO];
        [imgMainMenuPanel setAlpha:1];
        [viewMainMenuPanel setAlpha:1];
        [btnNewRoute setAlpha:1];
        [btnFind setAlpha:1];
        [btnHelp setAlpha:1];
        [btnClearRoute setAlpha:1];
        [btnSettings setAlpha:1];
        [btnZoomIn setAlpha:0];
        [btnZoomOut setAlpha:0];
        [self setIsMainMenuShown:YES];
    }
    [UIView commitAnimations];
}

//waiting animation
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
    //lock application
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [spinner startAnimating];
    [imgCover setHidden:NO];
    /*  [imgCover setHidden:NO];
     [_imgWaiting setHidden:NO];
     _imgWaiting.animationDuration = 1;//total time for one animation
     _imgWaiting.animationRepeatCount = 0;
     [_imgWaiting startAnimating];*/
}
-(void)stopWaiting
{
    //unlock application
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [spinner stopAnimating];
    [imgCover setHidden:YES];
    /*  [imgCover setHidden:YES];
     [_imgWaiting stopAnimating];
     [_imgWaiting setHidden:YES];*/
}
/*-(void)doWaitingAnimationForRoute
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
 [_imgWaiting setTransform:CGAffineTransformMakeRotation(radians)];
 [UIView commitAnimations];
 }*/
//buttons
-(void)updateNorthUpButton
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:WAITING_ANIMATION_HALF_PERIOD];
    
    UIImage *img = nil;
    if (!isNorthUp) {
        //set it to non-northup
        img = [UIImage imageNamed:@"NorthUp_Disabled.png"];
        [_imgNavCursor setTransform:CGAffineTransformMakeRotation(0)];
    }
    else {
        img = [UIImage imageNamed:@"NorthUp.png"];
        [_mapView setTransform:CGAffineTransformMakeRotation(0)];
        [annotationviewEnd setTransform:CGAffineTransformMakeRotation(0)];
        //poi annotation views if any
        for (MKAnnotationView *poiView in annotationviewsPOIs) {
            [poiView setTransform:CGAffineTransformMakeRotation(0)];
        }
        //gas station
        for (MKAnnotationView *view in annotationviewsGas) {
            [view setTransform:CGAffineTransformMakeRotation(0)];
        }
        [northUpButton setTransform:CGAffineTransformMakeRotation(0)];
#ifdef __IPHONE_7_0
        _mapView.camera.heading = 0;
        //ins annotation views if any
        for (MKAnnotationView *insView in annotationviewsIns) {
            [insView setTransform:CGAffineTransformMakeRotation(0)];
        }
#endif
    }
    [northUpButton setImage:img forState:UIControlStateNormal];
    
    [UIView commitAnimations];
}
#pragma mark button menu
-(void)buttonMenuAnimation:(BOOL)isHiding first:(BOOL)first
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    
    //reposition
    CGRect rectLocLbl=locUpdateTime.frame;
    CGRect rectMenuBtn = [menuButton frame];
    CGRect rectMenuPanel = [topPoiView frame];
    CGRect rectMainMenuBtn = [btnMenu frame];
    CGRect rectRerouteBtn = [_btnReroute frame];
    CGRect rectDirectionInfo=[directionInfoView frame];
    CGRect rectRouteDetail=[routeDetailView frame];
    CGRect rectInstructionFrame=[instructionDiscloserView frame];
    
    //CGRect rect=]
    NSString *path = nil;
    if (isHiding) {
        rectMenuBtn.origin.y -= 50;
        rectMenuPanel.origin.y -= 50;
        if (!first) {
            rectRouteDetail.origin.y -= 50;
            rectDirectionInfo.origin.y -= 50;
            rectInstructionFrame.origin.y-=50;
        }
        
        path = @"MenuButton_down.png";
        [self setIsMenuHidden:YES];
    }else {
        rectMenuBtn.origin.y += 50;
        rectMenuPanel.origin.y += 50;
        if (!first) {
            rectRouteDetail.origin.y += 50;
            rectDirectionInfo.origin.y += 50;
            rectInstructionFrame.origin.y+=50;
        }
        path = @"MenuButton_up.png";
        [self setIsMenuHidden:NO];
    }
    
    UIImage *img = [UIImage imageNamed:path];
    [menuButton setImage:img forState:UIControlStateNormal];
    [locUpdateTime setFrame:rectLocLbl];
    [menuButton setFrame:rectMenuBtn];
    [topPoiView setFrame:rectMenuPanel];
    
    [btnMenu setFrame:rectMainMenuBtn];
    [_btnReroute setFrame:rectRerouteBtn];
    directionInfoView.frame=rectDirectionInfo;
    routeDetailView.frame=rectRouteDetail;
    instructionDiscloserView.frame=rectInstructionFrame;
    if (laneassistView) {
        CGRect laneAssistFrame=[laneassistView frame];
        laneAssistFrame.origin.y=routeDetailView.frame.origin.y+routeDetailView.frame.size.height+10;
        laneassistView.frame=laneAssistFrame;
    }
    
    
    [UIView commitAnimations];
    
    //additional animation of scrolling
    if (!isHiding)
    {
        [UIView animateWithDuration:1 animations:^()
         {
             CGPoint newOffset = _svMenu.contentOffset;
             newOffset.x = 250;
             _svMenu.contentOffset =newOffset ;
             //[_svMenu scrollRectToVisible:CGRectMake(0, 0, 10, 1) animated:NO];
         } completion:^(BOOL finished){
             [UIView animateWithDuration:1 animations:^()
              {
                  CGPoint newOffset1 = _svMenu.contentOffset;
                  newOffset1.x = 0;
                  _svMenu.contentOffset =newOffset1 ;
                  //[_svMenu scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
              }];
         }];
        
        /*[UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:1];
         [_svMenu scrollRectToVisible:CGRectMake(0, 0, 10, 1) animated:NO];
         [UIView commitAnimations];
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:1];
         [_svMenu scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
         [UIView commitAnimations];*/
    }
}

#pragma mark - poi
-(void)updatePOIs
{//return;
    if (isSearchOn) {
        return;
    }
    //gas station shares same timer with pois for now
    if ([self needRefreshGasStaion]) {
        [self searchGasStation];
    }
    
    if (!isTruckStopOn && !isTruckDealerOn && !isTruckParkingOn && !isWeightstationOn && !isCatScaleOn && !isRestAreaOn && !isCampground) {
        [_mapView removeAnnotations:annotationsPOIs];
        return;
    }
    NSLog(@"~~~~~update poi");
    
    if (dZoomLevel > ZOOM_THRESHOLD_FOR_POI) {
        [_mapView removeAnnotations:annotationsPOIs];
        return;
    }
    
    
    //step 0: get current geo rect
    MKCoordinateRegion region = [_mapView region];
    
    if (![self needReloadPOIInRegion:region]) {
        return;//region did not change much
    }
    
    NSLog(@"region: lat: %f, lon: %f, delta lat: %f, delta lon: %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
    
    //step 1: call poi manager to get the poi array within current geo rect
    NSArray *result_array = [[poiManager searchPOIinRegion2:region]retain];
    
    //    NSArray *result_array = [poiManager retrievePOIsWithArea:region];
    //    NSArray *result_array = [poiManager retrievePOIsWithName:@"Flying J"];
    
    //step 2: remove pois from mapview
    [_mapView removeAnnotations:annotationsPOIs];
    
    //    for (TTPOI *aPoi in result_array) {
    //        NSLog(@"ID %d, Type %d, Name: %@, Coord %.1f, %.1f; Address: %@, City: %@, State: %@, Zipcode: %@, Phone: %@, Wifi %d, Idle %d, Scale %d, Service %d, Wash %d, Showers %d, SecureP %d, NightPOnly %d, Img: %@", aPoi.identifier, aPoi.type, aPoi.name, aPoi.coord.latitude, aPoi.coord.longitude, aPoi.address, aPoi.city, aPoi.state, aPoi.zipcode, aPoi.number, aPoi.hasWifi, aPoi.hasIdle, aPoi.hasScale, aPoi.hasService, aPoi.hasWash, aPoi.showers, aPoi.hasSecureparking, aPoi.isNightparkingonly, aPoi.image);
    //     }
    //    return;
    
    //step 3: prepare annotations
    TTPOIAnnotation *cur_annotation = nil;
    MKAnnotationView *cur_annotationview = nil;
    //clear
    [self clearPOIAnotations];
    
    NSLog(@"original %d pois", result_array.count);
    NSArray *new_result_array = [self thinPOI:result_array];
    
    UIImage *img = nil;
    for (TTPOI *cur_poi in new_result_array) {
        cur_annotation = [[TTPOIAnnotation alloc]init];
        cur_annotation.coordinate = cur_poi.coord;
        cur_annotation.title = [NSString stringWithString:cur_poi.name];
        [cur_annotation setPoi:cur_poi];
        [annotationsPOIs addObject:cur_annotation];
        img = [UIImage imageNamed:cur_poi.image];
        if (!img) {
            switch (cur_poi.type) {
                case truck_stop:
                    img = [UIImage imageNamed:@"2002__Truckstop.png"];
                    break;
                    
                case weighstation:
                    img = [UIImage imageNamed:@"2004__Weighstation.png"];
                    break;
                    
                case campgrounds:
                    img = [UIImage imageNamed:@"poi_campground.png"];
                    break;
                    
                case truck_parking:
                    img = [UIImage imageNamed:@"2011__RestArea.png"];
                    break;
                    
                case rest_area:
                    img = [UIImage imageNamed:@"2011__R_on.png"];
                    break;
                    
                case truck_dealer:
                default:
                    img = [UIImage imageNamed:@"2010__TransportationOther.png"];
                    break;
            }
        }
        //        NSString *identifier = [NSString stringWithFormat:@"annotationview_%d", cur_poi.type];
        //        cur_annotationview = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        //        if (!cur_annotationview) {
        //            cur_annotationview = [[[MKAnnotationView alloc]initWithAnnotation:cur_annotation reuseIdentifier:identifier]retain];
        cur_annotationview = [[MKAnnotationView alloc]initWithAnnotation:cur_annotation reuseIdentifier:nil];
        cur_annotationview.image = img;
        cur_annotationview.canShowCallout = NO;
        //        }
        [cur_annotationview addObserver:self
                             forKeyPath:@"selected"
                                options:NSKeyValueObservingOptionNew
                                context:@"MAPVIEW_ANNOTATION_SELECTED"];
        [annotationviewsPOIs addObject:cur_annotationview];
        //        [cur_annotation release];
        //        [cur_annotationview release];
    }
    
    //step 4: add annotations
    [_mapView addAnnotations:annotationsPOIs];
    
    [result_array release];
}
-(void)clearPOIAnotations
{
    for (MKPointAnnotation *cur_annotation in annotationsPOIs) {
        [cur_annotation release];
    }
    for (MKAnnotationView *cur_annotationview in annotationviewsPOIs) {
        [cur_annotationview removeObserver:self forKeyPath:@"selected" context:@"MAPVIEW_ANNOTATION_SELECTED"];
        [cur_annotationview release];
    }
    [annotationsPOIs removeAllObjects];
    [annotationviewsPOIs removeAllObjects];
}
-(BOOL)needReloadPOIInRegion:(MKCoordinateRegion)region
{
    //fast check
    if (0 == last_region.span.latitudeDelta) {
        last_region = region;
        return YES;
    }
    if (0 == region.span.latitudeDelta) {
        return NO;
    }
    
    //analyse
    double value1, value2, value3, value4;
    value1 = fabs(region.center.latitude - last_region.center.latitude)/region.span.latitudeDelta;
    value2 = fabs(region.center.longitude - last_region.center.longitude)/region.span.longitudeDelta;
    value3 = region.span.latitudeDelta/last_region.span.latitudeDelta;
    value4 = region.span.longitudeDelta/last_region.span.longitudeDelta;
    if ( value1 >= .2 || value2 >= .2 || value3 < .7 || value3 > 1.5 || value4 < .7 || value4 > 1.5) {
        last_region = region;
        return YES;
    }else {
        return NO;
    }
}
#pragma mark - gas station
-(void)searchGasStation//by current location
{
    //submit request
    CLLocationCoordinate2D center_coord;
    /*
     //based on current location
     CLLocation *currentLocation = [locationManager location];
     if (nil == currentLocation) {
     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service for this app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];
     [alert release];
     return;
     }
     center_coord = currentLocation.coordinate;*/
    
    //based on map center
    MKCoordinateRegion region = [_mapView region];
    center_coord = region.center;
    
    [data_gas_station setLength:0];
    NSString *strURL = [NSString stringWithFormat:@"%@/stations/radius/%f/%f/%d/%@/%@/%@.json", SERVER_URL_FOR_GAS_STATION_SEARCH, center_coord.latitude, center_coord.longitude, DEFAULT_RADIUS_FOR_GAS_STATION_SEARCH, DEFAULT_METHOD_FOR_GAS_STATION_SEARCH, @"Price", APPLICATION_KEY_FOR_GAS_STATION_SEARCH];
    
    NSLog(@"GAS Station Feed URL : %@",strURL);
    
    connection_gas_station = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]] delegate:self];
    
    if(connection_gas_station)
    {
        NSLog(@"Find Gas Station Request submitted:");
        last_coord_gas_station = center_coord;
        isSearchingGasStation = YES;
        //        [self startWaiting];
    }else {
        NSLog(@"Failed to submit request");
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
-(void)processGasStationSearchingResult
{
    NSError *err = nil;
    NSData *data = nil;
    NSDictionary *jsonArray = nil;
    jsonArray = [NSJSONSerialization JSONObjectWithData:data_gas_station options:NSJSONReadingMutableContainers error:&err];
    //    NSLog(@"jsonArray: %@", jsonArray);
    NSArray *stations = [jsonArray objectForKey:@"stations"];
    NSMutableArray *poi_array = [[[NSMutableArray alloc]init]autorelease];
    
    NSLog(@"found %d gas stations", stations.count);
    
    for(int i=0; i<stations.count; i++)
    {//suppose only one item
        NSDictionary *item = [stations objectAtIndex:i];
        TTPOI *aPoi = [[TTPOI alloc]init];
        aPoi.identifier = [[item objectForKey:@"id"]integerValue];
        aPoi.address = [item objectForKey:@"address"];
        aPoi.city = [item objectForKey:@"city"];
        aPoi.state = [item objectForKey:@"region"];
        aPoi.country = [item objectForKey:@"country"];
        aPoi.zipcode  = [item objectForKey:@"zip"];
        data = [item objectForKey:@"price"];
        aPoi.gasPrice = [NSString stringWithFormat:@"%@", data];
        
        aPoi.reg_price=[item objectForKey:@"reg_price"];
        aPoi.pre_price=[item objectForKey:@"pre_price"];
        aPoi.mid_price=[item objectForKey:@"mid_price"];
        aPoi.diesel_price=[item objectForKey:@"diesel_price"];
        aPoi.reg_preice_date=[item objectForKey:@"reg_date"];
        aPoi.pre_price_date=[item objectForKey:@"pre_date"];
        aPoi.mid_price_date=[item objectForKey:@"mid_date"];
        aPoi.diesel_price_date=[item objectForKey:@"diesel_date"];
        aPoi.diesel_string=[item objectForKey:@"diesel"];
        aPoi.type = Gas_Station;
        aPoi.name = [item objectForKey:@"station"];
        aPoi.image = [NSString stringWithFormat:@"%@.png", aPoi.name];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[item objectForKey:@"lat"] doubleValue], [[item objectForKey:@"lng"] doubleValue]);
        aPoi.coord = coord;
        [poi_array addObject:aPoi];
        [aPoi release];
    }
    [self addGasStations:poi_array];
}
-(void)addGasStations:(NSArray *)array
{
    //store
    [self clearPOIResults];
    
    for (TTPOI *poi in array) {
        [poiResults addObject:[poi retain]];
    }
    
    [self updatePOIResults];
    
    //    NSLog(@"finish adding gasstations");
}
-(void)updatePOIResults
{
    if (!poiResults.count) {
        return;
    }
    
    [self clearGasStations];
    
    TTPOIAnnotation *cur_annotation = nil;
    MKAnnotationView *cur_annotationview = nil;
    
    NSArray *new_array = [self thinPOI:poiResults];
    
    UIImage *img = nil;
    BOOL hasPrice = NO;
    UIImage *result = nil;
    for (TTPOI *cur_poi in new_array) {
        cur_annotation = [[TTPOIAnnotation alloc]init];
        cur_annotation.coordinate = cur_poi.coord;
        //        cur_annotation.title = [NSString stringWithString:cur_poi.name];
        [cur_annotation setPoi:cur_poi];
        [annotationsGas addObject:cur_annotation];
        
        img = [UIImage imageNamed:cur_poi.image];
        if (nil == img) {
            img = [UIImage imageNamed:@"2001__Gas.png"];
        }
        hasPrice = ![cur_poi.diesel_price isEqualToString:@"N/A"];
        if (hasPrice) {
            CGSize size = CGSizeMake(32,32+20);
            //        UIImage *icon = [UIImage imageNamed:@"2001__Gas.png"];
            UIGraphicsBeginImageContext(size);
            CGRect rect = CGRectMake(0, 0, 32, 32);
            [img drawInRect:rect];
            [[UIColor blackColor] set];
            UIFont *font = [UIFont boldSystemFontOfSize:14];
            [cur_poi.diesel_price drawInRect:CGRectMake(0, 32, 32, 20) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }else {
            result = img;
        }
        
        
        //        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //        CGContextRotateCTM(ctx, M_PI);
        //        CGContextTranslateCTM(ctx, size.width/2, size.height/2);
        //        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-size.width/2, -size.height/2, size.width, 32), icon.CGImage);
        //        CGContextRotateCTM(ctx, M_PI + DEGREES_TO_RADIANS(cur_ins->nEdgeDegrees[1]));
        //        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-size.width/2, -size.height/2, size.width, size.height), arrow.CGImage);
        //        CGContextRotateCTM(ctx, M_PI + DEGREES_TO_RADIANS(cur_ins->nEdgeDegrees[0] - cur_ins->nEdgeDegrees[1]));
        //        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-size.width/2, -size.height/2, size.width, size.height), boddy.CGImage);
        
        
        
        cur_annotationview = [[MKAnnotationView alloc]initWithAnnotation:cur_annotation reuseIdentifier:nil];
        cur_annotationview.image = result;
        cur_annotationview.canShowCallout = NO;
        [cur_annotationview addObserver:self
                             forKeyPath:@"selected"
                                options:NSKeyValueObservingOptionNew
                                context:@"MAPVIEW_ANNOTATION_SELECTED"];
        [annotationviewsGas addObject:cur_annotationview];
        if (dZoomLevel > ZOOM_THRESHOLD_FOR_GAS_STATION_HIGH) {
            break;//only add one
        }
        //[cur_annotation release];
        //[cur_annotationview release];
    }
    //add annotations
    [_mapView addAnnotations:annotationsGas];
}

-(BOOL)needRefreshGasStaion
{
    if (!isGasStationOn || isSearchingGasStation) {
        return NO;
    }
    CLLocationCoordinate2D center_coord;
    MKCoordinateRegion region = [_mapView region];
    center_coord = region.center;
    double dist_in_meters = [_utility distanceFromCoordinate:center_coord toCoordinate:last_coord_gas_station];
    return METERS_TO_MILES(dist_in_meters)>DEFAULT_RADIUS_FOR_GAS_STATION_SEARCH/2;
}

-(void)clearGasStations
{
    NSLog(@"clearing gasstations");
    
    [_mapView removeAnnotations:annotationsGas];
    
    for (MKPointAnnotation *cur_annotation in annotationsGas)
    {
        [cur_annotation release];
    }
    for (MKAnnotationView *cur_annotationview in annotationviewsGas)
    {
        [cur_annotationview removeObserver:self forKeyPath:@"selected" context:@"MAPVIEW_ANNOTATION_SELECTED"];
        [cur_annotationview release];
    }
    [annotationsGas removeAllObjects];
    [annotationviewsGas removeAllObjects];
    
    NSLog(@"finish clearing gasstations");
}
#pragma mark - process pois before adding into mapview
-(NSArray *)thinPOI:(NSArray *)arrayPOI
{
    if (dZoomLevel<=ZOOM_THRESHOLD_FOR_GAS_STATION_LOW) {
        return arrayPOI;
    }
    
    //check
    CGRect rect = _mapView.bounds;
    double unit_x = 1.0 * rect.size.width / POI_THINNING_COLUMN;
    double unit_y = 1.0 * rect.size.height / POI_THINNING_ROW;
    int count = 0;
    int idx_x, idx_y;
    CGPoint point;
    NSMutableArray *array_in_range = [[[NSMutableArray alloc]init]autorelease];
    for (int i=0; i<arrayPOI.count; i++) {
        TTPOI *poi = [arrayPOI objectAtIndex:i];
        point = [_mapView convertCoordinate:poi.coord toPointToView:_mapView];
        idx_x = (int)((point.x-rect.origin.x)/unit_x);
        idx_y = (int)((point.y-rect.origin.y)/unit_y);
        if (idx_x >= 0 && idx_x < POI_THINNING_COLUMN && idx_y >= 0 && idx_y < POI_THINNING_ROW) {
            count++;
            [array_in_range addObject:poi];
        }
    }
    
    if (count <= THRESHOLD_MAX_POIS) {
        return array_in_range;
    }
    
    //process
    static BOOL bArray[POI_THINNING_ROW][POI_THINNING_COLUMN];
    for (int i=0; i<POI_THINNING_COLUMN; i++) {
        for (int j=0; j<POI_THINNING_ROW; j++) {
            bArray[j][i] = NO;
        }
    }
    
#ifdef DEBUG
    /*    static NSMutableArray *anno_array = nil;
     if (!anno_array) {
     anno_array = [[NSMutableArray alloc]init];
     }
     [mapView removeAnnotations:anno_array];
     TTPOIAnnotation *annotation = nil;
     CGPoint pt;
     CLLocationCoordinate2D coord;
     [anno_array removeAllObjects];
     for (int i=0; i<POI_THINNING_COLUMN; i++) {
     pt.x = rect.origin.x + unit_x*i;
     for (int j=0; j<POI_THINNING_ROW; j++) {
     pt.y = rect.origin.y + unit_y*j;
     coord = [mapView convertPoint:pt toCoordinateFromView:mapView];
     annotation = [[TTPOIAnnotation alloc]init];
     annotation.coordinate = coord;
     [anno_array addObject:annotation];
     }
     }
     [mapView addAnnotations:anno_array];
     
     static int count = 0;
     if (count++%2) {
     return arrayPOI;
     }*/
#endif
    
    NSMutableArray *result_array = [[[NSMutableArray alloc]init]autorelease];
    for (int i=0; i<array_in_range.count; i++) {
        TTPOI *poi = [array_in_range objectAtIndex:i];
        point = [_mapView convertCoordinate:poi.coord toPointToView:_mapView];
        idx_x = (int)((point.x-rect.origin.x)/unit_x);
        idx_y = (int)((point.y-rect.origin.y)/unit_y);
        if (idx_x >= 0 && idx_x < POI_THINNING_COLUMN && idx_y >= 0 && idx_y < POI_THINNING_ROW && !bArray[idx_y][idx_x]) {
            bArray[idx_y][idx_x] = YES;
            [result_array addObject:poi];
        }
    }
    NSLog(@"thinned from %d poi to %d poi", arrayPOI.count, result_array.count);
    return result_array;
}
-(void)clearPOIResults
{
    for (TTPOI *poi in poiResults)
    {
        [poi release];
    }
    [poiResults removeAllObjects];
}
-(void)addPOISearchResults:(NSArray *)arrayPOI
{
    if (arrayPOI.count == 0) {
        return;//do nothing
    }
    
    isSearchOn = YES;
    [_menuButtonSearch setImage:[UIImage imageNamed:@"POISearch.png"] forState:UIControlStateNormal];
    
    [self updateMenuButtons];
    [_mapView removeAnnotations:annotationsPOIs];
    [self clearPOIAnotations];
    [self clearPOIResults];
    [self clearGasStations];//gas station annotations and pois
    
    //add results
    MKMapRect rect = MKMapRectNull;
    MKMapRect ptRect;
    ptRect.size.width = ptRect.size.height = 0;
    
    //prepare annotations
    TTPOIAnnotation *cur_annotation = nil;
    MKAnnotationView *cur_annotationview = nil;
    UIImage *img = nil;
    for (TTPOI *cur_poi in arrayPOI) {
        cur_annotation = [[TTPOIAnnotation alloc]init];
        cur_annotation.coordinate = cur_poi.coord;
        cur_annotation.title = [NSString stringWithString:cur_poi.name];
        [cur_annotation setPoi:cur_poi];
        [annotationsPOIs addObject:cur_annotation];
        img = [UIImage imageNamed:cur_poi.image];
        if (!img) {
            switch (cur_poi.type) {
                case truck_stop:
                    img = [UIImage imageNamed:@"2002__Truckstop.png"];
                    break;
                    
                case weighstation:
                    img = [UIImage imageNamed:@"2004__Weighstation.png"];
                    break;
                    
                case CAT_scale:
                    img = [UIImage imageNamed:@"2004_CATScale.png"];
                    break;
                    
                case truck_parking:
                    img = [UIImage imageNamed:@"2011__RestArea.png"];
                    break;
                    
                case rest_area:
                    img = [UIImage imageNamed:@"2011__R_on.png"];
                    break;
                    
                case truck_dealer:
                default:
                    img = [UIImage imageNamed:@"2010__TransportationOther.png"];
                    break;
            }
        }
        cur_annotationview = [[MKAnnotationView alloc]initWithAnnotation:cur_annotation reuseIdentifier:nil];
        cur_annotationview.image = img;
        cur_annotationview.canShowCallout = NO;
        //        }
        [cur_annotationview addObserver:self
                             forKeyPath:@"selected"
                                options:NSKeyValueObservingOptionNew
                                context:@"MAPVIEW_ANNOTATION_SELECTED"];
        [annotationviewsPOIs addObject:cur_annotationview];
        //        [cur_annotation release];
        //        [cur_annotationview release];
        
        //gather location info
        ptRect.origin.x = cur_poi.coord.longitude;
        ptRect.origin.y = cur_poi.coord.latitude;
        rect = MKMapRectUnion(rect, ptRect);
        
    }
    
    //add annotations
    [_mapView addAnnotations:annotationsPOIs];
    
    // Position the map so that all overlays and annotations are visible on screen.
    [_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(rect.origin.y + rect.size.height/2, rect.origin.x + rect.size.width/2), MKCoordinateSpanMake(rect.size.height*1.2+.5, rect.size.width*1.2+.5)) animated:NO];
}
-(void)dismissPOISearchResults
{
    isSearchOn = NO;
    [_menuButtonSearch setImage:[UIImage imageNamed:@"POISearch off.png"] forState:UIControlStateNormal];
    [self updateMenuButtons];
    [_mapView removeAnnotations:annotationsPOIs];
    [self clearPOIAnotations];
    [self clearPOIResults];
}
#pragma mark - odometer
-(void)resetOdometer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"odometer_total_distance"];
    [userDefaults removeObjectForKey:@"odometer_dictionary"];
}
-(void)updateOdometer
{//return;
    //    NSLog(@"****** start updating odo");
    CLLocation *cur_location = locationManager.location;
#ifdef DEBUG
    if (isNavigating && isSimulating) {
        cur_location = [routeAnalyzer getCurrentSimulationLocation];
    }
#endif
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (nil == cur_location) {
        [userDefaults removeObjectForKey:@"odometer_last_latitude"];
        [userDefaults removeObjectForKey:@"odometer_last_longitude"];
        return;
    }
    CLLocationCoordinate2D last_coord;
    last_coord.latitude = [userDefaults doubleForKey:@"odometer_last_latitude"];
    last_coord.longitude = [userDefaults doubleForKey:@"odometer_last_longitude"];
    if (cur_location.speed > 0.01 && last_coord.latitude) {
        double distance = [_utility distanceFromCoordinate:last_coord toCoordinate:cur_location.coordinate];
        double temp;
        //check distance
        if (distance <= ODOMETER_DISTANCE_THRESHOLD) {
            temp = [userDefaults doubleForKey:@"odometer_total_distance"];
            [userDefaults removeObjectForKey:@"odometer_total_distance"];
            [userDefaults setDouble:distance+temp forKey:@"odometer_total_distance"];
            //state odo
            NSString *strState = [_utility getStateWithCoord:cur_location.coordinate];
            if (![strState isEqualToString:@"UNKNOWN_STATE"]) {
                NSDictionary *dictionary = [userDefaults dictionaryForKey:@"odometer_dictionary"];
                NSMutableDictionary *mutable_dictionary = nil;
                mutable_dictionary = [[NSMutableDictionary alloc]initWithDictionary:dictionary];
                temp = [[mutable_dictionary objectForKey:strState] doubleValue];
                [mutable_dictionary setObject:[NSString stringWithFormat:@"%f", temp+distance] forKey:strState];
                //NSLog(@"----- state odo updated %@: %.1f", strState, [[mutable_dictionary objectForKey:strState]doubleValue]);
                [userDefaults removeObjectForKey:@"odometer_dictionary"];
                [userDefaults setObject:mutable_dictionary forKey:@"odometer_dictionary"];
                [mutable_dictionary release];
            }
        }
    }
    [userDefaults removeObjectForKey:@"odometer_last_latitude"];
    [userDefaults removeObjectForKey:@"odometer_last_longitude"];
    [userDefaults setDouble:cur_location.coordinate.latitude forKey:@"odometer_last_latitude"];
    [userDefaults setDouble:cur_location.coordinate.longitude forKey:@"odometer_last_longitude"];
    
    //    NSLog(@"****** main ODO: %.1f meters, speed %.1f mps", [userDefaults doubleForKey:@"odometer_total_distance"], cur_location.speed);
}

#pragma mark - observer value for keypath
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context{
    
    NSString *action = (NSString*)context;
    MKAnnotationView *view = object;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    NSLog(@"observeValueForKeyPath");
    
    if([[change valueForKey:@"new"] intValue] == 1 && [action isEqualToString:@"MAPVIEW_ANNOTATION_SELECTED"])  {
        TTPOI *poi = ((TTPOIAnnotation*)view.annotation).poi;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTTruckStopInfoViewController *tsvc = nil;
        TTGenericInfoViewController *gvc = nil;
        TTGasStationInfoViewController *gsvc = nil;
        
        switch (poi.type)
        {
            case truck_stop:
                if (IS_IPAD) {
                    tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController_ipad"];
                }
                else{
                    tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController"];
                }
                [tsvc setParentVC:self];
                [tsvc setIsNotificationOn:YES];
                [tsvc setPoi:poi];
                [self presentViewController:tsvc animated:YES completion:nil];
               
//                if (UIDeviceOrientationIsLandscape(deviceOrientation))
//                {
//                    [self presentViewController:tsvc animated:NO completion:nil];
//                }
//                else{
//                    [self presentViewController:tsvc animated:YES completion:nil];
//                }

                return;
            case Gas_Station:
                if(IS_IPAD)
                     gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"GasStationInfoViewController_ipad"];
                else
                    gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"GasStationInfoViewController"];
                
                [gsvc setParentVC:self];
                [gsvc setPoi:poi];
                [gsvc setIsNotificationOn:YES];
                //UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
                if (UIDeviceOrientationIsLandscape(deviceOrientation))
                    [self presentViewController:gsvc animated:NO completion:nil];
                else
                    [self presentViewController:gsvc animated:YES completion:nil];
                return;
            default:
                if (IS_IPAD)
                    gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController_ipad"];
                else
                    gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController"];
                
                [gvc setParentVC:self];
                [gvc setIsNotificationOn:YES];
                [gvc setPoi:poi];
                //[self presentViewController:gvc animated:YES completion:nil];
                if (UIDeviceOrientationIsLandscape(deviceOrientation))
                {
                    [self presentViewController:gvc animated:NO completion:nil];
                }
                else{
                    [self presentViewController:gvc animated:YES completion:nil];
                }

                return;
        }
    }
}

#pragma mark update view
-(void)updateView
{
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:NAVIGATOR_ANIMATION_DURATION];
    //    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    if (navInfo.speed<=0)
    {
        [_mapView removeAnnotation:(id<MKAnnotation>)annotationNavCursor];
        int y=[[UIScreen mainScreen] bounds].size.height/4;
        [self moveCenterByOffset:CGPointMake(0, y) from:[navInfo location_estimated]];
        if(routeAnalyzer.idxCurSimLoc<3 && navInfo.speed<=0 && !isNorthUp)
        {
            CLLocation *location;
            [navInfo setSpeed:0];
            
//            [annotationNavCursor setCoordinate:[navInfo location_estimated]];
//            [_mapView addAnnotation:(id<MKAnnotation>)annotationNavCursor];
            
            
            location = [routeAnalyzer getNextSimulationLocation:30];
            TTNavInfo *navInfoNew = [routeAnalyzer analyseWithLocation:location];
            _mapView.camera.heading = [navInfoNew heading];
            
        }
        return;
    }
    
    double radians = M_PI * 2 - DEGREES_TO_RADIANS([navInfo heading]);
    // [_mapView setPitchEnabled:YES]; // enable camera angle change
    if (isAutoZoom)
    {
        [self adjustZoomBySpeed:navInfo.speed];
        if (!isPerspective) {
            [self updateZoom];
        }
    }
    
    [_mapView removeAnnotation:(id<MKAnnotation>)annotationNavCursor];
    int y=[[UIScreen mainScreen] bounds].size.height/4;
    [self moveCenterByOffset:CGPointMake(0, y) from:[navInfo location_estimated]];
    //[_mapView.camera setCenterCoordinate:[navInfo location_estimated]];
    //[annotationNavCursor setCoordinate:[navInfo location_estimated]];
    if (!isNorthUp)
    {
        if (navInfo.speed>0){
            _mapView.camera.heading = [navInfo heading];
//            MKMapCamera *newCamera = [[_mapView camera] copy];
//            //        [newCamera setPitch:45.0];
//            [newCamera setHeading:[navInfo heading]];
//            //        [newCamera setAltitude:500.0];
//            [_mapView setCamera:newCamera animated:NO];

        }
        
        [northUpButton setTransform:CGAffineTransformMakeRotation(radians)];
        for (MKAnnotationView *insView in annotationviewsIns)
        {
            [insView setTransform:CGAffineTransformMakeRotation(radians)];
        }
    }
    else
    {
        [_imgNavCursor setTransform:CGAffineTransformMakeRotation(-radians)];
    }
    if (isPerspective)
    {
//        MKMapCamera *newCamera = [[_mapView camera] copy];
//        //        [newCamera setPitch:45.0];
//        //        [newCamera setHeading:90.0];
//        //        [newCamera setAltitude:500.0];
//        [_mapView setCamera:newCamera animated:NO];

        
//        _mapView.camera.pitch=[self pitchValueBaseOnZoom];//_mapView.camera.pitch;//_mapView.camera.pitch;
//        if (_mapView.camera.pitch==0) {
//            _mapView.camera.pitch=[self pitchValueBaseOnZoom];//_mapView.camera.pitch;
//        }
        //[_mapView setPitchEnabled:NO];
       // [self updateZoom];
    }
    else
    {
        [self updateZoom];
    }
    //[self moveCenterByOffset:CGPointMake(0, y) from:[navInfo location_estimated]];
}
-(IBAction)changeSpeedButtonClick:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (btn.tag==0)
    {
        //newFunction=YES;
        if (travel_speed>=100)
        {
            return;
        }
        travel_speed+=10;
    }
    else
    {
        if (travel_speed<=0) {
            return;
        }
        travel_speed-=10;
    }
    [navInfo setSpeed:travel_speed];
}
-(void)initMoveLocation{
    CLLocation *currentLocation=[locationManager location];
    CGPoint point = [_mapView convertCoordinate:currentLocation.coordinate toPointToView:_mapView];
    point.x += 5;
    point.y += 5;
    CLLocationCoordinate2D center = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    [_mapView.camera setCenterCoordinate:center];
    
}
- (void)moveCenterByOffset:(CGPoint)offset from:(CLLocationCoordinate2D)coordinate
{
    [_mapView.camera setCenterCoordinate:coordinate];
    
    float screenHeight=_mapView.frame.size.height;
    float screenWidth=_mapView.frame.size.width;
    NSLog(@"Screen Width : %f : %f",screenWidth,screenHeight);
    CGPoint fakecenter = CGPointMake(screenWidth/2, (screenHeight/5)+(_mapView.camera.pitch));
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
    {
        fakecenter = CGPointMake(screenWidth/2, (screenHeight/4)+(_mapView.camera.pitch/3));
    }
    else{
        
    }
    

    NSLog(@"point : %f - %f",fakecenter.x,fakecenter.y);
    CLLocationCoordinate2D coordinateNew = [_mapView convertPoint:fakecenter toCoordinateFromView:_mapView];
    [_mapView.camera setCenterCoordinate:coordinateNew];
    [annotationNavCursor setCoordinate:[navInfo location_estimated]];
    [_mapView addAnnotation:(id<MKAnnotation>)annotationNavCursor];
    
/*  CGPoint point = [_mapView convertCoordinate:coordinate toPointToView:_mapView];
    point.x -= offset.x;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        point.y -= 70;
    }
    else{
        point.y -= 120;
    }
    NSLog(@"Point X: %f - Y : %f",point.x,point.y);
    CLLocationCoordinate2D center = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    MKMapCamera *newCamera = [[_mapView camera] copy];
    if ((center.latitude>=-90 && center.latitude<=90) && (center.longitude>=-180 && center.longitude<=180)) {
        [newCamera setCenterCoordinate:center];
        [_mapView setCamera:newCamera animated:NO];
    }*/
}

-(void)updateInstructionAnnotations
{
    if (annotationsIns.count)
    {
        if (isAnnotationAdded && dZoomLevel >= ZOOM_THRESHOLD_FOR_TURNS ) {
            //remove instruction annotations
            [_mapView removeAnnotations:annotationsIns];
            isAnnotationAdded = NO;
        }else if (!isAnnotationAdded && dZoomLevel < ZOOM_THRESHOLD_FOR_TURNS) {
            //add instruction annotations
            [_mapView addAnnotations:annotationsIns];
            isAnnotationAdded = YES;
        }
    }
}

-(void)updateZoom
{
    
    //#ifdef __IPHONE_7_0
    //no animation here, otherwise need to release old camera and set new camera with [mapview setcamera: animated:]
    //NSLog(@" Zoom Level : %f",dZoomLevel);
    //[_mapView setPitchEnabled:YES];
    
    MKMapCamera *newCamera = [[_mapView camera] copy];
    [newCamera setAltitude:ZOOM_1_ALTITUDE*pow(2, dZoomLevel-1)];
    [_mapView setCamera:newCamera animated:NO];
    
//    _mapView.camera.altitude = ZOOM_1_ALTITUDE*pow(2, dZoomLevel-1);
//    NSLog(@"Altitude : %f = %f",_mapView.camera.altitude,_mapView.camera.pitch);
//    //_mapView.camera.pitch=[self pitchValueBaseOnZoom];
//    //[_mapView setPitchEnabled:NO];
    
    
}

-(void)calculateZoom
{
#ifdef __IPHONE_7_0
    dZoomLevel = log2(_mapView.camera.altitude/ZOOM_1_ALTITUDE)+1;
#else
    //latitude not working, lets calculate by longitude
    MKCoordinateRegion region = [_mapView region];
    dZoomLevel = log2(region.span.longitudeDelta/ZOOM_1_SPAN_LON);
#endif
#ifdef DEBUG
    [_labelZoom setText:[NSString stringWithFormat:@"%.1f", dZoomLevel]];
#endif
}
-(float)adjustCameraAngleBySpeed:(double)speed //in mph
{
    //    double minZ = 0, maxZ =700, minS = 5, maxS = 100;
    //    double rate = (maxZ - minZ)/(maxS - minS);
    //    if (speed <= minS){
    //        return minZ;
    //    }
    //    else if (speed >= maxS){
    //        return  maxZ;
    //    }
    //    else
    //    {
    //        return (minZ + (speed - minS)*rate);
    //    }
}
-(void)adjustZoomBySpeed:(double)speed//in mph
{
    //for now:
    //speed(mph)     dZoomLevel (from MIN_ZOOM(2) to MAX_ZOOM(18))
    //0~5            2
    //smoothly proportional
    //>65            6
    
    if (!isPerspective) {
        
        double minZ = 2, maxZ = 6, minS = 5, maxS = 65;
        double rate = (maxZ - minZ)/(maxS - minS);
        if (speed <= minS){
            dZoomLevel = minZ;
        }
        else if (speed >= maxS)
        {
            dZoomLevel = maxZ;
        }
        else {
            dZoomLevel = minZ + (speed - minS)*rate;
        }
        NSLog(@"Zoom Level : %f",dZoomLevel);
    }
    else
    {
        double minZ = 0.1, maxZ = 4.0, minS = 5, maxS = 65;
        double rate = (maxZ - minZ)/(maxS - minS);
        if (speed <= minS){
            dZoomLevel = minZ;
        }
        else if (speed >= maxS){
            dZoomLevel = maxZ;
        }
        else {
            dZoomLevel = minZ + (speed - minS)*rate;
        }
        NSLog(@"Zoom Level : %f",dZoomLevel);
    }
}
-(void)setTrackingMode//based on northup flag
{
    if (isNorthUp) {
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    }else {
        [_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
    }
    
    //[UIView commitAnimations];
    
}
///////////////////////////////////////////////////////////////
#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == connection_gas_station) {
        [data_gas_station appendData:data];
    }else {
        [responseData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"failed 2: %@", [error localizedDescription]);
    
    if (connection == connection_gas_station) {
        [connection_gas_station release];
        isSearchingGasStation = NO;
        //        [self stopWaiting];
        return;//do nothing
    }
    
    if ([server_url isEqualToString:SERVER_URL_MAIN]) {
        //update start address, speed and bearing
        CLLocation *currentLocation = [locationManager location];
        routeRequest.start_address = @"Current Location";
        routeRequest.start_location = currentLocation.coordinate;
        if (currentLocation.speed < 0) {
            routeRequest.speed = 0;
        }else {
            routeRequest.speed = METERS_PER_SECOND_TO_MILES_PER_HOUR(currentLocation.speed)*100;
        }
        if (currentLocation.course < 0) {
            routeRequest.bearing = -1;
        }else {
            routeRequest.bearing = currentLocation.course;
        }
        //TRY BACKUP SERVER
        server_url = SERVER_URL_BACKUP;
        [self submitRerouteRequest];
        return;
    }
    
    [self stopWaiting];
    
    //notification
    NSString * msgStr=[NSString stringWithFormat:@"%@ Please recheck your internet connection. Do you wish to clear the route?.",[error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:msgStr delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"OK",nil];
    alert.tag=88;
    [alert show];
    [alert release];
    
    //    [connection release];
    [responseData release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == connection_gas_station) {
        //      [self stopWaiting];
        [connection_gas_station release];
        [self processGasStationSearchingResult];
        isSearchingGasStation = NO;
        return;
    }
    
    [self stopWaiting];
    [self clearRoute];
    //check
    NSString *string = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]autorelease];
    //    if([string length]>2) {
    if (ROUTE_ERROR_SUCCESS == [string integerValue]) {
        //succeed, then save result into userdefault
        NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
        
        //unzip
        if ([routeRequest.format isEqualToString:@"kmz"]) {
            NSData *unzippedData = nil;
            NSRange range;
            range.location = 2;
            range.length = responseData.length - 2;
            unzippedData = [NSData gtm_dataByInflatingData:[responseData subdataWithRange:range]];
            [dataDefault setObject:unzippedData forKey:@"data"];
            NSString *str = [[[NSString alloc] initWithData:unzippedData encoding:NSUTF8StringEncoding]autorelease];
            if (str.length < 100000) {
                NSLog(@"%@",str);
            }else {
                NSLog(@"kml is too big to display ");
            }
        }else {
            [dataDefault setObject:[[string substringFromIndex:2] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] forKey:@"data"];
            NSLog(@"%@", [string substringFromIndex:2]);
        }
        [dataDefault synchronize];
        /*        [dataDefault removeObjectForKey:@"data"];
         [dataDefault setObject:[[string substringFromIndex:2] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] forKey:@"data"];*/
        
        NSLog(@"Finished receiving route!");
        
        //load kml
        [self loadKML];
        //start navigating
        [self startNavigating];
    }else {
        UIAlertView *alert = nil;
        //error
        NSLog(@"error code: %@", string);
        switch ([string integerValue]) {
            case ROUTE_ERROR_NO_SUBSCRIPTION:
                alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                   message:@"No subscription!"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_EXPIRED_SUBSCRIPTION:
                alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                   message:@"Expired subscription!"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_ROUTE_FAILED:
                alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                   message:@"Route failed!"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_SERVER_ERROR:
                alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                   message:@"Please Retry Route in 1 Minute!"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
                
            case ROUTE_ERROR_MYSQL_ERROR:
                alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                   message:@"Database has issue!"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
                
            default:
                break;
        }
    }
    
    //release
    //    [connection release];
    [responseData release];
}
#pragma mark uigesturerecognizerdelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark process requests from outside
-(void)pauseNavigatingFromOutside
{
    if (isNavigating) {
        [self stopNavigating];
        [navButton setHidden:NO];
    }
}

-(void)moveToCoordinate:(CLLocationCoordinate2D )coord withZoomLevel:(double)zoomLevel
{
    dZoomLevel = zoomLevel;
    [self updateZoom];
    [_mapView setCenterCoordinate:coord animated:YES];
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
#pragma mark - toggle buttons
- (IBAction)toggleTruckStop:(id)sender
{
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isTruckStopOn = YES;
    }else {
        isTruckStopOn = !isTruckStopOn;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_truckstop"];
    [userDefault setBool:isTruckStopOn forKey:@"poi_display_truckstop"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isTruckStopOn) {
        img = [UIImage imageNamed:@"2002__Truckstop.png"];
    }else {
        img = [UIImage imageNamed:@"2002__Truckstop off.png"];
    }
    [_menuButtonTruckStop setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}
- (IBAction)toggleWeighStation:(id)sender {
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isWeightstationOn = YES;
    }else {
        isWeightstationOn = !isWeightstationOn;
    }
    //    isWeightstationOn = !isWeightstationOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_weighstation"];
    [userDefault setBool:isWeightstationOn forKey:@"poi_display_weighstation"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isWeightstationOn) {
        img = [UIImage imageNamed:@"2004__Weighstation.png"];
    }else {
        img = [UIImage imageNamed:@"2004__Weighstation off.png"];
    }
    [_menuButtonWeighStation setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}
- (IBAction)toggleTruckDealer:(id)sender {
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isTruckDealerOn = YES;
    }else {
        isTruckDealerOn = !isTruckDealerOn;
    }
    
    //isTruckDealerOn = !isTruckDealerOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_truckdealer"];
    [userDefault setBool:isTruckDealerOn forKey:@"poi_display_truckdealer"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isTruckDealerOn) {
        img = [UIImage imageNamed:@"2010__TransportationOther.png"];
    }else {
        img = [UIImage imageNamed:@"2010__TransportationOther off.png"];
    }
    [_menuButtonTruckDealer setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}

- (IBAction)toggleTruckParking:(id)sender {
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isTruckParkingOn = YES;
    }else {
        isTruckParkingOn = !isTruckParkingOn;
    }
    //    isTruckParkingOn = !isTruckParkingOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_truckparking"];
    [userDefault setBool:isTruckParkingOn forKey:@"poi_display_truckparking"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isTruckParkingOn) {
        img = [UIImage imageNamed:@"2011__RestArea.png"];
    }else {
        img = [UIImage imageNamed:@"2011__RestArea off.png"];
    }
    [_menuButtonTruckParking setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}

- (IBAction)toggleGasStation:(id)sender {
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isGasStationOn = YES;
    }else {
        isGasStationOn = !isGasStationOn;
    }
    //    isGasStationOn = !isGasStationOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_gasstation"];
    [userDefault setBool:isGasStationOn forKey:@"poi_display_gasstation"];
    UIImage *img;
    if (!isGasStationOn) {
        img = [UIImage imageNamed:@"2001__Gas off.png"];
        [self clearGasStations];
        [self clearPOIResults];
    }else {
        img = [UIImage imageNamed:@"2001__Gas.png"];
        [self searchGasStation];
    }
    [_menuButtonGasStation setImage:img forState:UIControlStateNormal];
}

- (IBAction)toggleMenuButtonSearch:(id)sender {
    if (isSearchOn) {
        //dismiss searching results and recover other poi display
        [self dismissPOISearchResults];
        [self updatePOIs];
    }else {
        //go to searching view
        [self mainMenuAnimation:YES];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTFindMenuViewController *fmvc = [storyBoard instantiateViewControllerWithIdentifier:@"FindMenuViewController"];
        TTFindMenuViewController *fmvc = nil;
        if (IS_IPAD) {
            fmvc = [storyBoard instantiateViewControllerWithIdentifier:@"FindMenuViewController_ipad"];
        }
        else{
            fmvc = [storyBoard instantiateViewControllerWithIdentifier:@"FindMenuViewController"];
        }
        [fmvc setParentVC:self];
        [fmvc setIsNotificationOn:YES];
        [fmvc setPoiManager:poiManager];
        //[self presentViewController:fmvc animated:YES completion:nil];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation))
            [self presentViewController:fmvc animated:NO completion:nil];
        else
            [self presentViewController:fmvc animated:YES completion:nil];

    }
}

-(void)updateMenuButtons
{
    if (isSearchOn) {
        [_menuButtonTruckStop setImage:[UIImage imageNamed:@"2002__Truckstop off.png"] forState:UIControlStateNormal];
        [_menuButtonWeighStation setImage:[UIImage imageNamed:@"2004__Weighstation off.png"] forState:UIControlStateNormal];
        [_menuButtonCatScale setImage:[UIImage imageNamed:@"CATScale off.png"] forState:UIControlStateNormal];
        [_menuButtonTruckDealer setImage:[UIImage imageNamed:@"2010__TransportationOther off.png"] forState:UIControlStateNormal];
        [_menuButtonTruckParking setImage:[UIImage imageNamed:@"2011__RestArea off.png"] forState:UIControlStateNormal];
        [_menuButtonRestArea setImage:[UIImage imageNamed:@"2011__R_off.png"] forState:UIControlStateNormal];
        [_menuButtonGasStation setImage:[UIImage imageNamed:@"2001__Gas off.png"] forState:UIControlStateNormal];
        return;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    isTruckStopOn = [userDefault boolForKey:@"poi_display_truckstop"];
    isWeightstationOn = [userDefault boolForKey:@"poi_display_weighstation"];
    isTruckDealerOn = [userDefault boolForKey:@"poi_display_truckdealer"];
    isTruckParkingOn = [userDefault boolForKey:@"poi_display_truckparking"];
    isGasStationOn = [userDefault boolForKey:@"poi_display_gasstation"];
    isCatScaleOn = [userDefault boolForKey:@"poi_display_catscale"];
    isRestAreaOn = [userDefault boolForKey:@"poi_display_restarea"];
    isCampground = [userDefault boolForKey:@"poi_display_campgrounds"];
    UIImage *img;
    if (isTruckStopOn) {
        img = [UIImage imageNamed:@"2002__Truckstop.png"];
    }else {
        img = [UIImage imageNamed:@"2002__Truckstop off.png"];
    }
    [_menuButtonTruckStop setImage:img forState:UIControlStateNormal];
    if (isWeightstationOn) {
        img = [UIImage imageNamed:@"2004__Weighstation.png"];
    }else {
        img = [UIImage imageNamed:@"2004__Weighstation off.png"];
    }
    [_menuButtonWeighStation setImage:img forState:UIControlStateNormal];
    if (isCampground) {
        img = [UIImage imageNamed:@"poi_campground_on"];
    }else {
        img = [UIImage imageNamed:@"poi_campground_off"];
    }
    [_menuButtonCatScale setImage:img forState:UIControlStateNormal];
    if (isTruckDealerOn) {
        img = [UIImage imageNamed:@"2010__TransportationOther.png"];
    }else {
        img = [UIImage imageNamed:@"2010__TransportationOther off.png"];
    }
    [_menuButtonTruckDealer setImage:img forState:UIControlStateNormal];
    if (isTruckParkingOn) {
        img = [UIImage imageNamed:@"2011__RestArea.png"];
    }else {
        img = [UIImage imageNamed:@"2011__RestArea off.png"];
    }
    [_menuButtonTruckParking setImage:img forState:UIControlStateNormal];
    if (isRestAreaOn) {
        img = [UIImage imageNamed:@"2011__R_on.png"];
    }else {
        img = [UIImage imageNamed:@"2011__R_off.png"];
    }
    [_menuButtonRestArea setImage:img forState:UIControlStateNormal];
    if (!isGasStationOn) {
        img = [UIImage imageNamed:@"2001__Gas off.png"];
    }else {
        img = [UIImage imageNamed:@"2001__Gas.png"];
    }
    [_menuButtonGasStation setImage:img forState:UIControlStateNormal];
}

- (IBAction)toggleRestArea:(id)sender {
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isRestAreaOn = YES;
    }else {
        isRestAreaOn = !isRestAreaOn;
    }
    //    isRestAreaOn = !isRestAreaOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_restarea"];
    [userDefault setBool:isRestAreaOn forKey:@"poi_display_restarea"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isRestAreaOn) {
        img = [UIImage imageNamed:@"2011__R_on.png"];
    }else {
        img = [UIImage imageNamed:@"2011__R_off.png"];
    }
    [_menuButtonRestArea setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}

- (IBAction)toggleCatScale:(id)sender {
   /* [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isCatScaleOn = YES;
    }else {
        isCatScaleOn = !isCatScaleOn;
    }
    //    isCatScaleOn = !isCatScaleOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_catscale"];
    [userDefault setBool:isCatScaleOn forKey:@"poi_display_catscale"];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isCatScaleOn) {
        img = [UIImage imageNamed:@"2004_CATScale.png"];
    }else {
        img = [UIImage imageNamed:@"CATScale off.png"];
    }
    [_menuButtonCatScale setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
    */
    
    [self menuButtonRemind];
    if (isSearchOn) {
        [self dismissPOISearchResults];
        isCampground = YES;
    }else {
        isCampground = !isCampground;
    }
    //    isCatScaleOn = !isCatScaleOn;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"poi_display_campgrounds"];
    [userDefault setBool:isCampground forKey:@"poi_display_campgrounds"];
    [userDefault synchronize];
    last_region.span.latitudeDelta = 0;//trigger reload
    UIImage *img;
    if (isCampground) {
        img = [UIImage imageNamed:@"poi_campground_on.png"];
    }else {
        img = [UIImage imageNamed:@"poi_campground_off.png"];
    }
    [_menuButtonCatScale setImage:img forState:UIControlStateNormal];
    [self updatePOIs];
}

#pragma mark - memory check
-(void)print_free_memory
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", (mem_used/1024)/1024, (mem_free/1024)/1024, (mem_total/1024)/1024);
    _labelZoom.text=[NSString stringWithFormat:@"%u",(mem_used/1024)/1024];
}

-(void)menuButtonRemind
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"No_Menu_Button_Reminder"]) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Click the icon to Display or Clear the service on the map"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Dismiss Reminder", nil];
    [alert setTag:100];
    [alert show];
    [alert release];
}

#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView11 clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView11.tag==88 && buttonIndex==1) {
        [self clearRoute];
    }
    if (alertView11.tag==110 && buttonIndex ==1) {
        [self clearRoute];
        [navButton setHidden:YES];
        [self mainMenuAnimation:YES];
    }
    if (alertView11.tag==1111 && buttonIndex==1) {
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *subject = @"SmartRVRoute Support Request for invisible route";
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:subject];
            NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
            [mailer setToRecipients:toRecipients];
            NSData *dta=[[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
            NSString *str = [[[NSString alloc] initWithData:dta encoding:NSUTF8StringEncoding]autorelease];
            [mailer setMessageBody:str isHTML:NO];
            [self presentViewController:mailer animated:YES completion:nil];
            [mailer release];
        }
        
    }
    
    if (100 == alertView11.tag && 1 == buttonIndex) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"No_Menu_Button_Reminder"];
    }
    CLGeocoder *geocoder;
    CLLocation *loct;
    NSUserDefaults *userDefaults=nil;
    UIStoryboard *storyBoard;
    TTNewRouteViewController *nrvc;
    
    if (alertView11.tag==12 && buttonIndex == 1 ) {
        
        CLPlacemark *placeObj=objc_getAssociatedObject(alertView11, &fooKey);
        NSArray *addressArray=[placeObj.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSLog(@"Address Array: %@",addressArray);
        NSString *addressStr=[NSString stringWithFormat:@"%@, %@, %@, %@ \n%.6f,%.6f \n 1",[alertView11 textFieldAtIndex:0].text,[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],(addressArray.count==3) ? [addressArray objectAtIndex:2] :@"",placeObj.location.coordinate.latitude,placeObj.location.coordinate.longitude];
        [self updateHistory:addressStr];
        
        _mapView.showsUserLocation=NO;
        
        CLLocation *location=placeObj.location; //[[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
        
        if (historyAnnotaion)
        {
            [_mapView removeAnnotation:historyAnnotaion];
        }
        
        historyAnnotaion = [[MKPointAnnotation alloc] init];
        //annotationPoint.
        historyAnnotaion.coordinate = location.coordinate;
        historyAnnotaion.title =[alertView11 textFieldAtIndex:0].text;
        historyAnnotaion.subtitle = [addressArray objectAtIndex:0];
        
        [_mapView addAnnotation:historyAnnotaion];
        _mapView.camera.centerCoordinate=location.coordinate;
        
        _mapView.camera.altitude=4000;
        
        _mapView.camera.centerCoordinate=location.coordinate;
        
    }
    else if(alertView11.tag == 10)
    {
        NSString *addressStr=nil;
        CLPlacemark *placeObj=objc_getAssociatedObject(alertView11, &fooKey);
        NSArray *addressArray=[placeObj.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSLog(@"Address Array: %@",addressArray);
        NSString *textValue=[alertView11 textFieldAtIndex:0].text;
        addressStr=[NSString stringWithFormat:@"%@ %@, %@, %@ \n%.6f,%.6f \n %@",(textValue.length>0)? [NSString stringWithFormat:@"%@,",textValue]:@"",[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],(addressArray.count==3) ? [addressArray objectAtIndex:2] :@"",placeObj.location.coordinate.latitude,placeObj.location.coordinate.longitude,(textValue.length>0)? @"1":@"0"];
        if (buttonIndex==1){
            
            [self updateHistory:addressStr];
        }
        //NSString *str = [NSString stringWithFormat:@"My Point: %.6f, %.6f", coord_press.latitude, coord_press.longitude];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"route_request_end_address"];
        [userDefaults removeObjectForKey:@"route_request_end_latitude"];
        [userDefaults removeObjectForKey:@"route_request_end_longitude"];
        [userDefaults setObject:addressStr forKey:@"route_request_end_address"];
        [userDefaults setDouble:coord_press.latitude forKey:@"route_request_end_latitude"];
        [userDefaults setDouble:coord_press.longitude forKey:@"route_request_end_longitude"];
        //[userDefaults synchronize];
        //call new route view with start location
        [self mainMenuAnimation:YES];
        storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        if (IS_IPAD) {
            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
        }
        else{
            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        }
        //nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        [nrvc setParentVC:self];
        [nrvc setIsNotificationOn:YES];
        //            [nrvc setIsUserDefinedStartLocation:YES];
        //[self presentViewController:nrvc animated:YES completion:nil];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation))
            [self presentViewController:nrvc animated:NO completion:nil];
        else
            [self presentViewController:nrvc animated:YES completion:nil];

    }
    else if(alertView11.tag==11 )
    {
        NSString *addressStr=nil;
        CLPlacemark *placeObj=objc_getAssociatedObject(alertView11, &fooKey);
        NSArray *addressArray=[placeObj.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSLog(@"Address Array: %@",addressArray);
        NSString *textValue=[alertView11 textFieldAtIndex:0].text;
        addressStr=[NSString stringWithFormat:@"%@ %@, %@, %@ \n%.6f,%.6f \n %@",(textValue.length>0)? [NSString stringWithFormat:@"%@,",textValue]:@"",[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],(addressArray.count==3) ? [addressArray objectAtIndex:2] :@"",placeObj.location.coordinate.latitude,placeObj.location.coordinate.longitude,(textValue.length>0)? @"1":@"0"];
        if (buttonIndex==1){
            [self updateHistory:addressStr];
        }
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"route_request_start_address"];
        [userDefaults removeObjectForKey:@"route_request_start_latitude"];
        [userDefaults removeObjectForKey:@"route_request_start_longitude"];
        [userDefaults setObject:addressStr forKey:@"route_request_start_address"];
        [userDefaults setDouble:coord_press.latitude forKey:@"route_request_start_latitude"];
        [userDefaults setDouble:coord_press.longitude forKey:@"route_request_start_longitude"];
        //call new route view with start location
        [self mainMenuAnimation:YES];
        storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        //nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        if (IS_IPAD) {
            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
        }
        else{
            nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        }
        [nrvc setIsNotificationOn:YES];
        [nrvc setParentVC:self];
        [nrvc setIsUserDefinedStartLocation:YES];
        //[self presentViewController:nrvc animated:YES completion:nil];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation))
            [self presentViewController:nrvc animated:NO completion:nil];
        else
            [self presentViewController:nrvc animated:YES completion:nil];

        
    }
    [userDefaults synchronize];
}

-(void)sendCustomerReports:(NSString *)type from:(int)from
{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report details or comments."
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Send", nil];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
    CGRect textRect=v.frame;
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        textRect=CGRectMake(20,0,230,90);
    }
    UITextView *textView = [[UITextView alloc]initWithFrame:textRect];
    textView.font = [UIFont fontWithName:@"Helvetica" size:12];
    textView.font = [UIFont boldSystemFontOfSize:12];
    textView.backgroundColor = [UIColor whiteColor];
    textView.scrollEnabled = YES;
    textView.pagingEnabled = YES;
    textView.editable = YES;
    textView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth=0.8f;
    textView.layer.cornerRadius=10.0f;
    [textView becomeFirstResponder];
    [v addSubview:textView];
    [av setValue:v forKey:@"accessoryView"];
    v.backgroundColor = [UIColor clearColor];
    // av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    av.tapBlock = ^(UIAlertView *alertView1, NSInteger buttonIndex) {
        if (buttonIndex == alertView1.firstOtherButtonIndex) {
            NSLog(@"Username: %@", [textView text]);
            
            CLLocation *currentLocation = [locationManager location];
            CLLocationCoordinate2D reportLocation=currentLocation.coordinate;
            if (from==1) {
                reportLocation=coord_press;
            }
            
            NSString *deviceType=nil;
            if (IS_IPAD) {
                deviceType=@"iPad";
            }
            else if(IS_IPHONE_5)
            {
                deviceType=@"iPhone_5";
            }
            else if (IS_IPHONE_6)
            {
                deviceType=@"iPhone_6";
            }
            else if (IS_IPHONE_6P)
            {
                deviceType=@"iPhone_6P";
            }
            else{
                deviceType=@"iPhone_4";
            }
            
            NSString *deviceDetail=[NSString stringWithFormat:@"v%@, IOS %.1f, %@",[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"],[[[UIDevice currentDevice] systemVersion] floatValue],deviceType];//[deviceDetail stringByAppendingString:];
            NSString *postString=[NSString stringWithFormat:@"phoneId=%@&lat=%f&lon=%f&type=%@&text=%@&os=%@",[TTUtilities getSerialNumberString],reportLocation.latitude,reportLocation.longitude,type,[textView text],deviceDetail];
            
            NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            NSString *postLength = [NSString stringWithFormat:@"%d", [postVariables length]];
            NSURL *postURL = [NSURL URLWithString:@"http://www.teletype.com/truckroutes/customer_report.php"];
            [request setURL:postURL];
            [request setHTTPMethod:@"POST"];
            [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody: postVariables];
            
            //get
            NSError *error = nil;
            NSHTTPURLResponse *responseCode = nil;
            NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
            if (!error) {
                NSString *string = [[[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding] autorelease];
                
                if ([string isEqualToString:@"1"]) {
                    NSLog(@"Responce String : %@",string);
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your report has been successfully submitted. Thank you." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                }
            }
        } else if (buttonIndex == alertView1.cancelButtonIndex) {
            
        }
    };
    
    //    av.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView1) {
    //        return ([[textView text] length] > 0);
    //    };
    [av show];
}

#pragma mark - uiactionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==108 || actionSheet.tag==109)
    {//@"Low Bridge",@"Hazmet",@"Trucks Not Allowed",@"Narrow Road"
        NSString *typeString=nil;
        switch (buttonIndex) {
            case 0:
                typeString=@"Low Bridge";
                break;
            case 1:
                typeString=@"Hazmat";
                break;
            case 2:
                typeString=@"RV Not Allowed";
                break;
            case 3:
                typeString=@"Narrow Road";
            case 4:
                typeString=@"Missing Feature";
            case 5:
                typeString=@"Busses Not Allowed";
                break;
            case 6:
                typeString=@"Weight Station Info";
                break;
            case 7:
                typeString=@"Weight Restricted";
                break;
            case 8:
                typeString=@"Width Restricted";
                break;
            case 9:
                typeString=@"Sharp Turn";
                break;
            case 10:
                typeString=@"Other";
                break;
                
            default:
                return;
                break;
        }
        if (actionSheet.tag==108) {
            [self sendCustomerReports:typeString from:0];
        }
        else{
            [self sendCustomerReports:typeString from:1];
        }
        
        return;
    }
    if (actionSheet==actionSheet1) {
        if (buttonIndex==2) {
            return;
        }
    }
    else{
        if (buttonIndex==4) {
            return;
        }
    }
    CLGeocoder *geocoder;
    CLLocation *loct;
    NSUserDefaults *userDefaults;
    UIStoryboard *storyBoard;
  //  TTNewRouteViewController *nrvc;
    geocoder = [[CLGeocoder alloc] init];
    loct=[[CLLocation alloc]initWithLatitude:coord_press.latitude longitude:coord_press.longitude];
    [geocoder reverseGeocodeLocation:loct
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(),^
                        {
                            if (placemarks.count == 1){
                                CLPlacemark *place = [placemarks objectAtIndex:0];
                                if (actionSheet==actionSheet1){
                                    if (buttonIndex==0){
                                        [self saveCurrentLocation:place tag:10];
                                    }
                                    else if(buttonIndex==1){
                                        [self saveCurrentLocation:place tag:11];
                                    }
                                }
                                else if(actionSheet == actionSheet2){
                                    if (buttonIndex==0){
                                        [self saveCurrentLocation:place tag:11];
                                    }
                                    else if(buttonIndex==1){
                                        [self saveCurrentLocation:place tag:12];
                                    }
                                }
                                else {
                                    if (buttonIndex==0){
                                        [self saveCurrentLocation:place tag:10];
                                    }
                                    else if(buttonIndex==1){
                                        [self saveCurrentLocation:place tag:11];
                                    }
                                    else if(buttonIndex==2){
                                        [self saveCurrentLocation:place tag:12];
                                    }
                                    else if(buttonIndex==3)
                                    {
                                        UIActionSheet *typeActionSheet=[[UIActionSheet alloc]initWithTitle:@"Select Type \n Report issue at or near current location. (To report another location issue, long tap on map in the new location  And Press on \"Report feedback for this location \")" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Low Bridge",@"Hazmat",@"RV Not Allowed",@"Narrow Road",@"Missing Feature",@"Busses Not Allowed",@"Weigh Station Info",@"Weight Restricted",@"Width Restricted",@"Sharp Turn",@"Other", nil];
                                        typeActionSheet.tag=109;
                                        [typeActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
                                        //                                        UIActionSheet *typeActionSheet=[[UIActionSheet alloc]initWithTitle:@"Select Type \n " delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Low Bridge",@"Hazmat",@"Trucks Not Allowed",@"Narrow Road",@"Other", nil];
                                        //                                        typeActionSheet.tag=109;
                                        //                                        [typeActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
                                    }
                                }
                            }
                        });
     }];
    
    /*
     switch (buttonIndex) {
     case 0:
     NSLog(@"route to");
     geocoder = [[CLGeocoder alloc] init];
     loct=[[CLLocation alloc]initWithLatitude:coord_press.latitude longitude:coord_press.longitude];
     [geocoder reverseGeocodeLocation:loct
     completionHandler:^(NSArray *placemarks, NSError *error)
     {
     dispatch_async(dispatch_get_main_queue(),^
     {
     if (placemarks.count == 1)
     {
     CLPlacemark *place = [placemarks objectAtIndex:0];
     [self saveCurrentLocation:place tag:10];
     }
     });
     }];
     break;
     
     case 1:
     NSLog(@"route from");
     geocoder = [[CLGeocoder alloc] init];
     loct=[[CLLocation alloc]initWithLatitude:coord_press.latitude longitude:coord_press.longitude];
     [geocoder reverseGeocodeLocation:loct
     completionHandler:^(NSArray *placemarks, NSError *error)
     {
     dispatch_async(dispatch_get_main_queue(),^
     {
     if (placemarks.count == 1)
     {
     CLPlacemark *place = [placemarks objectAtIndex:0];
     [self saveCurrentLocation:place tag:11];
     }
     });
     }];
     break;
     
     case 2:
     NSLog(@"add");
     //CLLocationCoordinate2D
     geocoder = [[CLGeocoder alloc] init];
     loct=[[CLLocation alloc]initWithLatitude:coord_press.latitude longitude:coord_press.longitude];
     [geocoder reverseGeocodeLocation:loct
     completionHandler:^(NSArray *placemarks, NSError *error)
     {
     dispatch_async(dispatch_get_main_queue(),^
     {
     if (placemarks.count == 1)
     {
     CLPlacemark *place = [placemarks objectAtIndex:0];
     [self saveCurrentLocation:place tag:12];
     }
     });
     }];
     break;
     
     default:
     break;
     }*/
}

-(void)saveCurrentLocation:(CLPlacemark *)placeObj tag:(int)tag
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Name this point:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    alert.tag=tag;
    [alert show];
    
    objc_setAssociatedObject(alert, &fooKey, placeObj, OBJC_ASSOCIATION_RETAIN);
    
    // alert.tag=11;
    //[alert release];
    //    NSArray *addressArray=[placeObj.addressDictionary objectForKey:@"FormattedAddressLines"];
    //    NSLog(@"Address Array: %@",addressArray);
    //    NSString *addressStr=[NSString stringWithFormat:@"%@,%@ ,%@ \n%.6f,%.6f ",[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],(addressArray.count==3) ? [addressArray objectAtIndex:2] :@"",placeObj.location.coordinate.latitude,placeObj.location.coordinate.longitude];
    //    [self updateHistory:addressStr];
    
}

-(void)updateHistory:(NSString *)value
{
    //if(resultArray.count > 0 && idxSelected < resultArray.count)
    {
        //retrieve the saved location array, then insert the new location and save the array
        NSArray *arrayHistory = nil;
        NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
        arrayHistory = [dataDefault arrayForKey:@"History"];
        //check if the result already exists
        for (id record in arrayHistory)
        {
            NSString *recordString = [record objectForKey:@"LocationString"];
            if ([value isEqual:recordString])
            {
                //no change
                return;
            }
        }
        NSMutableArray *arrayNew = [[NSMutableArray alloc]init];
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setValue:value forKey:@"LocationString"];
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

-(IBAction)didTapTitleView:(id)sender
{
    //[btn setImage:[UIImage imageNamed:@"notification_icon2.png"] forState:UIControlStateNormal];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

-(IBAction)travelAlertViewController:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (!self.popoverController)
    {
        
        [btn setImage:[UIImage imageNamed:@"notification_icon2_selected.png"] forState:UIControlStateNormal];
        
        WEPopoverContentViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
        contentViewController.delegate=self;
        
        CGRect frame =travelAlertsButton.frame; //[tableView cellForRowAtIndexPath:indexPath].frame;
        //double percentage =  (rand() / ((double)RAND_MAX));
        //double percentage = 0.95;
        //CGRect rect = CGRectMake(frame.size.width * percentage, frame.origin.y, 1, frame.size.height);
        CGRect rect = frame;
        
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:contentViewController];
        UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleLabelButton setTitle:@"Travel Alerts" forState:UIControlStateNormal];
        titleLabelButton.frame = CGRectMake(0, 0, 70, 44);
        [titleLabelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        titleLabelButton.font = [UIFont boldSystemFontOfSize:16];
        [titleLabelButton addTarget:self action:@selector(didTapTitleView:) forControlEvents:UIControlEventTouchUpInside];
        contentViewController.navigationItem.titleView = titleLabelButton;
        self.popoverController = [[[popoverClass alloc] initWithContentViewController:nav] autorelease];
        
        if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)])
        {
            [self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
        }
        
        self.popoverController.delegate = self;
        
        //Uncomment the line below to allow the table view to handle events while the popover is displayed.
        //Otherwise the popover is dismissed automatically if a user touches anywhere outside of its view.
        
        self.popoverController.passthroughViews = [NSArray arrayWithObject:self.view];
        
        [self.popoverController presentPopoverFromRect:rect
                                                inView:self.view
                              permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown|
                                                        UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight)
                                              animated:YES];
        //currentPopoverCellIndex = indexPath.row;
        
        [contentViewController release];
    } else
    {
        [btn setImage:[UIImage imageNamed:@"notification_icon2.png"] forState:UIControlStateNormal];
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
    
//        if (travelAlertView.hidden) {
//            [travelAlertView reloadTableView];
//            travelAlertView.hidden=NO;
//        }
//        else{
//            travelAlertView.hidden=YES;
//        }
}

-(void)selectedLocationFromNotification:(NSString *)lat longitute:(NSString *)lon
{
    NSLog(@"Lat : %@ , Lon : %@",lat,lon);
    
    _mapView.showsUserLocation=NO;
    
    CLLocation *location=[[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    
    if (notificationAnnotaion)
    {
        [_mapView removeAnnotation:notificationAnnotaion];
    }
    
    notificationAnnotaion = [[MKPointAnnotation alloc] init];
    //annotationPoint.
    notificationAnnotaion.coordinate = location.coordinate;
    notificationAnnotaion.title = @"Microsoft";
    notificationAnnotaion.subtitle = @"Microsoft's headquarters";
    [_mapView addAnnotation:notificationAnnotaion];
    
    _mapView.camera.centerCoordinate=location.coordinate;
    
    _mapView.camera.altitude=4000;
    [travelAlertsButton setImage:[UIImage imageNamed:@"notification_icon2.png"] forState:UIControlStateNormal];
    
    _mapView.camera.centerCoordinate=location.coordinate;
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
    
    // _mapView.showsUserLocation=YES;
}

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
    
    WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
    NSString *bgImageName = nil;
    CGFloat bgMargin = 0.0;
    CGFloat bgCapSize = 0.0;
    CGFloat contentMargin = 4.0;
    
    bgImageName = @"popoverBg.png";
    
    // These constants are determined by the popoverBg.png image file and are image dependent
    bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
    bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
    
    props.leftBgMargin = bgMargin;
    props.rightBgMargin = bgMargin;
    props.topBgMargin = bgMargin;
    props.bottomBgMargin = bgMargin;
    props.leftBgCapSize = bgCapSize;
    props.topBgCapSize = bgCapSize;
    props.bgImageName = bgImageName;
    props.leftContentMargin = contentMargin;
    props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
    props.topContentMargin = contentMargin;
    props.bottomContentMargin = contentMargin;
    
    props.arrowMargin = 4.0;
    
    props.upArrowImageName = @"popoverArrowUp.png";
    props.downArrowImageName = @"popoverArrowDown.png";
    props.leftArrowImageName = @"popoverArrowLeft.png";
    props.rightArrowImageName = @"popoverArrowRight.png";
    return props;
}

-(IBAction)customerReportButtonClick:(id)sender
{
   
    
    UIActionSheet *typeActionSheet=[[UIActionSheet alloc]initWithTitle:@"Select Type \n Report issue at or near current location. (To report another location issue, long tap on map in the new location  And Press on \"Report feedback for this location \")" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Low Bridge",@"Hazmat",@"RV Not Allowed",@"Narrow Road",@"Missing Feature",@"Busses Not Allowed",@"Weigh Station Info",@"Weight Restricted",@"Width Restricted",@"Sharp Turn",@"Other", nil];
    typeActionSheet.tag=108;
    if(IS_IPAD)
    {
        [typeActionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    }
    else{
        [typeActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    }
    //[typeActionSheet]
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (typePickerView.tag==1) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger type = [userDefaults integerForKey:@"trip_info_panel1"];
        [userDefaults removeObjectForKey:@"trip_info_panel1"];
        [userDefaults setInteger:row forKey:@"trip_info_panel1"];
        [userDefaults synchronize];
        //    NSLog(@"set panel2 %d", type);
        [self setTripPanelAtIndex:1];

    }
    else if (typePickerView.tag==2)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger type = [userDefaults integerForKey:@"trip_info_panel2"];
            [userDefaults removeObjectForKey:@"trip_info_panel2"];
        [userDefaults setInteger:row forKey:@"trip_info_panel2"];
        [userDefaults synchronize];
        //    NSLog(@"set panel2 %d", type);
        [self setTripPanelAtIndex:2];
    }
    else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger type = [userDefaults integerForKey:@"trip_info_panel3"];
        [userDefaults removeObjectForKey:@"trip_info_panel3"];
        [userDefaults setInteger:row forKey:@"trip_info_panel3"];
        [userDefaults synchronize];
        [self setTripPanelAtIndex:3];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    NSLog(@"Auto Rotation Complete");
//    CGRect screenRect=[UIScreen mainScreen].bounds;
//     NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    CGRect instructionDiscloserViewRect=instructionDiscloserView.frame;
//    if (!IS_IPAD) {
//        float w=0,h=0;
//        if (screenRect.size.width>screenRect.size.height) {
//            h=screenRect.size.width;
//            w=screenRect.size.height;
//        }
//        else{
//            h=screenRect.size.height;
//            w=screenRect.size.width;
//        }
//        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
//          //  NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
//            instructionDiscloserViewRect.origin.x=77;
//            instructionDiscloserViewRect.size.width=h- 154;
//        }
//        else{
//            instructionDiscloserViewRect.origin.x=7;
//            instructionDiscloserViewRect.size.width=w-14;
//        }
//    }
//    else{
//        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
//            instructionDiscloserViewRect.origin.x=115;
//            instructionDiscloserViewRect.size.width=799;
//        }
//        else{
//            instructionDiscloserViewRect.origin.x=110;
//            instructionDiscloserViewRect.size.width=548;
//        }
//
//    }
//    instructionDiscloserView.frame=instructionDiscloserViewRect;
//    if (!IS_IPAD) {
//        float screenHeight=_mapView.frame.size.height;
//        float screenWidth=_mapView.frame.size.width;
//        
//        if (fromInterfaceOrientation== UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
//        {
//            navInfoViewForiPhone.frame=CGRectMake(0,screenHeight-30,screenWidth,30);
//        }
//        else{
//            navInfoViewForiPhone.frame=CGRectMake(0,screenHeight-44,screenWidth,44);
//        }
//    }

}

-(IBAction)pickerDoneButtonClick:(id)sender
{
    CGRect rect=pickerHolderView.frame;
    rect.origin.y+=206;
    pickerHolderView.frame=rect;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Auto Rotation Complete");
    CGRect screenRect=[UIScreen mainScreen].bounds;
    NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGRect instructionDiscloserViewRect=instructionDiscloserView.frame;
    if (!IS_IPAD) {
        float w=0,h=0;
        if (screenRect.size.width>screenRect.size.height) {
            h=screenRect.size.width;
            w=screenRect.size.height;
        }
        else{
            h=screenRect.size.height;
            w=screenRect.size.width;
        }
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            //  NSLog(@"Screen Frame : %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
            instructionDiscloserViewRect.origin.x=77;
            instructionDiscloserViewRect.size.width=h- 154;
        }
        else{
            instructionDiscloserViewRect.origin.x=7;
            instructionDiscloserViewRect.size.width=w-14;
        }
    }
    else{
        if(UIDeviceOrientationIsLandscape(deviceOrientation)){
            instructionDiscloserViewRect.origin.x=115;
            instructionDiscloserViewRect.size.width=799;
        }
        else{
            instructionDiscloserViewRect.origin.x=110;
            instructionDiscloserViewRect.size.width=548;
        }
        
    }
    instructionDiscloserView.frame=instructionDiscloserViewRect;
}

// recreate avaudiosynthesizer when AVAudioSessionRouteChangeNotification is recieved
- (void)audioRouteChanged:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    // get the AVAudioSessionInterruptionTypeKey enum from the dictionary
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    // decide what to do based on interruption type here...
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio Session Interruption case started.");
            // When the audio session is interupted, recreate the speech synthesizer.
            self.synthesizer = nil;
            self.synthesizer = [[AVSpeechSynthesizer alloc] init];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"Audio Session Interruption case ended.");
            break;
        default:
            NSLog(@"Audio Session Interruption Notification case default.");
            break;
    }
}

//Audio route session notifications
- (void)routeChange:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");//AVAudioSessionRouteChangeReasonCategoryChange
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            break;
    }
}

- (void)createRouteFromUrlSchemeInfo:(NSDictionary *)infoFromUrl
{
    [self createRouteWithRouteInfo:infoFromUrl];
}

- (void)createRouteWithRouteInfo:(NSDictionary *)info
{
    
    [self mainMenuAnimation:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //TTNewRouteViewController *nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    TTNewRouteViewController *nrvc = nil;
    if (IS_IPAD) {
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
    }
    else{
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    }
    [nrvc setParentVC:self];
    [nrvc setIsNotificationOn:YES];
    //[self presentViewController:nrvc animated:YES completion:nil];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:nrvc animated:NO completion:^{
            [nrvc createRouteFromUrlInfo:info];
        }];
    }
    else{
        [self presentViewController:nrvc animated:YES completion:^{
            [nrvc createRouteFromUrlInfo:info];
        }];
    }
}

#pragma mark speechSynthesizer delegate methods
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSError *activationError = nil;
    BOOL isPlayingWithOthers = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
    if (isPlayingWithOthers) {
        [[AVAudioSession sharedInstance ] setActive:NO error:&activationError];
    }
}

@end
