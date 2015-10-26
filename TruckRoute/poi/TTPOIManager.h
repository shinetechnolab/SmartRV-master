#import <sqlite3.h>
#import "TTPOI.h"
#import "CSVParser.h"

@interface TTPOIManager : NSObject {
    sqlite3 *db;//pointer to the db structure
    char *errMsg;
    BOOL bTypeMask[all_poi];
    int type_for_loading;
}

@property (readonly, nonatomic) NSArray *truckstop_names;
@property (readonly, nonatomic) NSArray *searchable_poi_types;

- (void) initializeDB;//will be removed
- (void) initializeDB2;//new
- (void) deinitializeDB;

- (BOOL) importCSVFile:(NSString *)filePath asType:(int)type;
- (void) receiveRecord:(NSDictionary *)aRecord;//will be removed
- (void) receiveRecord2:(NSDictionary *)aRecord;//NEW

//search poi
- (NSArray *) searchPOIinRegion:(MKCoordinateRegion)region;//will be removed
- (NSArray *) searchPOIinRegion2:(MKCoordinateRegion)region;
- (NSArray *) searchPOIinRegion:(MKCoordinateRegion)region withCondition:(TTPOI *)poi_condition;
- (NSArray *) searchPOIinRegion2:(MKCoordinateRegion)region withCondition:(TTPOI *)poi_condition;
-(NSArray *)getWeightStationByRegion:(MKCoordinateRegion)region;
/*- (NSArray *) retrievePOIsWithArea:(MKCoordinateRegion)region;
- (NSArray *) retrievePOIsWithName:(NSString *)name;*/

//DEBUG
- (void)displayAll;

@end