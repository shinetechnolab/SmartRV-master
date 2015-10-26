//
//  TTInfoViewController.h
//  TruckRoute
//
//  Created by admin on 3/21/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTMapViewController.h"
@protocol TruckStopBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@interface TTTruckStopInfoViewController : UIViewController<TruckStopBackButtonClick> {
    BOOL isTruckStop;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    IBOutlet UIView *centerView;
    IBOutlet UIView *bottomView;
    IBOutlet UIView *topView;
    
    IBOutlet UIImageView *mainBgImageView_landscape;
    IBOutlet UIButton *backButton_landscape;
    IBOutlet UIButton *createRouteButton_landscape;
    
    IBOutlet UIView *centerView_landscape;
    IBOutlet UIView *bottomView_landscape;
    IBOutlet UIView *topView_landscape;
    
    IBOutlet UIView *landscapeMainView;
    
    BOOL isShowingLandscapeView;
    //BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<TruckStopBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;

@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) TTPOI *poi;

@property (retain, nonatomic) IBOutlet UIImageView *imageviewIcon;
@property (retain, nonatomic) IBOutlet UILabel *labelName;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation;
@property (retain, nonatomic) IBOutlet UILabel *labelAddress;
@property (retain, nonatomic) IBOutlet UILabel *labelWiFi;
@property (retain, nonatomic) IBOutlet UILabel *labelIdle;
@property (retain, nonatomic) IBOutlet UILabel *labelScale;
@property (retain, nonatomic) IBOutlet UILabel *labelWash;
@property (retain, nonatomic) IBOutlet UILabel *labelShowers;
//@property (retain, nonatomic) IBOutlet UILabel *labelSecureP;
//@property (retain, nonatomic) IBOutlet UILabel *labelNightPOnly;
@property (retain, nonatomic) IBOutlet UIImageView *imageviewBG;
@property (retain, nonatomic) IBOutlet UILabel *labelServices;
- (IBAction)phone:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone;

@property (retain, nonatomic) IBOutlet UIImageView *imageviewIcon_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelName_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelAddress_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelWiFi_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelIdle_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelScale_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelWash_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelShowers_landscape;
//@property (retain, nonatomic) IBOutlet UILabel *labelSecureP;
//@property (retain, nonatomic) IBOutlet UILabel *labelNightPOnly;
@property (retain, nonatomic) IBOutlet UIImageView *imageviewBG_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelServices_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone_landscape;

- (IBAction)back:(id)sender;
- (IBAction)routeTo:(id)sender;

-(void)callNumber;

@end
