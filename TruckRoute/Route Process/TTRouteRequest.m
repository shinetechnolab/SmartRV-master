//
//  TTRouteRequest.m
//  TruckRoute
//
//  Created by admin on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTRouteRequest.h"
#import "TTConfig.h"

@implementation TTRouteRequest
@synthesize request_id, start_address, start_location, end_address, end_location, user_id, route_type, avoid_toll_road, vehicle_height, vehicle_length, vehicle_width, vehicle_weight, hazmat, speed, bearing, format,request_type, client, os;

- (void)dealloc
{
    [user_id release];
    [start_address release];
    //[end_address release];
    [format release];
    [super dealloc];
}

-(id)initWithRequestID:(NSUInteger)aRequest_id userID:(NSString *)aUser_id startAddress:(NSString *)aStartAddress startLocation:(CLLocationCoordinate2D) aStart_location endAddress:(NSString *)aEndAddress endLocation:(CLLocationCoordinate2D) aEnd_location routeType:(NSUInteger)aRoute_type AvoidTollRoad:(BOOL)aAvoid_toll_road Height:(NSUInteger)aVehicle_height Length:(NSUInteger)aVehicle_length Width:(NSUInteger)aVehicle_width Weight:(NSUInteger)aVehicle_weight Hazmat:(NSUInteger)aHazmat Speed:(NSUInteger)aSpeed Bearing:(NSInteger)aBearing Format:(NSString *)aFormat
{
    if (self = [super init]) {
        request_id = aRequest_id;
//        user_id = [[NSString alloc] initWithString:aUser_id];//should not retain the parameter string pointer
        user_id = [aUser_id copy];
        if(aStartAddress) {       
//            start_address = [[NSString alloc] initWithString:aStartAddress];//should not retain the parameter string pointer
            start_address = [aStartAddress copy];
        }else {
            start_address = @"";
        }
        start_location = aStart_location;
        if(aEndAddress) {            
//            end_address = [[NSString alloc] initWithString:aEndAddress];//should not retain the parameter string pointer
            end_address = [aEndAddress copy];
        }else {
            end_address = @"";
        }
        end_location = aEnd_location;    
        route_type = aRoute_type;
        avoid_toll_road = aAvoid_toll_road;
        vehicle_height = aVehicle_height;
        vehicle_length = aVehicle_length;
        vehicle_width = aVehicle_width;
        vehicle_weight = aVehicle_weight;
        hazmat = aHazmat;
        speed = aSpeed;
        bearing = aBearing;
//        format = [NSString stringWithString:aFormat];
        if (aFormat) {
            format = [aFormat copy];
        }else {
            format = DEFAULT_ROUTE_REQUEST_FORMAT;
        }
        request_type = @"n";
        client = @"v4.0";
        os = @"iOS7";
    }
    return self;
}

-(id)initWithRequest:(TTRouteRequest *)aRequest
{
    if(aRequest)
    {
//        self = [aRequest copy];
        if (self = [super init]) {
            request_id = [aRequest request_id];
//            user_id = [NSString stringWithString:aRequest.user_id];
            user_id = [aRequest.user_id copy];
//            start_address = [NSString stringWithString:aRequest.start_address];
            start_address = [aRequest.start_address copy];
            start_location = [aRequest start_location];
//            end_address = [[NSString alloc] initWithString:[aRequest end_address]];//should not retain the parameter string pointer
            self.end_address = [aRequest.end_address copy];
            end_location = [aRequest end_location];    
            route_type = [aRequest route_type];
            avoid_toll_road = [aRequest avoid_toll_road];
            vehicle_height = [aRequest vehicle_height];
            vehicle_length = [aRequest vehicle_length];
            vehicle_width = [aRequest vehicle_width];
            vehicle_weight = [aRequest vehicle_weight];
            hazmat = [aRequest hazmat];
            speed = [aRequest speed];
            bearing = [aRequest bearing];
//            format = [[NSString alloc] initWithString:[aRequest format]];//should not retain the parameter string pointer
            format = [aRequest.format copy];
        }
        return self;
    }else
        return nil;
}

@end
