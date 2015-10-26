#import "TTRouteRequest.h"
#import "TTNavInfo.h"
#import "TTUtilities.h"

@interface TTRoute : NSObject {
@private
    struct Shape_Group *route_shape_group;
    int nShapeGroupSize;
    double *headings;
    double *seg_lengths;
//    struct Route_Instruction *instructions;
//    int nInstruction;
}
@property (nonatomic, assign) TTUtilities *utility;
@property (nonatomic, assign) NSUInteger route_id;
@property (nonatomic, assign) TTRouteRequest *request;
@property (nonatomic, assign) MKPolyline *route_points;
@property (nonatomic, assign) NSMutableArray *instructions;
//init
-(id)initWithRouteRequest:(TTRouteRequest *)aRouteRequest shapes:(MKPolyline *)shapes_array instructions:(NSArray *)instruction_array;
-(void)processShapes;
-(void)processInstructions;//updateShapeIdxInInstructions;

//interfaces
-(double *)getHeadings;
-(double *)getSegLengths;

//analyze
-(BOOL)processLocation:(CLLocation *)aLocation toNavInfo:(TTNavInfo*)navInfo;
-(double)distanceToRouteShapeGroup:(CLLocation *)aLocation atGroupIndex:(int)index;
-(int)startShapeIndexAtGroup:(int)idxGroup;
-(int)endShapeIndexAtGroup:(int)idxGroup;
-(BOOL)isHeading:(double)heading closeToRouteHeadingAtIndex:(int)index;
-(int)getIdxTargetInstruction:(int)idxShape;
@end