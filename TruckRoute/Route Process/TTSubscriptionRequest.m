#import "TTSubscriptionRequest.h"

@implementation TTSubscriptionRequest

-(void)loadDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _FirstName = [userDefault objectForKey:@"SubscriptionRequest_FirstName"];
    _LastName = [userDefault objectForKey:@"SubscriptionRequest_LastName"];
    _Address = [userDefault objectForKey:@"SubscriptionRequest_Address"];
    _City = [userDefault objectForKey:@"SubscriptionRequest_City"];
    _State = [userDefault objectForKey:@"SubscriptionRequest_State"];
    _Country = [userDefault objectForKey:@"SubscriptionRequest_Country"];
    _ZipCode = [userDefault objectForKey:@"SubscriptionRequest_Zipcode"];
    _Email = [userDefault objectForKey:@"SubscriptionRequest_Email"];
    
    _ProductID = [userDefault objectForKey:@"SubscriptionRequest_ProductID"];
    _TransactionID = [userDefault objectForKey:@"SubscriptionRequest_TransactionID"];
    _ReceiptData = [userDefault dataForKey:@"SubscriptionRequest_ReceiptData"];
    
    _isPurchased = [userDefault boolForKey:@"SubscriptionRequest_IsPurchased"];
}

-(void)save
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"SubscriptionRequest_FirstName"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_LastName"];
//    [userDefault removeObjectForKey:@"SubscriptionRequest_Address"];
//    [userDefault removeObjectForKey:@"SubscriptionRequest_City"];
//    [userDefault removeObjectForKey:@"SubscriptionRequest_State"];
//    [userDefault removeObjectForKey:@"SubscriptionRequest_Country"];
//    [userDefault removeObjectForKey:@"SubscriptionRequest_Zipcode"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_Email"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_ProductID"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_TransactionID"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_ReceiptData"];
    [userDefault removeObjectForKey:@"SubscriptionRequest_IsPurchased"];
    
    [userDefault setObject:_FirstName forKey:@"SubscriptionRequest_FirstName"];
    [userDefault setObject:_LastName forKey:@"SubscriptionRequest_LastName"];
//    [userDefault setObject:_Address forKey:@"SubscriptionRequest_Address"];
//    [userDefault setObject:_City forKey:@"SubscriptionRequest_City"];
//    [userDefault setObject:_State forKey:@"SubscriptionRequest_State"];
//    [userDefault setObject:_Country forKey:@"SubscriptionRequest_Country"];
//    [userDefault setObject:_ZipCode forKey:@"SubscriptionRequest_Zipcode"];
    [userDefault setObject:_Email forKey:@"SubscriptionRequest_Email"];
    [userDefault setObject:_ProductID forKey:@"SubscriptionRequest_ProductID"];
    [userDefault setObject:_TransactionID forKey:@"SubscriptionRequest_TransactionID"];
    [userDefault setObject:_ReceiptData forKey:@"SubscriptionRequest_ReceiptData"];
    [userDefault setBool:_isPurchased forKey:@"SubscriptionRequest_IsPurchased"];
    [userDefault synchronize];
}
@end