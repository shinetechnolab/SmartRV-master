#import <Foundation/Foundation.h>
#import "TTRoute.h"
#import "TTNavInfo.h"

@interface TTRouteAnalyzer : NSObject {
    //    CLLocation *simulationLocations;
    //    int nSimulationLocations;
    int idxCurSimLoc;
    int nextStateCrossingSimLocIndex;
    
}

@property (nonatomic,assign)int idxCurSimLoc;
@property (nonatomic,assign)int nextStateCrossingSimLocIndex;
@property (nonatomic, assign) TTUtilities *utility;
@property (nonatomic, retain) TTRoute *route;
@property (nonatomic, assign) BOOL hasRoute;
@property (nonatomic, readonly) TTNavInfo *navInfo;
@property (nonatomic, retain)   NSMutableArray *simulationLocations;
@property (nonatomic, assign) BOOL isMetric;
@property (nonatomic, assign) BOOL is24Hour;
//summary
@property (nonatomic, readonly) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, readonly) NSString *strDestination;
@property (nonatomic, readonly) NSString *strTotalDistance;
@property (nonatomic, readonly) NSString *strTotalDistanceInKm;
@property (nonatomic, readonly) NSString *strTotalTime;
@property (nonatomic, readonly) NSString *strRouteType;

-(id)initWithRouteRequest:(TTRouteRequest *)aRouteRequest shapes:(MKPolyline *)shapes_array instructions:(NSArray *)instruction_array;

-(TTNavInfo *)analyseWithLocation:(CLLocation *)aLocation;
-(void)clearRoute;
//simulator
-(void)prepareSimulationLocations;
//-(CLLocation *)getNextSimulationLocation;
-(CLLocation *)getNextSimulationLocation:(int)speed;
-(CLLocation *)getCurrentSimulationLocation;
-(void)clearSimLoc;
//data-text converter
-(NSString *)convertDistToText:(int)dist_in_meter forDisplay:(BOOL)forDisplay metric:(BOOL)isMetricOn;
-(NSString *)convertHeadingToText:(int)degree;
-(NSString *)convertSpeedToText:(double)speed_in_mph;
-(NSString *)convertTimerToText:(int)timer_in_sec withSeconds:(BOOL)withSeconds;
-(NSString *)convertTimeToText:(NSDate *)time;
//instruction getter
-(NSArray *)instructions;

-(NSArray *)getSimulationLocationArray;
- (NSDictionary *)returnNextStateCrossingInfo;
- (NSString *)returnRoundedDistInMetersToText:(int)dist_in_meter metric:(BOOL)isMetricOn;

@end

