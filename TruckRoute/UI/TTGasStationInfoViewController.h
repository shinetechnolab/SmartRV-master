//
//  TTGasStationInfoViewController.h
//  TruckRoute
//
//  Created by admin on 4/5/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTMapViewController.h"
@protocol BackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@interface TTGasStationInfoViewController : UIViewController <BackButtonClick>{
    UIActivityIndicatorView *spinner;
    NSMutableData *responseData;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    IBOutlet UIButton *backButton_landscape;
    IBOutlet UIButton *createRouteButton_landscape;
    
    IBOutlet UIView *centerView;
    IBOutlet UIView *bottomView;
    IBOutlet UIView *topView;
    
    IBOutlet UIView *centerView_landscape;
    IBOutlet UIView *bottomView_landscape;
    IBOutlet UIView *topView_landscape;
    IBOutlet UIView *landscapeMainView;
    BOOL isShowingLandscapeView;
    //BOOL isVisible;
    
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<BackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) TTPOI *poi;

@property (retain, nonatomic) IBOutlet UILabel *labelName;
@property (retain, nonatomic) IBOutlet UIImageView *imageLogo;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone;
- (IBAction)callPhoneNumber:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *labelPriceReg;
@property (retain, nonatomic) IBOutlet UILabel *labelPricePlus;
@property (retain, nonatomic) IBOutlet UILabel *labelPricePremium;
@property (retain, nonatomic) IBOutlet UILabel *labelPriceDiesel;
@property (retain, nonatomic) IBOutlet UILabel *labelAddress;
@property (retain, nonatomic) IBOutlet UILabel *labelCity;
@property (retain, nonatomic) IBOutlet UILabel *labelState;
@property (retain, nonatomic) IBOutlet UILabel *labelZip;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeReg;
@property (retain, nonatomic) IBOutlet UILabel *labelTimePlus;
@property (retain, nonatomic) IBOutlet UILabel *labelTimePremium;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeDiesel;
@property (retain, nonatomic) IBOutlet UILabel *labelDiesel;

@property (retain, nonatomic) IBOutlet UILabel *labelReg;
@property (retain, nonatomic) IBOutlet UILabel *labelPrim;
@property (retain, nonatomic) IBOutlet UILabel *labelPlus;


@property (retain, nonatomic) IBOutlet UILabel *labelName_landscape;
@property (retain, nonatomic) IBOutlet UIImageView *imageLogo_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPriceReg_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPricePlus_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPricePremium_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPriceDiesel_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelAddress_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelCity_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelState_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelZip_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeReg_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelTimePlus_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelTimePremium_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeDiesel_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelDiesel_landscape;

@property (retain, nonatomic) IBOutlet UILabel *labelReg_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPrim_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPlus_landscape;



- (IBAction)back:(id)sender;
- (IBAction)routeTo:(id)sender;

-(void)submitRequest;
//waiting animation
-(void)initSpinner;
-(void)startWaiting;
-(void)stopWaiting;

@end
