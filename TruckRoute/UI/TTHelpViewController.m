//
//  TTHelpViewController.m
//  TruckRoute
//
//  Created by admin on 11/8/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTHelpViewController.h"

@interface TTHelpViewController ()

@end

@implementation TTHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.smarttruckroute.com/iPhone-FAQ.htm"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ok:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [_webView release];
    [super dealloc];
}
@end
