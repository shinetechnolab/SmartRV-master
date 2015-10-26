#import <Foundation/Foundation.h>
#import "TTDefinition.h"
#import <MapKit/MapKit.h>

@interface TTNavInfo : NSObject
@property (nonatomic, assign) int idxShape;//if current location is between shape[6] and shape[7], idxShape == 6
@property (nonatomic, assign) double dPotionFromCurrentIdx;
@property (nonatomic, assign) NSInteger idxTargetInstruction;//always the next "turn" instruction
@property (nonatomic, assign) CLLocationCoordinate2D location_raw;
@property (nonatomic, assign) CLLocationCoordinate2D location_estimated;
@property (nonatomic, assign) NSInteger time_to_destination;//in seconds
@property (nonatomic, assign) NSInteger time_to_via;//in seconds
@property (nonatomic, assign) NSInteger time_to_next_turn;//in seconds
@property (nonatomic, assign) NSDate *time_current;
@property (nonatomic, assign) NSDate *time_sunrise;
@property (nonatomic, assign) NSDate *time_sunset;
@property (nonatomic, assign) NSDate *time_eta;
@property (nonatomic, assign) NSDate *time_etand;
@property (nonatomic, assign) BOOL isOffRoute;
@property (nonatomic, assign) BOOL isOnRestrictedRoad;
@property (nonatomic, assign) enum  TT_STREET_TYPE street_type_current;
@property (nonatomic, assign) NSInteger dist_to_destination;//in meters
@property (nonatomic, assign) NSInteger dist_to_via;//in meters
@property (nonatomic, assign) NSInteger dist_to_next_turn;//in meters
@property (nonatomic, assign) NSInteger dist_total;//in meters
@property (nonatomic, assign) NSInteger heading;//in degrees
@property (nonatomic, assign) NSInteger odo1;//in meters
@property (nonatomic, assign) NSInteger odo2;//in meters
@property (nonatomic, assign) NSUInteger last_odo_tick;//in seconds
@property (nonatomic, assign) enum  SIGNAL_STRENGTH signal_strength;
@property (nonatomic, assign) double speed;//in mph
@property (nonatomic)int speed_limit_index;
@property (nonatomic, assign) NSInteger elevation;//in meters
@property (nonatomic, assign) enum DIRECTION direction;
@property (nonatomic, assign) NSInteger turning_degrees;//from 0 to 180 --> left turn, from 180 to 360 --> right turn
@property (nonatomic, assign) NSArray *edgeDegrees;//array[0] for start edge, array[1] for end edge
@property (nonatomic, assign) BOOL isWeighstationAhead;
@property (nonatomic, copy) NSString *weighstation_ahead;
@property (nonatomic, assign) NSUInteger current_stateID;
@property (nonatomic, assign) NSUInteger previous_stateID;
//panel info texts
@property (nonatomic, assign) NSString *current_instruction;
@property (nonatomic, assign) NSString *current_street_name;
@property (nonatomic, assign) NSString *next_instruction;
@property (nonatomic, assign) NSInteger dist_between_targetWP_and_nextWP;
@property (nonatomic, assign) NSString *heading_string;//N W S E NE SW SE SW
@property (nonatomic, assign) NSString *text_dist_to_next_turn;
@property (nonatomic, assign) NSString *text_distance_to_go;
//altitude
@property (nonatomic, assign) NSString *text_altitude;
//
@property (nonatomic, assign) NSString *text_odo1;
@property (nonatomic, assign) NSString *text_odo2;
@property (nonatomic, assign) NSString *text_speed;
@property (nonatomic, assign) NSString *text_timer_to_destination;
@property (nonatomic, assign) NSString *text_timer_to_next_turn;
@property (nonatomic, assign) NSString *text_time_arrivel;//eta
@property (nonatomic, assign) NSString *text_time_current;
@property (nonatomic, assign) NSString *text_time_sunrise;
@property (nonatomic, assign) NSString *text_time_sunset;
//lane assist info
@property (nonatomic, assign) BOOL lane_info_isChanged;
@property (nonatomic, assign) NSUInteger lane_info_total;
@property (nonatomic, assign) NSUInteger lane_info_start;
@property (nonatomic, assign) NSUInteger lane_info_end;

//navigating flags
@property (assign, nonatomic) BOOL isAnnounced;
@property (assign, nonatomic) BOOL isReminded;
@property (assign, nonatomic) BOOL isWarned;

// Navigation Next Two Instruction
@property (nonatomic, assign) NSString *nextOneInstruction;
@property (nonatomic, assign) NSString *nextTwoInstruction;
@property (nonatomic, assign) NSString *nextOneDistance;
@property (nonatomic, assign) NSString *nextTwoDistance;
@property (nonatomic, assign) enum DIRECTION nextOneDirection;
@property (nonatomic, assign) enum DIRECTION nextTwoDirection;
@end
