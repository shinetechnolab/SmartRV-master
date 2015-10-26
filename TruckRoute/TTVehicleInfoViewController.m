//
//  TTVehicleInfoViewController.m
//  TruckRoute
//
//  Created by admin on 10/9/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTVehicleInfoViewController.h"
#import "TTConfig.h"

@interface TTVehicleInfoViewController ()


@end

static float const hazmatPickerViewPaddingFactor = 0.9;


@implementation TTVehicleInfoViewController
@synthesize route_request;

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
            //mainBgImageView.image=[UIImage imageNamed:@"Find Address template .png"];
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
           // mainBgImageView.image=[UIImage imageNamed:@"Find Address template -Landscape.png"];
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
    //[self getCurrentOrientation];
}
-(void)viewDidAppear:(BOOL)animated{
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }else{
        [(TTVehicleInfoViewController *)_superViewController  setIsVisible:YES];
        [(TTVehicleInfoViewController *)_superViewController  viewDidAppear:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
//-(void)viewDidAppear:(BOOL)animated
//{
//    isVisible=YES;
//    if (_isNotificationOn) {
//        [self orientationChanged:nil];
//    }
//}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTVehicleInfoViewController *)_superViewController  setIsVisible:NO];
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    height_in_feet = route_request.vehicle_height/100;
    height_in_inches = route_request.vehicle_height*12/100 - height_in_feet*12 + .5;
    height_in_meter = (height_in_feet * 12 + height_in_inches)/39.3701;
    
    width_in_feet = route_request.vehicle_width/100;
    width_in_inches = route_request.vehicle_width*12/100 - width_in_feet*12 + .5;
    width_in_meter = (width_in_feet * 12 + width_in_inches)/39.3701;
    
    weight = route_request.vehicle_weight;
    
    length_in_feet = route_request.vehicle_length/100;
    length_in_inches = route_request.vehicle_length*12/100 - length_in_feet*12 + .5;
    length_in_meter = (length_in_feet * 12 + length_in_inches)/39.3701;
    
    hazmat = route_request.hazmat;
    if(isUnitMetric){
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
        [fmt setMaximumFractionDigits:0]; // to avoid any decimal
        NSInteger value = (int)(weight*0.453592);
        NSString *result = [fmt stringFromNumber:@(value)];
        
        [_labelHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        
        //[_labelWeight setText:[NSString stringWithFormat:@"%d", weight]];
        [_textWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        
        [_textWidth setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    }
    else{
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
        [fmt setMaximumFractionDigits:0]; // to avoid any decimal
        NSInteger value = weight;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_labelHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        
        [_labelWeight setText:[NSString stringWithFormat:@"%@ lbs",result]];
        [_textWeight setText:[NSString stringWithFormat:@"%@ lbs",result]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        
        [_textWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        
        
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ lbs",result]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    }
    
    _pickerData=[[NSArray alloc] initWithObjects:@"0.No Hazmat", @"1.Explosives", @"2.Gas", @"3.Flammable Liquids", @"4.Other Flammable Substances", @"5.Oxidizing Substances & Organic Peroxides", @"6.Toxic (Poisonous) & Infectious Substances", @"7.Radioactive Materials",@"8.Corrosives", @"9.Miscellaneous Dangerous Goods" ,nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
       // if (IS_IPAD) {
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
            
//        }
//        else{
//            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.delegate backButtonClick:self];
//        }
        
    }
}

- (IBAction)ok:(id)sender {
    //save result
    
   // NSArray *array=[_textLength.text componentsSeparatedByString:@"'"];
    
    route_request.vehicle_height = (height_in_feet+height_in_inches/12.0)*100;
    route_request.vehicle_width = (width_in_feet+width_in_inches/12.0)*100;
    route_request.vehicle_weight = weight;
    route_request.vehicle_length = (length_in_feet+length_in_inches/12.0)*100;
    //route_request.vehicle_length = ([[array objectAtIndex:0] intValue]+[[array objectAtIndex:1] intValue]/12.0)*100;
    route_request.hazmat = hazmat;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"route_request_vehicle_height"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_height)) forKey:@"route_request_vehicle_height"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_length"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_length)) forKey:@"route_request_vehicle_length"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_width"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_width)) forKey:@"route_request_vehicle_width"];
    [userDefaults removeObjectForKey:@"route_request_vehicle_weight"];
    [userDefaults setInteger:((NSInteger)(route_request.vehicle_weight)) forKey:@"route_request_vehicle_weight"];
    [userDefaults removeObjectForKey:@"route_request_hazmat"];
    [userDefaults setInteger:((NSInteger)(route_request.hazmat)) forKey:@"route_request_hazmat"];
    [userDefaults synchronize];
    
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
    }
}

- (IBAction)defaultValue:(id)sender {
    height_in_feet = DEFAULT_HEIGHT;
    height_in_inches = (DEFAULT_HEIGHT-height_in_feet)*12;
    width_in_feet = DEFAULT_WIDTH;
    width_in_inches = (DEFAULT_WIDTH-width_in_feet)*12;
    length_in_feet = DEFAULT_LENGTH;
    length_in_inches = (DEFAULT_LENGTH-length_in_feet)*12;

    height_in_meter=(height_in_feet * 12 + height_in_inches)/39.3701;
    width_in_meter=(width_in_feet * 12 + width_in_inches)/39.3701;
    length_in_meter=(length_in_feet * 12 + length_in_inches)/39.3701;
    
    weight = DEFAULT_WEIGHT;
    hazmat = DEFAULT_HAZMAT;
    
/*    [_labelHeight setText:[NSString stringWithFormat:@"%.1f", height]];
    [_labelWeight setText:[NSString stringWithFormat:@"%d", weight]];
    [_labelLength setText:[NSString stringWithFormat:@"%.1f", length]];
    [_labelWidth setText:[NSString stringWithFormat:@"%.1f", width]];
    [_labelHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];*/
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if(isUnitMetric){
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
        [fmt setMaximumFractionDigits:0]; // to avoid any decimal
        NSInteger value = (int)(weight*0.453592);
        NSString *result = [fmt stringFromNumber:@(value)];
        [_labelHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        
        [_labelWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        
        [_textWidth setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    }
    else{
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
        [fmt setMaximumFractionDigits:0]; // to avoid any decimal
        NSInteger value = weight;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_labelHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight setText:[NSString stringWithFormat:@"%d'%d\"",height_in_feet,height_in_inches]];
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%d'%d\"",height_in_feet,height_in_inches]];
        
        [_labelWeight setText:result];
        [_textWeight setText:[NSString stringWithFormat:@"%@ lbs",result]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ lbs",result]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        
        [_labelWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textWidth setText:[NSString stringWithFormat:@"%d'%d\"",width_in_feet,width_in_inches]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%d'%d\"",width_in_feet,width_in_inches]];
        
        [_labelHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    }
    
    [_textHeight setTextColor:[UIColor grayColor]];
    [_textWeight setTextColor:[UIColor grayColor]];
    [_textWeight setTextColor:[UIColor grayColor]];
    [_textLength setTextColor:[UIColor grayColor]];
    [_textLength setTextColor:[UIColor grayColor]];
    [_textWidth setTextColor:[UIColor grayColor]];
    [_textHazmat setTextColor:[UIColor grayColor]];
    
    [_textHeight_landscape setTextColor:[UIColor grayColor]];
    [_textWeight_landscape setTextColor:[UIColor grayColor]];
    [_textWeight_landscape setTextColor:[UIColor grayColor]];
    [_textLength_landscape setTextColor:[UIColor grayColor]];
    [_textLength_landscape setTextColor:[UIColor grayColor]];
    [_textWidth_landscape setTextColor:[UIColor grayColor]];
    [_textHazmat_landscape setTextColor:[UIColor grayColor]];
}

- (IBAction)decreaseHeight:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if (height_in_feet <= 0 && height_in_inches <= 0) {
        return;
    }
    if (0 == height_in_inches) {
        height_in_inches = 11;
        height_in_feet--;
    }else {
        if(isUnitMetric){height_in_inches-=3;}
        else{height_in_inches--;}
    }
    height_in_meter=(height_in_feet * 12 + height_in_inches)/39.3701;
    
    
   
    if(isUnitMetric){
        [_labelHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_labelHeight setTextColor:[UIColor orangeColor]];
        
        [_textHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight setTextColor:[UIColor orangeColor]];
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight_landscape setTextColor:[UIColor orangeColor]];
    }
    else{
        [_labelHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_labelHeight setTextColor:[UIColor orangeColor]];
    
        [_textHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight setTextColor:[UIColor orangeColor]];
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight_landscape setTextColor:[UIColor orangeColor]];
    }
    
}

- (IBAction)increaseHeight:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if (11 == height_in_inches) {
        height_in_inches = 0;
        height_in_feet++;
    }else {
        if(isUnitMetric){height_in_inches+=3;}
        else{height_in_inches++;}
        
    }
    height_in_meter=(height_in_feet * 12 + height_in_inches)/39.3701;
    
    if(isUnitMetric){
        [_labelHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
       
    }
    else{
        [_labelHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
    }
    [_labelHeight setTextColor:[UIColor orangeColor]];
    [_textHeight setTextColor:[UIColor orangeColor]];
    [_textHeight_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)decreaseWeight:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if (weight <= 0) {
        return;
    }
    weight -= 1000;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
    [fmt setMaximumFractionDigits:0]; // to avoid any decimal
    
    if(isUnitMetric){
        NSInteger value =  (int)(weight*0.453592);;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_textWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ Kg",result]];
    }
    else{
        NSInteger value = weight;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_textWeight setText:[NSString stringWithFormat:@"%@ lbs",result]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ lbs",result]];
    }
    [_textWeight setTextColor:[UIColor orangeColor]];
    [_textWeight_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)increaseWeight:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    weight += 1000;
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
    [fmt setMaximumFractionDigits:0]; // to avoid any decimal
    
    if(isUnitMetric){
        NSInteger value =  (int)(weight*0.453592);;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_textWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ Kg",result]];
    }
    else{
        NSInteger value = weight;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_textWeight setText:[NSString stringWithFormat:@"%@ lbs",result]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ lbs",result]];
    }
    [_textWeight setTextColor:[UIColor orangeColor]];
    [_textWeight_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)decreaseLength:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    if (length_in_feet <= 0 && length_in_inches <= 0) {
        return;
    }
    if (length_in_inches == 0) {
        length_in_inches = 11;
        length_in_feet--;
    }else {
        if(isUnitMetric){height_in_inches+=3;}
        else{height_in_inches++;}
        length_in_inches--;
    }
    
    length_in_meter=(length_in_feet * 12 + length_in_inches)/39.3701;
    
    
    if(isUnitMetric){
        [_labelLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
    }
    else{
        [_labelLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
    }
    [_labelLength setTextColor:[UIColor orangeColor]];
    [_textLength setTextColor:[UIColor orangeColor]];
    [_textLength_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)increaseLength:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    if (length_in_inches == 11) {
        length_in_inches = 0;
        length_in_feet++;
    }else {
        if(isUnitMetric){length_in_inches+=3;}
        else{length_in_inches++;}
        
    }
    
    length_in_meter=(length_in_feet * 12 + length_in_inches)/39.3701;
        if(isUnitMetric){
        
        [_labelLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
    }
    else{
        [_labelLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
    }
    [_labelLength setTextColor:[UIColor orangeColor]];
    [_textLength setTextColor:[UIColor orangeColor]];
    [_textLength_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)decreaseWidth:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    if (width_in_feet <= 0 && width_in_inches <= 0) {
        return;
    }
    if (width_in_inches == 0) {
        width_in_inches = 11;
        width_in_feet--;
    }else {
        if(isUnitMetric){width_in_inches-=3;}
        else{width_in_inches--;}
        
    }
    
    width_in_meter=(width_in_feet * 12 + width_in_inches)/39.3701;
    
    
    if(isUnitMetric){
        [_textWidth setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
    }
    else{
        [_labelWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        
    }
    [_labelWidth setTextColor:[UIColor orangeColor]];
    [_textWidth setTextColor:[UIColor orangeColor]];
    [_textWidth_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)increaseWidth:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    if (width_in_inches == 11) {
        width_in_inches = 0;
        width_in_feet++;
    }else {
        if(isUnitMetric){ width_in_inches+=3;}
        else{ width_in_inches++;}
       
    }
    
    width_in_meter=(width_in_feet * 12 + width_in_inches)/39.3701;
    
    if(isUnitMetric){
        [_textWidth setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
    }
    else{
        [_labelWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        
    }
    [_labelWidth setTextColor:[UIColor orangeColor]];
    [_textWidth setTextColor:[UIColor orangeColor]];
    [_textWidth_landscape setTextColor:[UIColor orangeColor]];
}

- (IBAction)decreaseHazmat:(id)sender {
    hazmat--;
    if (hazmat<0) {
        hazmat = 9;
    }
    [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
    [_textHazmat setTextColor:[UIColor orangeColor]];
    [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    [_textHazmat_landscape setTextColor:[UIColor orangeColor]];

}

- (IBAction)increaseHazmat:(id)sender {
    hazmat++;
    if (hazmat>9) {
        hazmat = 0;
    }
    [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
    [_textHazmat setTextColor:[UIColor orangeColor]];
    
    [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
    [_textHazmat_landscape setTextColor:[UIColor orangeColor]];
}

- (void)dealloc {
    [_labelHeight release];
    [_textHeight release];
    [_labelWeight release];
    [_textWeight release];
    
    [_labelLength release];
    [_textLength release];
    [_labelWidth release];
    [_textWidth release];
    [_labelHazmat release];
    [_textHazmat release];
    
    [_textHeight_landscape release];
    [_textWeight_landscape release];
    [_textLength_landscape release];
    [_textWidth_landscape release];
    [_textHazmat_landscape release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLabelHeight:nil];
    [self setTextHeight:nil];
    
    [self setLabelWeight:nil];
    [self setTextWeight:nil];
    
    [self setLabelLength:nil];
    [self setTextLength:nil];
    
    [self setLabelWidth:nil];
    [self setTextWidth:nil];
    
    [self setLabelHazmat:nil];
    [self setTextHazmat:nil];
    
    [self setTextHeight_landscape:nil];
    [self setTextWeight_landscape:nil];
    [self setTextLength_landscape:nil];
    [self setTextWidth_landscape:nil];
    [self setTextHazmat_landscape:nil];
    [super viewDidUnload];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_textWeight==textField || _textWidth_landscape==textField) {
        if (textField.text.length>0) {
            [textField resignFirstResponder];
            weight=[textField.text intValue];
            return YES;
        }else{
            [self alertViewForValidation:@"Please enter Proper Weight Value"];
            return NO;
        }
        
    }
    else if(_textLength == textField || _textHeight == textField || _textWidth == textField || _textLength_landscape == textField || _textHeight_landscape == textField || _textWidth_landscape == textField)
    {
        NSArray *array=[textField.text componentsSeparatedByString:@"'"];
        if (array.count>1) {
            if ([[array objectAtIndex:0] length]>0 && [[array objectAtIndex:1] length]>1) {
                [textField resignFirstResponder];
                if (_textLength==textField) {
                    length_in_feet=[[array objectAtIndex:0] intValue];
                    length_in_inches=[[array objectAtIndex:1] intValue];

                }else if(_textWidth==textField){
                    width_in_feet=[[array objectAtIndex:0] intValue];
                    width_in_inches=[[array objectAtIndex:1] intValue];
                }
                else{
                    height_in_feet=[[array objectAtIndex:0] intValue];
                    height_in_inches=[[array objectAtIndex:1] intValue];
                }
                return YES;
            }else{ return NO;}
        }
        else{
            [self alertViewForValidation:@"Please enter Proper Length Value"];
            return NO;
        }
    }
    else if(_textHazmat == textField || _textHazmat_landscape==textField){
        if (textField.text.length>0) {
            [textField resignFirstResponder];
            hazmat=[textField.text intValue];
            return YES;
        }else{
            [self alertViewForValidation:@"Please enter Proper Weight Value"];
            return NO;
        }
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
    
}
-(void)alertViewForValidation:(NSString *)msg
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
   // return NO;

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_textLength==textField || _textWidth==textField || _textHeight==textField || _textLength_landscape==textField || _textWidth_landscape==textField || _textHeight_landscape==textField) {
        NSString *textToChange  = [[textField text] substringWithRange:range];
        if (string.length == 0)
        {
            NSLog(@"is cleared! : %@  , %@",textField.text,textToChange);
            if ([textToChange isEqualToString:@"\""] || [textToChange isEqualToString:@"'"]) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:@"You can change only number value" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                return NO;
            }
            //return NO;
        }
    }
    return YES;

}
-(IBAction)clickOnTextField:(id)sender
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    UITextField *textField=(UITextField *)sender;
    //    if (textField.tag==1 || textField.tag==4) {
    if (textField.tag== 1) {
        NSInteger value = (int)(weight*0.453592) +1;
        if (isUnitMetric) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%ld",(long)value]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }
        else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%i",weight]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }
    }
    else if (textField.tag == 4) {
        [self showHamatOptions];
    }
    else {
       
        if (isUnitMetric) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%.1f",[textField.text floatValue]]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];

        }
        else{
            NSArray *array=[textField.text componentsSeparatedByString:@"'"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            // Alert style customization
            [[av textFieldAtIndex:1] setSecureTextEntry:NO];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%i",[[array objectAtIndex:0] intValue]]];
            [[av textFieldAtIndex:1] setText:[NSString stringWithFormat:@"%i",[[array objectAtIndex:1] intValue]]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [[av textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }
    }
}
-(IBAction)editButtonClick:(id)sender
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];

    UIButton *btn=(UIButton *)sender;
//    if (btn.tag==1 || btn.tag==4)
    if (btn.tag==1 )
    {
        NSInteger value = (int)(weight*0.453592);
        if (isUnitMetric) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%ld",(long)value]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }
        else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:_textWeight.text];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }

    }
    else if (btn.tag == 4){
        [self showHamatOptions];
    }
    else{
        if (isUnitMetric) {
            NSString *string=nil;
            switch (btn.tag) {
                case 0:
                    string =_textHeight.text;
                    break;
                case 2:
                    string =_textLength.text;
                    break;
                case 3:
                    string =_textWidth.text;
                    break;
                default:
                    break;
            }

            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%.1f",[string floatValue]]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
            
        }
        else{
            NSArray *array=nil;
            switch (btn.tag) {
                case 0:
                    array =[_textHeight.text componentsSeparatedByString:@"'"];
                    break;
                case 2:
                    array =[_textLength.text componentsSeparatedByString:@"'"];
                    break;
                case 3:
                    array =[_textWidth.text componentsSeparatedByString:@"'"];
                    break;
                default:
                    break;
            }
            // array =[textField.text componentsSeparatedByString:@"'"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.tag=[sender tag];
            [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            // Alert style customization
            [[av textFieldAtIndex:1] setSecureTextEntry:NO];
            [[av textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%i",[[array objectAtIndex:0] intValue]]];
            [[av textFieldAtIndex:1] setText:[NSString stringWithFormat:@"%i",[[array objectAtIndex:1] intValue]]];
            [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [[av textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
            [av show];
            [av release];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isUnitMetric = [userDefault boolForKey:@"Metric"];
    if (isUnitMetric) {
        //width_in_meter=(width_in_feet * 12 + width_in_inches)/39.3701;
        if (alertView.tag==0) {
            float value1=[[alertView textFieldAtIndex:0].text floatValue] * 39.3701 /12; //*100;
            height_in_feet = value1;
            height_in_inches = value1*12 - height_in_feet*12 + .5;
            height_in_meter=(height_in_feet * 12 + height_in_inches)/39.3701;

        }
        else if (alertView.tag==2)
        {
            float value1=[[alertView textFieldAtIndex:0].text floatValue] * 39.3701 /12;
            length_in_feet = value1;//64566.9609
            length_in_inches = value1*12 - length_in_feet*12 + .5;
            length_in_meter=(length_in_feet * 12 + length_in_inches)/39.3701;
        }
        else if(alertView.tag==3)
        {
            float value1=[[alertView textFieldAtIndex:0].text floatValue] * 39.3701 /12;
            width_in_feet = value1;
            width_in_inches = value1*12 - width_in_feet*12 + .5;
            width_in_meter=(width_in_feet * 12 + width_in_inches)/39.3701;
        }
        else{
            weight=[[alertView textFieldAtIndex:0].text intValue]/0.453592;
            
        }
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
        [fmt setMaximumFractionDigits:0]; // to avoid any decimal
        NSInteger value = (int)(weight*0.453592) +1 ;
        NSString *result = [fmt stringFromNumber:@(value)];
        [_labelHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textHeight setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        
        //[_labelWeight setText:[NSString stringWithFormat:@"%d", weight]];
        [_textWeight setText:[NSString stringWithFormat:@"%@ Kg",result]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textLength setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        
        [_textWidth setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%.1f m", height_in_meter]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%@ Kg",result]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%.1f m", length_in_meter]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%.1f m", width_in_meter]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];

    }
    else{
    //NSArray *array=[textField.text componentsSeparatedByString:@"'"];
    if (buttonIndex==1) {
            int value1;
            int value2;
            
            if (alertView.alertViewStyle== UIAlertViewStylePlainTextInput) {
                value1=[[alertView textFieldAtIndex:0].text intValue];
                value2=0;
            }
            else{
                value1=[[alertView textFieldAtIndex:0].text intValue];
                value2=[[alertView textFieldAtIndex:1].text intValue];
            }
        
        switch (alertView.tag) {
            case 0:
                NSLog(@"0");
                height_in_feet=value1;
                height_in_inches=value2;
                break;
            case 1:
                NSLog(@"1");
                weight=value1;
                break;
            case 2:
                NSLog(@"2");
                length_in_feet=value1;
                length_in_inches=value2;
                break;
            case 3:
                NSLog(@"3");
                width_in_feet=value1;
                width_in_inches=value2;
                break;
            case 4:
                NSLog(@"4");
                hazmat=value1;
                break;
            default:
                break;
        }
        
        [_labelHeight setText:[NSString stringWithFormat:@"%d'%d\"", height_in_feet, height_in_inches]];
        [_textHeight setText:[NSString stringWithFormat:@"%d'%d\"",height_in_feet,height_in_inches]];
        
        [_labelWeight setText:[NSString stringWithFormat:@"%d lbs", weight]];
        [_textWeight setText:[NSString stringWithFormat:@"%d lbs", weight]];
        
        [_labelLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textLength setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        
        [_textWidth setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_labelWidth setText:[NSString stringWithFormat:@"%d'%d\"",width_in_feet,width_in_inches]];
        
        [_labelHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
        
        [_textHeight_landscape setText:[NSString stringWithFormat:@"%d'%d\"",height_in_feet,height_in_inches]];
        [_textWeight_landscape setText:[NSString stringWithFormat:@"%d", weight]];
        [_textLength_landscape setText:[NSString stringWithFormat:@"%d'%d\"", length_in_feet, length_in_inches]];
        [_textWidth_landscape setText:[NSString stringWithFormat:@"%d'%d\"", width_in_feet, width_in_inches]];
        [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];

    }
    }
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    if (IS_IPAD) {
        UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
        if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight))
        {
            portraitView.hidden=YES;
        }
        else{
            portraitView.hidden=NO;
        }
    }
    else{
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
            TTVehicleInfoViewController *vivc=nil;
            if (IS_IPAD) {
                vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController_ipad_landscape"];
            }
            else{
                vivc= [storyBoard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController_landscape"];
            }
            
            [vivc setRoute_request:self.route_request];
            vivc.delegate=self;
            vivc.isNotificationOn=NO;
            [vivc setSuperViewController:self];
            [self presentViewController:vivc animated:NO completion:^{ self.isVisible=YES; }];
            isShowingLandscapeView = YES;
        }
        else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            isShowingLandscapeView = NO;
        }
    }
}
-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIPickerView methods

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"option %ld selected", (long)row);
    hazmat = row;
    [_textHazmat setText:[NSString stringWithFormat:@"%d", hazmat]];
    [_textHazmat_landscape setText:[NSString stringWithFormat:@"%d", hazmat]];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setFont:[UIFont fontWithName:@"System" size:14]];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        pickerLabel.adjustsFontSizeToFitWidth=YES;
        pickerLabel.minimumScaleFactor=0.5;
    }

    pickerLabel.text = _pickerData[row];
    return pickerLabel;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return [pickerHolderView bounds].size.width * hazmatPickerViewPaddingFactor;
}

-(void)showHamatOptions
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y -= 206;
    pickerHolderView.frame=rect;
    [UIView commitAnimations];
}

-(IBAction)pickerDoneButtonClick:(id)sender
{
    [self dismissHazmatPickerView];
}

- (void)dismissHazmatPickerView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MENU_PANEL_ANIMATION_DURATION];
    CGRect rect=pickerHolderView.frame;
    rect.origin.y += 206;
    pickerHolderView.frame = rect;
    [UIView commitAnimations];
}

@end
