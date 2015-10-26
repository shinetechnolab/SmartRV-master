//make route instruction a object, so it is ez to manage
#import <Foundation/Foundation.h>
#import "TTDefinition.h"

@interface TTRouteInstruction : NSObject {
@public
    int nEdgeDegrees[MAX_EDGES];//absolute degrees for instrution graph, the first one is the from_edge degree, the 2nd is the to_edge degree, -1 when the rest edges do not exist
}
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, assign) int idxShape;
@property (nonatomic, assign) enum DIRECTION direction;
@property (nonatomic, assign) double timeToDest;//time from curernt instruction to destination, in minutes
@property (nonatomic, assign) int distToDest;//in meters
@property (nonatomic, assign) int degree;//in degrees, from-via-to
@property (nonatomic, retain) NSString *distanceInfo;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, assign) bool IsTruckRestricted;
@property (nonatomic, retain) NSString *SVGInfo;
@property (nonatomic, assign) NSString *targetName;//target street name
//lane info
@property (nonatomic, assign) int lane_total;
@property (nonatomic, assign) int lane_start;
@property (nonatomic, assign) int lane_end;
//@property (nonatomic, assign) int nEdgeDegrees[MAX_EDGES];//absolute degrees for instrution graph, the first one is the from_edge degree, the 2nd is the to_edge degree, -1 when the rest edges do not exist

-(void)setLaneInfo:(NSString*)str;
@end