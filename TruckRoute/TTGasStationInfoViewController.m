//
//  TTGasStationInfoViewController.m
//  TruckRoute
//
//  Created by admin on 4/5/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTGasStationInfoViewController.h"
#import "TTNewRouteViewController.h"
#import "TTConfig.h"
#import "TTUtilities.h"

@interface TTGasStationInfoViewController ()

@end

@implementation TTGasStationInfoViewController

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
//             mainBgImageView.image=[UIImage imageNamed:@"Truck Stop Detail BG~ipad.png"];
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
//             mainBgImageView.image=[UIImage imageNamed:@"Truck Stop Detail BG-Landscape~ipad.png"];
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
   // [self getCurrentOrientation];
//if (_isNotificationOn) {
//        [self orientationChanged:nil];
// }
    NSLog(@"UIInterfaceOrientation change");
}
-(void)viewDidAppear:(BOOL)animated
{
    self.isVisible=YES;
    if (_isNotificationOn) {
         [self orientationChanged:nil];
    }
    else{
        [(TTGasStationInfoViewController *)_superViewController  setIsVisible:YES];
        [(TTGasStationInfoViewController *)_superViewController  viewDidAppear:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTGasStationInfoViewController *)_superViewController  setIsVisible:NO];
    }
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    isShowingLandscapeView = NO;
    
    
    [super viewDidLoad];
    
    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
      //  [self orientationChanged:nil];
    }
   // [self orientationChanged:nil];
    topView.layer.cornerRadius=7;
    bottomView.layer.cornerRadius=7;
    centerView.layer.cornerRadius=7;
    topView_landscape.layer.cornerRadius=7;
    bottomView_landscape.layer.cornerRadius=7;
    centerView_landscape.layer.cornerRadius=7;
    //[self getCurrentOrientation];
	// Do any additional setup after loading the view.
    responseData = [[NSMutableData alloc]init];
    //[self initSpinner];
    
    UIImage *img = nil;
    img = [UIImage imageNamed:[NSString stringWithFormat:@"L%@",_poi.image]];
    if (nil == img) {
        img = [UIImage imageNamed:@"L2001__Gas.png"];
    }
    [_imageLogo setImage:img];
    [_labelName setText:_poi.name];
    [_labelLocation setText:[NSString stringWithFormat:@"%.4f,  %.4f", _poi.coord.latitude, _poi.coord.longitude]];
    
    [_imageLogo_landscape setImage:img];
    [_labelName_landscape setText:_poi.name];
    [_labelLocation_landscape setText:[NSString stringWithFormat:@"%.4f,  %.4f", _poi.coord.latitude, _poi.coord.longitude]];
    if (_poi.address) {
        [_labelAddress setText:_poi.address];
        [_labelAddress_landscape setText:_poi.address];
    }else {
        [_labelAddress setHidden:YES];
        [_labelAddress_landscape setHidden:YES];
    }
/*    if (_poi.number) {
        [_buttonPhone setTitle:_poi.number forState:UIControlStateNormal];
    }else {
        [_buttonPhone setHidden:YES];
    }*/
    if (_poi.city) {
        [_labelCity setText:_poi.city];
        [_labelCity_landscape setText:_poi.city];
    }else {
        [_labelCity setHidden:YES];
         [_labelCity_landscape setHidden:YES];
    }
    if (_poi.state) {
        [_labelState setText:[TTUtilities getAbbreviation:_poi.state]];
        [_labelState_landscape setText:[TTUtilities getAbbreviation:_poi.state]];
    }else {
        [_labelState setHidden:YES];
        [_labelState_landscape setHidden:YES];
    }
    if (_poi.zipcode) {
        [_labelZip setText: _poi.zipcode];
        [_labelZip_landscape setText: _poi.zipcode];
    }else {
        [_labelZip setHidden:YES];
        [_labelZip_landscape setHidden:YES];
    }
    
    
    if ([_poi.diesel_string isEqual:@"0"]) {
        [_labelDiesel setHidden:YES];
        [_labelPriceDiesel setHidden:YES];
        [_labelTimeDiesel setHidden:YES];
        [_labelDiesel_landscape setHidden:YES];
        [_labelPriceDiesel_landscape setHidden:YES];
        [_labelTimeDiesel_landscape setHidden:YES];
    }else {
        if ([@"N/A" isEqual:_poi.diesel_price]) {
            [_labelPriceDiesel setText:@""];
            [_labelPriceDiesel_landscape setText:@""];
            [_labelTimeDiesel setText:@"unknown"];
            [_labelTimeDiesel_landscape setText:@"unknown"];
        }else {
            //[_labelPriceDiesel setText:[NSString stringWithFormat:@"$%@",_poi.diesel_price]];
            [_labelPriceDiesel setText:@""];
            //[_labelTimeDiesel setText:_poi.diesel_price_date];
            [_labelTimeDiesel setText:@"Available"];
            [_labelPriceDiesel_landscape setText:[NSString stringWithFormat:@"$%@",_poi.diesel_price]];
            [_labelTimeDiesel_landscape setText:@"Available"];
            _labelTimeDiesel.textColor=[UIColor darkTextColor];
            _labelTimeDiesel_landscape.textColor=[UIColor darkTextColor];
        }
    }
    if ([@"N/A" isEqual:_poi.reg_price]) {
        [_labelPriceReg setText:@""];
        [_labelPriceReg_landscape setText:@""];
        [_labelTimeReg setText:@"unknown"];
        [_labelTimeReg_landscape setText:@"unknown"];
    }else {
        [_labelPriceReg setText:@""];
        [_labelTimeReg setText:@"Available"];
        [_labelPriceReg_landscape setText:@""];
        [_labelTimeReg_landscape setText:@"Available"];
        _labelTimeReg.textColor=[UIColor darkTextColor];
        _labelTimeReg_landscape.textColor=[UIColor darkTextColor];
    }
    if ([@"N/A" isEqual:_poi.mid_price]) {
        [_labelPricePlus setText:@""];
         [_labelPricePlus_landscape setText:@""];
        [_labelTimePlus setText:@"unknown"];
        [_labelTimePlus_landscape setText:@"unknown"];
    }else {
        [_labelPricePlus setText:@""];
        
        [_labelPricePlus_landscape setText:@""];
        [_labelTimePlus setText:@"Available"];
        [_labelTimePlus_landscape setText:@"Available"];
        _labelTimePlus.textColor=[UIColor darkTextColor];
        _labelTimePlus_landscape.textColor=[UIColor darkTextColor];


    }
    if ([@"N/A" isEqual:_poi.pre_price]) {
        [_labelPricePremium setText:@""];
        [_labelPricePremium_landscape setText:@""];
        [_labelTimePremium setText:@"unknown"];
        [_labelTimePremium_landscape setText:@"unknown"];
    }else {
        [_labelPricePremium setText:@""];
        [_labelPricePremium_landscape setText:@""];
        
        [_labelTimePremium setText:@"Available"];
        [_labelTimePremium_landscape setText:@"Available"];
        _labelTimePremium.textColor=[UIColor darkTextColor];
        _labelTimePremium_landscape.textColor=[UIColor darkTextColor];

    }

    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    } else {
        [_labelPriceDiesel adjustsFontSizeToFitWidthAndHeight];
        [_labelPriceReg adjustsFontSizeToFitWidthAndHeight];
        [_labelPricePlus adjustsFontSizeToFitWidthAndHeight];
        [_labelPricePremium adjustsFontSizeToFitWidthAndHeight];
        [_labelTimeDiesel adjustsFontSizeToFitWidthAndHeight];
        [_labelTimePlus adjustsFontSizeToFitWidthAndHeight];
        [_labelTimePremium adjustsFontSizeToFitWidthAndHeight];
        [_labelTimeReg adjustsFontSizeToFitWidthAndHeight];
        [_labelDiesel adjustsFontSizeToFitWidthAndHeight];
        [_labelPrim adjustsFontSizeToFitWidthAndHeight];
        [_labelReg adjustsFontSizeToFitWidthAndHeight];
        [_labelPlus adjustsFontSizeToFitWidthAndHeight];
        
        [_labelName adjustsFontSizeToFitWidthAndHeight];
        [_labelCity adjustsFontSizeToFitWidthAndHeight];
        [_labelState adjustsFontSizeToFitWidthAndHeight];
        [_labelZip adjustsFontSizeToFitWidthAndHeight];
        
        [_labelLocation adjustsFontSizeToFitWidthAndHeight];
    }
   // [self submitRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_labelName release];
    [_imageLogo release];
    [_buttonPhone release];
    [_labelPriceReg release];
    [_labelPricePlus release];
    [_labelPricePremium release];
    [_labelPriceDiesel release];
    [_labelAddress release];
    [_labelCity release];
    [_labelState release];
    [_labelZip release];
    [_labelLocation release];
    [_labelTimeReg release];
    [_labelTimePlus release];
    [_labelTimePremium release];
    [_labelTimeDiesel release];
    [_labelDiesel release];
    
    [_labelName_landscape release];
    [_imageLogo_landscape release];
    [_buttonPhone_landscape release];
    [_labelPriceReg_landscape release];
    [_labelPricePlus_landscape release];
    [_labelPricePremium_landscape release];
    [_labelPriceDiesel_landscape release];
    [_labelAddress_landscape release];
    [_labelCity_landscape release];
    [_labelState_landscape release];
    [_labelZip_landscape release];
    [_labelLocation_landscape release];
    [_labelTimeReg_landscape release];
    [_labelTimePlus_landscape release];
    [_labelTimePremium_landscape release];
    [_labelTimeDiesel_landscape release];
    [_labelDiesel_landscape release];
    
    [responseData release];
    [super dealloc];
}
- (IBAction)callPhoneNumber:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Call %@ ?", _poi.number]
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
    [userDefaults synchronize];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    TTNewRouteViewController *nrvc = nil;
    if (IS_IPAD) {
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController_ipad"];
    }
    else{
        nrvc=[storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
    }
    [nrvc setParentVC:self.parentVC];
    [nrvc setIsNotificationOn:YES];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self presentViewController:nrvc animated:NO completion:nil];
    }
    else{
        [self presentViewController:nrvc animated:YES completion:nil];
    }
    
/*    [self dismissViewControllerAnimated:NO completion:^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTNewRouteViewController *nrvc = [storyBoard instantiateViewControllerWithIdentifier:@"NewRouteViewController"];
        [nrvc setParentVC:_parentVC];
        [_parentVC presentViewController:nrvc animated:YES completion:nil];
    }];*/
}

-(void)submitRequest
{
    [self startWaiting];
    [responseData setLength:0];
    NSString *strURL = [NSString stringWithFormat:@"%@/stations/details/%d/%@.json", SERVER_URL_FOR_GAS_STATION_SEARCH, _poi.identifier, APPLICATION_KEY_FOR_GAS_STATION_SEARCH];
    
    NSURLConnection *connectionResponse = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]] delegate:self];
    [connectionResponse autorelease];
    
    if(connectionResponse)
    {
        NSLog(@"Find Gas Station Request submitted");
    }
    else {
        NSLog(@"Failed to submit request");
        
        [self stopWaiting];
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
#pragma mark waiting animation
-(void)initSpinner
{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(110, 190, 100, 100);
    spinner.hidesWhenStopped = YES;
    CGAffineTransform transform = CGAffineTransformMakeScale(3, 3);
    [spinner setTransform:transform];
    spinner.color = [UIColor blueColor];
    [self.view addSubview:spinner];
}
-(void)startWaiting
{
    //lock app
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [spinner startAnimating];
}
-(void)stopWaiting
{
    [spinner stopAnimating];
    //unlock application
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}
#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"failed 1: %@", [error localizedDescription]);
    
    [self stopWaiting];
    NSString * msgStr=[NSString stringWithFormat:@"%@ Please re-check your internet connection.",[error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"connection failed" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stopWaiting];
#ifdef DEBUG
    //    NSString *string = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]autorelease];
    //    NSLog(@"%@", string);
#endif
    NSError *err = nil;
    NSDictionary *jsonArray = nil;
    jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
    NSLog(@"jsonArray: %@", jsonArray);
    NSDictionary *details = [jsonArray objectForKey:@"details"];
    if ([[details objectForKey:@"diesel"] isEqual:@"0"]) {
        [_labelDiesel setHidden:YES];
        [_labelPriceDiesel setHidden:YES];
        [_labelTimeDiesel setHidden:YES];
        [_labelDiesel_landscape setHidden:YES];
        [_labelPriceDiesel_landscape setHidden:YES];
        [_labelTimeDiesel_landscape setHidden:YES];

    }else {
        if ([@"N/A" isEqual:[details objectForKey:@"diesel_price"]]) {
            [_labelPriceDiesel setText:@"unknown"];
            [_labelPriceDiesel_landscape setText:@"unknown"];
        }else {
            [_labelPriceDiesel setText:[NSString stringWithFormat:@"$%@", [details objectForKey:@"diesel_price"]]];
            [_labelTimeDiesel setText:[details objectForKey:@"diesel_date"]];
        }        
    }
    if ([@"N/A" isEqual:[details objectForKey:@"reg_price"]]) {
        [_labelPriceReg setText:@"unknown"];
    }else {
        [_labelPriceReg setText:[NSString stringWithFormat:@"$%@", [details objectForKey:@"reg_price"]]];
        [_labelTimeReg setText:[details objectForKey:@"reg_date"]];
    }
    if ([@"N/A" isEqual:[details objectForKey:@"mid_price"]]) {
        [_labelPricePlus setText:@"unknown"];
    }else {
        [_labelPricePlus setText:[NSString stringWithFormat:@"$%@", [details objectForKey:@"mid_price"]]];
        [_labelTimePlus setText:[details objectForKey:@"mid_date"]];
    }
    if ([@"N/A" isEqual:[details objectForKey:@"pre_price"]]) {
        [_labelPricePremium setText:@"unknown"];
    }else {
        [_labelPricePremium setText:[NSString stringWithFormat:@"$%@", [details objectForKey:@"pre_price"]]];
        [_labelTimePremium setText:[details objectForKey:@"pre_date"]];
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
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    //save new orientation
//    NSLog(@"orientation change");
//}

- (void)orientationChanged:(NSNotification *)notification

{
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
    {
        landscapeMainView.hidden=NO;
    }else{
        landscapeMainView.hidden=YES;
    }

    
/*    if (isIpad) {
        if (!self.isVisible)
        {
            return;
        }
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
        {
            //TTGasStationInfoViewController tempView=self;
            //[self dismissViewControllerAnimated:YES completion:nil];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            TTGasStationInfoViewController *gsvc = nil;
            if (IS_IPAD) {
                gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TTGasStationInfoViewController_ipad_landscape"];
            }
            else{
                gsvc = [storyBoard instantiateViewControllerWithIdentifier:@"TTGasStationInfoViewController_landscape"];
            }
            [gsvc setParentVC:self.parentVC];
            [gsvc setPoi:self.poi];
            gsvc.delegate=self;
            [gsvc setSuperViewController:self];
            [self presentViewController:gsvc animated:NO completion:^{self.isVisible=YES;}];
            isShowingLandscapeView = YES;
        }
        else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            isShowingLandscapeView = NO;
        }

    }
    else{
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
            landscapeMainView.hidden=NO;
        }else{
            landscapeMainView.hidden=YES;
        }

    }*/
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
