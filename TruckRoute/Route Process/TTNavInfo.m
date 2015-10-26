#import "TTNavInfo.h"

@implementation TTNavInfo
@synthesize idxShape;//if current location is between shape[6] and shape[7], idxShape == 6
@synthesize dPotionFromCurrentIdx;
@synthesize idxTargetInstruction;//always the next "turn" instruction
@synthesize location_raw;
@synthesize location_estimated;
@synthesize time_to_destination;//in seconds
@synthesize time_to_via;//in seconds
@synthesize time_to_next_turn;//in seconds
@synthesize time_current;
@synthesize time_sunrise;
@synthesize time_sunset;
@synthesize time_eta;
@synthesize time_etand;
@synthesize isOffRoute;
@synthesize isOnRestrictedRoad;
@synthesize street_type_current;
@synthesize current_street_name;
@synthesize dist_to_destination;//in meters
@synthesize dist_to_via;//in meters
@synthesize dist_to_next_turn;//in meters
@synthesize dist_total;//in meters
@synthesize text_dist_to_next_turn;
@synthesize heading;//in degrees
@synthesize heading_string;//N W S E NE SW SE SW
@synthesize odo1;//in meters
@synthesize odo2;//in meters
@synthesize last_odo_tick;//in seconds
@synthesize signal_strength;
@synthesize speed;//in mph
@synthesize elevation;//in meters
@synthesize current_instruction;
@synthesize dist_between_targetWP_and_nextWP;
@synthesize next_instruction;
@synthesize direction;
@synthesize turning_degrees;//from 0 to 180 --> left turn, from 180 to 360 --> right turn
@synthesize edgeDegrees;//array[0] for start edge, array[1] for end edge
@synthesize isWeighstationAhead;
@synthesize weighstation_ahead;
@synthesize current_stateID;
@synthesize previous_stateID;
@synthesize isAnnounced;
@synthesize isReminded;
@synthesize isWarned;
@synthesize text_distance_to_go;
@synthesize text_altitude;
@synthesize text_timer_to_destination;
@synthesize text_timer_to_next_turn;
@synthesize text_time_arrivel;
@synthesize text_time_current;
@synthesize text_time_sunrise;
@synthesize text_time_sunset;
@synthesize lane_info_isChanged, lane_info_total, lane_info_start, lane_info_end;

@synthesize nextOneDirection,nextOneDistance,nextOneInstruction,nextTwoDirection,nextTwoDistance,nextTwoInstruction;
-(void) dealloc
{
    [time_current release];
    [time_sunrise release];
    [time_sunset release];
    [time_eta release];
    [time_etand release];
    [edgeDegrees release];//array[0] for start edge, array[1] for end edge
    [super dealloc];
}
@end