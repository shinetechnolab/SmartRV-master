//
//  TTNotificationDetailViewController.m
//  TruckRoute
//
//  Created by Alpesh55 on 10/18/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTNotificationDetailViewController.h"

@interface TTNotificationDetailViewController ()

@end

@implementation TTNotificationDetailViewController
@synthesize detailLable;
@synthesize detailText;
@synthesize latString,lonString;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover=CGSizeMake(150,200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIButton *settingsButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"location_icon.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setFrame:CGRectMake(60,5,32,32)];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    //[view addSubview:settingsButton];
    
    
//    detailLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 44, 150, 200)];
//    detailLable.text=detailText;
//    detailLable.textColor=[UIColor darkGrayColor];
//    detailLable.font=[UIFont systemFontOfSize:14.0f];
//    detailLable.numberOfLines=0;
//    detailLable.lineBreakMode=UILineBreakModeWordWrap;
//    detailLable.backgroundColor=[UIColor whiteColor];
//    [self.view addSubview:detailLable];
    
    UITextView *textView=[[UITextView alloc]initWithFrame:CGRectMake(0, 0, 150, 250)];
    textView.text=detailText;//@"Hellods fdsfdsf dsfhfdsjf dfjkhds fufdsjkmf fdsjhf ds fdjsfhdsf dsjfh fsdfj sdfhjkfdsfj fdsjkfhdf dsfjhioerwkdsf fdsk, khjdsf dklsf kldsfsire a i am fgoo dfsfkboy wanna chat with me how are you what are you doing wanna chat with me where are you from";
    textView.editable=NO;
    textView.font=[UIFont systemFontOfSize:14.0f];
    textView.textColor=[UIColor darkGrayColor];
    [self.view addSubview:textView];
    
	// Do any additional setup after loading the view.
}
-(void)locationButtonClick:(id)sender
{
    [delegate notificationLocation:latString longitute:lonString];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
