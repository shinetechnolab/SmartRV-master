#import "TTRoute.h"
#import "TTConfig.h"
#import "TTRouteInstruction.h"

@implementation TTRoute
@synthesize utility;
@synthesize route_id;
@synthesize request;
@synthesize route_points;
@synthesize instructions;

#pragma mark init
-(id)initWithRouteRequest:(TTRouteRequest *)aRouteRequest shapes:(MKPolyline *)shapes_array instructions:(NSArray *)instruction_array
{
    if(aRouteRequest)
    {
        if(self = [super init])
        {
            if (!utility) {
                utility = [TTUtilities alloc];
            }
            
            route_id = [aRouteRequest request_id];
            
            if (!request) {
                request = [TTRouteRequest alloc];
            }
            [request initWithRequest:aRouteRequest];
            if (route_points) {
                [route_points release];
            }
            NSLog(@"Shares Array : %i",[shapes_array pointCount]);
            route_points = [MKPolyline polylineWithPoints:[shapes_array points] count:[shapes_array pointCount]];
            [route_points setTitle:@"Route"];
            [route_points setSubtitle:@"Route Shapes"];
            [route_points retain];//important
            if (!instructions) {
                instructions = [[NSMutableArray alloc]init];
            }else {
                [instructions removeAllObjects];
            }
//            [instructions initWithArray:instruction_array];
            for (id one_ins in instruction_array) {
                [instructions addObject:one_ins];
            }
            [self processShapes];
            [self processInstructions];//updateShapeIdxInInstructions];
           }
        return self;
    }else {
        return nil;
    }
}

-(void)processShapes
{
    //clear memory
    if(route_shape_group)
        free(route_shape_group);
    if(headings)
        free(headings);
    if(seg_lengths)
        free(seg_lengths);
   
    nShapeGroupSize = [route_points pointCount] / MAX_SHAPES_IN_ROUTE_SHAPE_GROUP + 1;
    route_shape_group = malloc(sizeof(struct Shape_Group) * nShapeGroupSize);
    int nAdded = 0;
    NSRange range;//apple reference is WRONG here for the API, range.location is actually start idx and range.length should be actual end idx + 1 for the request!! THIS IS FIXED IN IOS6 SDK!!
    CLLocationCoordinate2D tmpCoord[MAX_SHAPES_IN_ROUTE_SHAPE_GROUP];
    int i, j;
    for(i=0; i<nShapeGroupSize; i++)
    {
        if(i == nShapeGroupSize - 1)
            route_shape_group[i].count = [route_points pointCount] % MAX_SHAPES_IN_ROUTE_SHAPE_GROUP;//last group
        else
            route_shape_group[i].count = MAX_SHAPES_IN_ROUTE_SHAPE_GROUP;
        
        route_shape_group[i].idxS = nAdded;        
        range.location = route_shape_group[i].idxS;
//        range.length = range.location+1;
        range.length = 1;
        [route_points getCoordinates:tmpCoord range:range];
        route_shape_group[i].ptS = tmpCoord[0];
        
        route_shape_group[i].idxE = route_shape_group[i].idxS + route_shape_group[i].count - 1;
        range.location = route_shape_group[i].idxE;
//        range.length = range.location+1;
        range.length = 1;
        [route_points getCoordinates:tmpCoord range:range];
        route_shape_group[i].ptE = tmpCoord[0];
        
        //update nAdded
        nAdded += route_shape_group[i].count;
    }
    
    //    headings = malloc(sizeof(double)*[shapes pointCount]);
    //    seg_lengths = malloc(sizeof(double)*[shapes pointCount]);
    int size = sizeof(double)*[route_points pointCount];
    headings = malloc(size);
    seg_lengths = malloc(size);
    for(j = 0; j<nShapeGroupSize; j++)
    { 
        range.location = route_shape_group[j].idxS;
//        range.length = range.location + route_shape_group[j].count;
        range.length = route_shape_group[j].count;
        [route_points getCoordinates:tmpCoord range:range];
        for(i = 0; i < route_shape_group[j].count - 1; i++)
        {
            //debug
/*            if (j == 2 && i == 21) {
                int check = 3;
            }*/
            headings[i + j*MAX_SHAPES_IN_ROUTE_SHAPE_GROUP] = [utility headingFromCoordinate:tmpCoord[i] toCoordinate:tmpCoord[i + 1]];
            seg_lengths[i + j*MAX_SHAPES_IN_ROUTE_SHAPE_GROUP] = [utility distanceFromCoordinate:tmpCoord[i] toCoordinate:tmpCoord[i + 1]]; //this is optional, coz right now the server already sends seg_length info                                                                                                       
        }
        //heading and length of the last point of current group
        if (nShapeGroupSize - 1 != j) {
            //not last group
//            range.location = range.length - 1;
//            range.length++;
            range.location += range.length - 1;
            range.length = 2;
            [route_points getCoordinates:tmpCoord range:range];
            headings[i+j*MAX_SHAPES_IN_ROUTE_SHAPE_GROUP] = [utility headingFromCoordinate:tmpCoord[0] toCoordinate:tmpCoord[1]];
            seg_lengths[i+j*MAX_SHAPES_IN_ROUTE_SHAPE_GROUP] = [utility distanceFromCoordinate:tmpCoord[0] toCoordinate:tmpCoord[1]];
        }
    }
    headings[[route_points pointCount] - 1] = 0;
    seg_lengths[[route_points pointCount] - 1] = 0;    
}

-(void)processInstructions;//updateShapeIdxInInstructions
{
    int idxShape = 0;
    int idxInstruction = 1;//because the first one is "worldnav gps for trucks"
    NSRange range;
    int size = sizeof(CLLocationCoordinate2D)*[route_points pointCount];
    CLLocationCoordinate2D *tmpCoord = malloc(size);
    TTRouteInstruction *cur_instruction;
    range.location = 0;
    range.length = [route_points pointCount];
    [route_points getCoordinates:tmpCoord range:range];
    
    //check
    //    for(int i=0; i<instructions.count; i++)
    //    {
    //        cur_instruction = [instructions objectAtIndex:i];
    //    }
    
    while (idxInstruction < instructions.count) {
        cur_instruction = [instructions objectAtIndex:idxInstruction];
        float lat1 = cur_instruction.coord.latitude;
        float lon1 = cur_instruction.coord.longitude;
        while (idxShape < [route_points pointCount]) {            
            float lat2 = tmpCoord[idxShape].latitude;            
            float lon2 = tmpCoord[idxShape].longitude;
            if(lat1 == lat2 && lon1 == lon2)
                //            if( (cur_instruction.coord.latitude == tmpCoord[idxShape].latitude) && (cur_instruction.coord.longitude == tmpCoord[idxShape].longitude) )
            {
                //updateShapeIdxInInstructions
                [cur_instruction setIdxShape:idxShape];
//                NSLog(@"added shape index %d to instruction index %d", idxShape - 1, idxInstruction);
                
                //update the from/to edge degree
                if (idxShape > 0) {
                    cur_instruction->nEdgeDegrees[0] = headings[idxShape - 1];
                    cur_instruction->nEdgeDegrees[1] = headings[idxShape];
                }else {
                    cur_instruction->nEdgeDegrees[0] = headings[idxShape] + 180;
                    cur_instruction->nEdgeDegrees[1] = headings[idxShape];
                }
                
                idxShape++;
                break;
            }
            
            idxShape++;
        }
        
        idxInstruction++;
    }
    
    free(tmpCoord);
}

#pragma mark interfaces
-(double *)getHeadings
{
    return headings;
}
-(double *)getSegLengths
{
    return seg_lengths;
}

#pragma mark process
-(BOOL)processLocation:(CLLocation *)aLocation toNavInfo:(TTNavInfo*)navInfo
{
    //basic info
    NSLog(@"Speed123 : %f",[aLocation speed]);
    double speed_in_mph = METERS_PER_SECOND_TO_MILES_PER_HOUR([aLocation speed]);
    if (speed_in_mph < 0) {
        //invalid, set it as 0
        speed_in_mph = 0;
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Simulating"])
    {
        [navInfo setSpeed:speed_in_mph];
    }
    
    //calculate location
    NSRange range;//apple reference is WRONG here for the API, range.location is actually start idx and range.length should be actual end idx + 1 for the request!!, iOS6 fixed the bug
    CLLocationCoordinate2D tmpCoord[MAX_SHAPES_IN_ROUTE_SHAPE_GROUP];
    BOOL bCheckHeading = (-1 == aLocation.course)?NO:YES;
    int resultShapeIdx = 0;
    double dist = 0, distToGroup;
    double dMinShape = THRESHOLD_MIN_DISTANCE_TO_ROUTE_SEGMENT;
    CLLocationCoordinate2D tmpCoordinate, tmpResultCoordinate = aLocation.coordinate;
    for (int i=0; i<nShapeGroupSize; i++)
    {
        distToGroup = [self distanceToRouteShapeGroup:aLocation atGroupIndex:i];
        if( distToGroup >= 0 && distToGroup < THRESHOLD_DISTANCE_TO_ROUTE_SHAPE_GROUP )
        {
            //get location on route shape group
            int start = [self startShapeIndexAtGroup:i];
            int end = [self endShapeIndexAtGroup:i];
            range.location = start;
//            range.length = end + 1;
            range.length = end - start + 1;
            [route_points getCoordinates:tmpCoord range:range];
            for(int j = 0; j < range.length - 1; j++)
            {
                if([utility distanceBetweenCoordinate:aLocation.coordinate andSegmentFromCoordinate:tmpCoord[j] segmentToCoordinate:tmpCoord[j+1] returnCoordinate:&tmpCoordinate distanceInDegrees:&dist]
                   && dist < dMinShape)
                {
                    //compare headings
                    if(!bCheckHeading || [self isHeading: aLocation.course closeToRouteHeadingAtIndex:j+start])
                    {                    
                        dMinShape = dist;
                        tmpResultCoordinate = tmpCoordinate;
                        resultShapeIdx = j + start;
                    }
                }
            }
        }
    }
    
    //write to navinfo
    if(dMinShape < THRESHOLD_MIN_DISTANCE_TO_ROUTE_SEGMENT)
    {
        [navInfo setLocation_raw:aLocation.coordinate];
        [navInfo setLocation_estimated:tmpResultCoordinate];
        [navInfo setHeading:headings[resultShapeIdx]];
        [navInfo setIdxShape:resultShapeIdx];
        
        //calculate navInfo.dPotionFromCurrentIdx
        if (seg_lengths[resultShapeIdx]) {
            //get shape[resultShapeIdx]
            range.location = resultShapeIdx;
//            range.length = resultShapeIdx + 1;
            range.length = 1;
            [route_points getCoordinates:tmpCoord range:range];
            [navInfo setDPotionFromCurrentIdx:[utility distanceFromCoordinate:tmpCoord[0] toCoordinate:tmpResultCoordinate]/seg_lengths[resultShapeIdx]];
//            NSLog(@"dPortion: %f", [navInfo dPotionFromCurrentIdx]);
        }
        
        //get target instruction index
        int idxPrevTargetIns = [navInfo idxTargetInstruction];
        int idxTargetIns = [self getIdxTargetInstruction:resultShapeIdx];
        if(INVALID_INDEX == idxTargetIns)
        {
            [navInfo setIdxTargetInstruction:INVALID_INDEX];
            return NO;
        }
        
        [navInfo setIdxTargetInstruction:idxTargetIns];
        if (idxPrevTargetIns != idxTargetIns) {
            //clear flags
            [navInfo setIsWarned:NO];
            [navInfo setIsReminded:NO];
            [navInfo setIsAnnounced:NO];
            //lane info change
            [navInfo setLane_info_isChanged:YES];
        }
        
        TTRouteInstruction *targetIns = [instructions objectAtIndex:idxTargetIns];
        TTRouteInstruction *nextIns = nil;
        if (idxTargetIns < instructions.count - 1) {
            nextIns = [instructions objectAtIndex:idxTargetIns+1];
        }
        
        //lane info
        navInfo.lane_info_total = targetIns.lane_total;
        navInfo.lane_info_start = targetIns.lane_start;
        navInfo.lane_info_end = targetIns.lane_end;
        
        //calculate distance to go
        double dDistToNextTurn = (1-[navInfo dPotionFromCurrentIdx])*seg_lengths[resultShapeIdx];
        for(int j=resultShapeIdx + 1; j<[targetIns idxShape]; j++)
        {
            dDistToNextTurn = dDistToNextTurn + seg_lengths[j];
        }
        [navInfo setDist_to_next_turn:dDistToNextTurn];        
        [navInfo setDist_to_destination: dDistToNextTurn + [targetIns distToDest]];
        
        //calculate time to go
        int nTimeToNextTurn;
        if (aLocation.speed > DEFAULT_LOW_SPEED) {
            nTimeToNextTurn = dDistToNextTurn / [aLocation speed];
        }else {
            nTimeToNextTurn = dDistToNextTurn / MILES_PER_HOUR_TO_METERS_PER_SECOND(DEFAULT_STANDARD_SPEED);
        }        
        [navInfo setTime_to_next_turn:nTimeToNextTurn];
        [navInfo setTime_to_destination:nTimeToNextTurn + MINUTES_TO_SECONDS([targetIns timeToDest])];
        
        //copy instructions
        [navInfo setCurrent_instruction:[targetIns info]];
        if (nextIns && direction_end != nextIns.direction && direction_via != nextIns.direction) {
            [navInfo setNext_instruction:[nextIns info]];
            [navInfo setDist_between_targetWP_and_nextWP:targetIns.distToDest - nextIns.distToDest];
        } else {
            [navInfo setNext_instruction:nil];
            [navInfo setDist_between_targetWP_and_nextWP:0];
        }
        
        //direction
        [navInfo setDirection:[targetIns direction]];
        
        [navInfo setIsOffRoute:NO];
        return YES;
    }else {
        //not on route
        [navInfo setLocation_raw:aLocation.coordinate];
        [navInfo setLocation_estimated:aLocation.coordinate];
        double heading = aLocation.course;
        if (heading < 0) {
            heading = 0;//invalid heading
        }
        [navInfo setHeading:heading];
        [navInfo setIdxShape:INVALID_INDEX];
        [navInfo setIdxTargetInstruction:INVALID_INDEX];
        [navInfo setIsOffRoute:YES];
//        NSLog(@"offroute detected!");
        return YES;
    }
}

-(double)distanceToRouteShapeGroup:(CLLocation *)aLocation atGroupIndex:(int)index
{
    CLLocationCoordinate2D resultCoordinate;
    double resultDist;
    if([utility distanceBetweenCoordinate:aLocation.coordinate andSegmentFromCoordinate:route_shape_group[index].ptS segmentToCoordinate:route_shape_group[index].ptE returnCoordinate:&resultCoordinate distanceInDegrees:&resultDist])
        return resultDist;
    else {
        return -1;
    }
}

-(int)startShapeIndexAtGroup:(int)idxGroup
{
    return route_shape_group[idxGroup].idxS;
}
-(int)endShapeIndexAtGroup:(int)idxGroup
{
    return route_shape_group[idxGroup].idxE;
}
-(BOOL)isHeading:(double)heading closeToRouteHeadingAtIndex:(int)index
{
    BOOL returnValue;
    double route_heading = headings[index];//supposed to be regulated, (0 ~ 359.9)
    returnValue = (abs((int)(heading - route_heading)%360) < THRESHOLD_JUDGE_BEARING) ? YES:NO;
    return returnValue;
}

-(int)getIdxTargetInstruction:(int)idxShape
{
    for(int i=1; i<instructions.count; i++)
    {
        TTRouteInstruction *cur_ins = [instructions objectAtIndex:i];
        if (idxShape < [cur_ins idxShape]) {
            return i;
        }
    }
    return -1;
}
#pragma mark dealloc
-(void) dealloc 
{
    //clear memory
    if(route_shape_group)
        free(route_shape_group);
    if(headings)
        free(headings);
    if(seg_lengths)
        free(seg_lengths);
    
    [utility release];
    
//    [route_points dealloc];
    [request release];    
    [instructions release];
    [super dealloc];
}

@end


