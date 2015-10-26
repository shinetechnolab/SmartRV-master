//
//  TTFindMenuViewController.h
//  TruckRoute
//
//  Created by admin on 4/1/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "TTMapViewController.h"
#import "TTPOIManager.h"
@protocol FindBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end

@interface TTFindMenuViewController : UIViewController <CLLocationManagerDelegate,FindBackButtonClick> {
    CLLocationManager *locationManager;

    UIActivityIndicatorView *spinner;
    
    BOOL isNearCurrentLocation;
    int idxName;
    int idxType;
    
    IBOutlet UIView *wifiView;
    IBOutlet UIView *idleView;
    IBOutlet UIView *serviceView;
    IBOutlet UIView *scaleView;
    IBOutlet UIView *showerView;
    IBOutlet UIView *washView;
    
    IBOutlet UIView *wifiView_landscape;
    IBOutlet UIView *idleView_landscape;
    IBOutlet UIView *serviceView_landscape;
    IBOutlet UIView *scaleView_landscape;
    IBOutlet UIView *showerView_landscape;
    IBOutlet UIView *washView_landscape;
    IBOutlet UIView *typeView_landscape;
    IBOutlet UIView *nameView_landscape;
    
    IBOutlet UIView *typeView;
    IBOutlet UIView *nameView;
    BOOL isShowingLandscapeView;
    
    IBOutlet UIView *landscapeMainView;
   // BOOL isVisible;
    
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<FindBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) TTPOIManager *poiManager;
@property (nonatomic, readonly) TTPOI *poi_condition;

//temp ui area begin
@property (retain, nonatomic) IBOutlet UIImageView *imageview;
@property (retain, nonatomic) IBOutlet UILabel *labelType;
- (IBAction)swipeTypeToRight:(id)sender;
- (IBAction)swipeTypeToLeft:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *labelName;
- (IBAction)swipeNameToRight:(id)sender;
- (IBAction)swipeNameToLeft:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonCurrentLocation;
- (IBAction)tapCurrentLocation:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonNewLocation;
//- (IBAction)tapNewLocation:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *labelNewAddress;
- (IBAction)tapNewAddress:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonWifi;
- (IBAction)toggleWifi:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonIdle;
- (IBAction)toggleIdle:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonScale;
- (IBAction)toggleScale:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonWash;
- (IBAction)toggleWash:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonService;
- (IBAction)toggleService:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonShower;
- (IBAction)toggleShower:(id)sender;
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *labelTruckStopSettings;
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *labelTruckStopSettings_landscape;
- (IBAction)historyLocation:(id)sender;
- (IBAction)tapButtonNewLocation:(id)sender;


-(void)updateType;
-(void)updateTruckStopSettings;
-(void)updateTruckStopName;
-(void)updateNewAddress;
//temp ui area end

- (IBAction)back:(id)sender;
- (IBAction)search:(id)sender;

//waiting animation
-(void)initSpinner;
-(void)startWaiting;
-(void)stopWaiting;

// Declare for landscape mode
@property (retain, nonatomic) IBOutlet UIImageView *imageview_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelType_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelName_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonCurrentLocation_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonNewLocation_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelNewAddress_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonWifi_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonIdle_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonScale_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonWash_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonService_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonShower_landscape;
@end
