//
//  TTVehicleInfoViewController.h
//  TruckRoute
//
//  Created by admin on 10/9/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRouteRequest.h"
@protocol VehicalInfoBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;
@end

@interface TTVehicleInfoViewController : UIViewController<VehicalInfoBackButtonClick, UIPickerViewDataSource, UIPickerViewDelegate> {
    //tmp buf
    int height_in_feet;
    int height_in_inches;
    int length_in_feet;
    int length_in_inches;
    int width_in_feet;
    int width_in_inches;
    
    float height_in_meter;
    float length_in_meter;
    float width_in_meter;
    
    int weight;
    int hazmat;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    BOOL isShowingLandscapeView;
    
    IBOutlet UIView *portraitView;
    NSArray *_pickerData;
    IBOutlet UIView *pickerHolderView;
    IBOutlet UIPickerView *hazmatPickerView;
    //BOOL isVisible;

}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<VehicalInfoBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
-(IBAction)editButtonClick:(id)sender;
@property (retain, nonatomic) TTRouteRequest *route_request;

@property (retain, nonatomic) IBOutlet UILabel *labelHeight;
@property (retain, nonatomic) IBOutlet UILabel *labelWeight;
@property (retain, nonatomic) IBOutlet UILabel *labelLength;
@property (retain, nonatomic) IBOutlet UILabel *labelWidth;
@property (retain, nonatomic) IBOutlet UILabel *labelHazmat;
@property (retain, nonatomic) IBOutlet UITextField *textLength;
@property (retain, nonatomic) IBOutlet UITextField *textWeight;
@property (retain, nonatomic) IBOutlet UITextField *textWidth;
@property (retain, nonatomic) IBOutlet UITextField *textHeight;
@property (retain, nonatomic) IBOutlet UITextField *textHazmat;
@property (retain, nonatomic) IBOutlet UITextField *textLength_landscape;
@property (retain, nonatomic) IBOutlet UITextField *textWeight_landscape;
@property (retain, nonatomic) IBOutlet UITextField *textWidth_landscape;
@property (retain, nonatomic) IBOutlet UITextField *textHeight_landscape;
@property (retain, nonatomic) IBOutlet UITextField *textHazmat_landscape;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)defaultValue:(id)sender;

- (IBAction)decreaseHeight:(id)sender;
- (IBAction)increaseHeight:(id)sender;
- (IBAction)decreaseWeight:(id)sender;
- (IBAction)increaseWeight:(id)sender;
- (IBAction)decreaseLength:(id)sender;
- (IBAction)increaseLength:(id)sender;
- (IBAction)decreaseWidth:(id)sender;
- (IBAction)increaseWidth:(id)sender;
- (IBAction)decreaseHazmat:(id)sender;
- (IBAction)increaseHazmat:(id)sender;
-(IBAction)clickOnTextField:(id)sender;
@end
