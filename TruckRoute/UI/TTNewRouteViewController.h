//
//  TTNewRouteViewController.h
//  TruckRoute
//
//  Created by admin on 9/21/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
#import "UIAlertView+NSCookbook.h"
#import "TTHistoryViewController.h"
#import <UIKit/UIKit.h>
#import "TTMapViewController.h"
#import "TTRouteRequest.h"
#import "TTUtilities.h"
#import <MessageUI/MessageUI.h>
@protocol NewRouteBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@interface TTNewRouteViewController : UIViewController<CLLocationManagerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate,NewRouteBackButtonClick,historyDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    CLLocationManager *locationManager;
    TTRouteRequest *route_request;
    NSString *server_url;
    NSTimer *another_timer;
    UIActivityIndicatorView *spinner;
    
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    IBOutlet UIView *topView;
    IBOutlet UIView *centerLeftView;
    IBOutlet UIView *centerRightView;
    IBOutlet UIView *bottomView;
    BOOL isShowingLandscapeView;
    
    IBOutlet UIView *iPhoneLandscapeMainView;
    IBOutlet UIView *iPhonePortraitMainView;
    //BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<NewRouteBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
@property (nonatomic, assign) BOOL isUserDefinedStartLocation;
//@property (nonatomic, assign) TTUtilities *utility;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) TTMapViewController *parentVC;
@property (retain, nonatomic) IBOutlet UILabel *labelMode;
@property (retain, nonatomic) IBOutlet UILabel *labelToll;
@property (retain, nonatomic) IBOutlet UILabel *labelMode_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelToll_landscape;
@property (retain, nonatomic) IBOutlet UIImageView *imgCover;
@property (retain, nonatomic) IBOutlet UILabel *labelEndAddress;
@property (retain, nonatomic) IBOutlet UILabel *labelEndAddress_landscape;
//vehicle info
@property (retain, nonatomic) IBOutlet UILabel *labelHeight;
@property (retain, nonatomic) IBOutlet UILabel *labelWeight;
@property (retain, nonatomic) IBOutlet UILabel *labelLength;
@property (retain, nonatomic) IBOutlet UILabel *labelWidth;
@property (retain, nonatomic) IBOutlet UILabel *labelHazmat;

@property (retain, nonatomic) IBOutlet UILabel *labelHeight_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelWeight_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelLength_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelWidth_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelHazmat_landscape;
@property (retain, nonatomic) IBOutlet UIView * carModeVehicleInfoViewPotrait;
@property (retain, nonatomic) IBOutlet UIView * carModeVehicleInfoViewLandscape;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray * vehicleInfoEditButton;

- (IBAction)backToMapView:(id)sender;
- (IBAction)createRoute:(id)sender;
- (IBAction)setEndAddress:(id)sender;
- (IBAction)historyEnd:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)tapToll:(id)sender;
- (IBAction)swipRouteTypeRight:(id)sender;
- (IBAction)swipRouteTypeLeft:(id)sender;
- (IBAction)tapRouteType:(id)sender;
- (IBAction)swipeTollRight:(id)sender;
- (IBAction)swipeTollLeft:(id)sender;

- (IBAction)routeSettingInfo:(id)sender;


//waiting animation
-(void)initSpinner;
-(void)startWaitingAnimation;
//-(void)doWaitingAnimation;//in timer
-(void)stopWaitingAnimation;

//ui methods
-(void)updateStartAddress;
-(void)updateEndAddress;
-(void)updateVehicleInfo;
-(void)updateRouteTypeLabel;
-(void)updateTollLabel;
-(void)toggleToll;
-(void)preRouteType;
-(void)nextRouteType;

//route request operations
-(void)loadRouteRequest;
-(void)saveRouteRequest;
-(void)submitRequest;
-(void)resubmitRequestTo2ndServer;

-(void)announceDestination;
- (void)createRouteFromUrlInfo:(NSDictionary *)info;

@end
