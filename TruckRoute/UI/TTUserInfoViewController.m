//
//  TTUserInfoViewController.m
//  TruckRoute
//
//  Created by admin on 11/21/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTSubscriptionViewController.h"
#import "TTUserInfoViewController.h"
#import "TTConfig.h"

@interface TTUserInfoViewController ()

@end

@implementation TTUserInfoViewController

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
    //[self getCurrentOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (_isForPurchase) {
        msgText.hidden=YES;
    }
    [_tfFName setDelegate:self];
    [_tfLName setDelegate:self];
    [_tfAddress setDelegate:self];
    [_tfCity setDelegate:self];
    [_tfState setDelegate:self];
    [_tfCountry setDelegate:self];
    [_tfZip setDelegate:self];
    [_tfEmail setDelegate:self];
    //set tags
    [_tfState setTag:100];
    [_tfCountry setTag:100];
    [_tfZip setTag:100];
    [_tfEmail setTag:100];
    isMovedUp = NO;
    //countries
    arrayCountry = [[NSArray alloc]initWithObjects:@"USA", @"Canada", @"Mexico", nil];
    idxCurCountry = 0;//usa
    //init with subscription request
    TTSubscriptionRequest *request = [_parentVC subscriptionRequest];
    if (request) {
        [request loadDefault];
        
        [_tfFName setText:[request FirstName]];
        [_tfLName setText:[request LastName]];
        [_tfAddress setText:[request Address]];
        [_tfCity setText:[request City]];
        [_tfState setText:[request State]];
        [_tfCountry setText:[request Country]];
        if ([request.Country length]<1) {
            [_tfCountry setText:[arrayCountry objectAtIndex:idxCurCountry]];
        }
        [_tfZip setText:[request ZipCode]];
        [_tfEmail setText:[request Email]];
    }else {
        [_tfCountry setText:@"USA"];
    }
    
    //send http post here
    _responseData = [[NSMutableData alloc] init];
    
    [self initSpinner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tfFName setDelegate:nil];
    [_tfLName setDelegate:nil];
    [_tfAddress setDelegate:nil];
    [_tfCity setDelegate:nil];
    [_tfState setDelegate:nil];
    [_tfCountry setDelegate:nil];
    [_tfZip setDelegate:nil];
    
    [_labelFName release];
    [_labelLName release];
    [_labelAddress release];
    [_labelCity release];
    [_labelState release];
    [_labelCountry release];
    [_labelZip release];
    [_tfFName release];
    [_tfLName release];
    [_tfAddress release];
    [_tfCity release];
    [_tfState release];
    [_tfCountry release];
    [_tfZip release];
    
    [arrayCountry release];
    [_labelEmail release];
    [_tfEmail release];
    
    [_responseData release];
    [super dealloc];
}

- (IBAction)ok:(id)sender {
    
    //save
    TTSubscriptionRequest *request = [_parentVC subscriptionRequest];
    [request loadDefault];
    [request setFirstName:_tfFName.text];
    [request setLastName:_tfLName.text];
    [request setAddress:_tfAddress.text];
    [request setCity:_tfCity.text];
    [request setState:_tfState.text];
    [request setCountry:_tfCountry.text];
    [request setZipCode:_tfZip.text];
    [request setEmail:_tfEmail.text];
    [request save];
    
    //check email field
    if ([request.Email isEqualToString:@""]
         ||[request.FirstName isEqualToString:@""]
         ||[request.LastName isEqualToString:@""]
         /*||[request.Address isEqualToString:@""]
         ||[request.City isEqualToString:@""]
         ||[request.State isEqualToString:@""]
         ||[request.Country isEqualToString:@""]
         ||[request.ZipCode isEqualToString:@""]*/) {
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please fill all the fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }   
    
    if (_isForPurchase) {
        [self startWaiting];
        [self submitRequest];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [_parentVC startRestore];
    }   
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapCountry:(id)sender {
    if (++idxCurCountry >= arrayCountry.count)
    {
        idxCurCountry = 0;
    }
    [_tfCountry setText:[arrayCountry objectAtIndex:idxCurCountry]];
}

//animation of rearrange controls
-(void)popupKeyboardAnimation:(BOOL)isMovingUp
{
    /*
    CGRect frameLFN = [_labelFName frame];
    CGRect frameLLN = [_labelLName frame];
    CGRect frameLAddress = [_labelAddress frame];
    CGRect frameLCity = [_labelCity frame];
    CGRect frameTFN = [_tfFName frame];
    CGRect frameTLN = [_tfLName frame];
    CGRect frameTAddress = [_tfAddress frame];
    CGRect frameTCity = [_tfCity frame];
    
    CGRect frameLState = [_labelState frame];
    CGRect frameLCountry = [_labelCountry frame];
    CGRect frameLZip = [_labelZip frame];
    CGRect frameLEmail = [_labelEmail frame];
    CGRect frameTState = [_tfState frame];
    CGRect frameTCountry = [_tfCountry frame];
    CGRect frameTZip = [_tfZip frame];
    CGRect frameTEmail = [_tfEmail frame];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:WAITING_ANIMATION_HALF_PERIOD];
    
#define DEFAULT_OFFSET 130

    if (isMovingUp && !isMovedUp) {
        frameLFN.origin.y -= DEFAULT_OFFSET;
        [_labelFName setFrame:frameLFN];
        frameLLN.origin.y -= DEFAULT_OFFSET;
        [_labelLName setFrame:frameLLN];
        frameLAddress.origin.y -= DEFAULT_OFFSET;
        [_labelAddress setFrame:frameLAddress];
        frameLCity.origin.y -= DEFAULT_OFFSET;
        [_labelCity setFrame:frameLCity];
        frameTFN.origin.y -= DEFAULT_OFFSET;
        [_tfFName setFrame:frameTFN];
        frameTLN.origin.y -= DEFAULT_OFFSET;
        [_tfLName setFrame:frameTLN];
        frameTAddress.origin.y -= DEFAULT_OFFSET;
        [_tfAddress setFrame:frameTAddress];
        frameTCity.origin.y -= DEFAULT_OFFSET;
        [_tfCity setFrame:frameTCity];
        frameLState.origin.y -= DEFAULT_OFFSET;
        [_labelState setFrame:frameLState];
        frameLCountry.origin.y -= DEFAULT_OFFSET;
        [_labelCountry setFrame:frameLCountry];
        frameLZip.origin.y -= DEFAULT_OFFSET;
        [_labelZip setFrame:frameLZip];
        frameLEmail.origin.y -= DEFAULT_OFFSET;
        [_labelEmail setFrame:frameLEmail];
        frameTState.origin.y -= DEFAULT_OFFSET;
        [_tfState setFrame:frameTState];
        frameTCountry.origin.y -= DEFAULT_OFFSET;
        [_tfCountry setFrame:frameTCountry];
        frameTZip.origin.y -= DEFAULT_OFFSET;
        [_tfZip setFrame:frameTZip];
        frameTEmail.origin.y -= DEFAULT_OFFSET;
        [_tfEmail setFrame:frameTEmail];
        isMovedUp = YES;
    }else if (!isMovingUp && isMovedUp){
        frameLFN.origin.y += DEFAULT_OFFSET;
        [_labelFName setFrame:frameLFN];
        frameLLN.origin.y += DEFAULT_OFFSET;
        [_labelLName setFrame:frameLLN];
        frameLAddress.origin.y += DEFAULT_OFFSET;
        [_labelAddress setFrame:frameLAddress];
        frameLCity.origin.y += DEFAULT_OFFSET;
        [_labelCity setFrame:frameLCity];
        frameTFN.origin.y += DEFAULT_OFFSET;
        [_tfFName setFrame:frameTFN];
        frameTLN.origin.y += DEFAULT_OFFSET;
        [_tfLName setFrame:frameTLN];
        frameTAddress.origin.y += DEFAULT_OFFSET;
        [_tfAddress setFrame:frameTAddress];
        frameTCity.origin.y += DEFAULT_OFFSET;
        [_tfCity setFrame:frameTCity];
        frameLState.origin.y += DEFAULT_OFFSET;
        [_labelState setFrame:frameLState];
        frameLCountry.origin.y += DEFAULT_OFFSET;
        [_labelCountry setFrame:frameLCountry];
        frameLZip.origin.y += DEFAULT_OFFSET;
        [_labelZip setFrame:frameLZip];
        frameLEmail.origin.y += DEFAULT_OFFSET;
        [_labelEmail setFrame:frameLEmail];
        frameTState.origin.y += DEFAULT_OFFSET;
        [_tfState setFrame:frameTState];
        frameTCountry.origin.y += DEFAULT_OFFSET;
        [_tfCountry setFrame:frameTCountry];
        frameTZip.origin.y += DEFAULT_OFFSET;
        [_tfZip setFrame:frameTZip];
        frameTEmail.origin.y += DEFAULT_OFFSET;
        [_tfEmail setFrame:frameTEmail];
        isMovedUp = NO;
    }
    
    [UIView commitAnimations];
     */
}

#pragma mark textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (100 == textField.tag && !isMovedUp) {
        [self popupKeyboardAnimation:YES];
    }else if (100 != textField.tag && isMovedUp) {
        [self popupKeyboardAnimation:NO];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self popupKeyboardAnimation:NO];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark requests to server
-(void)submitRequest
{
    NSString *postString = [NSString stringWithFormat:@"email=%@&fname=%@&lname=%@",_tfEmail.text, _tfFName.text, _tfLName.text];
    
    NSLog(@"%@", postString);
    NSData *postVariables = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postVariables length]];
    NSURL *postURL = [NSURL URLWithString:@"http://www.teletype.com/truckroutes/ios_checkemail.php"];
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
    }else {
        NSLog(@"Failed to submit request");
        
        [self stopWaiting];
        
        //notification
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to connect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"failed: %@", [error localizedDescription]);
    
    [self stopWaiting];
    
    //notification
//    NSInteger code = [error code];
    NSString *strErr = nil;
    strErr = [error localizedDescription];
/*    if (kCFURLErrorCannotConnectToHost == code) {
     //replace msg
     strErr = @"Internet is not accessible.\n Please turn on your WiFi or Cellular Data!";
     }else {
     strErr = [error localizedDescription];
     }*/
    NSString * msgStr=[NSString stringWithFormat:@"%@ Please re-check your internet connection.",[error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"connection failed" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {   
    [self stopWaiting];
    
    //check
    UIAlertView *alert = nil;
    NSString *string = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]autorelease];
    switch ([string integerValue]) {
        case 0://not exist email, go ahead purchase
        case 1://all matches, repurchase new subscription
            [self dismissViewControllerAnimated:YES completion:nil];
            [_parentVC startPurchase];
            break;
            
        case 2://email matches, but names dont match, forbid
            alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                               message:@"Email already exists!\nPlease use another email to purchase"
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles: nil];
            [alert show];
            [alert release];
            break;
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

@end
