//
//  TTHelpViewController.h
//  TruckRoute
//
//  Created by admin on 11/8/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTHelpViewController : UIViewController
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
