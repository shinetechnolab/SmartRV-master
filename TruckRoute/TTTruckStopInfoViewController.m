//
//  TTInfoViewController.m
//  TruckRoute
//
//  Created by admin on 3/21/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTTruckStopInfoViewController.h"
#import "TTNewRouteViewController.h"
#import "TTUtilities.h"
#import "TTConfig.h"
@interface TTTruckStopInfoViewController ()

@end

@implementation TTTruckStopInfoViewController

@synthesize parentVC, poi;
@synthesize imageviewIcon, labelName, labelLocation, labelAddress;
@synthesize labelWiFi, labelIdle, labelScale, labelWash, labelShowers, labelServices;
@synthesize imageviewIcon_landscape, labelName_landscape, labelLocation_landscape, labelAddress_landscape;
@synthesize labelWiFi_landscape, labelIdle_landscape, labelScale_landscape, labelWash_landscape, labelShowers_landscape, labelServices_landscape;


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
//            mainBgImageView.image=[UIImage imageNamed:@"Truck Stop Detail BG~ipad.png"];
//            [backButton setImage:[UIImage imageNamed:@"Back1~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"Route To1~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"Route To2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
//            mainBgImageView.image=[UIImage imageNamed:@"Truck Stop Detail BG-Landscape~ipad.png"];
//            [backButton setImage:[UIImage imageNamed:@"Back1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"Route To1-Landscape~ipad"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"Route To2-Landscape~ipad"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self getCurrentOrientation];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else{
        [(TTTruckStopInfoViewController *)_superViewController  setIsVisible:YES];
        [(TTTruckStopInfoViewController *)_superViewController  viewDidAppear:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self orientationChanged:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!_isNotificationOn) {
        [(TTTruckStopInfoViewController *)_superViewController  setIsVisible:NO];
    }
    self.isVisible = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowingLandscapeView = NO;
    
    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        //  [self orientationChanged:nil];
    }

    topView.layer.cornerRadius=7;
    bottomView.layer.cornerRadius=7;
    centerView.layer.cornerRadius=7;
    _buttonPhone.layer.cornerRadius=7;
    topView_landscape.layer.cornerRadius=7;
    bottomView_landscape.layer.cornerRadius=7;
    centerView_landscape.layer.cornerRadius=7;
    _buttonPhone_landscape.layer.cornerRadius=7;
    [self getCurrentOrientation];
	// Do any additional setup after loading the view.
    //replace generic truck stop icon
    UIImage *img = nil;
    //bg
    if (truck_stop != poi.type) {
        isTruckStop = NO;
        img = [UIImage imageNamed:@"CatScale-Parking detailBG.png"];
        [_imageviewBG setImage:img];
        [labelServices setHidden:YES];
        [_imageviewBG_landscape setImage:img];
        [labelServices_landscape setHidden:YES];
    }else {
        isTruckStop = YES;
    }
    //icon
    if ([poi.image isEqualToString:@""]) {
        img = [UIImage imageNamed:@"L2002__Truckstop.png"];
    }else {
        img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",poi.image]];
    }
/*    switch (poi.type) {
        case truck_stop:
            if ([poi.image isEqualToString:@"2002__Truckstop.png"]) {
                img = [UIImage imageNamed:@"L2002__Truckstop.png"];
            }else {
                img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",poi.image]];
            }
            break;
            
        case weighstation:
            img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",poi.image]];
            break;
            
        default:
            img = [UIImage imageNamed:poi.image];
            break;
    }*/
    
    [imageviewIcon setImage:img];
    [labelName setText:poi.name];
    [labelLocation setText:[NSString stringWithFormat:@"%.4f,  %.4f", poi.coord.latitude, poi.coord.longitude]];
    
    [imageviewIcon_landscape setImage:img];
    [labelName_landscape setText:poi.name];
    [labelLocation_landscape setText:[NSString stringWithFormat:@"%.4f,  %.4f", poi.coord.latitude, poi.coord.longitude]];

    
    if (poi.address) {
        [labelAddress setText:[NSString stringWithFormat:@"%@\n%@, %@ %@", poi.address, poi.city, [TTUtilities getAbbreviation:poi.state], poi.zipcode]];
        [labelAddress_landscape setText:[NSString stringWithFormat:@"%@\n%@, %@ %@", poi.address, poi.city, [TTUtilities getAbbreviation:poi.state], poi.zipcode]];
    }else {
        [labelAddress setText:[NSString stringWithFormat:@"%@, %@ %@", poi.city, [TTUtilities getAbbreviation:poi.state], poi.zipcode]];
        [labelAddress_landscape setText:[NSString stringWithFormat:@"%@, %@ %@", poi.city, [TTUtilities getAbbreviation:poi.state], poi.zipcode]];
    }    
    if (poi.number && ![poi.number isEqualToString:@""]) {
        //process phone number first
        [_buttonPhone setTitle:[TTUtilities processPhoneNumber:poi.number] forState:UIControlStateNormal];
        [_buttonPhone_landscape setTitle:[TTUtilities processPhoneNumber:poi.number] forState:UIControlStateNormal];
    }else {
        [_buttonPhone setHidden:YES];
        [_buttonPhone_landscape setHidden:YES];
    }    
    if (isTruckStop) {
        if (poi.hasWifi) {
            [labelWiFi setText:@"WiFi - YES"];
            [labelWiFi_landscape setText:@"WiFi - YES"];
        }else {
            [labelWiFi setText:@"WiFi - NO"];
            [labelWiFi_landscape setText:@"WiFi - NO"];
        }
        if (poi.hasIdle) {
            [labelIdle setText:@"Idle - YES"];
            [labelIdle_landscape setText:@"Idle - YES"];
        }else {
            [labelIdle setText:@"Idle - NO"];
            [labelIdle_landscape setText:@"Idle - NO"];
        }
        if (poi.hasScale) {
            [labelScale setText:@"Scale - YES"];
            [labelScale_landscape setText:@"Scale - YES"];
        }else {
            [labelScale setText:@"Scale - NO"];
            [labelScale_landscape setText:@"Scale - NO"];
        }
        if (poi.hasWash) {
            [labelWash setText:@"Wash - YES"];
            [labelWash_landscape setText:@"Wash - YES"];
        }else {
            [labelWash setText:@"Wash - NO"];
            [labelWash_landscape setText:@"Wash - NO"];
        }
        if (poi.hasService) {
            [labelServices setText:@"Service - YES"];
            [labelServices_landscape setText:@"Service - YES"];
        }else {
            [labelServices setText:@"Service - NO"];
            [labelServices_landscape setText:@"Service - NO"];
        }
        [labelShowers setText:[NSString stringWithFormat:@"Showers - %d", poi.showers]];
        [labelShowers_landscape setText:[NSString stringWithFormat:@"Showers - %d", poi.showers]];
/*        if (poi.hasSecureparking) {
            [labelSecureP setText:@"Secure Parking - YES"];
        }else {
            [labelSecureP setText:@"Secure Parking - NO"];
        }
        if (poi.isNightparkingonly) {
            [labelNightPOnly setText:@"Night Parking Only - YES"];
        }else {
            [labelNightPOnly setText:@"Night Parking Only - NO"];
        }*/
    }else {
        [labelWiFi setHidden:YES];
        [labelIdle setHidden:YES];
        [labelScale setHidden:YES];
        [labelWash setHidden:YES];
//        [labelSecureP setHidden:YES];
        [labelShowers setHidden:YES];
//        [labelNightPOnly setHidden:YES];
        [labelWiFi_landscape setHidden:YES];
        [labelIdle_landscape setHidden:YES];
        [labelScale_landscape setHidden:YES];
        [labelWash_landscape setHidden:YES];
        [labelShowers_landscape setHidden:YES];
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)phone:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Call %@ ?", [TTUtilities processPhoneNumber:poi.number]]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Cancel", nil];
    [alert show];
    [alert release];
//    [self callNumber];
}

- (IBAction)back:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
       // if(IS_IPAD){
            [self dismissViewControllerAnimated:NO completion:^{ [self.delegate backButtonClick:self];}];
           
//        }else{
//            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.delegate backButtonClick:self];
//        }
    }

}

- (IBAction)routeTo:(id)sender {
    
    // save route data to history
    [self updateHistory];
    
    //update route request
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"route_request_end_address"];
    //more detail about the destination
    NSString *str = [NSString stringWithString:poi.name];
    if (poi.address) {
        str = [str stringByAppendingFormat:@"\n%@", poi.address];
    }
    if (poi.city) {
        str = [str stringByAppendingFormat:@"\n%@", poi.city];
    }
    if (poi.state) {
        str = [str stringByAppendingFormat:@"\n%@", poi.state];
    }
    [userDefaults setObject:str forKey:@"route_request_end_address"];
//    [userDefaults setObject:poi.name forKey:@"route_request_end_address"];
    [userDefaults removeObjectForKey:@"route_request_end_latitude"];
    [userDefaults setDouble:poi.coord.latitude forKey:@"route_request_end_latitude"];
    [userDefaults removeObjectForKey:@"route_request_end_longitude"];
    [userDefaults setDouble:poi.coord.longitude forKey:@"route_request_end_longitude"];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //TTNewRouteViewController *nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    TTNewRouteViewController *nrvc = nil;
    if (IS_IPAD) {
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
    }
    else{
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    }
    [nrvc setParentVC:parentVC];
    [nrvc setIsNotificationOn:YES];
    //[self presentViewController:nrvc animated:YES completion:nil];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:nrvc animated:NO completion:nil];
    }
    else{
        [self presentViewController:nrvc animated:YES completion:nil];
    }
    
/*    if (!parentVC) {
        parentVC = (TTMapViewController*)self.presentingViewController;
    }
    [self dismissViewControllerAnimated:NO completion:^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTNewRouteViewController *nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        [nrvc setParentVC:parentVC];
        [parentVC presentViewController:nrvc animated:YES completion:nil];
    }];*/
}
- (void)dealloc {
    [imageviewIcon release];
    [labelName release];
    [labelLocation release];
    [labelAddress release];
    [labelWiFi release];
    [labelIdle release];
    [labelScale release];
    [labelWash release];
    [labelShowers release];

    [_imageviewBG release];
    [labelServices release];
    [_buttonPhone release];
    
    [imageviewIcon_landscape release];
    [labelName_landscape release];
    [labelLocation_landscape release];
    [labelAddress_landscape release];
    [labelWiFi_landscape release];
    [labelIdle_landscape release];
    [labelScale_landscape release];
    [labelWash_landscape release];
    [labelShowers_landscape release];
    
    [_imageviewBG_landscape release];
    [labelServices_landscape release];
    [_buttonPhone_landscape release];

    [super dealloc];
}

-(void)callNumber
{
//    int number = [poi.number intValue];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", poi.number]]];
}

#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        [self callNumber];
    }
}


-(void)updateHistory
{
    
        //retrieve the saved location array, then insert the new location and save the array
        NSArray *arrayHistory = nil;
        NSUserDefaults *dataDefault = [NSUserDefaults standardUserDefaults];
        arrayHistory = [dataDefault arrayForKey:@"History"];
        NSLog(@"%@",arrayHistory);
    
    //%@, %@\n%.6f,%.6f", place.name, place.address, place.latitude, place.longitude]];
    NSString *str = [NSString stringWithString:poi.name];
    if (poi.address) {
        str = [str stringByAppendingFormat:@",%@", poi.address];
    }
    if (poi.city) {
        str = [str stringByAppendingFormat:@",%@", poi.city];
    }
    if (poi.state) {
        str = [str stringByAppendingFormat:@",%@", poi.state];
    }
    
    NSString *routeString = [NSString stringWithFormat:@"%@\n%.6f,%.6f",str,poi.coord.latitude,poi.coord.longitude];
        //check if the result already exists
        for (id record in arrayHistory) {
            NSString *recordString = [record objectForKey:@"LocationString"];
            if ([routeString isEqual:recordString]) {
                //no change
                return;
            }
        }
        NSMutableArray *arrayNew = [[NSMutableArray alloc]init];
        NSMutableDictionary *tempDict = [[[NSMutableDictionary alloc]init] autorelease];
        [tempDict setValue:[NSString stringWithFormat:@"%@",routeString] forKey:@"LocationString"];
        [tempDict setValue:[NSNumber numberWithInt:0] forKey:@"LocationStatus"];
        [arrayNew addObject:tempDict];
    
    for(id object in arrayHistory)
            [arrayNew addObject:object];
        [dataDefault removeObjectForKey:@"History"];
        [dataDefault setObject:arrayNew forKey:@"History"];
        // Update data on the iCloud
        [[NSUbiquitousKeyValueStore defaultStore] setArray:arrayNew forKey:@"HistoryNew"];
        //        [arrayHistory release];
        [arrayNew release];
    
}

- (void)orientationChanged:(NSNotification *)notification

{
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
    {
        landscapeMainView.hidden=NO;
    }
    else{
        landscapeMainView.hidden=YES;
    }
    
//    if (self.isVisible)
//    {
//        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//        if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
//        {
//            //TTGasStationInfoViewController tempView=self;
//            //[self dismissViewControllerAnimated:YES completion:nil];
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//            TTTruckStopInfoViewController *tsvc = nil;
//            if (IS_IPAD) {
//                tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController_ipad_landscape"];
//                [tsvc setParentVC:self.parentVC];
//            }else{
//                tsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TruckStopInfoViewController_landscape"];
//                [tsvc setParentVC:self.parentVC];
//            }
//            
//            tsvc.delegate=self;
//            //tsvc.isNotificationOn=NO;
//            [tsvc setPoi:self.poi];
//            [tsvc setSuperViewController:self];
//            [self presentViewController:tsvc animated:NO completion:^{self.isVisible=YES;}];
//
//            isShowingLandscapeView = YES;
//            self.isVisible=YES;
//        }
//        else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
//        {
//            [self dismissViewControllerAnimated:YES completion:nil];
//            isShowingLandscapeView = NO;
//        }
//    }
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
