//
//  TTMapViewController.h
//  TruckRoute_NavigatorController
//
//  Created by admin on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UIAlertView+Blocks.h"
#import "CustomPlacemark.h"
#import "TTWeightStationAlert.h"
#import "WEPopoverContentViewController.h"
#import "TTTravelAlertView.h"
#import "UILabel+adjustsFontSize.h"
#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "KMLParser.h"
#import "TTRouteRequest.h"
#import "TTRouteAnalyzer.h"
#import "TTPOIManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MessageUI/MessageUI.h>
#import "WEPopoverController.h"
#import "CustomIOS7AlertView.h"
#import "GADBannerView.h"
#import "JSON.h"
#import "UIView+Glow.h"
//⚠
@interface TTMapViewController : UIViewController <CLLocationManagerDelegate, AVAudioPlayerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate,WEPopoverControllerDelegate,WEPopoverDelegate,TTWeightStationAlert, AVSpeechSynthesizerDelegate>{
    IBOutlet MKMapView *_mapView;
#ifdef __IPHONE_7_0
    //ios7 map camera
    //    MKMapCamera *camera;
#endif
    /*
     mapview layers before
     {
     MKMapView
     UIView
     MKScrollView
     MKMapTileView
     MKAnnotationContainerView
     UIImageView
     }
     
     mapview layers for ios6
     {
     MKMapView
     UIView
     VKMapView
     VKMapCanvas
     MKScrollContainerView
     MKAnnotationContainerView
     MKAttributionLabel
     }
     */
    //sub views of the mapView
    //    UIImageView *GoogleImgView;
    //    MKAnnotationView *annotationContainerView;
    //    UIView *mainSubView;
    
    Class popoverClass;
    
    //route
    KMLParser *kmlParser;
    TTRouteRequest *routeRequest;
    NSString *destinationTimeZone;
    UIImageView* routeView;
    
    //set navigating loop here to control mapview and routeAnalyzer
    TTRouteAnalyzer *routeAnalyzer;
    CLLocationManager *locationManager;
    NSTimer *timer;
    TTNavInfo *navInfo;
    
    //waiting animation for reroute
    //    NSTimer *timerAnimation;
    UIActivityIndicatorView *spinner;
    
    //annotations
    BOOL isAnnotationAdded;
    MKPointAnnotation *annotationEnd;
    MKAnnotationView *annotationviewEnd;
    
    MKPointAnnotation *annotationNavCursor;
    MKAnnotationView *annotationviewNavCursor;
    
    NSMutableArray *annotationsIns;
    NSMutableArray *annotationviewsIns;
    //    UIImage *navCursorImg;
    
    //reroute request
    NSString *server_url;
    // State Change
    NSTimer *timer_state;
    NSString *oldState;
    NSString *newState;
    //voice
    
    //abbreviation dictionary
    NSDictionary *abbDictionary;
    
    //pois
    TTPOIManager *poiManager;
    NSTimer *timer_poi;
    NSMutableArray *annotationsPOIs;
    NSMutableArray *annotationviewsPOIs;
    MKCoordinateRegion last_region;
    NSMutableArray *poiResults;
    
    //gas stations
    NSMutableArray *annotationsGas;
    NSMutableArray *annotationviewsGas;
    NSURLConnection *connection_gas_station;
    NSMutableData *data_gas_station;
    BOOL isSearchingGasStation;
    CLLocationCoordinate2D last_coord_gas_station;
    
    //poi display
    BOOL isTruckStopOn;
    BOOL isWeightstationOn;
    BOOL isTruckDealerOn;
    BOOL isTruckParkingOn;
    BOOL isGasStationOn;
    BOOL isCatScaleOn;
    BOOL isRestAreaOn;
    BOOL isCampground;
    BOOL isSearchOn;
    BOOL isWeighScaleAlert;
    BOOL weightStationAlert;
    BOOL isSpeedZero;
    //lane assist
    UIView *laneassistView;
    
    //odometer
    NSTimer *timer_odo;
    NSTimer *speedAlertTimer;
    
    //long press
    CLLocationCoordinate2D coord_press;
    
    int timeValue;
    BOOL newFunction;
    int travel_speed;
    BOOL isSpeedLimitAlert;
    /// for Travel Alert
    TTTravelAlertView *travelAlertView;
    
    MKPointAnnotation *notificationAnnotaion;
    MKPointAnnotation *historyAnnotaion;
    TTWeightStationAlert *weightStation;
    
    UIActionSheet *actionSheet1;
    UIActionSheet *actionSheet2;
    
    CustomIOS7AlertView *alertView;
    
    IBOutlet UILabel *locUpdateTime;
    
    float lastZoomLevel;
    
    GADBannerView *bannerView_;
    
    IBOutlet UIView *directionInfoView;
    IBOutlet UIView *routeDetailView;
    IBOutlet UIView *navInfoViewForiPhone;
    IBOutlet UIView *navInfoViewForiPad;
    IBOutlet UIView *speedLimitView;
    IBOutlet UIImageView *speedLimitBg;
    IBOutlet UILabel *speedLimitLbl;
    
    IBOutlet UIView *instructionDiscloserView;
    IBOutlet UIView *instructionDiscloserSubView;
    IBOutlet UIButton *instructionDescloserBtn;
    IBOutlet UILabel *firstInstructionLbl;
    IBOutlet UILabel *firstSubInstructionLbl;
    IBOutlet UIImageView *firstDirectionImage;
    
    IBOutlet UILabel *secondInstructionLbl;
    IBOutlet UILabel *secondSubInstructionLbl;
    IBOutlet UIImageView *secondDirectionImage;
    
    IBOutlet UIView *pickerHolderView;
    
    IBOutlet UIPickerView *typePickerView;
    NSArray *_pickerData;
    
    IBOutlet UIView *topPoiView;
    

}
-(IBAction)pickerDoneButtonClick:(id)sender;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (nonatomic,retain)NSArray *speedLimitArray;
@property (nonatomic, retain) WEPopoverController *popoverController;

@property (nonatomic, assign) TTUtilities *utility;

@property (assign, nonatomic) BOOL needReload;
@property (assign, nonatomic) BOOL isNavigating;
@property (assign, nonatomic) BOOL isMainMenuShown;
@property (assign, nonatomic) double  dZoomLevel;
@property (assign, nonatomic) double  last_zoom_level;
@property (assign, nonatomic) BOOL isMenuHidden;
@property (assign, nonatomic) BOOL isPanelHidden;
@property (nonatomic, retain) NSMutableData *responseData;
//configurations
@property (assign, nonatomic) NSInteger nOffRouteCount;
//settings
@property (assign, nonatomic) enum TT_TRIP_INFO_TYPE tripInfo_panel1;
@property (assign, nonatomic) enum TT_TRIP_INFO_TYPE tripInfo_panel2;
@property (assign, nonatomic) enum TT_TRIP_INFO_TYPE tripInfo_panel3;
@property (assign, nonatomic) BOOL isNorthUp;
@property (assign, nonatomic) BOOL isSimulating;
@property (assign, nonatomic) BOOL isAutoReroute;
@property (assign, nonatomic) BOOL isTravelAlerts;
@property (assign,nonatomic) BOOL isWeighScaleAlerts;
@property (assign, nonatomic) BOOL isAutoZoom;
@property (assign, nonatomic) BOOL isShowBuildings;
@property (assign, nonatomic) BOOL isPerspective;
@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) BOOL isVoiceOn;
@property (nonatomic, assign) float rateValue;
@property (nonatomic, assign) float pitchValue;
@property (nonatomic, assign) BOOL isUnitMetric;
@property (nonatomic, assign) BOOL is24Hour;
@property (nonatomic, assign) BOOL isOdometerOn;
@property (nonatomic, assign) BOOL isUserTips;
@property (nonatomic, assign) BOOL isSpeedWarning;

//flitecontroller
//@property (nonatomic, strong) FliteController *fliteController;

//actions
- (IBAction)zoomOut:(id)sender;
- (IBAction)zoomIn:(id)sender;
//- (IBAction)toggleSimulation:(id)sender;
- (IBAction)toggleNorthUp:(id)sender;
- (IBAction)toggleMenu:(id)sender;
- (IBAction)checkRouteInstruction:(id)sender;
- (IBAction)navigate:(id)sender;
- (IBAction)tapScreen:(id)sender;
- (IBAction)incrementTripPanel1Type:(id)sender;
- (IBAction)incrementTripPanel2Type:(id)sender;
- (IBAction)incrementTripPanel3Type:(id)sender;
- (IBAction)showMenu:(id)sender;
- (IBAction)newRoute:(id)sender;
- (IBAction)find:(id)sender;
- (IBAction)setup:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)rerouteManually:(id)sender;
- (IBAction)repeatInstruction:(id)sender;
- (IBAction)routeDetails:(id)sender;
- (IBAction)pinchMapView:(id)sender;
- (IBAction)longpressMapView:(id)sender;
- (IBAction)clickMapView:(id)sender;
- (IBAction)rotateMapView:(id)sender;
- (void)make3DMapView:(id)sender;
//outlets
//@property (retain, nonatomic) IBOutlet UIButton *simuButton;
@property (retain, nonatomic) IBOutlet UIButton *northUpButton;
//@property (retain, nonatomic) IBOutlet UIButton *accountButton;
//@property (retain, nonatomic) IBOutlet UIButton *instructionButton;
@property (retain, nonatomic) IBOutlet UIButton *navButton;
@property (retain, nonatomic) IBOutlet UIImageView *menuPanel;
@property (retain, nonatomic) IBOutlet UIButton *menuButton;
@property (retain, nonatomic) IBOutlet UIImageView *lowerPanel;
@property (retain, nonatomic) IBOutlet UIImageView *upperPanel;
@property (retain, nonatomic) IBOutlet UIImageView *graphPanel;
@property (retain, nonatomic) IBOutlet UIImageView *splitLine;
@property (retain, nonatomic) IBOutlet UIImageView *leftArrowsImg;
@property (retain, nonatomic) IBOutlet UIImageView *rightArrowsImg;
@property (retain, nonatomic) IBOutlet UIImageView *directionImg;
@property (retain, nonatomic) IBOutlet UILabel *labelInstruction;
@property (retain, nonatomic) IBOutlet UILabel *labelGraph;

@property (retain, nonatomic) IBOutlet UILabel *labelTripInfo1;
@property (retain, nonatomic) IBOutlet UILabel *labelTripInfo2;
@property (retain, nonatomic) IBOutlet UILabel *labelTripInfo3;
@property (retain, nonatomic) IBOutlet UILabel *labelTripTitle1;
@property (retain, nonatomic) IBOutlet UILabel *labelTripTitle2;
@property (retain, nonatomic) IBOutlet UILabel *labelTripTitle3;
@property (retain, nonatomic) IBOutlet UILabel *labelTripFoot1;
@property (retain, nonatomic) IBOutlet UILabel *labelTripFoot2;
@property (retain, nonatomic) IBOutlet UILabel *labelTripFoot3;
@property (retain, nonatomic) IBOutlet UIButton *btnTripPanel1;
@property (retain, nonatomic) IBOutlet UIButton *btnTripPanel2;
@property (retain, nonatomic) IBOutlet UIButton *btnTripPanel3;

@property (retain, nonatomic) IBOutlet UILabel *labelTripInfo1_iphone;
@property (retain, nonatomic) IBOutlet UILabel *labelTripInfo2_iphone;
@property (retain, nonatomic) IBOutlet UILabel *labelTripTitle1_iphone;
@property (retain, nonatomic) IBOutlet UILabel *labelTripTitle2_iphone;
@property (retain, nonatomic) IBOutlet UILabel *labelTripFoot1_iphone;
@property (retain, nonatomic) IBOutlet UILabel *labelTripFoot2_iphone;
@property (retain, nonatomic) IBOutlet UIButton *btnTripPanel1_iphone;
@property (retain, nonatomic) IBOutlet UIButton *btnTripPanel2_iphone;

@property (retain, nonatomic) IBOutlet UIButton *btnMenu;
@property (retain, nonatomic) IBOutlet UIImageView *imgMainMenuPanel;
@property (retain, nonatomic) IBOutlet UIView *viewMainMenuPanel;
@property (retain, nonatomic) IBOutlet UIButton *btnNewRoute;
@property (retain, nonatomic) IBOutlet UIButton *btnFind;
@property (retain, nonatomic) IBOutlet UIButton *btnSettings;
@property (retain, nonatomic) IBOutlet UIButton *btnHelp;
@property (retain, nonatomic) IBOutlet UIButton *btnClearRoute;
@property (retain, nonatomic) IBOutlet UIImageView *imgCover;
@property (retain, nonatomic) IBOutlet UIButton *btnZoomIn;
@property (retain, nonatomic) IBOutlet UIButton *btnZoomOut;
@property (retain, nonatomic) IBOutlet UIButton *btn3DView;
@property (retain, nonatomic) IBOutlet UIButton *btnReroute;
@property (retain, nonatomic) IBOutlet UIButton *btnReport;
@property (retain, nonatomic) IBOutlet UIButton *btnAnnounce;
@property (retain, nonatomic) IBOutlet UIButton *btnRouteDetails;
@property (retain, nonatomic) IBOutlet UIImageView *imgNavCursor;

@property (retain, nonatomic) IBOutlet UIButton *speedPlusButton;
@property (retain, nonatomic) IBOutlet UIButton *speedMinButton;
@property (retain, nonatomic) IBOutlet UIButton *travelAlertsButton;
//////////////////////
//menu buttons
@property (retain, nonatomic) IBOutlet UIButton *menuButtonTruckStop;
- (IBAction)toggleTruckStop:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonWeighStation;
- (IBAction)toggleWeighStation:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonTruckDealer;
- (IBAction)toggleTruckDealer:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonTruckParking;
- (IBAction)toggleTruckParking:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonGasStation;
- (IBAction)toggleGasStation:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonRestArea;
- (IBAction)toggleRestArea:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonCatScale;
- (IBAction)toggleCatScale:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *svMenu;
//////////////////////
@property (retain, nonatomic) IBOutlet UILabel *labelZoom;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation;
@property (retain, nonatomic) IBOutlet UIButton *menuButtonSearch;
- (IBAction)toggleMenuButtonSearch:(id)sender;

-(void)updateMenuButtons;


//route related
-(void)loadKML;//into route analyzer and mapview
-(void)setRouteRequest:(TTRouteRequest *)aRequest;
-(void)prepareInstructionAnnotations:(NSArray *)instructions;
-(void)clearInstructionAnnotations;

//settings
-(void)loadNavSettings;

//reroute
-(BOOL)shouldReroute;
-(void)submitRerouteRequest;

//navigating
-(void)startNavigating;
-(void)stopNavigating;
-(void)doNavigating;
-(void)clearRoute;
-(void)suspendNavigating;
-(void)resumeNavigating;
-(void)resetFlags;

//poi
-(void)updatePOIs;
-(void)clearPOIAnotations;
-(BOOL)needReloadPOIInRegion:(MKCoordinateRegion)region;
-(MKAnnotationView *)viewForPOI:(id <MKAnnotation>)annotation;


//gas station
-(void)searchGasStation;//by current location
-(void)processGasStationSearchingResult;
-(void)addGasStations:(NSArray *)array;
-(void)clearGasStations;
-(MKAnnotationView *)viewForGasStation:(id <MKAnnotation>)annotation;
-(void)updatePOIResults;
-(BOOL)needRefreshGasStaion;

//process pois before adding into mapview
-(NSArray *)thinPOI:(NSArray *)arrayPOI;
-(void)clearPOIResults;
-(void)addPOISearchResults:(NSArray *)arrayPOI;
-(void)dismissPOISearchResults;

//view
-(void)updateView;
- (MKAnnotationView *)viewForDestination;
- (MKAnnotationView *)viewForInstruction:(id <MKAnnotation>)annotation;
-(void)updateInstructionAnnotations;
-(void)updateZoom;
-(void)calculateZoom;
-(void)adjustZoomBySpeed:(double)speed;//in mph
-(void)setTrackingMode;//based on northup flag

//lane assist
-(void)updateLaneAssist;
-(void)clearLaneAssist;

//nav panel
-(void)updateNavPanel;
-(void)navPanelAnimation:(BOOL)isHiding;
-(void)setTripPanelAtIndex:(int)index;
-(void)updateTripInfoPanelAtIndex:(int)index;
-(void)clearNavPanel;

//waiting animation
-(void)initSpinner;
-(void)startWaiting;
-(void)stopWaiting;
//-(void)doWaitingAnimationForRoute;

//buttons
-(void)updateNorthUpButton;

//main menu
-(void)mainMenuAnimation:(BOOL)isHiding;

//button menu
-(void)buttonMenuAnimation:(BOOL)isHiding;

//voice
-(void)announce;//if necessary
-(void)playWarningSound;
-(void)playRemindingSound;
-(void)read:(NSString *)str;
-(void)initAbbreviationDictionary;
-(NSString *)checkAbbreviation:(NSString *)str;

//execute requests from outside of the view
-(void)pauseNavigatingFromOutside;
-(void)moveToCoordinate:(CLLocationCoordinate2D )coord withZoomLevel:(double)zoomLevel;

//odometer
-(void)resetOdometer;
-(void)updateOdometer;

//memory check
-(void)print_free_memory;

//menu button instruction message
-(void)menuButtonRemind;

//  speed plus , minus button
-(IBAction)changeSpeedButtonClick:(id)sender;
- (void)createRouteFromUrlSchemeInfo:(NSDictionary *)infoFromUrl;

-(IBAction)travelAlertViewController:(id)sender;

-(IBAction)customerReportButtonClick:(id)sender;
-(IBAction)instructionDescloserButtonClick:(id)sender;
@end