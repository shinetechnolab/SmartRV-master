//ttdefinition.h
#import <MapKit/MapKit.h>

#define MAX_EDGES   8
#define INVALID_INDEX -1

//basics
enum TT_STREET_TYPE{
	river = 0,
    ferry,
	rail,
    walkway,	
	localstreet,
	ramp,
    statehighway2,
    statehighway1,
    majorhighway2,
    majorhighway1
};
enum  SIGNAL_STRENGTH{
    signal_weak = 0,
    signal_good,
    signal_excellent
};

//route attributes
enum DIRECTION{//based on wn source code order
    direction_none = 0,
    direction_turn_left,
    direction_bear_left,
    direction_turn_right,
    direction_bear_right,
    direction_exit,
    direction_merge,
    direction_continue,
    direction_start,
    direction_end,
    direction_u_turn_left,
    direction_u_turn_right,
    direction_via,
    
    direction_start_head,
    direction_start_from,
    
    direction_stay_right,
    direction_stay_left,
    direction_ramp,
    direction_rotary,
    direction_exit_only,
    direction_towards,
    direction_restriction,
    direction_restriction_continue,
    direction_ramp_only,
    direction_turn_left_towards,
    direction_bear_left_towards,
    direction_turn_right_towards,
    direction_bear_right_towards,
    direction_turn_left_only,
    direction_bear_left_only,
    direction_turn_right_only,
    direction_bear_right_only,
    direction_exit_left,
    direction_exit_right,
    direction_ramp_left,
    direction_ramp_right,
    direction_merge_to_left,
    direction_merge_to_right
/*
    direction_turn_left_only,
    direction_turn_left_towards,
    
    direction_bear_left_only,
    direction_bear_left_towards,    
    
    direction_turn_right_only,
    direction_turn_right_towards,
    
    direction_bear_right_only,
    direction_bear_right_towards,    
    
    direction_exit_only,
    direction_exit_left = 32,
    direction_exit_right = 33,
    
    direction_ramp,
    direction_ramp_only,
    direction_ramp_left,
    direction_ramp_right,    
    
    direction_merge_to_left,
    direction_merge_to_right,    
    
    direction_rotary   */
};

struct LaneInfo {
    uint total;
    uint start;
    uint end;
};

struct Shape_Group {
    uint idxS;
    uint idxE;    
    CLLocationCoordinate2D ptS;
    CLLocationCoordinate2D ptE;
    int count;
};//for make route shape index group

//navigating panel
enum TT_TRIP_INFO_TYPE {
    speed,
    estimated_time_arrival,
    distance_to_go,
    heading,
    time_current,
    time_to_destination,
    time_to_next_turn,
    altitude,
    trip_info_type_none
};
#define MAX_TRIP_PANEL_TYPE ((int)trip_info_type_none)

//routing
enum TT_ROUTE_ERROR{
	ROUTE_ERROR_SUCCESS = 0,
    ROUTE_ERROR_ROUTE_FAILED = 2,
	ROUTE_ERROR_SERVER_ERROR = -1,
    ROUTE_ERROR_MYSQL_ERROR = -2,
	ROUTE_ERROR_NO_SUBSCRIPTION = -3,
	ROUTE_ERROR_EXPIRED_SUBSCRIPTION = -4
};
enum TT_ROUTE_TYPE {//conform to server route type protocal
    ROUTE_TYPE_CAR_QUICKEST = 1,
    ROUTE_TYPE_CAR_SHORTEST = 2,
    ROUTE_TYPE_CAR_AVOID_FREEWAYS = 3,
    ROUTE_TYPE_CAR_FREEWAYS = 4,
    ROUTE_TYPE_TRUCK_FREEWAYS = 7,
    ROUTE_TYPE_TRUCK_QUICKEST = 13,
    ROUTE_TYPE_TRUCK_SHORTEST = 14
    ,//default
    ROUTE_TYPE_NONE
};

//subscription plan
struct Subscription_Plan {
    BOOL isFreeTrial;
    int partNumber;//In-App-Purchase product id
    NSString *productLabel;
//    NSString *identifier;//for In-App-Purchase
};

