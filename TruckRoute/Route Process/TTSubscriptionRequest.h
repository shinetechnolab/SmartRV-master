@interface TTSubscriptionRequest : NSObject

@property (nonatomic, assign) NSString *FirstName;
@property (nonatomic, assign) NSString *LastName;
@property (nonatomic, assign) NSString *Address;
@property (nonatomic, assign) NSString *City;
@property (nonatomic, assign) NSString *State;
@property (nonatomic, assign) NSString *Country;
@property (nonatomic, assign) NSString *ZipCode;
@property (nonatomic, assign) NSString *Email;

@property (nonatomic, assign) NSString *ProductID;
@property (nonatomic, assign) NSString *TransactionID;
@property (nonatomic, assign) NSData   *ReceiptData;

@property (nonatomic, assign) BOOL isPurchased;

-(void)loadDefault;
-(void)save;

@end