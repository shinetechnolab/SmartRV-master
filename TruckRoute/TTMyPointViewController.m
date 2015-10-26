//
//  TTMyPointViewController.m
//  TruckRoute
//
//  Created by admin on 6/10/13.
//  Copyright (c) 2013 admin. All rights reserved.
//
#import "TTConfig.h"
#import "TTMyPointViewController.h"

@interface TTMyPointViewController ()

@end

@implementation TTMyPointViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) getCurrentOrientation{
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        if (isIpad) {
            mainBgImageView.image=[UIImage imageNamed:@"Find Address template .png"];
            [backButton setImage:[UIImage imageNamed:@"CancelButton1~ipad.png"] forState:UIControlStateNormal];
            [createRouteButton setImage:[UIImage imageNamed:@"OK1~ipad.png"] forState:UIControlStateNormal];
            [backButton setImage:[UIImage imageNamed:@"CancelButton2~ipad.png"] forState:UIControlStateHighlighted];
            [createRouteButton setImage:[UIImage imageNamed:@"OK2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
            mainBgImageView.image=[UIImage imageNamed:@"Find Address template -Landscape.png"];
            [backButton setImage:[UIImage imageNamed:@"CancelButton1-Landscape~ipad.png"] forState:UIControlStateNormal];
            [createRouteButton setImage:[UIImage imageNamed:@"OK1-Landscape~ipad.png"] forState:UIControlStateNormal];
            
            [backButton setImage:[UIImage imageNamed:@"CancelButton2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
            [createRouteButton setImage:[UIImage imageNamed:@"OK2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self getCurrentOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *str = [NSString stringWithFormat:@"%.6f, %.6f", _coord.latitude, _coord.longitude];
    [_labelCoord setText:str];
    [_tfName setText:[NSString stringWithFormat:@"My Point:%@", str]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tfName release];
    [_labelCoord release];
    [super dealloc];
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)OK:(id)sender {
    //add
    NSString *new_record = [NSString stringWithFormat:@"%@\n%.6f,%.6f", _tfName.text, _coord.latitude, _coord.longitude];
    //retrieve the saved location array, then insert the new location and save the array
    NSArray *arrayHistory = nil;
    NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
    arrayHistory = [dataDefault arrayForKey:@"History"];
    //check if the result already exists
    for (id record in arrayHistory) {
        NSString *recordString = [record objectForKey:@"LocationString"];
        if ([new_record isEqual:recordString]) {
            //no change
            //dismiss vc
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    NSMutableArray *arrayNew = [[NSMutableArray alloc]init];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
    [tempDict setValue:new_record forKey:@"LocationString"];
    [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
    [arrayNew addObject:tempDict];
    for(id object in arrayHistory)
        [arrayNew addObject:object];
    [dataDefault removeObjectForKey:@"History"];
    [dataDefault setObject:arrayNew forKey:@"History"];
    // Update data on the iCloud
    [[NSUbiquitousKeyValueStore defaultStore] setArray:arrayNew forKey:@"HistoryNew"];
    [arrayNew release];
    //dismiss vc
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
@end
