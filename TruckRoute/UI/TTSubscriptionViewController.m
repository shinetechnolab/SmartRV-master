//
//  TTSubscriptionViewController.m
//  TruckRoute
//
//  Created by admin on 10/9/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTSubscriptionViewController.h"
#import "TTConfig.h"
#import "TTUserInfoViewController.h"

@interface TTSubscriptionViewController ()

@end

@implementation TTSubscriptionViewController

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
//            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960~ipad.png"];
//            [backButton setImage:[UIImage imageNamed:@"Back1~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"OK1~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"OK2~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
    else{
        if (isIpad) {
            //mainBgImageView.image=[UIImage imageNamed:@"RouteMenuBG-960-Landscape~ipad"];
//            [backButton setImage:[UIImage imageNamed:@"Back1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"Back2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
//            [createRouteButton setImage:[UIImage imageNamed:@"OK1-Landscape~ipad.png"] forState:UIControlStateNormal];
//            [createRouteButton setImage:[UIImage imageNamed:@"OK2-Landscape~ipad.png"] forState:UIControlStateHighlighted];
        }
        else{
            
        }
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self getCurrentOrientation];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self orientationChanged:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.isVisible=YES;
    if (_isNotificationOn) {
        [self orientationChanged:nil];
    }
    else{
        [(TTSubscriptionViewController *)_superViewController  setIsVisible:YES];
        [(TTSubscriptionViewController *)_superViewController  viewDidAppear:YES];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.isVisible = NO;
    if (!_isNotificationOn) {
        [(TTSubscriptionViewController *)_superViewController  setIsVisible:NO];
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

//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = backButton.layer.bounds;
//    gradientLayer.colors = [NSArray arrayWithObjects:
//                            (id)[UIColor colorWithRed:255/255.0 green:136/255.0 blue:0.0/255.0 alpha:1.0].CGColor,
//                            (id)[UIColor colorWithRed:255/255.0 green:103/255.0 blue:0.0/255.0 alpha:1.0].CGColor,nil];
//    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:1.0f],nil];
//    gradientLayer.cornerRadius =8;// backButton.layer.cornerRadius;
//    [backButton.layer addSublayer:gradientLayer];
    
    containerView.layer.cornerRadius=7;
    [self getCurrentOrientation];
	// Do any additional setup after loading the view.
    
    //debug
//    [_btnDebug setHidden:YES];
    isDebug = NO;
    [_btnDebug setTitle:@"Debug Off" forState:UIControlStateNormal];
    [_btnUUID setTitle:[TTUtilities getFakeUUID] forState:UIControlStateNormal];
    [_btnUUID setHidden:YES];
    
    //init mutex
    isUnfinishedTransactionLastTime = YES;
    isWaitingForResponce = NO;
    
    //init request
    _subscriptionRequest = [[TTSubscriptionRequest alloc]init];
    [_subscriptionRequest loadDefault];
    
//    _utility = [[TTUtilities alloc]init];
    [self initSpinner];
    nSelectedIndex = -1; 
    
    //IAP init
//    server_url_verify = SERVER_URL_VERIFY_MAIN;
    server_url_verify = SERVER_URL_VERIFY;
    response_data_new_user = [[NSMutableData alloc]init];
    response_data_restore = [[NSMutableData alloc]init];
    
    //send http post here
    _responseData = [[NSMutableData alloc] init];
    [self retrievingStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textviewStatus release];
    [_labelStatus release];
    [_labelPlans release];
    [_plansTableView release];
    
    [_textviewStatus_landscape release];
    [_labelStatus_landscape release];
    [_labelPlans_landscape release];
    [_plansTableView_landscape release];
//    [_utility release];
    [_responseData release];
    [spinner release];
    [response_data_new_user release];
    [response_data_restore release];
    [_subscriptionRequest release];
    [_btnDebug release];
    [_btnUUID release];
    if (plans) {
        free(plans);
    }
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTextviewStatus:nil];
    [self setLabelStatus:nil];
    [self setLabelPlans:nil];
    [self setPlansTableView:nil];
    
    [self setTextviewStatus_landscape:nil];
    [self setLabelStatus_landscape:nil];
    [self setLabelPlans_landscape:nil];
    [self setPlansTableView_landscape:nil];
    [super viewDidUnload];
}

- (IBAction)back:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        //if(IS_IPAD){
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        }
//        else{
//            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.delegate backButtonClick:self];
//        }
    }
}

- (IBAction)ok:(id)sender {
    if (_isNotificationOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{[self.delegate backButtonClick:self];}];
//        [self dismissViewControllerAnimated:YES completion:nil];
//        [self.delegate backButtonClick:self];
    }
}

- (IBAction)tapRestore:(id)sender {
    if (isDebug || isRestoreEnabled) {
        //user info
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTUserInfoViewController *uivc = [storyBoard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
        [uivc setParentVC:self];
        [uivc setIsForPurchase:NO];
        [self presentViewController:uivc animated:YES completion:nil];
    }    
}

- (IBAction)debug:(id)sender {
    if (isDebug) {
        isDebug = NO;
        [_btnDebug setTitle:@"Debug Off" forState:UIControlStateNormal];
        [_btnUUID setHidden:YES];
    }else {
        isDebug = YES;
        [_btnDebug setTitle:@"Debug On" forState:UIControlStateNormal];
        [_btnUUID setHidden:NO];
    }
}

- (IBAction)newUUID:(id)sender {
    [_btnUUID setTitle:[TTUtilities generateFakeUUID] forState:UIControlStateNormal];
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
    // Return the number of rows in the section.
    return nPlans;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    [cell.textLabel setText:plans[indexPath.row].productLabel];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

#pragma mark Table View delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nSelectedIndex = indexPath.row;
    //confirm if user wishes to purchase
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"warning" message:@"Do you want to continue to purchase the selected subscription?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil]autorelease];
    alert.tag = 100;
    [alert show];
}

#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (-1 != nSelectedIndex && 100 == alertView.tag && 1 == buttonIndex) {
        //check
        if (![self canMakePurchases]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                            message:@"In app purchase is disabled!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
        }else {
            //save product id
            [_subscriptionRequest loadDefault];
            [_subscriptionRequest setProductID:[NSString stringWithFormat:@"%d", plans[nSelectedIndex].partNumber]];
            [_subscriptionRequest save];
            //user info            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            TTUserInfoViewController *uivc = [storyBoard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
            [uivc setParentVC:self];
            [uivc setIsForPurchase:YES];
            [self presentViewController:uivc animated:YES completion:nil];
            //start purchase
//            [self requestProductData:plans[nSelectedIndex].identifier];
        }
    }else if (2000 == alertView.tag || (alertView.tag > 2000 && 1 == buttonIndex) )
    {
        if (alertView.tag!=2004) {
            [[SKPaymentQueue defaultQueue] finishTransaction:current_transaction];//dont forget
        }
        
        //send email
        if ([MFMailComposeViewController canSendMail]) {
            [_subscriptionRequest loadDefault];
//            NSString *subject = @"SmartTruckRoute Purchase Completion Request";
            NSString *subject = [NSString stringWithFormat:@"SmartRVRoute Purchase Completion Request: Code %ld", alertView.tag - 2000];
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:subject];
            NSArray *toRecipients = [NSArray arrayWithObjects:SUPPORT_EMAIL, nil];
            [mailer setToRecipients:toRecipients];
            
            //            NSString *body = [NSString stringWithFormat:@"USER ID: %@\nPlease enter any additional information below:\n", [TTUtilities getSerialNumberString]];
            NSString *body = [NSString stringWithFormat:@"Please enter any additional information below:\n\n\nVersion: %@\nrequest_type=N\nUUID=%@\nproduct_id=%@\nfirst_name=%@\nlast_name=%@\naddress=%@\ncity=%@\nstate=%@\ncountry=%@\nzipcode=%@\nemail=%@\nTelephone Number=(PLEASE ENTER YOUR TELEPHONE NUMBER) \ntransaction_id=%@\nreceipt_data=%@\n\n", [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"], [TTUtilities getSerialNumberString], _subscriptionRequest.ProductID, _subscriptionRequest.FirstName, _subscriptionRequest.LastName, _subscriptionRequest.Address, _subscriptionRequest.City, _subscriptionRequest.State, _subscriptionRequest.Country, _subscriptionRequest.ZipCode, _subscriptionRequest.Email, _subscriptionRequest.TransactionID, _subscriptionRequest.ReceiptData];
            [mailer setMessageBody:body isHTML:NO];
            [self presentViewController:mailer animated:YES completion:nil];
            [mailer release];
        }
    }else if (alertView.tag > 2000 && 0 == buttonIndex) {
        //re-submit request
        if(alertView.tag!=2004)
        {
        NSLog(@"re-submit");
        [self startWaiting];
        isWaitingForResponce = NO;
        [self submitPurchaseReceipt];
        }
    }
}

#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"receiving data");
    if ([connection isEqual:connection_new_user]) {
        NSLog(@"receiving data from request N");
        [response_data_new_user appendData:data];
    }else if ([connection isEqual:connection_restore]) {
        NSLog(@"receiving data from request R");
        [response_data_restore appendData:data];
    }else {
        NSLog(@"receiving data from request status");
        [_responseData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"failed: %@", [error localizedDescription]);
    
    int type;//0--basic info, 1--new user, 2--restore
    if ([connection isEqual:connection_new_user]) {
        type = 1;
    }else if ([connection isEqual:connection_restore]) {
        type = 2;
    }else {
        type = 0;
    }
    
    //try backup server
    switch (type) {
        case 0:
            if ([server_url isEqualToString:SERVER_URL_FOR_SUBSCRIPTION_MAIN]) {
                server_url = SERVER_URL_FOR_SUBSCRIPTION_BACKUP;
                [self submitRequest];
                return;
            }
            break;
            
        case 1:
/*            isWaitingForResponce = NO;
            if ([server_url_verify isEqualToString:SERVER_URL_VERIFY_MAIN]) {
                server_url_verify = SERVER_URL_VERIFY_BACKUP;
                [self submitPurchaseReceipt];
                return;
            }*/
            break;
            
        case 2:
/*            if ([server_url_verify isEqualToString:SERVER_URL_VERIFY_MAIN]) {
                server_url_verify = SERVER_URL_VERIFY_BACKUP;
                [self submitRestoreSubscriptionRequest];
                return;
            }*/
            break;
            
        default:
            break;
    }
        
    //unlock application
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (0 == type) {
        //release timer of the waiting text
        [timer invalidate];
        //update status
        [_textviewStatus setText:@"connection failed"];
        [_textviewStatus_landscape setText:@"connection failed"];
    }else {
        [self stopWaiting];
    }
    
    if (1 == type) {
        //request N , connection failed
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Completion Required"
                                                        message:@"Press \"Retry\" to attempt server update now or press \"Email\" to request a representative to assist. You will not be charged again."
                                                       delegate:self
                                              cancelButtonTitle:@"Retry"
                                              otherButtonTitles:@"Email", nil];
        [alert setTag:2001];
        [alert show];
        [alert release];
    }else {
        //notification
        NSString * msgStr=[NSString stringWithFormat:@"%@ Please re-check your internet connection.",[error localizedDescription]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"connection failed" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    int type;//0--basic info, 1--new user, 2--restore
    if ([connection isEqual:connection_new_user]) {
        type = 1;
    }else if ([connection isEqual:connection_restore]) {
        type = 2;
    }else {
        type = 0;
    }
    
    //unlock application
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSString *string = nil;
    UIAlertView *alert = nil;
    int code, offset;
    
    switch (type) {
        case 0://load prodcut info and current user subscription info
            //release timer
            [timer invalidate];
            //check
            string = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
            NSLog(@"request status returns: %@", string);
            // 1,yyyy-mm-dd hh:mm:ss,JSON --> valid subscription
            // 1,0,JSON                   --> expired subscription
            // 0,0,JSON                   --> no subscription (new user)
            // -1, error message            --> error
//            CGRect frame;
            if([string length]>1)
            {
                code = [string integerValue];
//code = 0;//debug
                switch (code) { 
                    case 0:
                                                //prompt to restore if device changed
                        [_textviewStatus setText:@"Already Purchased?\nTap here to Restore."];
                        [_textviewStatus_landscape setText:@"Already Purchased?\nTap here to Restore."];
                        isRestoreEnabled = YES;
                        //prepare the plans
                        if (plans) {
                            free(plans);
                            plans = nil;
                            nPlans = 0;
                        }
                        offset = 4;
                        [self feedTableViewWithDataOffset:offset];
                        break;
                    case 1:
                        code = [[string substringFromIndex:2] integerValue];
                        //clear
                        if (plans) {
                            free(plans);
                            plans = nil;
                            nPlans = 0;
                        }
                        if (0 == code) {
                            offset = 4;
                            //show subscription expired
                            [_textviewStatus setText:@"Your subscription has expired"];
                            [_textviewStatus_landscape setText:@"Your subscription has expired"];
                            //prepare the plans
                            [self feedTableViewWithDataOffset:offset];
                        }else {
                            //show expiration date
                            NSArray *str_array = [string componentsSeparatedByString:@","];
                            NSString *str_tmp = [[[NSString alloc] initWithFormat:@"Your subscription will expire at\n%@", [str_array objectAtIndex:1]]autorelease];
                            [_textviewStatus setText:str_tmp];
                            [_textviewStatus_landscape setText:str_tmp];
                            
                            offset = 3 + [[str_array objectAtIndex:1] length];
                            [self feedTableViewWithDataOffset:offset];
//                            [_plansTableView reloadData];
                        }
                        isRestoreEnabled = NO;                        
                        break;
                        
                    case -1:
                    default:
                        isRestoreEnabled = NO;
                        [_textviewStatus setText:[string substringFromIndex:3]];
                        [_textviewStatus_landscape setText:[string substringFromIndex:3]];
                        break;
                }
            }else {
                //update status
                [_textviewStatus setText:@"received data but parsing data failed"];
                [_textviewStatus_landscape setText:@"received data but parsing data failed"];
            }
            
            //release
            [string release];
            break;
            
        case 1://server returned verification result
            string = [[NSString alloc] initWithData:response_data_new_user encoding:NSUTF8StringEncoding];
            NSLog(@"request N returns: %@", string);
            [self stopWaiting];
            code = [string integerValue];
            if (!string.length) {
                code = 1;
            }
            //0 = Success
            //1 = database error
            //2 = not valid purchase
            switch (code) {
                case 0://success
                    [_subscriptionRequest loadDefault];
                    [_subscriptionRequest setIsPurchased:YES];
                    [_subscriptionRequest save];
                    
                    //finish transaction
                    [[SKPaymentQueue defaultQueue] finishTransaction:current_transaction];//dont forget
                    
                    [self retrievingStatus];
                    
                    //notification
                    alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Subscription successfully purchased!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    break;
                    
                case 1:
                    //in-app-purchase succeeded but server database failed to add user
                    //default request is saved but not finished, ask user to contact teletype
                    //basically next time when this view control load, it will automatically send the saved request till server finish processing
                    //for now, do nothing
/*                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Purchase is not completed.\nPlease contact teletype.com to finish the purchase!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    break;*/
                    //request N , connection failed
                    alert = [[UIAlertView alloc] initWithTitle:@"Purchase Completion Required"
                                                                    message:@"Press \"Retry\" to attempt server update now or press \"Email\" to request a representative to assist. You will not be charged again."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Retry"
                                                          otherButtonTitles:@"Email", nil];
                    [alert setTag:2002];
                    [alert show];
                    [alert release];
                    break;
                case 2://not valid purchase
/*                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"It appears your purchase is invalid, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];*/
                    //request N , connection failed
                    alert = [[UIAlertView alloc] initWithTitle:@"Purchase Completion Required"
                                                                    message:@"Press \"Retry\" to attempt server update now or press \"Email\" to request a representative to assist. You will not be charged again."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Retry"
                                                          otherButtonTitles:@"Email", nil];
                    [alert setTag:2003];
                    [alert show];
                    [alert release];
                    break;
                    
                default:
                    break;
            }
            
            //release
            [string release];
            //reset flag
            isWaitingForResponce = NO;
            break;
            
        case 2://server returned restoration result
            string = [[NSString alloc] initWithData:response_data_restore encoding:NSUTF8StringEncoding];
            NSLog(@"request R returns: %@", string);
            
            [self stopWaiting];
            
            code = [string integerValue];
            if (!string.length) {
                code = 1;
            }
            //0,JSON = Success
            //1 = Failed
            switch (code) {
                case 0://success
                    //fill the user info
                    [_subscriptionRequest loadDefault];                    
                    //parse json
                    NSError *err = nil;
                    NSRange range;
                    NSArray *jsonArray = nil;
                    range.location = 2;
                    range.length = [response_data_restore length] - 2;
                    jsonArray = [NSJSONSerialization JSONObjectWithData:[response_data_restore subdataWithRange:range] options:NSJSONReadingMutableContainers error:&err];
                     NSLog(@"Item: %@", jsonArray);
                    for(int i=0; i<jsonArray.count; i++)
                    {//suppose only one item
                        NSDictionary *item = [jsonArray objectAtIndex:i];
//                        _subscriptionRequest.FirstName = [item objectForKey:@"first_name"];
//                        _subscriptionRequest.LastName = [item objectForKey:@"last_name"];
//                        _subscriptionRequest.Address = [item objectForKey:@"address"];
//                        _subscriptionRequest.City = [item objectForKey:@"city"];
//                        _subscriptionRequest.State = [item objectForKey:@"state"];
//                        _subscriptionRequest.Country = [item objectForKey:@"country"];
//                        _subscriptionRequest.ZipCode = [item objectForKey:@"zipcode"];
                        _subscriptionRequest.TransactionID = [item objectForKey:@"transaction_id"];
                        _subscriptionRequest.Email = [item objectForKey:@"Email"];
 
                    }
                    //save
                    [_subscriptionRequest setIsPurchased:YES];
                    [_subscriptionRequest save];
                                       
                    //notification
/*                    alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Subscription Restored!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];*/
                    
                    [self retrievingStatus];
                    
                    break;
                    
                case 1://failed
                    //notification
                    alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please contact SmartRVRoute for assistance in activating your subscription.\nCall 1-617-542-6220\nText (786) 445-0822\n\nEmail: iphone@smarttruckroute.com" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Contact Support", nil];
                    [alert show];
                    alert.tag=2004;
                    [alert release];
                    break;
                    
                default:
                    break;
            }
            
            [string release];
            break;
    }
}
#pragma mark retrieving product list
-(void)retrievingStatus
{
    //lock application
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    //start timer
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateWaitingText) userInfo:nil repeats:YES];
    server_url = SERVER_URL_FOR_SUBSCRIPTION_MAIN;
    //    server_url = SERVER_URL_FOR_SUBSCRIPTION_TESTING;
    [self submitRequest];
}
-(void)updateWaitingText
{
    static NSInteger count = 0;
    if(count < 3)
        count++;
    else {
        count = 0;
    }
    NSString *str = [[[NSString alloc]initWithFormat:@"retrieving"]autorelease];
    for(int i=0; i<count; i++)
        str = [str stringByAppendingString:@" ."];
    
    [_textviewStatus setText:str];
    [_textviewStatus_landscape setText:str];
}
-(void)feedTableViewWithDataOffset:(int)offset
{
    //parse json
    NSError *err = nil;
    NSRange range;
    NSArray *jsonArray = nil;
    range.location = offset;
    range.length = [_responseData length] - offset;
    jsonArray = [NSJSONSerialization JSONObjectWithData:[_responseData subdataWithRange:range] options:NSJSONReadingMutableContainers error:&err];
    nPlans = jsonArray.count;
    plans = malloc(sizeof(struct Subscription_Plan)*nPlans);
    for(int i=0; i<nPlans; i++)
    {

        NSDictionary *item = [jsonArray objectAtIndex:i];
//        plans[i].isFreeTrial = [[item objectForKey:@"isfreetrial"] boolValue];
        plans[i].isFreeTrial = NO;
        plans[i].partNumber = [[item objectForKey:@"sku"] intValue];
        plans[i].productLabel = [[[NSString alloc]initWithString:[item objectForKey:@"notes"]]retain];
        
//        NSLog(@"PLAN %d: %d", i, plans[i].partNumber);
    }
    
    //feed table view cells
    [_plansTableView reloadData];
    [_plansTableView_landscape reloadData];
    
    //restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}
#pragma mark waiting when purchasing
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
-(void)startWaiting//freeze the app
{
    //lock application
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [spinner startAnimating];
    NSLog(@"start waiting...");
}
-(void)stopWaiting
{
    [spinner stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSLog(@"stop waiting...");
}

#pragma mark in-app store
-(BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}
-(void)requestProductData:(NSString *)product_identifier
{
    //freeze the application
    [self startWaiting];
    
    NSSet *productIdentifiers = [NSSet setWithObject:product_identifier];
    productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    //we will release the request object in the delegate callback
}
-(void)startPurchase
{
    isUnfinishedTransactionLastTime = NO;
    [_subscriptionRequest loadDefault];    
    [self requestProductData:[_subscriptionRequest ProductID]];
}
#pragma mark Restore
-(void)startRestore
{
    [self startWaiting];
    [self submitRestoreSubscriptionRequest];
}
#pragma mark SKProductsRequestDelegate methods
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //finally release the request we alloc/init'ed in requestProUpgradeProductData
    [productsRequest release];
    
//    BOOL isProductAvailable = NO;
    NSArray *products = response.products;
//    SKProduct *final_product = nil;
    for (SKProduct *product in products) {
        NSLog(@"Product title: %@", product.localizedTitle);
        NSLog(@"Product description: %@", product.localizedDescription);
        NSLog(@"Product price: %@", product.price);
        NSLog(@"Product id: %@", product.productIdentifier);
//        isProductAvailable = YES;
//        final_product = product;
        
        //continue purchase
//        if (isProductAvailable) {
            //restarts any purchases if they were interrupted last time the app was open
            //        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//            NSLog(@"AddPayment: product id: %@", final_product.productIdentifier);
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            NSLog(@"AddPayment: payment id: %@", payment.productIdentifier);
            [[SKPaymentQueue defaultQueue] addPayment:payment];
//            NSLog(@"AddPayment done");
//        }
        return;//suppose purchase one subscription per time
    }
    //9157076789
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@", invalidProductId);
        //product not availabe
        [self stopWaiting];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Invalid product!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
}

#pragma mark transaction functions
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{   
    //check if the transaction is already verified
/*    if ([transaction.transactionIdentifier isEqualToString: _subscriptionRequest.TransactionID]
        && _subscriptionRequest.isPurchased) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [self stopWaiting];
        return;
    }*/
    
    if (isUnfinishedTransactionLastTime)
    {
        
        
        //finish transaction and return, so that user will not stuck
//        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];//dont forget
        current_transaction = transaction;
        isUnfinishedTransactionLastTime = NO;
        //notify user the itune purchase is done, but did not update our server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"The connection was lost during your last purchase."
                                                       delegate:self
                                              cancelButtonTitle:@"Contact Support to Complete"
                                              otherButtonTitles: nil];
        [alert setTag:2000];
        [alert show];
        [alert release];
        //automatically send email to marleen about the succeeded purchase, so that we can manually put into dataase
        [_subscriptionRequest loadDefault];
        [_subscriptionRequest setTransactionID:transaction.transactionIdentifier];
        [_subscriptionRequest setReceiptData:transaction.transactionReceipt];
        [_subscriptionRequest setIsPurchased:YES];
        [_subscriptionRequest save];
        [self submitCodeZeroRequest];
        [self submitPurchaseReceipt];
        NSString *str = transaction.originalTransaction.transactionIdentifier;
        return;
    }
    
    if (isWaitingForResponce) {
        //pending the current transaction, because there is already a transaction being processed by server
        //the current transaction will stay in the queue, so that next time we can process it.
        return;
    } 

    //save transaction id and receipt data
    [_subscriptionRequest loadDefault];
    [_subscriptionRequest setTransactionID:transaction.transactionIdentifier];
    [_subscriptionRequest setReceiptData:transaction.transactionReceipt];
    [_subscriptionRequest setIsPurchased:NO];
    [_subscriptionRequest save];
    current_transaction = transaction;
    
    [self submitPurchaseReceipt];//still block the app
}
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                    message:@"Transaction failed!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];//dont forget
    [self stopWaiting];
}
/*-(void)restoreTransaction:(SKPaymentTransaction *)transaction
{//one transaction per time
    NSLog(@"transaction: %@", transaction.originalTransaction.description);
//    final_transaction = transaction.originalTransaction;
    //save transaction id and receipt data
    [_subscriptionRequest loadDefault];
    [_subscriptionRequest setTransactionID:transaction.originalTransaction.transactionIdentifier];
    [_subscriptionRequest setReceiptData:transaction.originalTransaction.transactionReceipt];
    [_subscriptionRequest save];
    
    [self submitRestoreSubscriptionRequest];
}*/


#pragma mark requests to server
-(void)submitCodeZeroRequest
{
    [_subscriptionRequest loadDefault];
    
    NSString *uuid = isDebug ? [TTUtilities getFakeUUID] : [TTUtilities getSerialNumberString];
    NSString *urlString=[NSString stringWithFormat:@"http://teletype.com/truckroutes/temp_iossubscription.php?first_name=%@&last_name=%@&email=%@&udid=%@&city=%@&state=%@&country=%@&zipcode=%@&address=%@&product_id=%@&transaction_id=%@&request_type=n&receipt_data=%@",_subscriptionRequest.FirstName,_subscriptionRequest.LastName,_subscriptionRequest.Email,uuid,_subscriptionRequest.City,_subscriptionRequest.State,_subscriptionRequest.Country,_subscriptionRequest.ZipCode,_subscriptionRequest.Address,_subscriptionRequest.ProductID,_subscriptionRequest.TransactionID,_subscriptionRequest.ReceiptData];
    
    NSString *response=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    if([response isEqualToString:@"1"])
    {
        
    }
}

-(void)submitRequest
{
    NSString *uuid = isDebug ? [TTUtilities getFakeUUID] : [TTUtilities getSerialNumberString];
    NSString *postString = [NSString stringWithFormat:@"userid=%@",uuid];
    
    NSLog(@"%@", server_url);
    NSLog(@"%@", postString);
    NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postVariables length]];
    NSURL *postURL = [NSURL URLWithString:server_url];
    [request setURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postVariables];
    
    [_responseData setLength:0];//clear response data
    //get
    NSURLConnection *connectionResponse = [[[NSURLConnection alloc] initWithRequest:request delegate:self]autorelease];
    if(connectionResponse)
    {
        NSLog(@"Request submitted");
    }else
    {
        NSLog(@"Failed to submit request");
        //unlock application
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        //release timer
        [timer invalidate];
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        //update status
        [_textviewStatus setText:@"connection failed"];
        [_textviewStatus_landscape setText:@"connection failed"];
    }
}
-(void)submitPurchaseReceipt
{
    isUnfinishedTransactionLastTime = NO;
    isWaitingForResponce = YES;
    
    [_subscriptionRequest loadDefault];

    NSString *uuid = isDebug ? [TTUtilities getFakeUUID] : [TTUtilities getSerialNumberString];
    NSString *postString = [NSString stringWithFormat:@"request_type=N&UUID=%@&product_id=%@&first_name=%@&last_name=%@&address=%@&city=%@&state=%@&country=%@&zipcode=%@&email=%@&transaction_id=%@&receipt_data=%@",uuid,_subscriptionRequest.ProductID, _subscriptionRequest.FirstName, _subscriptionRequest.LastName, _subscriptionRequest.Address, _subscriptionRequest.City, _subscriptionRequest.State, _subscriptionRequest.Country, _subscriptionRequest.ZipCode, _subscriptionRequest.Email, _subscriptionRequest.TransactionID, _subscriptionRequest.ReceiptData];
    
#ifdef DEBUG
    postString = [postString stringByAppendingString:@"&isSandbox=1"];
#endif
    
    NSLog(@"%@", server_url_verify);
//    NSLog(@"UUID: %@", uuid);
    NSLog(@"%@", postString);
    
    //NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
   // NSData *postVariables = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSData *postVariables =[postString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postVariables length]];
    NSURL *postURL = [NSURL URLWithString:server_url_verify];
    [request setURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postVariables];
    
    [response_data_new_user setLength:0];//clear new user response data
    //get
    connection_new_user = [[[NSURLConnection alloc] initWithRequest:request delegate:self]autorelease];//will release after
    if(connection_new_user)
    {
        NSLog(@"Purchase Request submitted");
    }else {
        NSLog(@"Failed to submit request");
        
        //unlock application
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        isWaitingForResponce = NO;
    }
}
-(void)submitRestoreSubscriptionRequest
{
    [_subscriptionRequest loadDefault];
    
    NSString *uuid = isDebug ? [TTUtilities getFakeUUID] : [TTUtilities getSerialNumberString];
    NSString *postString = [NSString stringWithFormat:@"request_type=R&UUID=%@&product_id=%@&first_name=%@&last_name=%@&address=%@&city=%@&state=%@&country=%@&zipcode=%@&email=%@&transaction_id=%@&receipt_data=%@", uuid, _subscriptionRequest.ProductID, _subscriptionRequest.FirstName, _subscriptionRequest.LastName, _subscriptionRequest.Address, _subscriptionRequest.City, _subscriptionRequest.State, _subscriptionRequest.Country, _subscriptionRequest.ZipCode, _subscriptionRequest.Email, _subscriptionRequest.TransactionID, _subscriptionRequest.ReceiptData];
    
//    NSLog(@"%@", server_url_verify);
//    NSLog(@"UUID: %@", uuid);
    NSLog(@"%@", postString);
    
    NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postVariables length]];
    NSURL *postURL = [NSURL URLWithString:server_url_verify];
    [request setURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:DEFAULT_CONNECTION_TIMEOUT];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postVariables];
    
    [response_data_restore setLength:0];//clear restore response data
    //get
    connection_restore = [[[NSURLConnection alloc] initWithRequest:request delegate:self]autorelease];
    if(connection_restore)
    {
        NSLog(@"Restore Request submitted");
    }else {
        NSLog(@"Failed to submit request");
        //unlock application
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
#pragma mark SKPaymentTransactionObserver methods
//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"completeTransaction: %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"failedTransaction: %@", transaction.transactionIdentifier);
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"restoredTransaction: %@", transaction.transactionIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];//dont forget
//                [self restoreTransaction:transaction];//in our app, server has the info, so no point to call this
                break;
            
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            default:
                break;
        }
    }
}

#pragma mark mailcomposecontroller delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result){
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
    
    /*if (!self.isVisible)
    {
        return;
    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        //TTGasStationInfoViewController tempView=self;
        //[self dismissViewControllerAnimated:YES completion:nil];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        TTSubscriptionViewController *svc = nil;
        if (IS_IPAD) {
            svc=[storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController_ipad_landscape"];
        }
        else{
            svc=[storyBoard instantiateViewControllerWithIdentifier:@"SubscriptionViewController_landscape"];
        }
        [svc setIsNotificationOn:NO];
        [svc setSuperViewController:self];
        svc.delegate=self;
        [self presentViewController:svc animated:NO completion:^{self.isVisible=YES;}];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
