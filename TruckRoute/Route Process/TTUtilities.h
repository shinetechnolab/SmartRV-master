//TTUtilities.h
#import <CoreLocation/CLLocation.h>
#import "KeychainItemWrapper.h"
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))
#define DEGREES_TO_RADIANS(degrees) ((degrees)*(M_PI/180.0))
#define METERS_PER_SECOND_TO_MILES_PER_HOUR(mps)  ((mps)/0.44704)
#define MILES_PER_HOUR_TO_METERS_PER_SECOND(mph)  ((mph)*0.44704)
#define MILES_PER_HOUR_TO_KILOMETERS_PER_HOUR(mph0)  ((mph0)*1.60934)
#define KILOMETERS_PER_HOUR_TO_MILES_PER_HOUR(kph)  ((kph)/1.60934)
#define METERS_TO_MILES(meters) ((meters)*0.000621371)
#define MILES_TO_METERS(miles) ((miles)*1609.34)
#define METERS_TO_FEET(meters) ((meters)*3.28084)
#define FEET_TO_METERS(feet) ((feet)/3.28084)
#define MILES_TO_FEET(miles) ((miles)*5280.0)
#define FEET_TO_MILES(feet) ((feet)/5280.0)
#define MINUTES_TO_SECONDS(min) ((min)*60.0)

@interface TTUtilities: NSObject

//location coordinates calculation
@property (nonatomic, retain) KeychainItemWrapper *SaveValue;
//calculate perpendicute location and distance (in lat/lon degrees) between location A to segment(location B -- location C)
//return NO if any of the input is invalid
-(BOOL)distanceBetweenCoordinate:(CLLocationCoordinate2D)aCoordinate andSegmentFromCoordinate:(CLLocationCoordinate2D)segStartCoordinate segmentToCoordinate:(CLLocationCoordinate2D)segEndCoordinate returnCoordinate:(CLLocationCoordinate2D *)returnCoordinate distanceInDegrees:(double *)distance;

//calculate distance (in meters) between 2 locations
-(double)distanceFromCoordinate:(CLLocationCoordinate2D)aCoordinate toCoordinate:(CLLocationCoordinate2D)anotherCoordinate;

//in degrees, clockwise, 0 to 360, north up == 0
-(double)headingFromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate;
-(NSString *)getStateWithCoord:(CLLocationCoordinate2D)coord;
-(BOOL)isCoord:(CLLocationCoordinate2D)coord inPolygon:(NSArray *)polygon;

//universal methods
//get randome string as fake UUID, everytime calling this function will get different string
+(NSString *)generateFakeUUID;
+(NSString *)getFakeUUID;
//get device serial number and trim it into 32 digits to match our costumer database, later gonna hash it
+(NSString *)getSerialNumberString;

//init odo
+(void)initStatePolygons;
-(NSArray *)preparePolygon:(NSString*)name;

//abbreviations
+(NSString *)getAbbreviation:(NSString *)state;
//process phone number
+(NSString *)processPhoneNumber:(NSString *)number;

//full description
+(NSString *)getStateName:(NSString *)abbreviatedString;

@end