#import "TTRouteAnalyzer.h"
#import "TTConfig.h"
#import "TTRouteInstruction.h"

@implementation TTRouteAnalyzer
@synthesize route;
@synthesize hasRoute;
@synthesize navInfo;
@synthesize simulationLocations;
@synthesize isMetric;
@synthesize is24Hour;
@synthesize utility;
@synthesize idxCurSimLoc;
@synthesize nextStateCrossingSimLocIndex;

-(id)initWithRouteRequest:(TTRouteRequest *)aRouteRequest shapes:(MKPolyline *)shapes_array instructions:(NSArray *)instruction_array
{
    hasRoute = NO;
    if(self = [super init])
    {
        if (!simulationLocations) {
            simulationLocations = [[NSMutableArray alloc]init];
        }
        
        if (!utility) {
            utility = [[TTUtilities alloc]init];
        }
        
        if (!navInfo) {
            navInfo = [[TTNavInfo alloc]init];
        }
        
        //route should be always allocated
        route = [TTRoute alloc];        
//        route = [[TTRoute alloc]initWithRouteRequest:aRouteRequest shapes:shapes_array instructions:instruction_array];
        if (route) {
            [route initWithRouteRequest:aRouteRequest shapes:shapes_array instructions:instruction_array];
            hasRoute = YES;
            CLLocationCoordinate2D coord;
            NSRange range;
            range.location = [shapes_array pointCount] - 1;
            range.length = 1;
            [shapes_array getCoordinates:&coord range:range];
            _destinationCoordinate = coord;
            _strDestination = [aRouteRequest.end_address copy];//need release
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            isMetric = [userDefaults boolForKey:@"Metric"];
            is24Hour = [userDefaults boolForKey:@"24Hour"];

            TTRouteInstruction *first_ins = [route.instructions objectAtIndex:1];
            _strTotalDistance =  [[self convertDistToText:first_ins.distToDest forDisplay:YES metric:NO] copy];//need release
            _strTotalDistanceInKm= [[self convertDistToText:first_ins.distToDest forDisplay:YES metric:YES] copy];//need release
            _strTotalTime = [[self convertTimerToText:MINUTES_TO_SECONDS(first_ins.timeToDest) withSeconds:NO] copy];//need release
           
            switch (aRouteRequest.route_type) {
                case ROUTE_TYPE_CAR_QUICKEST:
                    _strRouteType = @"CAR QUICKEST";
                    break;
                case ROUTE_TYPE_CAR_SHORTEST:
                    _strRouteType = @"CAR SHORTEST";
                    break;
                case ROUTE_TYPE_CAR_AVOID_FREEWAYS:
                    _strRouteType = @"CAR AVOID FREEWAYS";
                    break;
                case ROUTE_TYPE_CAR_FREEWAYS:
                    _strRouteType = @"CAR PREFER FREEWAYS";
                    break;
                case ROUTE_TYPE_TRUCK_FREEWAYS:
                    _strRouteType = @"RV PREFER FREEWAYS";
                    break;
                case ROUTE_TYPE_TRUCK_SHORTEST:
                    _strRouteType = @"RV SHORTEST";
                    break;                 
                case ROUTE_TYPE_TRUCK_QUICKEST:
                default:
                    _strRouteType = @"RV QUICKEST";
                    break;
            }
            [self prepareSimulationLocations];
        }
    }
    [self setIsMetric:NO];
    return self;
}

-(void)clearRoute
{
    hasRoute = NO;
    if(route) {
        [route release];
        route = nil;
    }
    if (_strDestination) {
        [_strDestination release];
        _strDestination = nil;
    }
    if (_strTotalDistance) {
        [_strTotalDistance release];
        _strTotalDistance = nil;
    }
    if (_strTotalDistanceInKm) {
        [_strTotalDistanceInKm release];
        _strTotalDistanceInKm=nil;
    }
    if (_strTotalTime) {
        [_strTotalTime release];
        _strTotalTime = nil;
    }
}

///////////////////////////////////////////////////////////////
//*** WARNING!! this function is still under modification ***//
-(TTNavInfo *)analyseWithLocation:(CLLocation *)aLocation
{
    if (!hasRoute)
    {
//        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"No route in analyseWithLocation Method" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        return nil;
    }
/*    NSString *str_loc = [NSString stringWithFormat:@"%.4f,%.4f", aLocation.coordinate.latitude, aLocation.coordinate.longitude];
    NSString *str_heading = [NSString stringWithFormat:@"%.1f", aLocation.course];
    NSString *str_speed = [NSString stringWithFormat:@"%.1f", aLocation.speed];
    NSLog(@"location: %@    heading: %@    speed: %@", str_loc, str_heading, str_speed);
*/    
    //calculate location on route
    if(![route processLocation:aLocation toNavInfo:navInfo]) {
        NSLog(@"getLocationOnRoute return NO");
//        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"getLocationOnRoute return NO in analyseWithLocation Method" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        return nil;

        return nil;
    }else {
        //some other info
        navInfo.time_current = [NSDate date];
        navInfo.time_eta = [NSDate dateWithTimeInterval:navInfo.time_to_destination sinceDate:navInfo.time_current];
//        navInfo.time_sunrise = ;
//        navInfo.time_sunset = ;
        
        //panel texts
/* 
        @property (nonatomic, assign) NSString *current_street_name; 
        @property (nonatomic, assign) NSString *text_odo1;
        @property (nonatomic, assign) NSString *text_odo2; 
 */
        navInfo.text_dist_to_next_turn = [self convertDistToText:navInfo.dist_to_next_turn forDisplay:YES metric:isMetric];
        navInfo.text_distance_to_go = [self convertDistToText:navInfo.dist_to_destination forDisplay:YES metric:isMetric];
        navInfo.text_altitude = [self convertDistToText:aLocation.altitude forDisplay:YES metric:isMetric];
        navInfo.heading_string = [NSString stringWithFormat:@"%ld˚ %@", (long)navInfo.heading, [self convertHeadingToText:navInfo.heading]];
        navInfo.text_speed = [self convertSpeedToText:navInfo.speed];
        navInfo.text_timer_to_destination = [self convertTimerToText:navInfo.time_to_destination withSeconds:NO];
        navInfo.text_timer_to_next_turn = [self convertTimerToText:navInfo.time_to_next_turn withSeconds:YES];
        navInfo.text_time_arrivel = [self convertTimeToText:navInfo.time_eta];
        navInfo.text_time_current = [self convertTimeToText:navInfo.time_current];
//        navInfo.text_time_sunrise = [self convertTimeToText:navInfo.time_sunrise];
//        navInfo.text_time_sunset = [self convertTimeToText:navInfo.time_sunset];
        return navInfo;
    }    
}
///////////////////////////////////////////////////////////////

-(void) dealloc
{
    [utility release];
    if(route) {
        [route release];
        route = nil;
    }
    [navInfo release];
    if (_strDestination) {
        [_strDestination release];
        _strDestination = nil;
    }
    if (_strTotalDistance) {
        [_strTotalDistance release];
        _strTotalDistance = nil;
    }
    if (_strTotalDistanceInKm) {
        [_strTotalDistanceInKm release];
        _strTotalDistanceInKm=nil;
    }
    if (_strTotalTime) {
        [_strTotalTime release];
        _strTotalTime = nil;
    }
    [self clearSimLoc];         
    [simulationLocations release];

    [super dealloc];
}

#pragma mark simulation
-(void)prepareSimulationLocations
{
//    NSLog(@"starting preparing sim locations");
    [self clearSimLoc];

    BOOL isDestination = NO;
    CLLocationCoordinate2D coord;
    CLLocationDistance altitude = 0, distInterval = SIMULATION_SPEED * NAVIGATOR_INTERVAL;    
    CLLocationAccuracy vAccuracy = 0, hAccuracy = 0;
    CLLocationDirection course;
    CLLocationSpeed speed = SIMULATION_SPEED;
    
    //params for loading
    MKPolyline *points = route.route_points;
    NSRange range;
    range.location = 0;
    range.length = [points pointCount];
    CLLocationCoordinate2D *tmpCoord = malloc(sizeof(CLLocationCoordinate2D)*[points pointCount]);
    if(tmpCoord)
    {
        [points getCoordinates:tmpCoord range:range];
    }else {
        NSLog(@"malloc failed, in prepareSimulationLocations");
        return;
    }    
    
    //params for calculating
    CLLocationDistance distTravelledOnCurSeg = 0;
    int idxPoint = 0;
    double *headings = [route getHeadings];
    double *seg_lengths = [route getSegLengths];
    double ratioOnSeg = 0;
    CLLocation *cur_location = nil;
    
//    NSLog(@"check point 1 in prepareSimulationLocations");
        
    while (!isDestination) {       
        //debug
/*        if (97 == idxPoint || 183 == idxPoint) {
            int check = 3;
        } */      
        
        //calculate 
        while(distTravelledOnCurSeg >= seg_lengths[idxPoint])
        {
//            NSLog(@"loop: idxPoint = %d, in prepareSimulationLocations", idxPoint);
            distTravelledOnCurSeg = distTravelledOnCurSeg - seg_lengths[idxPoint++];
            if (idxPoint >= [points pointCount]) {
                isDestination = YES;
                break;
            }
        }
        if(isDestination)
        {
//            NSLog(@"check point 1.5 in prepareSimulationLocations");
            
            idxPoint = [points pointCount] - 1;
            course = headings[idxPoint - 1];
            coord = tmpCoord[idxPoint];       
            
            //make location
            cur_location = [[CLLocation alloc] initWithCoordinate:coord altitude:altitude horizontalAccuracy:hAccuracy verticalAccuracy:vAccuracy course:course speed:speed timestamp:nil];
            
            //add it to array
            [simulationLocations addObject:cur_location];
           // [cur_location release];
            break;
        }
        
        //found idxPoint and it is not the last point, then calculate heading and coordinate
        ratioOnSeg = distTravelledOnCurSeg / seg_lengths[idxPoint];
        course = headings[idxPoint];
        coord.latitude = (tmpCoord[idxPoint + 1].latitude - tmpCoord[idxPoint].latitude)*ratioOnSeg +tmpCoord[idxPoint].latitude;
        coord.longitude = (tmpCoord[idxPoint + 1].longitude - tmpCoord[idxPoint].longitude)*ratioOnSeg +tmpCoord[idxPoint].longitude;        
        
        //make location
        cur_location = [[CLLocation alloc] initWithCoordinate:coord altitude:altitude horizontalAccuracy:hAccuracy verticalAccuracy:vAccuracy course:course speed:speed timestamp:nil];
               
        //add it to array
        [simulationLocations addObject:cur_location];
        
        //for next loop
        distTravelledOnCurSeg = distTravelledOnCurSeg + distInterval;
    }
    
    //clear
    free(tmpCoord);
    idxCurSimLoc = 0;
    
    [self updateLocationOfNextStateCrossing:idxCurSimLoc currentState:[utility getStateWithCoord:[self getCurrentSimulationLocation].coordinate ]];
    
//    NSLog(@"sim locations are ready");
}

-(NSArray *)getSimulationLocationArray
{
    return simulationLocations;
}

-(CLLocation *)getNextSimulationLocation:(int)speed
{
    if (idxCurSimLoc < simulationLocations.count) {
        //idxCurSimLoc++;
        //        idxCurSimLoc++;
        idxCurSimLoc=idxCurSimLoc+speed/10;
        if (idxCurSimLoc>=simulationLocations.count) {
            return [simulationLocations lastObject];
        }
        return (CLLocation *)[simulationLocations objectAtIndex:idxCurSimLoc];
        
    }else {
        idxCurSimLoc = 0;
        return (CLLocation *)[simulationLocations objectAtIndex:idxCurSimLoc++];
    }

    
//    if (idxCurSimLoc < simulationLocations.count - speed/10) {
//          idxCurSimLoc++;
//        //        idxCurSimLoc++;
//        //idxCurSimLoc=idxCurSimLoc+speed/10;
//        return (CLLocation *)[simulationLocations objectAtIndex:idxCurSimLoc];
//        
//    }else {
//        idxCurSimLoc = 0;
//        return (CLLocation *)[simulationLocations objectAtIndex:idxCurSimLoc++];
//    }
}
-(CLLocation *)getCurrentSimulationLocation
{
    return (CLLocation *)[simulationLocations objectAtIndex:idxCurSimLoc];
}
-(void)clearSimLoc
{
    if (simulationLocations) {
        for (CLLocation *location in simulationLocations) {
            [location release];
        }
        [simulationLocations removeAllObjects];
    }    
}
#pragma mark converter
-(NSString *)convertDistToText:(int)dist_in_meter forDisplay:(BOOL)forDisplay metric:(BOOL)isMetricOn;
{
    if (dist_in_meter < 0) {
        return @"----";
    }
    
    NSString *retStr = nil;
    int nFt;
    if (isMetricOn) {
        if (dist_in_meter <= 100) {
            retStr = [NSString stringWithFormat:@"%d m", dist_in_meter];
        }else if (dist_in_meter <= 1000) {
            retStr = [NSString stringWithFormat:@"%d m", dist_in_meter/10*10];
        }else if (dist_in_meter <= 3000) {
            retStr = [NSString stringWithFormat:@"%.1f km", dist_in_meter/1000.0];
        }else {
            retStr = [NSString stringWithFormat:@"%d km", dist_in_meter/1000];
        }
    }else {
        nFt = METERS_TO_FEET(dist_in_meter);
        if (nFt <= 100) {
            retStr = [NSString stringWithFormat:@"%d ft", nFt];
        }else if (nFt <= MILES_TO_FEET(.3)) {
            retStr = [NSString stringWithFormat:@"%d ft", nFt/100*100];
        }else if (nFt <= MILES_TO_FEET(100)) {
            //round to .1 miles
            retStr = [NSString stringWithFormat:@"%.1f mi", FEET_TO_MILES(nFt)];
        }else {
            retStr = [NSString stringWithFormat:@"%d mi", (int)FEET_TO_MILES(nFt)];
        }
    }
    
    if (!forDisplay) {
        //for voice
        NSRange range;
        range.location = 0;
        range.length = [retStr length];
        if (isMetric) {
            retStr = [retStr stringByReplacingOccurrencesOfString:@" m" withString:@" meters" options:NSCaseInsensitiveSearch range:range];
            range.length = [retStr length];
            retStr = [retStr stringByReplacingOccurrencesOfString:@" km" withString:@" kilometers" options:NSCaseInsensitiveSearch range:range];
        }else {
            retStr = [retStr stringByReplacingOccurrencesOfString:@" ft" withString:@" feet" options:NSCaseInsensitiveSearch range:range];
            range.length = [retStr length];
            retStr = [retStr stringByReplacingOccurrencesOfString:@" mi" withString:@" miles" options:NSCaseInsensitiveSearch range:range];
        }
        
    }
    
    return retStr;
}
-(NSString *)convertHeadingToText:(int)degree
{
    //0~15/345~360  N
    //15~75         NE
    //75~105        E
    //105~165       SE
    //165~195       S
    //195~255       SW
    //255~285       W
    //285~345       NW
    if (degree <= 165) {
        if (degree >= 75) {
            if (degree <= 105)
                return @"E";
            else
                return @"SE";
        }else {
            if (degree >= 15)
                return @"NE";
            else
                return @"N";
        }
    }else {
        if (degree <= 255) {
            if (degree <= 195)
                return @"S";
            else
                return @"SW";
        }else {
            if (degree <= 285)
                return @"W";
            else if (degree <= 345)
                return @"NW";
            else
                return @"N";
        }
    }
}

-(NSString *)convertSpeedToText:(double)speed_in_mph
{
    if (isMetric) {
        return [NSString stringWithFormat:@"%.1f km/h", MILES_PER_HOUR_TO_KILOMETERS_PER_HOUR(speed_in_mph)];
    }else
        return [NSString stringWithFormat:@"%.1f mph", speed_in_mph];
}
-(NSString *)convertTimerToText:(int)timer_in_sec withSeconds:(BOOL)withSeconds
{
    if (timer_in_sec < 0) {
        return nil;
    }
    //mode 1 hh:mm
    //mode 2 mm:ss
    //mode 3 ss
    int hh = timer_in_sec/3600;
    int mm = timer_in_sec/60 - hh*60;
    int ss = timer_in_sec%60;
    if (!withSeconds || hh>0) {
        if (hh == 0 && mm == 0) {
            mm = 1;
        }
        //mode 1
        return [NSString stringWithFormat:@"%02d hrs %02d min", hh, mm];
    }else if (mm>0) {
        //mode 2
        return [NSString stringWithFormat:@"%02d min %02d sec", mm, ss];
    }else {
        //mode 3
        return [NSString stringWithFormat:@"%02d seconds", ss];
    }
}
-(NSString *)convertTimeToText:(NSDate *)time
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
    if (!is24Hour) {
        [formatter setDateFormat:@"hh:mm a"];
    }else {
        [formatter setDateFormat:@"HH:mm"];
    }
    
    return [formatter stringFromDate:time];
}
//instruction getter
-(NSArray *)instructions
{
    return route.instructions;
}

- (double)findNextStateCrossingDistance
{
    CLLocation *curLocation = [self getCurrentSimulationLocation];
    int  currentLocationIndex = idxCurSimLoc;
    double distanceToNextStateCrossing;
    NSString * currentState = [utility getStateWithCoord:curLocation.coordinate];
    if (   currentLocationIndex <= nextStateCrossingSimLocIndex) {
        CLLocation * nextStateCrossingLocation = [[self getSimulationLocationArray] objectAtIndex:nextStateCrossingSimLocIndex];
        distanceToNextStateCrossing = [utility distanceFromCoordinate:curLocation.coordinate toCoordinate:nextStateCrossingLocation.coordinate];
        return distanceToNextStateCrossing;
    }
    else
    {
      return ([self updateLocationOfNextStateCrossing:currentLocationIndex currentState:currentState]);
    }
    return 0;

}


- (double)updateLocationOfNextStateCrossing:(int)currentLocationIndex currentState:(NSString *)currentState
{
    // State location and current state correspond to US states
    NSString * stateOfLocation;
    NSArray * subArray = [[self getSimulationLocationArray] subarrayWithRange:NSMakeRange(currentLocationIndex, [[self getSimulationLocationArray] count] - currentLocationIndex)];
    
    
    for (int i =0; i< [subArray count]; i+=100) {
        stateOfLocation = [utility getStateWithCoord:[(CLLocation *)[subArray objectAtIndex:i] coordinate]];
        if (![stateOfLocation isEqualToString:currentState]) {
            nextStateCrossingSimLocIndex = (int)[[self getSimulationLocationArray] indexOfObject:[subArray objectAtIndex:i]];
            return [utility distanceFromCoordinate:[self getCurrentSimulationLocation].coordinate toCoordinate:[(CLLocation *)[subArray objectAtIndex:i] coordinate]];
            
        }
        
    }
    
//    for (CLLocation * location in subArray) {
//        stateOfLocation = [utility getStateWithCoord:location.coordinate];
//        if (![stateOfLocation isEqualToString:currentState]) {
//            nextStateCrossingSimLocIndex = (int)[[self getSimulationLocationArray] indexOfObject:location];
//            return [utility distanceFromCoordinate:[self getCurrentSimulationLocation].coordinate toCoordinate:location.coordinate];
//        }
//    }
    
    return 0;
}

- (NSDictionary *)returnNextStateCrossingInfo
{

    NSString * currentState = [utility getStateWithCoord:[self getCurrentSimulationLocation].coordinate];
    int distanceToNextStateCrossing = [self findNextStateCrossingDistance];
    CLLocation * nextStateLocation = [[self getSimulationLocationArray] objectAtIndex:nextStateCrossingSimLocIndex];
     NSString * nextState = [utility getStateWithCoord:nextStateLocation.coordinate];
    
    
    NSDictionary * returnInfo = @{@"currentState": [currentState substringFromIndex:3]
                                  , @"nextState" : [nextState substringFromIndex:3]
                                  , @"distanceToNextStateCrossing" : @(distanceToNextStateCrossing)};
    
    return returnInfo;
}

- (NSString *)returnRoundedDistInMetersToText:(int)dist_in_meter metric:(BOOL)isMetricOn
{
    
        if (dist_in_meter < 0) {
            return @"----";
        }
        
        NSString *retStr = nil;
        int nFt;
        if (isMetricOn) {
            if (dist_in_meter <= 100) {
                retStr = [NSString stringWithFormat:@"%d m", dist_in_meter];
            }else if (dist_in_meter <= 1000) {
                retStr = [NSString stringWithFormat:@"%d m", dist_in_meter/10*10];
            }else {
                retStr = [NSString stringWithFormat:@"%d km", dist_in_meter/1000];
            }
        }else {
            nFt = METERS_TO_FEET(dist_in_meter);
            if (nFt <= 100) {
                retStr = [NSString stringWithFormat:@"%d ft", nFt];
            }else if (nFt <= MILES_TO_FEET(.3)) {
                retStr = [NSString stringWithFormat:@"%d ft", nFt/100*100];
            }else if (nFt <= MILES_TO_FEET(100)) {
                //round to .1 miles
                retStr = [NSString stringWithFormat:@"%d mi", (int)(FEET_TO_MILES(nFt))];
            }else {
                retStr = [NSString stringWithFormat:@"%d mi", (int)FEET_TO_MILES(nFt)];
            }
        }
        
    return retStr;
    
}


@end