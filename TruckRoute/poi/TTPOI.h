#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

enum TTPOI_TYPE {
    truck_stop,
    weighstation,
    truck_dealer,
    truck_parking,
    Gas_Station,
    CAT_scale,
    rest_area,
    campgrounds,
    all_poi
};

@interface TTPOI : NSObject {
}

@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) enum TTPOI_TYPE type;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zipcode;
@property (nonatomic, retain) NSString *number;
@property (nonatomic, assign) BOOL hasWifi;
@property (nonatomic, assign) BOOL hasIdle;
@property (nonatomic, assign) BOOL hasScale;
@property (nonatomic, assign) BOOL hasService;
@property (nonatomic, assign) BOOL hasWash;
@property (nonatomic, assign) int showers;
@property (nonatomic, assign) BOOL hasSecureparking;
@property (nonatomic, assign) BOOL isNightparkingonly;
@property (nonatomic, retain) NSString *image;
//not in sqlite
@property (nonatomic,retain)NSString *diesel_price;
@property (nonatomic,retain)NSString *pre_price;
@property (nonatomic,retain)NSString *mid_price;
@property (nonatomic,retain)NSString *reg_price;
@property (nonatomic,retain)NSString *diesel_string;
@property (nonatomic,retain)NSString *diesel_price_date;
@property (nonatomic,retain)NSString *pre_price_date;
@property (nonatomic,retain)NSString *mid_price_date;
@property (nonatomic,retain)NSString *reg_preice_date;

@property (nonatomic, retain) NSString *gasPrice;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, assign) double distance;

@end