//
//  TTRouteDetailsViewController.m
//  TruckRoute
//
//  Created by admin on 10/23/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTRouteDetailsViewController.h"
#import "TTRouteInstruction.h"
#import "TTRouteDetailCell.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )

static NSString * const kMFMailComposeViewController = @"MFMailComposeViewController";
static NSString * const kMailRecipientForMFMailComposeView = @"";


@interface TTRouteDetailsViewController ()

@end

@implementation TTRouteDetailsViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
//    self.isVisible=YES;
//    if (_isNotificationOn) {
//        [self orientationChanged:nil];
//    }
//    else{
//        [(TTRouteDetailsViewController *)_superViewController  setIsVisible:YES];
//        [(TTRouteDetailsViewController *)_superViewController  viewDidAppear:YES];
//    }
    [tableView reloadData];
    [tableView_landscape reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    //if (_isNotificationOn) {
        [self orientationChanged:nil];
   // }
//    self.isVisible=YES;
    //    else{
//        [(TTRouteDetailsViewController *)_superViewController  setIsVisible:YES];
//    }
    [super viewWillAppear:animated];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(UIDeviceOrientationIsLandscape(deviceOrientation)){
        mainLandscapeView.hidden=YES;
    }
    else{
        mainLandscapeView.hidden=NO;
    }
    [tableView setContentOffset:self.routeDetailsContentOffset];
    [tableView_landscape setContentOffset:self.routeDetailsContentOffset_landscape];

}
- (void)viewWillDisappear:(BOOL)animated
{
//    self.isVisible = NO;
//    if (!_isNotificationOn) {
//        [(TTRouteDetailsViewController *)_superViewController  setIsVisible:NO];
//    }

    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if (_isNotificationOn) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
    }
	// Do any additional setup after loading the view.
    topView.layer.cornerRadius=7;
    topView.clipsToBounds=YES;
    tableView.layer.cornerRadius=7;
  //    SubscriptionRequest_IsPurchased
    
     instructions = [_routeAnalyzer instructions];
    //update the summary
    NSString *summary = [NSString stringWithFormat:@"To: %@\n%@", _routeAnalyzer.strDestination,_routeAnalyzer.strRouteType];
    [_labelSummary setText:summary];
    [_labelSummary_landscape setText:summary];
   // [_labelSummary adjustsFontSizeToFitWidthAndHeight];
    NSLog(@"Route Summary : %@",summary);
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    NSString *info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time : %@\n   %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime, self.stateBorderInfoText];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isMetric = [userDefaults boolForKey:@"Metric"];
    if (isMetric) {
        info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@\n   %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime, self.stateBorderInfoText];
    }
//    if(UIDeviceOrientationIsLandscape(deviceOrientation) && IS_IPAD){
//        info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
//        if (isMetric) {
//            info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime];
//        }
//
//    }
    
    if(IS_IPAD){
//        _labelInfo.font=[UIFont systemFontOfSize:40.0];
        _labelSummary.font=[UIFont systemFontOfSize:40.0];
    }
    //NSString *info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
    [_labelInfo_landscape setText:info];
    if(IS_IPAD){
        info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time : %@\n   %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime, self.stateBorderInfoText];
        if (isMetric) {
            info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time : %@\n   %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime, self.stateBorderInfoText];
        }
    }
//    _labelInfo.numberOfLines = 3;
//    _labelInfo.minimumScaleFactor = 0.5;
//    _labelInfo.adjustsFontSizeToFitWidth = YES;
    
    [_labelInfo setText:info];
    
#ifdef __IPHONE_7_0
//    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    [_labelSummary setFont:font];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ok:(id)sender {
   // [self dismissViewControllerAnimated:YES completion:nil];
//    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
//    }
//    else{
//        //if(IS_IPAD){
//            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
////        }else{
////            [self dismissViewControllerAnimated:NO completion:nil];
////            [self.delegate backButtonClick:self];
////        }
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return 120;
    }else{
        return 80;
    }
}
#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    //#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    //Return the number of rows in the section.
    return instructions.count - 2;//the first one and the last 2 are not real instructions
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TTRouteDetailCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    TTRouteInstruction *cur_instruction = [instructions objectAtIndex:indexPath.row + 1];
    
    // Configure the cell...
    [cell.lableInstruction setText:cur_instruction.info];
    [cell.labelDistance setText:cur_instruction.distanceInfo];
    if (IS_IPAD) {
        cell.lableInstruction.font=[UIFont boldSystemFontOfSize:35.0];
        cell.labelDistance.font=[UIFont systemFontOfSize:33.0];
//        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//        if(!UIDeviceOrientationIsLandscape(deviceOrientation))
//        {
//            CGRect rect=cell.lableInstruction.frame;
//            rect.origin.x=115;
//            rect.origin.y=-8;
//            rect.size.height=103;
//            rect.size.width=625;//tableView.frame.size.width-150;
//            cell.lableInstruction.frame=rect;
//            CGRect rect1=cell.labelDistance.frame;
//            rect1.origin.x=115;
//            rect1.origin.y=85;
//            rect1.size.height=25;
//            rect1.size.width=tableView.frame.size.width-115;
//            cell.labelDistance.frame=rect1;
//        }
    }
    
    NSString *name = nil;
    switch (cur_instruction.direction) {
        case direction_start:
        case direction_start_head:
        case direction_start_from:
            name = @"direction_start.png";
            break;
            
        case direction_turn_left:
        case direction_turn_left_only:
        case direction_turn_left_towards:
            name = @"direction_turnleft.png";
            break;
            
        case direction_bear_left:
        case direction_bear_left_only:
        case direction_bear_left_towards:
            name = @"direction_bearleft.png";
            break;
            
        case direction_turn_right:
        case direction_turn_right_only:
        case direction_turn_right_towards:
            name = @"direction_turnright.png";
            break;
            
        case direction_bear_right:
        case direction_bear_right_only:
        case direction_bear_right_towards:
            name = @"direction_bearright.png";
            break;
            
        case direction_exit:
        case direction_exit_only:
        case direction_ramp:
        case direction_ramp_only:
        case direction_ramp_left:
        case direction_ramp_right:
        case direction_rotary:
            name = @"direction_exit.png";//will work on this later
            break;
            
        case direction_exit_left:
            name = @"direction_exitleft.png";
            break;
            
        case direction_exit_right:
            name = @"direction_exitright.png";
            break;
            
        case direction_merge:
            name = @"direction_merge.png";
            break;
            
        case direction_merge_to_left:
            name = @"direction_mergeright.png";
            break;
            
        case direction_merge_to_right:
            name = @"direction_mergeleft.png";
            break;
            
        case direction_continue:
            name = @"direction_continue.png";
            break;
            
        case direction_u_turn_left:
            name = @"direction_uturnleft.png";
            break;
            
        case direction_u_turn_right:
            name = @"direction_uturnright.png";
            break;
            
        case direction_end:
            name = @"direction_destination.png";
            break;
            
        default:
            break;
    }
    UIImage *img = [UIImage imageNamed:name];
    [cell.imageDirection setImage:img];
    if (IS_IPAD) {
        cell.imageDirection.frame=CGRectMake(8, 8,90, 90);
    }
    
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTRouteInstruction *cur_ins = [instructions objectAtIndex:indexPath.row + 1];
    [_parentVC pauseNavigatingFromOutside];
    [_parentVC moveToCoordinate:cur_ins.coord withZoomLevel:1];
   // [self dismissViewControllerAnimated:YES completion:nil];
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
    }

}


- (void)dealloc {
    [_labelSummary release];
    [_labelInfo release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLabelSummary:nil];
    [super viewDidUnload];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight)){
        mainLandscapeView.hidden=YES;
    }
    else{
        mainLandscapeView.hidden=NO;
    }

    
//    NSString *summary = [NSString stringWithFormat:@"To: %@\n%@", _routeAnalyzer.strDestination,_routeAnalyzer.strRouteType];
//    [_labelSummary setText:summary];
//    // [_labelSummary adjustsFontSizeToFitWidthAndHeight];
//    NSLog(@"Route Summary : %@",summary);
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    NSString *info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isMetric = [userDefaults boolForKey:@"Metric"];
//    if (isMetric) {
//        info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime];
//    }
//    if(UIDeviceOrientationIsLandscape(deviceOrientation) && IS_IPAD){
//        info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
//        if (isMetric) {
//            info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime];
//        }
//        
//    }
//    [_labelInfo setText:info];
//
//    if (!self.isVisible) {
//        return;
//    }
//    
//   // UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if(UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
//    {
//        //TTGasStationInfoViewController tempView=self;
//        //[self dismissViewControllerAnimated:YES completion:nil];
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTRouteDetailsViewController *fmvc =nil;
//        if (IS_IPAD) {
//            fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_ipad_landscape"];
//        }
//        else{
//            fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_landscape"];
//        }
//        fmvc.delegate=self;
//        [fmvc setRouteAnalyzer:_routeAnalyzer];//readonly
//        [fmvc setParentVC:_parentVC];
//        [fmvc setIsNotificationOn:NO];
//        [fmvc setSuperViewController:self];
//        //[fmvc setPoiManager:self.poiManager];
//        [self presentViewController:fmvc animated:NO completion:^{self.isVisible=YES;}];
//        isShowingLandscapeView = YES;
//        fmvc.routeDetailsContentOffset = self.routeDetailsContentOffset;
//    }
//    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        isShowingLandscapeView = NO;
//    }
}

-(void)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Scroll the table view to the current instruction.
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition :(UITableViewScrollPosition)scrollPosition
{
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Scrolls the table view down by half of table view's row height.
    self.routeDetailsContentOffset = CGPointMake(0, (tableView.contentOffset.y - (tableView.rowHeight/2)));
    [tableView setContentOffset:self.routeDetailsContentOffset];
    
    [tableView_landscape scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Scrolls the table view down by half of table view's row height.
    self.routeDetailsContentOffset_landscape = CGPointMake(0, (tableView_landscape.contentOffset.y - (tableView_landscape.rowHeight/2)));
    [tableView_landscape setContentOffset:self.routeDetailsContentOffset_landscape];
}

#pragma mark IBAction Methods

-(IBAction)exportRouteButtonClick:(id)sender
{
    
    [self exportRouteInfo];
    
}

#pragma mark mailcomposecontroller methods

-(void)exportRouteInfo
{
    Class mailComposerClass = NSClassFromString(kMFMailComposeViewController);
    if (mailComposerClass != nil && [mailComposerClass canSendMail]){
        [self displayMailComposerView];
    }
    else {
        [self showCannotSendMailAlert];
    }
}

- (void)displayMailComposerView
{
    NSArray *toRecipents = [NSArray arrayWithObject:kMailRecipientForMFMailComposeView];
    MFMailComposeViewController *mailComposeView = [[MFMailComposeViewController alloc] init];
    mailComposeView.mailComposeDelegate = self;
    NSString *subject = [NSString stringWithFormat:@"Route information"];
    [mailComposeView setToRecipients:toRecipents];
    [mailComposeView setSubject:subject];
    NSArray *infoArray = [self getInfoArrayFrom:instructions];
    NSString * routeInstructions = [infoArray componentsJoinedByString:@"\n"];
     NSString *body = [NSString stringWithFormat:@"Route Type: %@\n Destination: %@\n Total Distance: %@\n Total Time: %@\n\n%@", [self getRouteType], _routeAnalyzer.strDestination,  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime, routeInstructions];
    [mailComposeView setMessageBody:body isHTML:NO];
    [self presentViewController:mailComposeView animated:YES completion:NULL];
    [mailComposeView release];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSArray *)getInfoArrayFrom:(NSArray *)instructions {
    NSMutableArray *info =[NSMutableArray array];
    for (TTRouteInstruction *instruction in instructions) {
        NSString * instructionString = [NSString stringWithFormat:@"%@\n%@\n",instruction.info, instruction.distanceInfo];
        [info addObject:instructionString];
    }
    return [info subarrayWithRange:NSMakeRange(0, info.count -1)];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if(UIDeviceOrientationIsLandscape(deviceOrientation)){
//        mainLandscapeView.hidden=YES;
//    }
//    else{
//        mainLandscapeView.hidden=NO;
//    }

    
//    NSString *summary = [NSString stringWithFormat:@"To: %@\n%@", _routeAnalyzer.strDestination,_routeAnalyzer.strRouteType];
//    [_labelSummary setText:summary];
//    // [_labelSummary adjustsFontSizeToFitWidthAndHeight];
//    NSLog(@"Route Summary : %@",summary);
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    NSString *info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isMetric = [userDefaults boolForKey:@"Metric"];
//    if (isMetric) {
//        info = [NSString stringWithFormat:@"   Total Distance: %@\n   Total Time: %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime];
//    }
//    if(UIDeviceOrientationIsLandscape(deviceOrientation) && IS_IPAD){
//        info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistance, _routeAnalyzer.strTotalTime];
//        if (isMetric) {
//            info = [NSString stringWithFormat:@"   Total Distance:\n   %@\n   Total Time:\n   %@",  _routeAnalyzer.strTotalDistanceInKm, _routeAnalyzer.strTotalTime];
//        }
//        
//    }
//    [_labelInfo setText:info];
//    
//    if (!self.isVisible) {
//        return;
//    }
//    
//    // UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if(UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
//    {
//        //TTGasStationInfoViewController tempView=self;
//        //[self dismissViewControllerAnimated:YES completion:nil];
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        TTRouteDetailsViewController *fmvc =nil;
//        if (IS_IPAD) {
//            fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_ipad_landscape"];
//        }
//        else{
//            fmvc=[storyBoard instantiateViewControllerWithIdentifier:@"RouteDetailsViewController_landscape"];
//        }
//        fmvc.delegate=self;
//        [fmvc setRouteAnalyzer:_routeAnalyzer];//readonly
//        [fmvc setParentVC:_parentVC];
//        [fmvc setIsNotificationOn:NO];
//        [fmvc setSuperViewController:self];
//        //[fmvc setPoiManager:self.poiManager];
//        [self presentViewController:fmvc animated:YES completion:^{self.isVisible=YES;}];
//        isShowingLandscapeView = YES;
//        fmvc.routeDetailsContentOffset = self.routeDetailsContentOffset;
//    }
//    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        isShowingLandscapeView = NO;
//    }
//
}
-(void)showCannotSendMailAlert
{
    UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:@"error" message:@"No mail account setup on device" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [AlertView addButtonWithTitle:@"Ok"];
    [AlertView show];
}



- (NSString *)getRouteType {
    NSString *strTitle = nil;
    switch (self.routeAnalyzer.route.request.route_type) {
        case ROUTE_TYPE_CAR_QUICKEST:
            strTitle = @"Car Quickest";
            break;
        case ROUTE_TYPE_CAR_SHORTEST:
            strTitle = @"Car Shortest";
            break;
        case ROUTE_TYPE_CAR_AVOID_FREEWAYS:
            strTitle = @"Car Avoid Freeways";
            break;
        case ROUTE_TYPE_CAR_FREEWAYS:
            strTitle = @"Car Freeways";
            
            break;
        case ROUTE_TYPE_TRUCK_FREEWAYS:
            strTitle = @"RV Freeways";
            
            break;
        case ROUTE_TYPE_TRUCK_QUICKEST:
            strTitle = @"RV Quickest";
            
            break;
        case ROUTE_TYPE_TRUCK_SHORTEST:
            strTitle = @"RV Shortest";
            
            break;
    }
    return strTitle;
}



@end