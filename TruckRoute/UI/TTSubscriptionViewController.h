//
//  TTSubscriptionViewController.h
//  TruckRoute
//
//  Created by admin on 10/9/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "TTDefinition.h"
#import "TTUtilities.h"
#import "TTSubscriptionRequest.h"
@protocol SubscriptionBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end

@interface TTSubscriptionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate, MFMailComposeViewControllerDelegate,SubscriptionBackButtonClick> {
    NSTimer *timer;
    NSString *server_url;
    struct Subscription_Plan *plans;
    int nPlans;
    
    //waiting when purchasing
    UIActivityIndicatorView *spinner;
    
    //in-app purchase
    int nSelectedIndex;
    NSString *server_url_verify;
    SKProductsRequest *productsRequest;
    NSURLConnection *connection_new_user;
    NSMutableData *response_data_new_user;
    NSURLConnection *connection_restore;
    NSMutableData *response_data_restore;
    //flag for sending purchase requests
    bool isUnfinishedTransactionLastTime;
    bool isWaitingForResponce;
    SKPaymentTransaction *current_transaction;
    //restore flag
    bool isRestoreEnabled;
    //debug
    bool isDebug;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    
    IBOutlet UIView *containerView;
    IBOutlet UIView *landscapeMainView;
    BOOL isShowingLandscapeView;
   // BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<SubscriptionBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;

//@property (nonatomic, assign) TTUtilities *utility;
@property (assign, nonatomic) TTSubscriptionRequest *subscriptionRequest;
@property (retain, nonatomic) NSMutableData *responseData;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UITextView *textviewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelPlans;
@property (retain, nonatomic) IBOutlet UITableView *plansTableView;

@property (retain, nonatomic) IBOutlet UILabel *labelStatus_landscape;
@property (retain, nonatomic) IBOutlet UITextView *textviewStatus_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelPlans_landscape;
@property (retain, nonatomic) IBOutlet UITableView *plansTableView_landscape;

- (IBAction)back:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)tapRestore:(id)sender;

//debug button
@property (retain, nonatomic) IBOutlet UIButton *btnDebug;
- (IBAction)debug:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *btnUUID;
- (IBAction)newUUID:(id)sender;

//retrieving status
-(void)retrievingStatus;
-(void)updateWaitingText;
-(void)feedTableViewWithDataOffset:(int)offset;

//in-app store
-(void)startPurchase;
-(BOOL)canMakePurchases;
-(void)requestProductData:(NSString *)product_identifier;
-(void)completeTransaction:(SKPaymentTransaction *)transaction;
//-(void)restoreTransaction:(SKPaymentTransaction *)transaction;
-(void)failedTransaction:(SKPaymentTransaction *)transaction;
//restore
-(void)startRestore;
//request to server for purchase
-(void)submitRequest;
-(void)submitPurchaseReceipt;
-(void)submitRestoreSubscriptionRequest;

//waiting
-(void)initSpinner;
-(void)startWaiting;//freeze the app
-(void)stopWaiting;
@end
