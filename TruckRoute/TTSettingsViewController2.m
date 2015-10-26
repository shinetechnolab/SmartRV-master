//
//  TTSettingsViewController2.m
//  TruckRoute
//
//  Created by admin on 11/6/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
#import "TTSwitchSliderCell.h"
#import "TTSettingsViewController2.h"
#import "TTGroupButtonCell.h"
#import "TTSwitchCell.h"
#import "TTSubscriptionViewController.h"
#import "TTConfig.h"
#import "TTOdoViewController.h"
#import "TTCellCursorView.h"
#import "TTOdometerCell.h"
//#import "TTUtilities.h"

@interface TTSettingsViewController2 ()

@end
BOOL downScrolling=NO;
@implementation TTSettingsViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) getCurrentOrientation
{
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
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
    //[self getCurrentOrientation];
    [_tableView reloadData];
}

-(void)automaticScroll
{
    if( _tableView.contentSize.height-_tableView.frame.size.height>_tableView.contentOffset.y+10 && !downScrolling)
    {
       [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + 20) animated:NO];

       [NSTimer scheduledTimerWithTimeInterval:0.01 //this value arranges the speed of the autoScroll
                                        target:self
                                      selector:@selector(automaticScroll)
                                      userInfo:nil
                                       repeats:NO];
    }
    else
    {
        //[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
//        downScrolling=YES;
//        if (_tableView.contentOffset.y!=0)
//        {
//            [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y - 10) animated:NO];
//            
//            [NSTimer scheduledTimerWithTimeInterval:0.01 //this value arranges the speed of the autoScroll
//                                             target:self
//                                           selector:@selector(automaticScroll)
//                                           userInfo:nil
//                                            repeats:NO];
//        }
    }
//    [UIView animateWithDuration:1 animations:^()
//     {
//         CGPoint newOffset = _tableView.contentOffset;
//         newOffset.y = 800;
//         [_tableView setContentOffset:newOffset animated:NO];
//         //[_svMenu scrollRectToVisible:CGRectMake(0, 0, 10, 1) animated:NO];
//     } completion:^(BOOL finished){
//         [UIView animateWithDuration:1 animations:^()
//          {
//              CGPoint newOffset1 = _tableView.contentOffset;
//              newOffset1.y = 0;
//             [_tableView setContentOffset:newOffset1 animated:NO];
//              //[_svMenu scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//          }];
//     }];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self getCurrentOrientation];
    downScrolling=NO;
    [_tableView reloadData];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:1];
    TTSwitchSliderCell *cell =(TTSwitchSliderCell *) [_tableView cellForRowAtIndexPath:rowToReload];
    [_tableView sendSubviewToBack:cell];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [_tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationRight];
    //[_tableView setContentOffset:CGPointMake(0.0, _tableView.contentSize.height - _tableView.bounds.size.height)
      //            animated:YES];
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:8]
//                      atScrollPosition:UITableViewScrollPositionBottom
//                              animated:YES];
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                      atScrollPosition:UITableViewScrollPositionBottom
//                              animated:YES];
    
//    [UIView animateWithDuration: 1.0
//                     animations: ^{
//                         [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:8] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//                     }completion: ^(BOOL finished){
//                     }
//     ];
    
//    [UIView
//     animateWithDuration:0.3f
//     delay:0.0f
//     options:UIViewAnimationOptionAllowUserInteraction
//     animations:^
//     {
//         // Scroll to row with animation
//         [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:8]
//                           atScrollPosition:UITableViewScrollPositionBottom
//                                   animated:YES];
//     }
//     completion:^(BOOL finished)
//     {
//         // Deselect row
//         [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                           atScrollPosition:UITableViewScrollPositionBottom
//                                   animated:YES];
//     }];
    //    [UIView animateWithDuration:4.0 animations:^{
//        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:8]
//                          atScrollPosition:UITableViewScrollPositionBottom
//                                  animated:YES];
//    }];
    
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                      atScrollPosition:UITableViewScrollPositionTop
//                              animated:NO];
    //[_tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self getCurrentOrientation];
/*    [NSTimer scheduledTimerWithTimeInterval:0.50 //this value arranges the speed of the autoScroll
                                     target:self
                                   selector:@selector(automaticScroll)
                                   userInfo:nil
                                    repeats:NO];*/
    _tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _tableView.layer.cornerRadius=7.0;
    _tableView.clipsToBounds=YES;
    apps=[[UIApplication sharedApplication] delegate];
    imagesArray=[[NSArray alloc]initWithObjects:@"navCursor",@"rv_nav1",@"rv_nav2",@"rv_nav3",@"rv_nav4", nil];
    
	// Do any additional setup after loading the view. 
    _mapType = _parentVC.mapType;
    _isVoiceOn = _parentVC.isVoiceOn;
    _rateValue = _parentVC.rateValue;
    _pitchValue = _parentVC.pitchValue;
    _isNorthUp = _parentVC.isNorthUp;
    _isSimulationOn = _parentVC.isSimulating;
    _isAutoZoom = [_parentVC isAutoZoom];
    _isPerspective=[_parentVC isPerspective];
    _isShowBuildings=[_parentVC isShowBuildings];
    _isAutoReroute = [_parentVC isAutoReroute];
    _isTravelAlerts = [_parentVC isTravelAlerts];
    _isWeighScaleAlerts=[_parentVC isWeighScaleAlerts];
    _isUnitMetric = _parentVC.isUnitMetric;
    _is24Hour = _parentVC.is24Hour;
    _isOdoOn = _parentVC.isOdometerOn;
    _isUserTips=_parentVC.isUserTips;
    _isSpeedWarning=_parentVC.isSpeedWarning;
    //poi
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _isTruckStopOn = [userDefault boolForKey:@"poi_display_truckstop"];
    _isWeightstationOn = [userDefault boolForKey:@"poi_display_weighstation"];    
    _isTruckDealerOn = [userDefault boolForKey:@"poi_display_truckdealer"];
    _isTruckParkingOn = [userDefault boolForKey:@"poi_display_truckparking"];
    _isCatScaleOn = [userDefault boolForKey:@"poi_display_catscale"];
    _isRestAreaOn = [userDefault boolForKey:@"poi_display_restarea"];
    _isUserTips=[userDefault boolForKey:@"usertips"];
    _isSpeedWarning=[userDefault boolForKey:@"speedwarning"];
    _isCampground =[userDefault boolForKey:@"poi_display_campgrounds"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
//    if (apps.newVersionAvailable)
//    {
//        return 11;
//    }
   // return 8;
    return 9;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (indexPath.section==1 && indexPath.row==0)
        {
            if (_isVoiceOn)
            {
                return 140;
            }
        }
        else if(indexPath.section==1 && indexPath.row ==1)
        {
            return 60;
        }
        else if (indexPath.section==8)
        {
            return 75;
        }
        return 60;
    } else {
        if (indexPath.section==1 && indexPath.row==0){
            if (_isVoiceOn){
                return 140;
            }else{
                return 75;
            }
        }
        else if(indexPath.section==1 && indexPath.row ==1){
            return 75;
        }
        return 75;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0://map mode
            return 3;
        case 1://navigation
            return 10;
        case 2://Unit
            return 2;
        case 3://time display
            return 2;
        case 4://pois
            return 4;
        case 5://odo
            return 3;
        case 6://Daily Tips
            return 1;
//        case 7://Daily Tips
//            return 1;
        case 7://email support
            return 2;
        case 8://subscription
            if (apps.newVersionAvailable){
                return 3;
            }
            return 2;
        case 10://Reset To Defult
            return 1;
        case 11://Update Version
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%d %d",indexPath.section, indexPath.row);
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    TTGroupButtonCell *gbCell = nil;
    TTSwitchCell *switchCell = nil;
    TTSwitchSliderCell *sliderCell=nil;
    TTCellCursorView *cursorCell=nil;
    TTOdometerCell *odometerCell = nil;
    
    switch (indexPath.section)
    {
        case 0://map mode
            gbCell =(TTGroupButtonCell *) [tableView dequeueReusableCellWithIdentifier:@"CellWithGroupButton"];
            switch (indexPath.row) {
                case 0://standard
                    [gbCell.label setText:@"Standard"];
                    gbCell.button.tag = 100;
                    break;
                case 1://satellite
                    [gbCell.label setText:@"Satellite"];
                    gbCell.button.tag = 101;
                    break;
                case 2://hybrid
                    [gbCell.label setText:@"Hybrid"];
                    gbCell.button.tag = 102;
                    break;                    
                default:
                    return nil;
            }
            if (_mapType == indexPath.row) {
                [gbCell.button setSelected:YES];
            }else {
                [gbCell.button setSelected:NO];
            }
            [gbCell.label adjustsFontSizeToFitWidthAndHeight];
            cell = gbCell;
            break;
        case 1://navigation
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
            switch (indexPath.row) {
                case 0://voice
                    [switchCell.label setText:@"Voice Guidance"];
                    [switchCell.mySwitch setOn:_isVoiceOn];
                    switchCell.mySwitch.tag = 110;
                    
                    break;
                case 1:
                    cursorCell = (TTCellCursorView *)[tableView dequeueReusableCellWithIdentifier:@"CellCursorView"];
                    NSString *imageName=[[NSUserDefaults standardUserDefaults] objectForKey:@"cursorImage"];
                    [cursorCell.cursorImage setImage:[UIImage imageNamed:imageName]];
                    [cursorCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
                    cell=cursorCell;
                    break;
                case 2://north up
                    [switchCell.label setText:@"North Up"];
                    [switchCell.mySwitch setOn:_isNorthUp];
                    switchCell.mySwitch.tag = 111;
                    cell = switchCell;
                    break;
                case 3://simulation
                    [switchCell.label setText:@"Simulation"];
                    [switchCell.mySwitch setOn:_isSimulationOn];
                    switchCell.mySwitch.tag = 112;
                    cell = switchCell;
                    break;
                case 4://autozoom
                    [switchCell.label setText:@"Auto Zoom"];
                    [switchCell.mySwitch setOn:_isAutoZoom];
                    switchCell.mySwitch.tag = 113;
                   // switchCell.mySwitch.frame=rect1;
                    //switchCell.accessoryType = UITableViewCellAccessoryDetailButton;
                    cell = switchCell;
                    break;
                case 5://Perspective
                    [switchCell.label setText:@"3D Perspective"];
                    [switchCell.mySwitch setOn:_isPerspective];
                    switchCell.mySwitch.tag = 114;
                    cell = switchCell;
                    break;

                case 6://Show Buildings
                    [switchCell.label setText:@"Show Buildings"];
                    [switchCell.mySwitch setOn:_isShowBuildings];
                    switchCell.mySwitch.tag = 115;
                    cell = switchCell;
                    break;

                case 7://auto reroute
                    [switchCell.label setText:@"Auto Reroute"];
                    [switchCell.mySwitch setOn:_isAutoReroute];
                    switchCell.mySwitch.tag = 116;
                    cell = switchCell;
                    break;
                case 8://auto reroute
                    [switchCell.label setText:@"Travel Alerts"];
                    [switchCell.mySwitch setOn:_isTravelAlerts];
                    switchCell.mySwitch.tag = 117;
                    cell = switchCell;
                    break;
                /*case 9://auto reroute
                    [switchCell.label setText:@"Weigh Scale Alert"];
                    [switchCell.mySwitch setOn:_isWeighScaleAlerts];
                    switchCell.mySwitch.tag = 118;
                    cell = switchCell;
                    break;*/
                case 9://auto reroute
                    [switchCell.label setText:@"Speed Limit Alert"];
                    [switchCell.mySwitch setOn:_isWeighScaleAlerts];
                    switchCell.mySwitch.tag = 119;
                    cell = switchCell;
                    break;
                default:
                    return nil;
            }
            [switchCell.label adjustsFontSizeToFitWidthAndHeight];
            break;
        case 2://Unit
            gbCell =(TTGroupButtonCell *) [tableView dequeueReusableCellWithIdentifier:@"CellWithGroupButton"];
            switch (indexPath.row) {
                case 0://Metric
                    [gbCell.label setText:@"Metric"];
                    [gbCell.button setSelected:_isUnitMetric];
                    gbCell.button.tag = 120;
                    break;
                case 1://English
                    [gbCell.label setText:@"English"];
                    [gbCell.button setSelected:!_isUnitMetric];
                    gbCell.button.tag = 121;
                    break;
                default:
                    return nil;
            }
            [gbCell.label adjustsFontSizeToFitWidthAndHeight];
            cell = gbCell;
            break;
        case 3://time display
            gbCell =(TTGroupButtonCell *) [tableView dequeueReusableCellWithIdentifier:@"CellWithGroupButton"];
            switch (indexPath.row) {
                case 0://24
                    [gbCell.label setText:@"24-hour"];
                    [gbCell.button setSelected:_is24Hour];
                    gbCell.button.tag = 130;
                    break;
                case 1://12
                    [gbCell.label setText:@"12-hour"];
                    [gbCell.button setSelected:!_is24Hour];
                    gbCell.button.tag = 131;
                    break;
                default:
                    return nil;
            }
            [gbCell.label adjustsFontSizeToFitWidthAndHeight];
            cell = gbCell;
            break;
        
        case 4://poi
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
            switch (indexPath.row) {
                case 0://truck stop
                    [switchCell.label setText:@"RV Stop"];
                    [switchCell.mySwitch setOn:_isTruckStopOn];
                    switchCell.mySwitch.tag = 160;
                    break;
                case 1://weigh station
                    [switchCell.label setText:@"Campground"];
                    [switchCell.mySwitch setOn:_isCampground];
                    switchCell.mySwitch.tag = 161;
                    break;
                /*case 2://truck dealership
                    [switchCell.label setText:@"Truck Dealership"];
                    [switchCell.mySwitch setOn:_isTruckDealerOn];
                    switchCell.mySwitch.tag = 162;
                    break;*/
                case 2://truck parking
                    [switchCell.label setText:@"Truck Parking"];
                    [switchCell.mySwitch setOn:_isTruckParkingOn];
                    switchCell.mySwitch.tag = 163;
                    break;
                /*case 4://CAT Scale
                    [switchCell.label setText:@"CAT Scale"];
                    [switchCell.mySwitch setOn:_isCatScaleOn];
                    switchCell.mySwitch.tag = 164;
                    break;*/
                case 3://Rest Area
                    [switchCell.label setText:@"Rest Area"];
                    [switchCell.mySwitch setOn:_isRestAreaOn];
                    switchCell.mySwitch.tag = 165;
                    break;
            }
           // [switchCell.label adjustsFontSizeToFitWidthAndHeight];
            cell = switchCell;
            break;
        case 5://odo
            /*
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
            [switchCell.label setText:@"Odometer"];
            [switchCell.mySwitch setOn:_isOdoOn];
            switchCell.mySwitch.tag = 170;*/
            
            switch (indexPath.row) {
                case 0://truck stop
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
                    [switchCell.label setText:@"Odometer"];
                    [switchCell.mySwitch setOn:_isOdoOn];
                    switchCell.mySwitch.tag = 170;
                    cell = switchCell;
                    
                    break;
                case 1://weigh station
                    odometerCell = (TTOdometerCell *)[tableView dequeueReusableCellWithIdentifier:@"OdometerCell"];
                    [odometerCell.imageView setContentMode:UIViewContentModeScaleAspectFit];
                    [odometerCell.imageView setImage:[UIImage imageNamed:@"view_log1.png"]];
                    [odometerCell.titleLabel setText:@"Tap to View log"];
                    //[cursorCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
                    //[cursorCell.titleLbl setText:@"Export log"];
                    cell = odometerCell;

                    break;
                case 2://truck dealership
                    odometerCell = (TTOdometerCell *)[tableView dequeueReusableCellWithIdentifier:@"OdometerCell"];
                    [odometerCell.imageView setImage:[UIImage imageNamed:@"export2.png"]];
                    [odometerCell.titleLabel setText:@"Tap to Export log"];
                    //[cursorCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
                    //[cursorCell.titleLbl setText:@"Export log"];
                    cell = odometerCell;
                    

                    break;
            }

            //switchCell.accessoryType=UITableViewCellAccessoryDetailButton;
           // [switchCell.label adjustsFontSizeToFitWidthAndHeight];
            
            break;
        case 6://Daily Tips
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
            [switchCell.label setText:@"Tips of the Day"];
            [switchCell.mySwitch setOn:_isUserTips];
            switchCell.mySwitch.tag = 180;
            //[switchCell.label adjustsFontSizeToFitWidthAndHeight];
            cell = switchCell;
            break;
        case 7://Recommand to friend
            switch (indexPath.row) {
                case 0:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
                    cell=switchCell;
                    break;
                case 1:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell1"];
                    cell=switchCell;
                    
                    break;
                default:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
                    cell=switchCell;
                    break;
            }
            break;
        case 8://subscription
            switch (indexPath.row) {
                case 0:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell2"];
                    cell=switchCell;
                    break;
                case 1:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell3"];
                    cell=switchCell;
                    
                    break;
                default:
                    switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell4"];
                    cell=switchCell;
                    break;
            }
            break;
        case 9://Reset to Defult
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell1"];
            //cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
            //[switchCell.label adjustsFontSizeToFitWidthAndHeight];
            cell=switchCell;
            break;
        case 10://subscription
            switchCell = (TTSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
            //switchCell.label.text=@"Reset to Default Settings";
            //cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
            [switchCell.label adjustsFontSizeToFitWidthAndHeight];
            cell=switchCell;
            break;

        default:
            return nil;
    }
    if (indexPath.section==1 && indexPath.row==0)
    {
        sliderCell = (TTSwitchSliderCell *)[tableView dequeueReusableCellWithIdentifier:@"CellWithSwitchSlider"];
        [sliderCell.titleLbl setText:@"Voice Guidance"];
        [sliderCell.subTitleLbl1 setText:@"Rate"];
        [sliderCell.subTitleLbl2 setText:@"Pitch"];
        [sliderCell.rateLbl setText:[NSString stringWithFormat:@"%.3f",_rateValue]];
        [sliderCell.pitchLbl setText:[NSString stringWithFormat:@"%.3f",_pitchValue]];
        [sliderCell.mySwitch setOn:_isVoiceOn];
        sliderCell.mySwitch.tag = 110;
        [sliderCell.rateSlider setValue:_rateValue];
        [sliderCell.pitchSlider setValue:_pitchValue];
        [sliderCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
        
        cell = sliderCell;
    }
    if (indexPath.section==1 && (indexPath.row==4 || indexPath.row==4))
    {
        //cell.accessoryType=UITableViewCellAccessoryDetailButton;
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-50,14 ,32,32)];
        UIButton* pencil = [UIButton buttonWithType:UIButtonTypeInfoDark];
        //[pencil setImage:[UIImage imageNamed:@"icon-pencil.gif"] forState:UIControlStateNormal];
        pencil.frame = CGRectMake(0, 0, 32, 32);
        pencil.userInteractionEnabled = YES;
        [pencil addTarget:self action:@selector(didAlertEditButton:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:pencil];
        [cell addSubview:view];
        cell.accessoryView = view;

    }
    else if (indexPath.section == 1 && indexPath.row ==0 && _isVoiceOn)
    {
        UIView *view=[[[UIView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-50,10 ,32,100)] autorelease];
        UIButton* pencil = [UIButton buttonWithType:UIButtonTypeInfoDark];
        //[pencil setImage:[UIImage imageNamed:@"icon-pencil.gif"] forState:UIControlStateNormal];
        pencil.frame = CGRectMake(0, 0, 32, 32);
        pencil.userInteractionEnabled = YES;
        [pencil addTarget:self action:@selector(didTapEditButton:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:pencil];
        //[cell addSubview:view];
        cell.accessoryView = view;
    }
    else if (indexPath.section==8 || indexPath.section==9 || indexPath.section==7){
        cell.accessoryView = nil;
        cell.accessoryType=nil;
    }
    else
    {
        UIView *view=[[[UIView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-50,10 ,32,100)] autorelease];
        cell.accessoryView = view;
    }
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        gbCell.label.font=[UIFont systemFontOfSize:21.0];
        switchCell.label.font=[UIFont systemFontOfSize:21.0];
        sliderCell.titleLbl.font=[UIFont systemFontOfSize:21.0];
        cursorCell.titleLbl.font=[UIFont systemFontOfSize:21.0];
        odometerCell.titleLabel.font=[UIFont systemFontOfSize:21.0];
    }
    else{
//        [gbCell.label adjustsFontSizeToFitWidthAndHeight];
//        [switchCell.label adjustsFontSizeToFitWidthAndHeight];
//        [sliderCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
//        [cursorCell.titleLbl adjustsFontSizeToFitWidthAndHeight];
//        [odometerCell.titleLabel adjustsFontSizeToFitWidthAndHeight];
        
        gbCell.label.font=[UIFont systemFontOfSize:35.0];
        switchCell.label.font=[UIFont systemFontOfSize:35.0];
        sliderCell.titleLbl.font=[UIFont systemFontOfSize:35.0];
        cursorCell.titleLbl.font=[UIFont systemFontOfSize:35.0];
        odometerCell.titleLabel.font=[UIFont systemFontOfSize:35.0];
    }
    cell.backgroundColor=[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    return cell;
}
-(void)didAlertEditButton:(id)sender
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Auto Zoom" message:@"When Automatic Zoom is turned on the map will adjust the zoom level based on your speed of travel. If you travel fast, the map will zoom out, if you travel slowly, the map will zoom in." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}
-(void)didTapEditButton:(id)sender
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Voice" message:@"Use the Rate and Pitch settings to change how the voice speaks." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Play", nil];
    alertView.tag=111;
    [alertView show];
    [alertView release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==111 && buttonIndex==1)
    {
        if (self.synthesizer)
        {
            [self.synthesizer release];
        }
        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
        
        if (self.synthesizer.speaking == NO)
        {
            AVSpeechUtterance *utterance = [[[AVSpeechUtterance alloc] initWithString:@"In 500 feet, turn right on Elm Street. Enter rotary, then take third exit on the right. In 2 miles, take exit 37B north to I-128 North."] autorelease];
            utterance.rate =_rateValue; //self.rateSlider.value; //AVSpeechUtteranceMinimumSpeechRate; //0.3;
            utterance.pitchMultiplier=_pitchValue; //self.pitchSlider.value;//1.5;
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];
            [self.synthesizer speakUtterance:utterance];
        }
    }
    else if(alertView.tag==999 && buttonIndex==1)
    {
        [self resetToDefaultSetting];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)] autorelease];
    [headerView setBackgroundColor:[UIColor colorWithRed:58.0/255.0 green:58.0/255.0 blue:58.0/255.0 alpha:1.0]];
    UILabel *lbl=[[[UILabel alloc] initWithFrame:headerView.bounds] autorelease];
    lbl.textAlignment=NSTextAlignmentCenter;
    lbl.textColor=[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    lbl.backgroundColor=[UIColor clearColor];
    lbl.font=[UIFont boldSystemFontOfSize:21.0];
    [headerView addSubview:lbl];
    NSString *title=nil;
    switch (section)
    {
        case 0:
            title= @"Map Mode";
            break;
        case 1:
            title= @"Navigation";
            break;
        case 2:
            title= @"Unit";
            break;
        case 3:
            title= @"Time Display";
            break;
        
        case 4:
            title= @"POI Display";
            break;
        case 5:
            title= @"Odometer";
            break;
        case 6:
            title= @"Tips of the day";
            break;
//        case 7:
//            title= @"Speed limit warning";
//            break;
        case 7:
            title= @"Recommend to a friend";
            break;
        case 8:
            title= @"Support";
            break;
        case 10:
            title= @" ";
            break;
        case 11:
            title= @"New Version Available in App Store";
            break;
        default:
            title= @"";
    }
    lbl.text=title;
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
     return nil;
     /*
     switch (section)
     {
         case 0:
             return @"Map Mode";
         case 1:
             return @"Navigation";
         case 2:
             return @"Unit";
         case 3:
             return @"Time Display";
         case 7:
             return @"Subscription";
         case 8:
             return @"FeedBack";
         case 4:
             return @"POI Display";
         case 5:
             return @"Odometer";
         case 6:
             return @"Tips of the day";
         case 9:
             return @" ";
         case 10:
             return @"New Version Available in App Store";
         default:
             return nil;
     }*/
 }

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[userDefaults objectForKey:@"odometer_dictionary"]);
    NSLog(@"%d %d",indexPath.section,indexPath.row);
    if (8 == indexPath.section && 0 == indexPath.row) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        //manage subscription
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTSubscriptionViewController *svc = nil;// [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
        if (IS_IPAD) {
            //SubscriptionViewController_ipad_landscape
            svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController_ipad_landscape"];
        }
        else{
            svc = [storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
        }
        //        [svc setParentVC:self];
        [svc setIsNotificationOn:YES];
        //[self presentViewController:svc animated:YES completion:nil];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation))
            [self presentViewController:svc animated:NO completion:nil];
        else
            [self presentViewController:svc animated:YES completion:nil];

    }
    else if (8 == indexPath.section && 1 == indexPath.row) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        //report failed route button is clicked
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *subject = @"SmartRVRoute Support Request";
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:subject];
            NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
            [mailer setToRecipients:toRecipients];
            
            NSString *body = [NSString stringWithFormat:@"Enter your phone number <span style=\"color:#ff0000\">(required)</span>:<br/><br/>Enter your name (optional):<br/><br/>Enter your comment:<br/><br/>Version: %@<br/>USER ID: %@<br/><br/>Thank you for your feedback.<br/>", [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"], [TTUtilities getSerialNumberString]];
            [mailer setMessageBody:body isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
            [mailer release];
        }
    }
    else if (8 == indexPath.section && 2 == indexPath.row)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/smarttruckroute/id580967260"]];
    }
    else if (5 == indexPath.section && 1 == indexPath.row)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTOdoViewController *ovc = [storyBoard instantiateViewControllerWithIdentifier:@"OdoViewController"];
        [self presentViewController:ovc animated:YES completion:nil];
    }
    else if (indexPath.section == 5 && indexPath.row ==2)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        //report failed route button is clicked
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *subject = @"SmartRVRoute Odometer Report";
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:subject];
            //NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
            //[mailer setToRecipients:toRecipients];
            NSString *tempString = [self odometerReportString];
            [mailer setMessageBody:tempString isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
            [mailer release];
        }

    }
    else if (indexPath.section==1 && indexPath.row==1)
    {
        [self showPickerView];
    }
    else if (indexPath.section==7 && indexPath.row==0)
    {
        NSString *subject = @"SmartRVRoute App";
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:subject];
        //NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
        //[mailer setToRecipients:toRecipients];
        NSString *tempString = @"Hello,\n\nI found this GPS RV navigation app helpful. Thought you might like to try it too.\nhttps://itunes.apple.com/us/app/smarttruckroute/id580967260?mt=8";
        [mailer setMessageBody:tempString isHTML:YES];
        [self presentViewController:mailer animated:YES completion:nil];
        [mailer release];
    }
    else if (indexPath.section==7 && indexPath.row==1){
        MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"Hello,\nI found this GPS RV navigation app helpful. Thought you might like to try it too.\nhttps://itunes.apple.com/us/app/smarttruckroute/id580967260?mt=8";
            //controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        }
    }

    else if (indexPath.section==9){
        // Reset to Default Setting
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to Reset Settings ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView setTag:999];
        [alertView show];
        [alertView release];
        //[self resetToDefaultSetting];
    }
    else if (indexPath.section==10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/smarttruckroute/id580967260"]];
    }
}

- (NSString *)odometerReportString
{
    NSMutableString *finalString = [[NSMutableString alloc]init];
    [finalString appendString:@"<h2>Odometer Report</h2>"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isUnitMetricNew = [userDefaults boolForKey:@"Metric"];
    
    arrayUSA = [[NSMutableArray alloc]init];
    arrayCANADA = [[NSMutableArray alloc]init];
    
    NSString *total = [userDefaults objectForKey:@"odometer_total_distance"];
    double dist_in_meters = [total doubleValue];
    if (isUnitMetricNew) {
        if (dist_in_meters/1000 < .1) {
            [finalString appendString:@"<h3>Total Distance: < 0.1 KMs</h3>"];
        }else {
            [finalString appendString:[NSString stringWithFormat:@"<h3>Total Distance: %.1f KMs</h3>", dist_in_meters/1000]];
        }
    }else {
        if (METERS_TO_MILES(dist_in_meters) < .1) {
            [finalString appendString:@"<h3>Total Distance: < 0.1 Mile</h3>"];
        }else {
            [finalString appendString:[NSString stringWithFormat:@"<h3>Total Distance: %.1f Miles</h3>", METERS_TO_MILES(dist_in_meters)]];
        }
    }
    
    NSString *str = nil;
    NSDictionary *dic = [userDefaults objectForKey:@"odometer_dictionary"];
    for (NSString *obj in arrayUSA) {
        [obj release];
    }
    for (NSString *obj in arrayCANADA) {
        [obj release];
    }
    [arrayUSA removeAllObjects];//clear
    [arrayCANADA removeAllObjects];//clear
    for (id key in dic) {
        if ([[key substringToIndex:2]isEqualToString:@"US"]) {
            str = [[NSString stringWithFormat:@"%@,%@", [key substringFromIndex:3] , [dic objectForKey:key]]retain];
            [arrayUSA addObject:str];
        }else {
            str = [[NSString stringWithFormat:@"%@,%@", [key substringFromIndex:3] , [dic objectForKey:key]]retain];
            [arrayCANADA addObject:str];
        }
    }
    if (sortedUSA) {
        [sortedUSA release];
    }
    if (sortedCANADA) {
        [sortedCANADA release];
    }
    sortedUSA = [arrayUSA sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    sortedCANADA = [arrayCANADA sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [sortedUSA retain];
    [sortedCANADA retain];
    
    
    if (sortedUSA.count>0) {
        
        [finalString appendString:[NSString stringWithFormat:@"<br/><h4>USA</h4>"]];
        for (NSString *tempString in sortedUSA) {
            
            NSArray *str_array = [tempString componentsSeparatedByString:@","];
            NSString *str_state = [TTUtilities getStateName:[str_array objectAtIndex:0]];
            NSString *str_dist = nil;
            double dist_in_meters = [[str_array objectAtIndex:1]doubleValue];
            if (isUnitMetricNew) {
                
                if (dist_in_meters/1000 < .1) {
                    
                    str_dist = [NSString stringWithFormat:@"< 0.1 KMs"];
                }else {
                    str_dist = [NSString stringWithFormat:@"%.1f KMs", dist_in_meters/1000];
                }
            }else {
                
                if (METERS_TO_MILES(dist_in_meters) < .1) {
                    str_dist = [NSString stringWithFormat:@"< 0.1 Miles"];
                }else {
                    str_dist = [NSString stringWithFormat:@"%.1f Miles", METERS_TO_MILES(dist_in_meters)];
                }
            }
            
            [finalString appendString:[NSString stringWithFormat:@"%@ &nbsp %@<br/><br/>",str_state,str_dist]];
        }
        
    }
    
    if (sortedCANADA.count>0) {
        
        [finalString appendString:[NSString stringWithFormat:@"<br/><h4>CANADA</h4>"]];
        for (NSString *tempString in sortedCANADA) {
            NSArray *str_array = [tempString componentsSeparatedByString:@","];
            NSString *str_state = [TTUtilities getStateName:[str_array objectAtIndex:0]];
            NSString *str_dist = nil;
            double dist_in_meters = [[str_array objectAtIndex:1]doubleValue];
            if (isUnitMetricNew) {
                
                if (dist_in_meters/1000 < .1) {
                    
                    str_dist = [NSString stringWithFormat:@"< 0.1 KMs"];
                }else {
                    str_dist = [NSString stringWithFormat:@"%.1f KMs", dist_in_meters/1000];
                }
            }else {
                
                if (METERS_TO_MILES(dist_in_meters) < .1) {
                    str_dist = [NSString stringWithFormat:@"< 0.1 Miles"];
                }else {
                    str_dist = [NSString stringWithFormat:@"%.1f Miles", METERS_TO_MILES(dist_in_meters)];
                }
            }
            
            [finalString appendString:[NSString stringWithFormat:@"%@ &nbsp %@<br/><br/>",str_state,str_dist]];
        }
        
    }
    
    return [finalString autorelease];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1 && indexPath.row==4)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Auto Zoom" message:@"When Automatic Zoom is turned on the map will adjust the zoom level based on your speed of travel. If you travel fast, the map will zoom out, if you travel slowly, the map will zoom in." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Auto Zoom" message:@"Map zoom level automatically adjusts based on speed of travel. (Turn Off to conserve data usage)." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
    }
    else if (indexPath.section == 1 && indexPath.row == 4)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Auto Zoom" message:@"When Automatic Zoom is turned on the map will adjust the zoom level based on your speed of travel. If you travel fast, the map will zoom out, if you travel slowly, the map will zoom in." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    else
    {
        /*
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Odometer" message:@"Tap the field to display state mileage" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
         */
    }
}
-(IBAction)rateSliderValueChange:(id)sender{
    UISlider *slider=(UISlider *)sender;
    _rateValue = slider.value;
    [_tableView reloadData];
}
-(IBAction)pitchSliderValueChange:(id)sender{
    UISlider *slider=(UISlider *)sender;
    _pitchValue = slider.value;
    [_tableView reloadData];
}
- (IBAction)onTapSwitch:(UISwitch *)sender
{
    switch (sender.tag)
    {
        case 110://voice
            _isVoiceOn = sender.isOn;
            [_tableView reloadData];
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:1];
            TTSwitchSliderCell *cell =(TTSwitchSliderCell *) [_tableView cellForRowAtIndexPath:rowToReload];
            [_tableView sendSubviewToBack:cell];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [_tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationRight];
           // [_tableView reloadData];
            break;
        case 111://north up
            _isNorthUp = sender.isOn;
            break;
        case 112://simulation
            
            _isSimulationOn = sender.isOn;
            break;
        case 113://autozoom
            _isAutoZoom = sender.isOn;
            break;
        case 114://Perspective
            _isPerspective = sender.isOn;
            break;
        case 115://Show Buildings
            _isShowBuildings = sender.isOn;
            break;
        case 116://auto reroute
            _isAutoReroute = sender.isOn;
            break;
        case 117://auto reroute
            _isTravelAlerts = sender.isOn;
            break;
        case 118://auto reroute
            _isWeighScaleAlerts = sender.isOn;
            break;
        case 119://auto reroute
            _isSpeedWarning = sender.isOn;
            break;

        case 160://truck stop
            _isTruckStopOn = sender.isOn;
            break;
        case 161://weigh station
            _isCampground = sender.isOn;
            break;
        case 162://truck dealership
            _isTruckDealerOn = sender.isOn;
            break;
        case 163://truck parking
            _isTruckParkingOn = sender.isOn;
            break;
        case 164://cat scale
            _isCatScaleOn = sender.isOn;
            break;
        case 165://rest area
            _isRestAreaOn = sender.isOn;
            break;
        case 170://odo
            _isOdoOn = sender.isOn;
        case 180://odo
            _isUserTips = sender.isOn;
        case 190://odo
            _isSpeedWarning = sender.isOn;
            break;
    }
    
    if (sender.tag==112)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Simulation" message:@"For testing and demonstration purposes. Turn OFF for real-time navigation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
    
//        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Google fdssfdsf" message:@"For testing and demonstration purposes. Turn OFF for real-time navigation." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 75, 75)];
//        
//        NSString *path = [[NSString alloc] initWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Weigh-Station.png"]];
//        UIImage *bkgImg = [UIImage imageNamed:@"Weigh-Station.png"];
//        [imageView setImage:bkgImg];
//        [bkgImg release];
//        [path release];
//        
//        [successAlert addSubview:imageView];
//        [imageView release];
//        
//        [successAlert show];
//        [successAlert release];
    }
}

- (IBAction)onTapGroupButton:(UIButton *)sender {
    int nSection = sender.tag/10;
    int nRow = sender.tag%10;
    switch (nSection) {
        case 10://map mode
            switch (nRow) {
                case 0://standard
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:101] setSelected:YES];//satellite
                        [(UIButton*)[self.view viewWithTag:102] setSelected:NO];//hybrid
                        _mapType = MKMapTypeSatellite;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:101] setSelected:NO];//satellite
                        [(UIButton*)[self.view viewWithTag:102] setSelected:NO];//hybrid
                        _mapType = MKMapTypeStandard;
                    }
                    break;
                case 1://satellite
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:100] setSelected:YES];//standard
                        [(UIButton*)[self.view viewWithTag:102] setSelected:NO];//hybrid
                        _mapType = MKMapTypeStandard;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:100] setSelected:NO];//standard
                        [(UIButton*)[self.view viewWithTag:102] setSelected:NO];//hybrid
                        _mapType = MKMapTypeSatellite;
                    }
                    break;
                case 2://hybrid
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:100] setSelected:YES];//standard
                        [(UIButton*)[self.view viewWithTag:101] setSelected:NO];//satellite
                        _mapType = MKMapTypeStandard;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:100] setSelected:NO];//standard
                        [(UIButton*)[self.view viewWithTag:101] setSelected:NO];//satellite
                        _mapType = MKMapTypeHybrid;
                    }
                    break;
            }
            break;
        case 12://Unit
            switch (nRow) {
                case 0://Metric
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:121] setSelected:YES];//English
                        _isUnitMetric = NO;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:121] setSelected:NO];//English
                        _isUnitMetric = YES;
                    }
                    break;
                case 1://English
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:120] setSelected:YES];//Metric
                        _isUnitMetric = YES;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:120] setSelected:NO];//Metric
                        _isUnitMetric = NO;
                    }
                    break;
            }
            break;
        case 13://Time Display
            switch (nRow) {
                case 0://24 hour
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:131] setSelected:YES];//12 Hour
                        _is24Hour = NO;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:131] setSelected:NO];//12 hour
                        _is24Hour = YES;
                    }
                    break;
                case 1://12 hour
                    if ([sender isSelected]) {
                        //deselect button, select the defaut counterpart
                        [sender setSelected:NO];
                        [(UIButton*)[self.view viewWithTag:130] setSelected:YES];//24 hour
                        _is24Hour = YES;
                    }else {
                        //select current button, deselect the counterparts
                        [sender setSelected:YES];
                        [(UIButton*)[self.view viewWithTag:130] setSelected:NO];//24 hour
                        _is24Hour = NO;
                    }
                    break;
            }
            break;
        default:
            break;
    }
}

/*
 
*/
- (IBAction)cancel:(id)sender
{
    downScrolling=NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)resetToDefaultSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:DEFAULT_SETTINGS_MAPMODE forKey:@"MapType"];
    [userDefaults setBool:DEFAULT_SETTINGS_VOICE forKey:@"Voice"];
    [userDefaults setFloat:0.117 forKey:@"rateValue"];
    [userDefaults setFloat:1.217 forKey:@"pitchValue"];
    [userDefaults setBool:DEFAULT_SETTINGS_NORTHUP forKey:@"NorthUp"];
    [userDefaults setBool:DEFAULT_SETTINGS_SIMULATION forKey:@"Simulating"];
    [userDefaults setBool:DEFAULT_SETTINGS_AUTOZOOM forKey:@"AutoZoom"];
    [userDefaults setBool:DEFAULT_SETTINGS_AUTOREROUTE forKey:@"AutoReroute"];
    [userDefaults setBool:NO forKey:@"ShowBuildings"];
    [userDefaults setBool:NO forKey:@"Perspective"];
    [userDefaults setBool:YES forKey:@"TravelAlerts"];
    [userDefaults setBool:YES forKey:@"WeighScaleAlerts"];
    [userDefaults setBool:DEFAULT_SETTINGS_UNIT_METRIC forKey:@"Metric"];
    [userDefaults setBool:DEFAULT_SETTINGS_TIME_24HOUR forKey:@"24Hour"];
    //nav panel info type
    [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKSTOP forKey:@"poi_display_truckstop"];
    [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKPARKING forKey:@"poi_display_truckparking"];
    [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKDEALER forKey:@"poi_display_truckdealer"];
    [userDefaults setBool:DEFAULT_POI_DISPLAY_WEIGHSTATION forKey:@"poi_display_weighstation"];
    [userDefaults setBool:YES forKey:@"poi_display_restarea"];
    [userDefaults setBool:NO forKey:@"poi_display_catscale"];
    [userDefaults setBool:YES forKey:@"usertips"];
    [userDefaults setObject:@"navCursor" forKey:@"cursorImage"];
    
    _mapType =[userDefaults integerForKey:@"MapType"];
    _isVoiceOn = [userDefaults boolForKey:@"Voice"];
    _rateValue = [userDefaults floatForKey:@"rateValue"];
    _pitchValue = [userDefaults floatForKey:@"pitchValue"];
    _isNorthUp = [userDefaults boolForKey:@"NorthUp"];
    _isSimulationOn = [userDefaults boolForKey:@"Simulating"];
    _isAutoZoom = [userDefaults boolForKey:@"AutoZoom"];
    _isPerspective=[userDefaults boolForKey:@"Perspective"];
    _isShowBuildings=[userDefaults boolForKey:@"ShowBuildings"];
    _isAutoReroute = [userDefaults boolForKey:@"AutoReroute"];
    _isTravelAlerts = [userDefaults boolForKey:@"TravelAlerts"];
    _isWeighScaleAlerts=[userDefaults boolForKey:@"WeighScaleAlerts"];
    _isUnitMetric = [userDefaults boolForKey:@"Metric"];
    _is24Hour = [userDefaults boolForKey:@"24Hour"];
   
    _isUserTips= [userDefaults boolForKey:@"usertips"];
    _isSpeedWarning=[userDefaults boolForKey:@"speedwarning"];
    //poi
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _isTruckStopOn = [userDefault boolForKey:@"poi_display_truckstop"];
    _isWeightstationOn = [userDefault boolForKey:@"poi_display_weighstation"];
    _isTruckDealerOn = [userDefault boolForKey:@"poi_display_truckdealer"];
    _isTruckParkingOn = [userDefault boolForKey:@"poi_display_truckparking"];
    _isCatScaleOn = [userDefault boolForKey:@"poi_display_catscale"];
    _isRestAreaOn = [userDefault boolForKey:@"poi_display_restarea"];
    _isCampground = [userDefault boolForKey:@"poi_display_campgrounds"];
  //[userDefault setBool:_isCampground forKey:@"poi_display_campgrounds"];
    [_tableView reloadData];
    
}

-(IBAction)ok:(id)sender
{
    downScrolling=NO;
    //save changes
    [_parentVC setMapType:_mapType];
    [_parentVC setIsVoiceOn:_isVoiceOn];
    [_parentVC setRateValue:_rateValue];
    [_parentVC setPitchValue:_pitchValue];
    [_parentVC setIsNorthUp:_isNorthUp];    
    [_parentVC setIsSimulating:_isSimulationOn];
    [_parentVC setIsAutoZoom:_isAutoZoom];
    [_parentVC setIsAutoReroute:_isAutoReroute];
    [_parentVC setIsTravelAlerts:_isTravelAlerts];
    [_parentVC setIsWeighScaleAlerts:_isWeighScaleAlerts];
    [_parentVC setIsPerspective:_isPerspective];
    [_parentVC setIsShowBuildings:_isShowBuildings];
    [_parentVC setIsUnitMetric:_isUnitMetric];
    [_parentVC setIs24Hour:_is24Hour];
    [_parentVC setIsOdometerOn:_isOdoOn];
    [_parentVC setIsUserTips:_isUserTips];
    [_parentVC setIsSpeedWarning:_isSpeedWarning];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"MapType"];
    [userDefault setInteger:_mapType forKey:@"MapType"];
    [userDefault removeObjectForKey:@"Voice"];
    [userDefault setBool:_isVoiceOn forKey:@"Voice"];
    
    [userDefault removeObjectForKey:@""];
    [userDefault setFloat:_rateValue forKey:@"rateValue"];
    [userDefault removeObjectForKey:@""];
    [userDefault setFloat:_pitchValue forKey:@"pitchValue"];
    
    [userDefault removeObjectForKey:@"NorthUp"];
    [userDefault setBool:_isNorthUp forKey:@"NorthUp"];    
    [userDefault removeObjectForKey:@"Simulating"];
    [userDefault setBool:_isSimulationOn forKey:@"Simulating"];
    [userDefault removeObjectForKey:@"AutoZoom"];
    [userDefault setBool:_isAutoZoom forKey:@"AutoZoom"];
    [userDefault setBool:_isShowBuildings forKey:@"ShowBuildings"];
    [userDefault setBool:_isPerspective forKey:@"Perspective"];
    [userDefault removeObjectForKey:@"AutoReroute"];
    [userDefault setBool:_isAutoReroute forKey:@"AutoReroute"];
    [userDefault setBool:_isTravelAlerts forKey:@"TravelAlerts"];
    [userDefault setBool:_isWeighScaleAlerts forKey:@"WeighScaleAlerts"];
    [userDefault removeObjectForKey:@"Metric"];
    [userDefault setBool:_isUnitMetric forKey:@"Metric"];
    [userDefault removeObjectForKey:@"24Hour"];
    [userDefault setBool:_is24Hour forKey:@"24Hour"];
    [userDefault removeObjectForKey:@"Odometer"];
    [userDefault setBool:_isOdoOn forKey:@"Odometer"];
    [userDefault removeObjectForKey:@"usertips"];
    [userDefault setBool:_isUserTips forKey:@"usertips"];
    [userDefault setBool:_isSpeedWarning forKey:@"speedwarning"];
    //poi
    [userDefault removeObjectForKey:@"poi_display_truckstop"];
    [userDefault setBool:_isTruckStopOn forKey:@"poi_display_truckstop"];
    [userDefault removeObjectForKey:@"poi_display_weighstation"];
    [userDefault setBool:_isWeightstationOn forKey:@"poi_display_weighstation"];
    [userDefault removeObjectForKey:@"poi_display_truckdealer"];
    [userDefault setBool:_isTruckDealerOn forKey:@"poi_display_truckdealer"];
    [userDefault removeObjectForKey:@"poi_display_truckparking"];
    [userDefault setBool:_isTruckParkingOn forKey:@"poi_display_truckparking"];
    [userDefault removeObjectForKey:@"poi_display_catscale"];
    [userDefault setBool:_isCatScaleOn forKey:@"poi_display_catscale"];
    [userDefault removeObjectForKey:@"poi_display_restarea"];
    [userDefault setBool:_isRestAreaOn forKey:@"poi_display_restarea"];
    [userDefault setBool:_isCampground forKey:@"poi_display_campgrounds"];
    [userDefault synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [arrayUSA release];
    [arrayCANADA release];
    [_tableView release];
    [super dealloc];
}

#pragma mark mailcomposecontroller delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showPickerView
{
    CGRect rect=[[UIScreen mainScreen] bounds];
    subView=[[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-244,rect.size.width, 244)];
    subView.backgroundColor=[UIColor whiteColor];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    //create buttons and set their corresponding selectors
    UIBarButtonItem *button1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClick:)] autorelease];
    //UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(button2Tap:)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0,50,30);
    //[btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitle:@"Done" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[UIImage imageNamed:@"image.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBackButton = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
    
    //add buttons to the toolbar
    [toolbar setItems:[NSArray arrayWithObjects:barBackButton, nil]];
    [subView addSubview:toolbar];
    
    pickerView = [[UIPickerView alloc] init];
    // Set the delegate and datasource. Don't expect picker view to work
    // correctly if you don't set it.
    [pickerView setDataSource: self];
    [pickerView setDelegate: self];
    // Set the picker's frame. We set the y coordinate to 50px.
    [pickerView setFrame: CGRectMake(0, 44.0, rect.size.width, 200.0f)];
    // Before we add the picker view to our view, let's do a couple more
    // things. First, let the selection indicator (that line inside the
    // picker view that highlights your selection) to be shown.
    pickerView.showsSelectionIndicator = YES;
    // Allow us to pre-select the third option in the pickerView.
    [pickerView selectRow:2 inComponent:0 animated:YES];
    // OK, we are ready. Add the picker in our view.
    [subView addSubview: pickerView];
    [self.view addSubview:subView];
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 70;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return imagesArray.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[imagesArray objectAtIndex:row]]];
    imageView.frame=CGRectMake(140, 0,64, 64);
    return imageView;
}
-(void)doneButtonClick:(id)sender
{
    //cursorImage
    NSInteger row = [pickerView selectedRowInComponent:0];
    [[NSUserDefaults standardUserDefaults] setObject:[imagesArray objectAtIndex:row] forKey:@"cursorImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [subView removeFromSuperview];
    [subView release];
    [pickerView release];
    [_tableView reloadData];
}
-(IBAction)resetButtonClick:(id)sender
{
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to Reset Settings ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:999];
    [alertView show];
    [alertView release];
}
@end
