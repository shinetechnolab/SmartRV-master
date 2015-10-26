//
//  TTUserInfoViewController.h
//  TruckRoute
//
//  Created by admin on 11/21/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTUserInfoViewController : UIViewController<UITextFieldDelegate> {
    BOOL isMovedUp;
    NSArray *arrayCountry;
    int idxCurCountry;
    UIActivityIndicatorView *spinner;
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    IBOutlet UILabel *msgText;
}

@property (retain, nonatomic) NSMutableData *responseData;

@property (nonatomic, assign) TTSubscriptionViewController *parentVC;
@property (nonatomic, assign) BOOL isForPurchase;
@property (retain, nonatomic) IBOutlet UILabel *labelFName;
@property (retain, nonatomic) IBOutlet UILabel *labelLName;
@property (retain, nonatomic) IBOutlet UILabel *labelAddress;
@property (retain, nonatomic) IBOutlet UILabel *labelCity;
@property (retain, nonatomic) IBOutlet UILabel *labelState;
@property (retain, nonatomic) IBOutlet UILabel *labelCountry;
@property (retain, nonatomic) IBOutlet UILabel *labelZip;
@property (retain, nonatomic) IBOutlet UILabel *labelEmail;
@property (retain, nonatomic) IBOutlet UITextField *tfFName;
@property (retain, nonatomic) IBOutlet UITextField *tfLName;
@property (retain, nonatomic) IBOutlet UITextField *tfAddress;
@property (retain, nonatomic) IBOutlet UITextField *tfCity;
@property (retain, nonatomic) IBOutlet UITextField *tfState;
@property (retain, nonatomic) IBOutlet UITextField *tfCountry;
@property (retain, nonatomic) IBOutlet UITextField *tfZip;
@property (retain, nonatomic) IBOutlet UITextField *tfEmail;


- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)tapCountry:(id)sender;

//waiting animation
-(void)initSpinner;
-(void)startWaiting;
-(void)stopWaiting;

//animation of rearrange controls
-(void)popupKeyboardAnimation:(BOOL)isMovingUp;

@end
