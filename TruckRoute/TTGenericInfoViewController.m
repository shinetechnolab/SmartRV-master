//
//  TTGenericInfoViewController.m
//  TruckRoute
//
//  Created by admin on 4/5/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTGenericInfoViewController.h"
#import "TTNewRouteViewController.h"
#import "TTUtilities.h"
#import "TTConfig.h"
@interface TTGenericInfoViewController ()

@end

@implementation TTGenericInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[self getCurrentOrientation];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else{
        [(TTGenericInfoViewController *)_superViewController  setIsVisible:YES];
        [(TTGenericInfoViewController *)_superViewController  viewDidAppear:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self orientationChanged:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
      [(TTGenericInfoViewController *)_superViewController  setIsVisible:NO];
    }
    
    [super viewWillDisappear:animated];
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
    topView.layer.cornerRadius=5;
    bottomView.layer.cornerRadius=5;
    topView_landscape.layer.cornerRadius=5;
    bottomView_landscape.layer.cornerRadius=5;
   // [self getCurrentOrientation];
	// Do any additional setup after loading the view.
    UIImage *img = nil;
    img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",_poi.image]];
    if (!img) {
        switch (_poi.type) {
            case truck_stop:
                img = [UIImage imageNamed:@"L2002__Truckstop.png"];
                break;
                
            case weighstation:
                img = [UIImage imageNamed:@"Weigh-Station.png"];
                break;
                
            case CAT_scale:
                img = [UIImage imageNamed:@"CatScale-info logo.png"];
                break;
                
            case truck_parking:
                img = [UIImage imageNamed:@"L2005__Parking.png"];
                break;
                
            case rest_area:
                img = [UIImage imageNamed:@"Rest Area.png"];
                break;
                
            case truck_dealer:
            default:
                img = [UIImage imageNamed:@"BlueFlag.png"];
                break;
        }
    }
    [_imageLogo setImage:img];
    [_labelName setText:_poi.name];
    [_labelLocation setText:[NSString stringWithFormat:@"%.4f,  %.4f", _poi.coord.latitude, _poi.coord.longitude]];
    
    [_imageLogo_landscape setImage:img];
    [_labelName_landscape setText:_poi.name];
    [_labelLocation_landscape setText:[NSString stringWithFormat:@"%.4f,  %.4f", _poi.coord.latitude, _poi.coord.longitude]];
    if (_poi.number && ![_poi.number isEqualToString:@""]) {
        //process phone number first
        [_buttonPhone setTitle:[TTUtilities processPhoneNumber:_poi.number] forState:UIControlStateNormal];
        [_buttonPhone_landscape setTitle:[TTUtilities processPhoneNumber:_poi.number] forState:UIControlStateNormal];
    }else {
        [_buttonPhone setHidden:YES];
        [_buttonPhone_landscape setHidden:YES];
    }
    //info
    NSString *info = [[[NSString alloc]init]autorelease];
    if (_poi.address.length > 3) {
        info = [info stringByAppendingFormat:@"%@\n", _poi.address];
    }
    if (_poi.city) {
        info = [info stringByAppendingFormat:@"%@, ", _poi.city];
    }
    if (_poi.state) {
        info = [info stringByAppendingFormat:@"%@, ", [TTUtilities getAbbreviation:_poi.state]];
    }
    if (_poi.zipcode) {
        info = [info stringByAppendingString: _poi.zipcode];
    }
    [_labelInfo setText:info];
    [_labelInfo_landscape setText:info];
    /*if (_poi.address) {
        [_labelAddress setText:_poi.address];
    }else {
        [_labelAddress setHidden:YES];
    }
    if (_poi.city) {
        [_labelCity setText:_poi.city];        
    }else {
        [_labelCity setHidden:YES];
    }
    if (_poi.state) {
        [_labelState setText:_poi.state];
    }else {
        [_labelState setHidden:YES];
    }
    if (_poi.zipcode) {
        [_labelZip setText: _poi.zipcode];
    }else {
        [_labelZip setHidden:YES];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_labelName release];
    [_buttonPhone release];
//    [_labelAddress release];
    [_imageLogo release];
//    [_labelCity release];
//    [_labelState release];
//    [_labelZip release];
    [_labelLocation release];
    [_labelInfo release];
    
    [_labelName_landscape release];
    [_buttonPhone_landscape release];
    [_imageLogo_landscape release];
    [_labelLocation_landscape release];
    [_labelInfo_landscape release];
    [super dealloc];
}
- (IBAction)callPhoneNumber:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Call %@ ?", [TTUtilities processPhoneNumber:_poi.number]]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Cancel", nil];
    [alert show];
    [alert release];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _poi.number]]];
}
- (IBAction)back:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        //if (IS_IPAD) {
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        }
//        else{
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
    NSString *str = [NSString stringWithString:_poi.name];
    if (_poi.address) {
        str = [str stringByAppendingFormat:@"\n%@", _poi.address];
    }
    if (_poi.city) {
        str = [str stringByAppendingFormat:@"\n%@", _poi.city];
    }
    if (_poi.state) {
        str = [str stringByAppendingFormat:@"\n%@", _poi.state];
    }
    [userDefaults setObject:str forKey:@"route_request_end_address"];
//    [userDefaults setObject:_poi.name forKey:@"route_request_end_address"];
    [userDefaults removeObjectForKey:@"route_request_end_latitude"];
    [userDefaults setDouble:_poi.coord.latitude forKey:@"route_request_end_latitude"];
    [userDefaults removeObjectForKey:@"route_request_end_longitude"];
    [userDefaults setDouble:_poi.coord.longitude forKey:@"route_request_end_longitude"];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TTNewRouteViewController *nrvc = nil;
    if (IS_IPAD) {
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
    }
    else{
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    }
    
    [nrvc setParentVC:_parentVC];
    [nrvc setIsNotificationOn:YES];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:nrvc animated:NO completion:nil];
    }
    else{
        [self presentViewController:nrvc animated:YES completion:nil];
    }
}
#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _poi.number]]];
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
    NSString *str = [NSString stringWithString:_poi.name];
    if (_poi.address.length > 0) {
        str = [str stringByAppendingFormat:@",%@", _poi.address];
    }
    if (_poi.city) {
        str = [str stringByAppendingFormat:@",%@", _poi.city];
    }
    if (_poi.state) {
        str = [str stringByAppendingFormat:@",%@", _poi.state];
    }
    
    NSString *routeString = [NSString stringWithFormat:@"%@\n%.6f,%.6f",str,_poi.coord.latitude,_poi.coord.longitude];
    //check if the result already exists
    for (id record in arrayHistory) {
        NSString *recordString = [record objectForKey:@"LocationString"];
        if ([routeString isEqual:recordString]) {
            //no change
            return;
        }
    }
    NSMutableArray *arrayNew = [[NSMutableArray alloc]init];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
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
        view_landscape.hidden=NO;
    }else{
        view_landscape.hidden=YES;
    }
/*    if (!self.isVisible)
    {
        return;
    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        //TTGasStationInfoViewController tempView=self;
        //[self dismissViewControllerAnimated:YES completion:nil];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTGenericInfoViewController *gvc = nil;
        if (IS_IPAD) {
            gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController_ipad_landscape"];
        }
        else{
            gvc = [storyBoard instantiateViewControllerWithIdentifier:@"GenericInfoViewController_landscape"];
        }
        
        [gvc setParentVC:self.parentVC];
        [gvc setIsNotificationOn:NO];
        gvc.delegate=self;
        [gvc setPoi:self.poi];
        [gvc setSuperViewController:self];
        [self presentViewController:gvc animated:NO completion:^{self.isVisible=YES;}];
        isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
    }*/
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
