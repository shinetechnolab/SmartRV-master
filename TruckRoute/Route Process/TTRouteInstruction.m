#import "TTRouteInstruction.h"

@implementation TTRouteInstruction
@synthesize coord, idxShape, direction, timeToDest, distToDest, degree, distanceInfo, info, SVGInfo,  IsTruckRestricted, targetName, lane_total, lane_start, lane_end;

-(void)setLaneInfo:(NSString*)str
{
    if (nil == str || [str isEqualToString:@""]) {
        lane_total = lane_start = lane_end = 0;
    }else {//@"4,5,6"
        NSArray *array = [str componentsSeparatedByString:@","];
        if (3 != array.count) {
            lane_total = lane_start = lane_end = 0;
        }else {
            lane_total = [[array objectAtIndex:0] intValue];
            lane_start = [[array objectAtIndex:1] intValue];
            lane_end = [[array objectAtIndex:2] intValue];
        }
    }
}
@end