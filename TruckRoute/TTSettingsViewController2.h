//
//  TTSettingsViewController2.h
//  TruckRoute
//
//  Created by admin on 11/6/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
#import "TTAppDelegate.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TTMapViewController.h"
#import <AVFoundation/AVFoundation.h>
//@interface TTSettingsViewController2 : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@interface TTSettingsViewController2 : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,MFMessageComposeViewControllerDelegate>

{
    UIView *subView;
    NSArray *imagesArray;
    UIPickerView *pickerView;
    TTAppDelegate *apps;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    NSMutableArray *arrayUSA;
    NSMutableArray *arrayCANADA;
    NSArray *sortedUSA;
    NSArray *sortedCANADA;
    BOOL isUnitMetricNew;
}
@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) BOOL isVoiceOn;
@property (nonatomic, assign) BOOL isNorthUp;
@property (nonatomic, assign) BOOL isSimulationOn;
@property (nonatomic, assign) BOOL isAutoZoom;
@property (nonatomic, assign) BOOL isPerspective;
@property (nonatomic, assign) BOOL isShowBuildings;
@property (nonatomic, assign) BOOL isAutoReroute;
@property (nonatomic, assign) BOOL isTravelAlerts;
@property (nonatomic, assign) BOOL isWeighScaleAlerts;
@property (nonatomic, assign) BOOL isUnitMetric;
@property (nonatomic, assign) BOOL is24Hour;
//pois
@property (nonatomic, assign) BOOL isTruckStopOn;
@property (nonatomic, assign) BOOL isWeightstationOn;
@property (nonatomic, assign) BOOL isTruckParkingOn;
@property (nonatomic, assign) BOOL isTruckDealerOn;
@property (nonatomic, assign) BOOL isCampground;
@property (nonatomic, assign) BOOL isCatScaleOn;
@property (nonatomic, assign) BOOL isRestAreaOn;
@property (nonatomic, assign) float rateValue;
@property (nonatomic, assign) float pitchValue;
@property (nonatomic, assign) BOOL isOdoOn;
@property (nonatomic, assign) BOOL isUserTips;
@property (nonatomic, assign) BOOL isSpeedWarning;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

-(IBAction)rateSliderValueChange:(id)sender;
-(IBAction)pitchSliderValueChange:(id)sender;
-(IBAction)onTapSwitch:(UISwitch *)sender;
-(IBAction)onTapGroupButton:(UIButton *)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)ok:(id)sender;
-(IBAction)resetButtonClick:(id)sender;

@end