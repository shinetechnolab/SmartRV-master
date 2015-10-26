//
//  TTRouteRequest.h
//  TruckRoute
//
//  Created by admin on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TTDefinition.h"

//@"userid=android_id&startLatitude=42357722&startLongitude=-71059501&endLatitude=40714554&endLongitude=-74007118&drivingOptions=8&avoidTollRoad=0&vehicleHeight=1350&vehicleLength=5300&vehicleWidth=850&vehicleWeight=8000000&hazmat=0&speed=0&bearing=-1&format=";
@interface TTRouteRequest : NSObject
@property (nonatomic, assign) NSUInteger request_id;
@property (nonatomic, assign) NSString *user_id;
@property (nonatomic, assign) NSString *start_address;
@property (nonatomic, assign) CLLocationCoordinate2D start_location;
@property (nonatomic, retain) NSString *end_address;
@property (nonatomic, assign) CLLocationCoordinate2D end_location;    
@property (nonatomic, assign) NSUInteger route_type;
@property (nonatomic, assign) BOOL avoid_toll_road;
@property (nonatomic, assign) double vehicle_height;//true value * 100
@property (nonatomic, assign) double vehicle_length;//true value * 100
@property (nonatomic, assign) double vehicle_width;//true value * 100
@property (nonatomic, assign) NSUInteger vehicle_weight;
@property (nonatomic, assign) NSUInteger hazmat;
@property (nonatomic, assign) NSUInteger speed;
@property (nonatomic, assign) NSInteger bearing;
@property (nonatomic, assign) NSString *format;
//new paras
@property (nonatomic, assign) NSString *request_type;//n--new, r--reroute, m--manually reroute
@property (nonatomic, assign) NSString *client;//v1.0
@property (nonatomic, assign) NSString *os;//iOS6.0

-(id)initWithRequestID:(NSUInteger)aRequest_id userID:(NSString *)aUser_id startAddress:(NSString *)aStartAddress startLocation:(CLLocationCoordinate2D) aStart_location endAddress:(NSString *)aEndAddress endLocation:(CLLocationCoordinate2D) aEnd_location routeType:(NSUInteger)aRoute_type AvoidTollRoad:(BOOL)aAvoid_toll_road Height:(NSUInteger)aVehicle_height Length:(NSUInteger)aVehicle_length Width:(NSUInteger)aVehicle_width Weight:(NSUInteger)aVehicle_weight Hazmat:(NSUInteger)aHazmat Speed:(NSUInteger)aSpeed Bearing:(NSInteger)aBearing Format:(NSString *)aFormat;

-(id)initWithRequest:(TTRouteRequest *)aRequest;
@end
