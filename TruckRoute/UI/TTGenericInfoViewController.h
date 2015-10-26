//
//  TTGenericInfoViewController.h
//  TruckRoute
//
//  Created by admin on 4/5/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTMapViewController.h"
@protocol GenericBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@interface TTGenericInfoViewController : UIViewController<GenericBackButtonClick>
{
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    IBOutlet UIView *bottomView;
    IBOutlet UIView *topView;
    BOOL isShowingLandscapeView;
   // BOOL isVisible;
    
    IBOutlet UIButton *backButton_landscape;
    IBOutlet UIButton *createRouteButton_landscape;
    IBOutlet UIView *bottomView_landscape;
    IBOutlet UIView *topView_landscape;
    IBOutlet UIView *view_landscape;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<GenericBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;

@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) TTPOI *poi;

@property (retain, nonatomic) IBOutlet UILabel *labelName;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone;
- (IBAction)callPhoneNumber:(id)sender;
//@property (retain, nonatomic) IBOutlet UILabel *labelAddress;
@property (retain, nonatomic) IBOutlet UIImageView *imageLogo;
//@property (retain, nonatomic) IBOutlet UILabel *labelCity;
//@property (retain, nonatomic) IBOutlet UILabel *labelState;
//@property (retain, nonatomic) IBOutlet UILabel *labelZip;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation;

@property (retain, nonatomic) IBOutlet UIImageView *imageLogo_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelLocation_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelName_landscape;
@property (retain, nonatomic) IBOutlet UIButton *buttonPhone_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelInfo_landscape;
- (IBAction)back:(id)sender;
- (IBAction)routeTo:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *labelInfo;

@end
