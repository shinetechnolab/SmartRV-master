//
//  TTMyPointViewController.h
//  TruckRoute
//
//  Created by admin on 6/10/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>

@interface TTMyPointViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
}
@property (retain, nonatomic) IBOutlet UITextField *tfName;
@property (retain, nonatomic) IBOutlet UILabel *labelCoord;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
- (IBAction)cancel:(id)sender;
- (IBAction)OK:(id)sender;

@end
