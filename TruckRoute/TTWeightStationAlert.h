//
//  TTWeightStationAlert.h
//  TruckRoute
//
//  Created by Alpesh55 on 11/19/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTPOIManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TTPOI.h"
@protocol TTWeightStationAlert <NSObject>
-(void)getWeightStationWithin7Miles:(TTPOI *)poi;
@end

@interface TTWeightStationAlert : NSObject<CLLocationManagerDelegate>
{
    TTPOIManager *poiManager;
}
@property (nonatomic,retain) id<TTWeightStationAlert> delegate;
-(void)findWeightStationWithinMile:(CLLocation *)location;
@end
