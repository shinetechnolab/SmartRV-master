//
//  TTAppDelegate.h
//  TruckRoute
//
//  Created by admin on 9/19/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
//#import "CustomIOS7AlertView.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import "TBXML.h"
@interface TTAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    NSString *notifText;
    NSMutableArray *userTipsArray;
    UIAlertView *userTipsAlert;
    UIAlertView *connectionAlert;
    UIAlertView *agreeAlertView;
    BOOL alertShowing;
}
@property (nonatomic)BOOL newVersionAvailable;
@property (nonatomic,retain)NSString *notifText;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain)Reachability *hostReachability;
@end
