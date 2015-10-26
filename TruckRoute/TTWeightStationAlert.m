//
//  TTWeightStationAlert.m
//  TruckRoute
//
//  Created by Alpesh55 on 11/19/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTWeightStationAlert.h"

@implementation TTWeightStationAlert
@synthesize delegate;
- (id)init
{
    self = [super init];
    if (self)
    {
         poiManager=[[TTPOIManager alloc]init];
         [poiManager initializeDB2];
    }
    return self;
}

-(void)findWeightStationWithinMile:(CLLocation *)location direction:(NSString *)direction
{
    
}
-(void)findWeightStationWithinMile:(CLLocation *)location
{
    CLLocationDistance latitudinalMeters = 11263;
    CLLocationDistance longitudinalMeters = 11263;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, latitudinalMeters, longitudinalMeters);
    NSArray *array=[poiManager getWeightStationByRegion:region];
    if (array.count>=1)
    {
        for (int i=0;i<array.count;i++) {
            TTPOI *poi=[array objectAtIndex:i];
            if (![self checkWarnOrNot:poi.identifier]) {
                [delegate getWeightStationWithin7Miles:poi];
            }
        }
        //[poiManager release];
    }
   // [delegate getWeightStationWithin7Miles:poi];
}

-(BOOL)checkWarnOrNot:(NSInteger)poi
{
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"warn_weigh_station"]);
    NSArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:@"warn_weigh_station"];
    for (NSString *aPoi in array) {
        if ([aPoi isEqualToString:[NSString stringWithFormat:@"%i",poi]]) {
            return YES;
        }
    }
    return NO;
}

@end
