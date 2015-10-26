                                                                                                                                                                     //
//  TTAppDelegate.m
//  TruckRoute
//
//  Created by admin on 9/19/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
//#import "Reachability.h"
#import "JSON.h"
#import "TTAppDelegate.h"
#import "TTMapViewController.h"
#import "TTConfig.h"
#import <AdSupport/AdSupport.h>
@implementation TTAppDelegate
@synthesize notifText;
@synthesize newVersionAvailable;
- (void)dealloc
{
    [_window release];
    [super dealloc];
}
-(BOOL)isIgnore:(NSString *)str
{
    NSArray *arr=[[NSUserDefaults standardUserDefaults] objectForKey:@"ignore"];
    
    for (int i=0; i<arr.count;i++)
    {
        if ([[arr objectAtIndex:i] isEqualToString:str])
        {
            return YES;
        }
    }
    return NO;
}
-(void)globalNotificationAlert
{
    if ([self hasAlertView])
    {
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(globalNotificationAlert) userInfo:nil repeats:NO];
        return;
    }
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"You must Turn ON Cellular Data, Wi-Fi, and Privacy Location Services before attempting to use SmartTruckRoute." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        return;
    }
    else{
        
    }
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //background processing goes here
        //This is where you download your data
        NSString *UUID =[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        UUID = [UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *urlStr=[NSString stringWithFormat:@"http://www.teletype.com/truckroutes/notification_alert.php?android_id=%@",UUID];
        NSLog(@"URL STR : %@",urlStr);
        NSError *error=nil;
        self.notifText=[[NSString alloc] init];
        self.notifText=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:&error];
        if(!error)
        {
        NSLog(@"Response : %@",notifText);
        //string =[string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *value=[self.notifText componentsSeparatedByString:@"<br>"];
            
            BOOL isAlert=NO;
            for (int i=0; i<3; i++)
            {
                NSArray *rowValue=[[value objectAtIndex:i] componentsSeparatedByString:@"->"];
                if (![[rowValue objectAtIndex:0] isEqualToString:@"0"])
                {
                    BOOL isIgnore=[self isIgnore:[rowValue objectAtIndex:0]];
                    if (!isIgnore)
                    {
                        if(i==2)
                        {
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy/Renew", nil];
                            alert.tag=i;
                            [alert show];
                            [alert release];
                        }
                        else if (i==0)
                        {
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            alert.tag=i;
                            [alert show];
                            [alert release];
                        }
                        else
                        {
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Don't Show Again", nil];
                            alert.tag=i;
                            [alert show];
                            [alert release];
                        }
                        isAlert=YES;
                        break;
                    }
                }
            }
            if (!isAlert)
            {
                [self getUserTips];
            }
        });
        }
    });
}

-(void)getUserTips
{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"usertips"])
    {
        userTipsArray=[[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.teletype.com/truckroutes/usertips_ios.php"] encoding:NSUTF8StringEncoding error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                TBXML *tbxml=[TBXML tbxmlWithXMLString:string];
                TBXMLElement *root=tbxml.rootXMLElement;
                if(root)
                {
                    TBXMLElement *statusEle=[TBXML childElementNamed:@"status" parentElement:root];
                    if([[TBXML textForElement:statusEle] isEqualToString:@"1"])
                    {
                        TBXMLElement *itemEle=[TBXML childElementNamed:@"item" parentElement:root];
                        while (itemEle)
                        {
                            TBXMLElement *descriptionEle=[TBXML childElementNamed:@"description" parentElement:itemEle];
                            [userTipsArray addObject:[TBXML textForElement:descriptionEle]];
                            itemEle=[TBXML nextSiblingNamed:@"item" searchFromElement:itemEle];
                        }
                    }
                }
                
                if (userTipsArray.count>0) {
                     NSInteger index=[[NSUserDefaults standardUserDefaults] integerForKey:@"tipsindex"];
                    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        NSString *msgStr=[NSString stringWithFormat:@"%@\n\n(Tip %i of %i)",[userTipsArray objectAtIndex:index],index+1,userTipsArray.count];
                        userTipsAlert=[[UIAlertView alloc]initWithTitle:@"User Tips" message:msgStr delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"Next",@"Dismiss", nil];
                    } else {
                        NSString *msgStr=[NSString stringWithFormat:@"User Tips\n\n%@\n\n(Tip %i of %i)",[userTipsArray objectAtIndex:index],index+1,userTipsArray.count];
                        userTipsAlert=[[UIAlertView alloc]initWithTitle:msgStr message:nil delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"Next",@"Dismiss", nil];
                    }
                    userTipsAlert.tag=index+1;
                    [userTipsAlert show];
                }
            });
        });
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView{
//    NSLog(@"Value : %@",[alertView valueForKey:@"_titleLabel"]);
//    UILabel *title = [alertView valueForKey:@"_titleLabel"];
//    title.userInteractionEnabled=YES;
//    title.font = [UIFont fontWithName:@"Arial" size:25];
//    [title setTextColor:[UIColor redColor]];
//     
//     UILabel *body = [alertView valueForKey:@"_bodyTextLabel"];
//     body.font = [UIFont fontWithName:@"Arial" size:20];
//     [body setTextColor:[UIColor whiteColor]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==5555) {
        alertShowing=NO;
        agreeAlertView=nil;
        if (buttonIndex==1) {
            [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(globalNotificationAlert) userInfo:nil repeats:NO];
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"agree"];
            [[NSUserDefaults standardUserDefaults] setObject:@"agree" forKey:@"agree"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            NSURL *url = [NSURL URLWithString:@"http://www.smarttruckroute.com/iPhone-FAQ.htm"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        return;
    }
    
    
    NSLog(@"Button Index : %li",(long)buttonIndex);
    if (alertView==userTipsAlert)
    {
        if (buttonIndex==1)
        {
            //if (userTipsArray.count<alertView.tag+1) {
            
            NSLog(@"Array Values : %lu - Tag : %li",(unsigned long)userTipsArray.count,(long)alertView.tag);
            
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                 NSString *msgStr=[NSString stringWithFormat:@"%@\n\n( Tip %i of %i )",[userTipsArray objectAtIndex:alertView.tag],alertView.tag+1,userTipsArray.count];
                userTipsAlert=[[UIAlertView alloc]initWithTitle:@"User Tips" message:msgStr delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"Next",@"Dismiss", nil];
            }
            else{
                NSString *msgStr=[NSString stringWithFormat:@"User Tips\n\n%@\n\n( Tip %li of %lu )",[userTipsArray objectAtIndex:alertView.tag],alertView.tag+1,(unsigned long)userTipsArray.count];
                userTipsAlert=[[UIAlertView alloc]initWithTitle:msgStr message:nil delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"Next",@"Dismiss", nil];
            }
            //userTipsAlert=[[UIAlertView alloc]initWithTitle:@"User Tips" message:msgStr delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Next", nil];
            userTipsAlert.tag=alertView.tag+1;
            if (userTipsArray.count>userTipsAlert.tag)
            {
                //userTipsAlert.tag=alertView.tag+1;
            }
            else
            {
                userTipsAlert.tag=0;
            }
            [userTipsAlert show];
           // }
        }
        else if (buttonIndex==0){
            NSUserDefaults *userPre=[NSUserDefaults standardUserDefaults];
            [userPre setBool:NO forKey:@"usertips"];
            [userPre synchronize];
        }
        else
        {
            if (userTipsArray.count>alertView.tag+1)
            {
                //userTipsAlert.tag=alertView.tag+1;
                [[NSUserDefaults standardUserDefaults] setInteger:alertView.tag forKey:@"tipsindex"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"tipsindex"];
                //userTipsAlert.tag=0;
            }

            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
     NSArray *value=[self.notifText componentsSeparatedByString:@"<br>"];
    if (buttonIndex==1)
    {
        if (alertView.tag==2)
        {
            NSArray *rowValue=[[value objectAtIndex:2] componentsSeparatedByString:@"->"];
            
            NSString *str=[rowValue objectAtIndex:3];
            NSLog(@"URL :%@",str);
            NSString *encod=[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:encod]])
            {
                        NSLog(@"%@%@",@"Failed to open url:",[[NSURL URLWithString:encod] description]);
            }
            
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[rowValue objectAtIndex:2]]];
        }
        else
        {
            NSArray *arr=[[NSUserDefaults standardUserDefaults] objectForKey:@"ignore"];
            NSMutableArray *mutArray=[NSMutableArray arrayWithArray:arr];
            NSArray *rowValue=[[value objectAtIndex:alertView.tag] componentsSeparatedByString:@"->"];
            [mutArray addObject:[rowValue objectAtIndex:0]];
            [[NSUserDefaults standardUserDefaults] setObject:mutArray forKey:@"ignore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if (alertView.tag==0) {
        //NSArray *value=[notifText componentsSeparatedByString:@"\n"];
        // NSLog(@"value : %@",string);
        BOOL isAlert=NO;
        for (int i=1; i<3; i++)
        {
            NSArray *rowValue=[[value objectAtIndex:i] componentsSeparatedByString:@"->"];
            if (![[rowValue objectAtIndex:0] isEqualToString:@"0"])
            {
                BOOL isIgnore=[self isIgnore:[rowValue objectAtIndex:0]];
                if (!isIgnore)
                {
                    if(i==2)
                    {
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy/Renew", nil];
                        alert.tag=i;
                        [alert show];
                        [alert release];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Don't Show Again", nil];
                        alert.tag=i;
                        [alert show];
                        [alert release];
                    }
                    isAlert=YES;
                    break;
                }
            }
            if (!isAlert) {
                [self getUserTips];
            }
        }
    }
    else if (alertView.tag==1)
    {
        NSArray *rowValue=[[value objectAtIndex:2] componentsSeparatedByString:@"->"];
        if (![[rowValue objectAtIndex:0] isEqualToString:@"0"])
        {
            BOOL isIgnore=[self isIgnore:[rowValue objectAtIndex:0]];
            if (!isIgnore)
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[rowValue objectAtIndex:2] message:[rowValue objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy/Renew", nil];
                alert.tag=2;
                [alert show];
                [alert release];
               // break;
            }else{
                [self getUserTips];
            }
        }
        else{
            [self getUserTips];
        }
    }
    }
}

-(BOOL) doesAlertViewExist
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
        {
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            //BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            if (alert)
            {
                NSLog(@"Alert Exist");
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)hasAlertView
{
    for (UIWindow* window in [UIApplication sharedApplication].windows){
        for (UIView *subView in [window subviews]){
            if ([subView isKindOfClass:[UIAlertView class]])
            {
                NSLog(@"has AlertView");
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)connected
{
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection]currentReachabilityStatus];
    if ([self hasAlertView])
    {
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(connected) userInfo:nil repeats:NO];
        return !(currentStatus == NotReachable);
    }
    if(currentStatus!=NotReachable)
    {
        if(currentStatus == kReachableViaWiFi) // ...wifi
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"You must Turn ON Cellular Data, Wi-Fi, and Privacy Location Services before attempting to use SmartRVRoute." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            if([CLLocationManager locationServicesEnabled])
            {
            }
            else
            {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"You must Turn ON Cellular Data, Wi-Fi, and Privacy Location Services before attempting to use SmartRVRoute." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
            }
        }
    }
    return !(currentStatus == NotReachable);
}
-(void)showAlert{
    if ([self doesAlertViewExist]) {
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
        return;
    }
    connectionAlert=[[UIAlertView alloc]initWithTitle:@"Internet connection is unavailable. Please check to see that Cellular Data is turned on." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [connectionAlert show];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(hideAlertView) userInfo:nil repeats:NO];
    //[alertView release];
}
-(void)hideAlertView
{
    [connectionAlert dismissWithClickedButtonIndex:0 animated:YES];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else{
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    
    
    [self performSelectorInBackground:@selector(checkForNewVersion) withObject:nil];
    
     NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection]currentReachabilityStatus];
    //NetworkStatus netStatus = [self.hostReachability currentReachabilityStatus];
    if (currentStatus == NotReachable)
    {
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
	self.hostReachability = [Reachability reachabilityForInternetConnection];
	[self.hostReachability startNotifier];
    
    // [self globalNotificationAlert];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    

   
    //first time running check
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *bNotFirstTime =[userDefaults objectForKey:@"NotFirstTime"];
    
    if (![[userDefaults objectForKey:@"agree"] isEqual:@"agree"])
    {
//        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Terms and conditions" message:@"TeleType has made every attempt to insure the accuracy of the information and navigation instructions provided in this app. You must however use caution when driving as TeleType assumes no responsibility or liability for errors or omissions. By using this app you agree to these terms and conditions. Tap the Help button to learn more about the app features. " delegate:self cancelButtonTitle:@"Help" otherButtonTitles:@"Agree", nil];
//        alertView.tag=5555;
//        [alertView show];
//        [alertView release];
    }
    else{
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(globalNotificationAlert) userInfo:nil repeats:NO];
    }
    
    NSString *testNull = bNotFirstTime;
    if (testNull == nil || testNull == (id)[NSNull null]) {
        bNotFirstTime=@"";
    } else {
        // category name is set
    }
    
    
    if (![bNotFirstTime isEqual:@"first"])
    {
        
        //first time, set default preferences
        [userDefaults setInteger:DEFAULT_SETTINGS_MAPMODE forKey:@"MapType"];
        [userDefaults setBool:DEFAULT_SETTINGS_VOICE forKey:@"Voice"];
        [userDefaults setFloat:0.107 forKey:@"rateValue"];
        [userDefaults setFloat:0.923 forKey:@"pitchValue"];
        [userDefaults setBool:DEFAULT_SETTINGS_NORTHUP forKey:@"NorthUp"];
        [userDefaults setBool:DEFAULT_SETTINGS_SIMULATION forKey:@"Simulating"];
        [userDefaults setBool:DEFAULT_SETTINGS_AUTOZOOM forKey:@"AutoZoom"];
        [userDefaults setBool:DEFAULT_SETTINGS_AUTOREROUTE forKey:@"AutoReroute"];
        [userDefaults setBool:DEFAULT_SETTINGS_UNIT_METRIC forKey:@"Metric"];
        [userDefaults setBool:DEFAULT_SETTINGS_TIME_24HOUR forKey:@"24Hour"];
        //nav panel info type
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [userDefaults setInteger:DEFAULT_NAV_PANEL1_TYPE forKey:@"trip_info_panel1"];
            [userDefaults setInteger:DEFAULT_NAV_PANEL3_TYPE forKey:@"trip_info_panel2"];
            [userDefaults setInteger:DEFAULT_NAV_PANEL2_TYPE forKey:@"trip_info_panel3"];// [iphone] or [itouch]
        } else {
            // [ipad]
            [userDefaults setInteger:DEFAULT_NAV_PANEL1_TYPE forKey:@"trip_info_panel1"];
            [userDefaults setInteger:DEFAULT_NAV_PANEL2_TYPE forKey:@"trip_info_panel2"];
            [userDefaults setInteger:DEFAULT_NAV_PANEL3_TYPE forKey:@"trip_info_panel3"];
        }
        
        //truck info default values
        [userDefaults setInteger:((NSInteger)(DEFAULT_HEIGHT*100)) forKey:@"route_request_vehicle_height"];
        [userDefaults setInteger:((NSInteger)(DEFAULT_LENGTH*100)) forKey:@"route_request_vehicle_length"];
        [userDefaults setInteger:((NSInteger)(DEFAULT_WIDTH*100)) forKey:@"route_request_vehicle_width"];
        [userDefaults setInteger:DEFAULT_WEIGHT forKey:@"route_request_vehicle_weight"];
        [userDefaults setInteger:DEFAULT_HAZMAT forKey:@"route_request_hazmat"];
        //route request default values
        [userDefaults setObject:DEFAULT_ROUTE_REQUEST_ADDRESS_START forKey:@"route_request_start_address"];
        [userDefaults setDouble:DEFAULT_ROUTE_REQUEST_LOCATION_START_LATITUDE forKey:@"route_request_start_latitude"];
        [userDefaults setDouble:DEFAULT_ROUTE_REQUEST_LOCATION_START_LONGITUDE forKey:@"route_request_start_longitude"];
        [userDefaults setObject:DEFAULT_ROUTE_REQUEST_ADDRESS_END forKey:@"route_request_end_address"];
        [userDefaults setDouble:DEFAULT_ROUTE_REQUEST_LOCATION_END_LATITUDE forKey:@"route_request_end_latitude"];
        [userDefaults setDouble:DEFAULT_ROUTE_REQUEST_LOCATION_END_LONGITUDE forKey:@"route_request_end_longitude"];
        [userDefaults setInteger:DEFAULT_ROUTE_REQUEST_ROUTE_TYPE forKey:@"route_request_type"];
        [userDefaults setBool:DEFAULT_ROUTE_REQUEST_TOLL forKey:@"route_request_avoid_toll_road"];
        [userDefaults setInteger:DEFAULT_ROUTE_REQUEST_SPEED forKey:@"route_request_speed"];
        [userDefaults setInteger:DEFAULT_ROUTE_REQUEST_BEARING forKey:@"route_request_bearing"];
        [userDefaults setObject:DEFAULT_ROUTE_REQUEST_FORMAT forKey:@"route_request_format"];
        //POI DISPLAY
        [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKSTOP forKey:@"poi_display_truckstop"];
        [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKPARKING forKey:@"poi_display_truckparking"];
        [userDefaults setBool:DEFAULT_POI_DISPLAY_TRUCKDEALER forKey:@"poi_display_truckdealer"];
        [userDefaults setBool:DEFAULT_POI_DISPLAY_WEIGHSTATION forKey:@"poi_display_weighstation"];
        [userDefaults setBool:NO forKey:@"poi_display_restarea"];
        [userDefaults setBool:YES forKey:@"poi_display_campgrounds"];
        [userDefaults setBool:YES forKey:@"TravelAlerts"];
        [userDefaults setBool:YES forKey:@"WeighScaleAlerts"];
        [userDefaults setBool:YES forKey:@"usertips"];
        [userDefaults setBool:YES forKey:@"speedwarning"];
        [userDefaults setInteger:0 forKey:@"tipsindex"];
        [userDefaults setObject:@"navCursor" forKey:@"cursorImage"];
        [userDefaults setBool:YES forKey:@"isSwitchEnabled"];
        //poi_display_restarea
        //init odometer stuff
//        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *defaultDataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"state_bounds.data"];
        NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:defaultDataPath];
        for (id key in dic) {
            [userDefaults setObject:[dic objectForKey:key] forKey:key];
        }
//        [TTUtilities initStatePolygons];
        [userDefaults setBool:DEFAULT_SETTINGS_ODOMETER forKey:@"Odometer"];
        //set notfirsttime
        //[userDefaults setBool:YES forKey:@"NotFirstTime"];
        [userDefaults setObject:@"first" forKey:@"NotFirstTime"];
        [userDefaults synchronize];
        [dic release];
    }
   
    [self fetchDataFromiCloud];
    //////////////////////////////////////////
    return YES;
}

- (void)fetchDataFromiCloud
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:@"HistoryNew"]);
    [prefs setObject:[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:@"HistoryNew"] forKey:@"History"];
    [prefs synchronize];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    NetworkStatus netStatus = [self.hostReachability currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
         [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    UIWindow *window = application.keyWindow;
//    [(TTMapViewController*)(window.rootViewController) pauseNavigatingFromOutside];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    
    if (application.applicationState == UIApplicationStateActive)
    {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RVRoute" message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(agreeAlertView){
        if ([agreeAlertView isVisible] && agreeAlertView!=nil) {
            [agreeAlertView dismissWithClickedButtonIndex:3 animated:NO];
            alertShowing=NO;
        }
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    //[TTUtilities getSerialNumberString]
    
    NSString  *token_string = [[[[deviceToken description]    stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                stringByReplacingOccurrencesOfString:@">" withString:@""]
                               stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSString *url=[NSString stringWithFormat:@"http://teletype.com/truckroutes/add_device_token.php?deviceToken=%@&udid=%@",token_string,[TTUtilities getSerialNumberString]];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",url);
    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSLog(@"content---%@", fileData);
    NSString* myString;
    myString = [[NSString alloc] initWithData:fileData encoding:NSASCIIStringEncoding];
    NSLog(@"Response string : %@",myString);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (BOOL)checkAlertExist{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0){
            for (id cc in subviews) {
                if ([cc isKindOfClass:[UIAlertView class]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Agree Text : %@",[userDefaults objectForKey:@"agree"]);
    if (![[userDefaults objectForKey:@"agree"] isEqual:@"agree"])
    {
        if (!alertShowing)
        {
            if ([self checkAlertExist]){
                return;
            }
            agreeAlertView=[[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"TeleType has made every attempt to insure the accuracy of the information and navigation instructions provided in this app. You must however use caution when driving as TeleType assumes no responsibility or liability for errors or omissions. By using this app you agree to these terms and conditions. Tap the Help button to learn more about the app features. " delegate:self cancelButtonTitle:@"Help" otherButtonTitles:@"Agree", nil];
            alertShowing=YES;
            agreeAlertView.tag=5555;
            [agreeAlertView show];
            [agreeAlertView release];
        }
    }

    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(locationServicesEnabled) userInfo:nil repeats:NO];
}
-(void)locationServicesEnabled
{
    if([CLLocationManager locationServicesEnabled]){
        
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"RVRoute requires Apple Location Services to be turned on. (iphone/ipad) Settings > Privacy > Location Services > On." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    if ([MKDirectionsRequest isDirectionsRequestURL:url])
//    {
//        //process here
//        NSLog(@"received");
//        return YES;
//    }
//    
    
    // urlscheme for opening the app - teletype.truckroute://?daddr=Boston,+MA&lat=42.3581&lon=-71.0636
    //                                 teletype.truckroute://?daddr=332+Newbury+St,+Boston,+MA+02115,+USA
    
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *urlComponents = [[[url query] stringByReplacingOccurrencesOfString:@"+" withString:@" "] componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        [queryStringDictionary setObject:value forKey:key];
    }
    
    [(TTMapViewController *)self.window.rootViewController createRouteFromUrlSchemeInfo:queryStringDictionary];
    
    return YES;
}
-(void)checkForNewVersion
{
    NSError *error=nil;
    NSString *jsonString=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://itunes.apple.com/lookup?id=580967260"] encoding:NSUTF8StringEncoding error:&error];
    if (error==nil)
    {
        NSDictionary *dict=[jsonString JSONValue];
        NSArray *array=[dict objectForKey:@"results"];
        dict=[array objectAtIndex:0];
        NSString *applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([applicationVersion length] == 0)
        {
            applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        }

        if (![[dict objectForKey:@"version"] isEqualToString:applicationVersion])
        {
            self.newVersionAvailable=YES;
        }
    }
}

- (void)setupAudioSession
{
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    NSError *activationError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback
                                 withOptions:AVAudioSessionCategoryOptionDuckOthers error:&setCategoryError];
    [audioSession setActive:YES error:&activationError];
}

@end
