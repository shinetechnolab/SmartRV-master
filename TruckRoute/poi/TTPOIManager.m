#import "TTPOIManager.h"

@implementation TTPOIManager

/*- (void) dealloc
{
//    free(errMsg);
    [super dealloc];
}*/

- (void) initializeDB
{//open default database file POI.sqlite, if it does not exist, create one
    if (!errMsg) {
        errMsg = malloc(200);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TRUCK_POI.sqlite"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *defaultPath = [paths objectAtIndex:0];
//    NSString *defaultDBPath = [defaultPath stringByAppendingPathComponent:@"TRUCK_POI.sqlite"];
    BOOL isExisting = [fileManager fileExistsAtPath:defaultDBPath];
    if (sqlite3_open([defaultDBPath UTF8String], &db) == SQLITE_OK)
    {//does not exist, create one
        if (!isExisting) {
        //created, then create database tables
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TRUCKSTOP (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, LAT FLOAT, LON FLOAT, ADDRESS TEXT, CITY TEXT, STATE TEXT, POSTCODE TEXT, NUMBER TEXT, WIFI INTEGER, IDLE INTEGER, SCALE INTEGER, SERVICE INTEGER, WASH INTEGER, SHOWERS INTEGER, SECUREPARKING INTEGER, NIGHTPARKINGONLY INTEGER, IMAGE TEXT)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg);
            sql_stmt = "CREATE TABLE IF NOT EXISTS WEIGHSTATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, LAT FLOAT, LON FLOAT, CITY TEXT, STATE TEXT, POSTCODE TEXT, IMAGE TEXT)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg);
            sql_stmt = "CREATE TABLE IF NOT EXISTS TRUCKPARKING (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, LAT FLOAT, LON FLOAT, ADDRESS TEXT, CITY TEXT, STATE TEXT, POSTCODE TEXT, IMAGE TEXT)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg);
            sql_stmt = "CREATE TABLE IF NOT EXISTS TRUCKDEALER (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, LAT FLOAT, LON FLOAT, ADDRESS TEXT, CITY TEXT, STATE TEXT, POSTCODE TEXT, NUMBER TEXT, IMAGE TEXT)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg);
        }
    }else{
        sprintf(errMsg, "Failed to open or create database!");
    }
    
    //initialize poi type mask
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bTypeMask[truck_stop] = [userDefaults boolForKey:@"poi_display_truckstop"];
    bTypeMask[weighstation] = [userDefaults boolForKey:@"poi_display_weighstation"];
    bTypeMask[truck_dealer] = [userDefaults boolForKey:@"poi_display_truckdealer"];
    bTypeMask[truck_parking] = [userDefaults boolForKey:@"poi_display_truckparking"];
    
    //initialize known poi names
    _truckstop_names = [[NSArray alloc]initWithObjects:@"Find Any", @"Flying J", @"Love's Travel Stops", @"PETRO Stopping Centers", @"Pilot Travel Centers", @"TravelCenters of America", nil];
    _searchable_poi_types = [[NSArray alloc]initWithObjects:@"Truck Stop", @"Weigh Station", @"Truck Dealer", @"Truck Parking", @"Gas Station", @"CAT Scale", @"Rest Area", nil];
}
- (void) initializeDB2
{
    //open default database file POI.sqlite, if it does not exist, create one
    if (!errMsg) {
        errMsg = malloc(200);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TRUCK_POI.sqlite"];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *defaultPath = [paths objectAtIndex:0];
//        NSString *defaultDBPath = [defaultPath stringByAppendingPathComponent:@"TRUCK_POI.sqlite"];
    BOOL isExisting = [fileManager fileExistsAtPath:defaultDBPath];
    if (sqlite3_open([defaultDBPath UTF8String], &db) == SQLITE_OK)
    {//does not exist, create one
        if (!isExisting) {
            //created, then create database tables
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS POI (ID INTEGER PRIMARY KEY AUTOINCREMENT,TYPE INTEGER, NAME TEXT, LAT FLOAT, LON FLOAT, ADDRESS TEXT, CITY TEXT, STATE TEXT, POSTCODE TEXT, NUMBER TEXT, WIFI INTEGER, IDLE INTEGER, SCALE INTEGER, SERVICE INTEGER, WASH INTEGER, SHOWERS INTEGER, SECUREPARKING INTEGER, NIGHTPARKINGONLY INTEGER, IMAGE TEXT)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg);
        }
    }else{
        sprintf(errMsg, "Failed to open or create database!");
    }
    
    //initialize poi type mask
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bTypeMask[truck_stop] = [userDefaults boolForKey:@"poi_display_truckstop"];
    bTypeMask[weighstation] = [userDefaults boolForKey:@"poi_display_weighstation"];
    bTypeMask[truck_dealer] = [userDefaults boolForKey:@"poi_display_truckdealer"];
    bTypeMask[truck_parking] = [userDefaults boolForKey:@"poi_display_truckparking"];
    bTypeMask[CAT_scale] = [userDefaults boolForKey:@"poi_display_catscale"];
    bTypeMask[rest_area] = [userDefaults boolForKey:@"poi_display_restarea"];
    bTypeMask[campgrounds] = [userDefaults boolForKey:@"poi_display_campgrounds"];
    //initialize known poi names
    _truckstop_names = [[NSArray alloc]initWithObjects:@"Find Any", @"Flying J", @"Love's Travel Stops", @"PETRO Stopping Centers", @"Pilot Travel Centers", @"TravelCenters of America", nil];
    _searchable_poi_types = [[NSArray alloc]initWithObjects:@"Truck Stop", @"Weigh Station", @"Truck Dealer", @"Truck Parking", @"Gas Station", @"Campgrounds", @"Rest Area", nil];
}

//dont forget
- (void) deinitializeDB
{
    sqlite3_close(db);
    free(errMsg);
    [_truckstop_names release];
    [_searchable_poi_types release];
}

- (BOOL) importCSVFile:(NSString *)filePath asType:(int)type
{
    type_for_loading = type;
    NSError *error;
    NSString *csvString;
    //open file, get csv string
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
    {
        csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (!csvString)
        {
            NSLog(@"Couldn't read file at path %s\n. Error: %s",
                   [filePath UTF8String],
                   [[error localizedDescription] ? [error localizedDescription] : [error description] UTF8String]);
            sprintf(errMsg, "couldn't read file");
            return NO;
        }
    }else{
        sprintf(errMsg, "csv file does not exist");
        return NO;
    }
    
    //parse
	CSVParser *parser =
    [[[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:NO
      fieldNames:
//      [NSArray arrayWithObjects:@"name",@"latitude",@"longitude",nil]]autorelease];
      [NSArray arrayWithObjects:@"poi_id",@"chain_id",@"name",@"cat_nt",@"cat_naics",@"lat",@"lon",@"addr",@"city",@"state",@"pcode",@"phone",@"wifi",@"idle",@"scale",@"service",@"wash",@"showers",@"secureparking",@"nightparkingonly",@"picture",nil]]autorelease];
	[parser parseRowsForReceiver:self selector:@selector(receiveRecord2:)];
    return YES;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
- (void) receiveRecord:(NSDictionary *)aRecord
{
    NSString *stringCAT_NT = [aRecord objectForKey:@"cat_nt"];
    NSString *sql = nil;
    sqlite3_stmt *stmt = nil;
    if ([stringCAT_NT isEqualToString:@"9719"]) {
        //truckdealer
        sql = @"INSERT INTO TRUCKDEALER(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";        
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return;
        }
        sqlite3_bind_text(stmt, 1, [[aRecord objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 2, [[aRecord objectForKey:@"lat"] doubleValue]);
        sqlite3_bind_double(stmt, 3, [[aRecord objectForKey:@"lon"] doubleValue]);
        sqlite3_bind_text(stmt, 4, [[aRecord objectForKey:@"addr"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, [[aRecord objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [[aRecord objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, [[aRecord objectForKey:@"pcode"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 8, [[aRecord objectForKey:@"phone"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 9, [[aRecord objectForKey:@"picture"] UTF8String], -1, SQLITE_TRANSIENT);
    }else if ([stringCAT_NT isEqualToString:@"9720"]) {
        //truckparking
        sql = @"INSERT INTO TRUCKPARKING(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return;
        }
        sqlite3_bind_text(stmt, 1, [[aRecord objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 2, [[aRecord objectForKey:@"lat"] doubleValue]);
        sqlite3_bind_double(stmt, 3, [[aRecord objectForKey:@"lon"] doubleValue]);
        sqlite3_bind_text(stmt, 4, [[aRecord objectForKey:@"addr"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, [[aRecord objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [[aRecord objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, [[aRecord objectForKey:@"pcode"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 8, [[aRecord objectForKey:@"picture"] UTF8String], -1, SQLITE_TRANSIENT);
    }else if ([stringCAT_NT isEqualToString:@"9522"]) {
        //truckstop
        sql = @"INSERT INTO TRUCKSTOP(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER, WIFI, IDLE, SCALE, SERVICE, WASH, SHOWERS, SECUREPARKING, NIGHTPARKINGONLY, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return;
        }
        sqlite3_bind_text(stmt, 1, [[aRecord objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 2, [[aRecord objectForKey:@"lat"] doubleValue]);
        sqlite3_bind_double(stmt, 3, [[aRecord objectForKey:@"lon"] doubleValue]);
        sqlite3_bind_text(stmt, 4, [[aRecord objectForKey:@"addr"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, [[aRecord objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [[aRecord objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, [[aRecord objectForKey:@"pcode"] UTF8String], -1, SQLITE_TRANSIENT);
        //"phone",@"wifi",@"idle",@"scale",@"service",@"wash",@"showers",@"secureparking",@"nightparkingonly",@"picture"        
        sqlite3_bind_text(stmt, 8, [[aRecord objectForKey:@"phone"] UTF8String], -1, SQLITE_TRANSIENT);
        if ([[aRecord objectForKey:@"wifi"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 9, 1);
        }else {
            sqlite3_bind_int(stmt, 9, 0);
        }
        if ([[aRecord objectForKey:@"idle"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 10, 1);
        }else {
            sqlite3_bind_int(stmt, 10, 0);
        }
        if ([[aRecord objectForKey:@"scale"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 11, 1);
        }else {
            sqlite3_bind_int(stmt, 11, 0);
        }
        if ([[aRecord objectForKey:@"service"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 12, 1);
        }else {
            sqlite3_bind_int(stmt, 12, 0);
        }
        if ([[aRecord objectForKey:@"wash"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 13, 1);
        }else {
            sqlite3_bind_int(stmt, 13, 0);
        }
        sqlite3_bind_int(stmt, 14, [[aRecord objectForKey:@"showers"] intValue]);
        if ([[aRecord objectForKey:@"secureparking"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 15, 1);
        }else {
            sqlite3_bind_int(stmt, 15, 0);
        }
        if ([[aRecord objectForKey:@"nightparkingonly"] isEqualToString:@"true"]) {
            sqlite3_bind_int(stmt, 16, 1);
        }else {
            sqlite3_bind_int(stmt, 16, 0);
        }
        sqlite3_bind_text(stmt, 17, [[aRecord objectForKey:@"picture"] UTF8String], -1, SQLITE_TRANSIENT);
    }else if ([stringCAT_NT isEqualToString:@"9710"]) {
        //weighstation
        sql = @"INSERT INTO WEIGHSTATION(NAME, LAT, LON, CITY, STATE, POSTCODE, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?)";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return;
        }
        sqlite3_bind_text(stmt, 1, [[aRecord objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 2, [[aRecord objectForKey:@"lat"] doubleValue]);
        sqlite3_bind_double(stmt, 3, [[aRecord objectForKey:@"lon"] doubleValue]);
        sqlite3_bind_text(stmt, 4, [[aRecord objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, [[aRecord objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [[aRecord objectForKey:@"pcode"] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, [[aRecord objectForKey:@"picture"] UTF8String], -1, SQLITE_TRANSIENT);
    }
    
//    NSLog(@"%@", aRecord);
    
    if ( SQLITE_DONE != sqlite3_step(stmt) ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
    }
    sqlite3_finalize(stmt);
}
- (void) receiveRecord2:(NSDictionary *)aRecord//NEW
{
    NSString *sql = nil;
    sqlite3_stmt *stmt = nil;
    
    //truckstop
    sql = @"INSERT INTO POI(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER, WIFI, IDLE, SCALE, SERVICE, WASH, SHOWERS, SECUREPARKING, NIGHTPARKINGONLY, IMAGE, TYPE) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
        return;
    }
    sqlite3_bind_text(stmt, 1, [[aRecord objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(stmt, 2, [[aRecord objectForKey:@"lat"] doubleValue]);
    sqlite3_bind_double(stmt, 3, [[aRecord objectForKey:@"lon"] doubleValue]);
    sqlite3_bind_text(stmt, 4, [[aRecord objectForKey:@"addr"] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, [[aRecord objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 6, [[aRecord objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 7, [[aRecord objectForKey:@"pcode"] UTF8String], -1, SQLITE_TRANSIENT);
    //"phone",@"wifi",@"idle",@"scale",@"service",@"wash",@"showers",@"secureparking",@"nightparkingonly",@"picture"
    sqlite3_bind_text(stmt, 8, [[aRecord objectForKey:@"phone"] UTF8String], -1, SQLITE_TRANSIENT);
    if ([[aRecord objectForKey:@"wifi"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 9, 1);
    }else {
        sqlite3_bind_int(stmt, 9, 0);
    }
    if ([[aRecord objectForKey:@"idle"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 10, 1);
    }else {
        sqlite3_bind_int(stmt, 10, 0);
    }
    if ([[aRecord objectForKey:@"scale"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 11, 1);
    }else {
        sqlite3_bind_int(stmt, 11, 0);
    }
    if ([[aRecord objectForKey:@"service"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 12, 1);
    }else {
        sqlite3_bind_int(stmt, 12, 0);
    }
    if ([[aRecord objectForKey:@"wash"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 13, 1);
    }else {
        sqlite3_bind_int(stmt, 13, 0);
    }
    sqlite3_bind_int(stmt, 14, [[aRecord objectForKey:@"showers"] intValue]);
    if ([[aRecord objectForKey:@"secureparking"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 15, 1);
    }else {
        sqlite3_bind_int(stmt, 15, 0);
    }
    if ([[aRecord objectForKey:@"nightparkingonly"] isEqualToString:@"true"]) {
        sqlite3_bind_int(stmt, 16, 1);
    }else {
        sqlite3_bind_int(stmt, 16, 0);
    }
    sqlite3_bind_text(stmt, 17, [[aRecord objectForKey:@"picture"] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 18, type_for_loading);
    
    
    //    NSLog(@"%@", aRecord);
    
    if ( SQLITE_DONE != sqlite3_step(stmt) ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
    }
    sqlite3_finalize(stmt);
}

#pragma mark retrieving procedures
- (NSArray *) searchPOIinRegion:(MKCoordinateRegion)region
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bTypeMask[truck_stop] = [userDefaults boolForKey:@"poi_display_truckstop"];
    bTypeMask[weighstation] = [userDefaults boolForKey:@"poi_display_weighstation"];
    bTypeMask[truck_dealer] = [userDefaults boolForKey:@"poi_display_truckdealer"];
    bTypeMask[truck_parking] = [userDefaults boolForKey:@"poi_display_truckparking"];
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    TTPOI *aPoi = nil;
    NSString *sql = nil;
    NSString *temp_str = nil;
    sqlite3_stmt *stmt = nil;
    double top = region.center.latitude + region.span.latitudeDelta;
    double bottom = region.center.latitude - region.span.latitudeDelta;
    double left = region.center.longitude - region.span.longitudeDelta;
    double right = region.center.longitude + region.span.longitudeDelta;
    
    if (bTypeMask[truck_stop]) {
        sql = @"SELECT * FROM TRUCKSTOP WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";        
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        sqlite3_bind_double(stmt, 1, bottom);
        sqlite3_bind_double(stmt, 2, top);
        sqlite3_bind_double(stmt, 3, left);
        sqlite3_bind_double(stmt, 4, right);
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_stop];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);      
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setNumber:temp_str];
            [aPoi setHasWifi:sqlite3_column_int(stmt, 9)];
            [aPoi setHasIdle:sqlite3_column_int(stmt, 10)];
            [aPoi setHasScale:sqlite3_column_int(stmt, 11)];
            [aPoi setHasService:sqlite3_column_int(stmt, 12)];
            [aPoi setHasWash:sqlite3_column_int(stmt, 13)];
            [aPoi setShowers:sqlite3_column_int(stmt, 14)];
            [aPoi setHasSecureparking:sqlite3_column_int(stmt, 15)];
            [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 16)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 17)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];            
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[weighstation]) {
        sql = @"SELECT * FROM WEIGHSTATION WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        sqlite3_bind_double(stmt, 1, bottom);
        sqlite3_bind_double(stmt, 2, top);
        sqlite3_bind_double(stmt, 3, left);
        sqlite3_bind_double(stmt, 4, right);
       // NAME, LAT, LON, CITY, STATE, POSTCODE
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:weighstation];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];            
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[truck_dealer]) {
        sql = @"SELECT * FROM TRUCKDEALER WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        sqlite3_bind_double(stmt, 1, bottom);
        sqlite3_bind_double(stmt, 2, top);
        sqlite3_bind_double(stmt, 3, left);
        sqlite3_bind_double(stmt, 4, right);
        //NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_dealer];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setNumber:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];            
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[truck_parking]) {
        sql = @"SELECT * FROM TRUCKPARKING WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        sqlite3_bind_double(stmt, 1, bottom);
        sqlite3_bind_double(stmt, 2, top);
        sqlite3_bind_double(stmt, 3, left);
        sqlite3_bind_double(stmt, 4, right);
        //NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_parking];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];
        }
        sqlite3_finalize(stmt);
    }
    
    return array;
}
- (NSArray *) searchPOIinRegion2:(MKCoordinateRegion)region
{
    /*    enum TTPOI_TYPE {
     truck_stop,9522
     weighstation,9710
     truck_dealer,9719
     truck_parking,9720-1
     Gas_Station,
     CAT_scale,0
     rest_area,9720-2
     all_poi
     };*/
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bTypeMask[truck_stop] = [userDefaults boolForKey:@"poi_display_truckstop"];
    bTypeMask[weighstation] = [userDefaults boolForKey:@"poi_display_weighstation"];
    bTypeMask[truck_dealer] = [userDefaults boolForKey:@"poi_display_truckdealer"];
    bTypeMask[truck_parking] = [userDefaults boolForKey:@"poi_display_truckparking"];
    bTypeMask[CAT_scale] = [userDefaults boolForKey:@"poi_display_catscale"];
    bTypeMask[rest_area] = [userDefaults boolForKey:@"poi_display_restarea"];
    bTypeMask[campgrounds] = [userDefaults boolForKey:@"poi_display_campgrounds"];
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    TTPOI *aPoi = nil;
    NSString *sql = nil;
    NSString *temp_str = nil;
    sqlite3_stmt *stmt = nil;
    double top = region.center.latitude + region.span.latitudeDelta;
    double bottom = region.center.latitude - region.span.latitudeDelta;
    double left = region.center.longitude - region.span.longitudeDelta;
    double right = region.center.longitude + region.span.longitudeDelta;
    
    sql = @"SELECT * FROM POI WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
    //sql = @"SELECT * FROM POI WHERE ";
    BOOL bAddType = NO;
    if (bTypeMask[truck_stop]) {
        bAddType = YES;
        temp_str = @" AND (TYPE = 0";
    }
    if (bTypeMask[weighstation]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 1"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 1";
        }
    }
    if (bTypeMask[truck_dealer]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 2"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 2";
        }
    }
    if (bTypeMask[truck_parking]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 3"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 3";
        }
    }
    if (bTypeMask[CAT_scale]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 5"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 5";
        }
    }
    if (bTypeMask[rest_area]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 6"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 6";
        }
    }
    if (bTypeMask[campgrounds]) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 7"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 7";
        }
    }
    if (bAddType) {
        temp_str = [temp_str stringByAppendingString:@")"];
        sql = [sql stringByAppendingString:temp_str];
    }
    
    if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
        return nil;
    }
    sqlite3_bind_double(stmt, 1, bottom);
    sqlite3_bind_double(stmt, 2, top);
    sqlite3_bind_double(stmt, 3, left);
    sqlite3_bind_double(stmt, 4, right);
    while ( sqlite3_step(stmt) == SQLITE_ROW) {
        aPoi = [[TTPOI alloc] init];
        [aPoi setType:sqlite3_column_int(stmt, 1)];
        [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)]autorelease];
        [aPoi setName:temp_str];
        CLLocationCoordinate2D coord;
        coord.latitude = sqlite3_column_double(stmt, 3);
        coord.longitude = sqlite3_column_double(stmt, 4);
        [aPoi setCoord:coord];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
        [aPoi setAddress:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
        [aPoi setCity:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
        [aPoi setState:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
        [aPoi setZipcode:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
        [aPoi setNumber:temp_str];
        [aPoi setHasWifi:sqlite3_column_int(stmt, 10)];
        [aPoi setHasIdle:sqlite3_column_int(stmt, 11)];
        [aPoi setHasScale:sqlite3_column_int(stmt, 12)];
        [aPoi setHasService:sqlite3_column_int(stmt, 13)];
        [aPoi setHasWash:sqlite3_column_int(stmt, 14)];
        [aPoi setShowers:sqlite3_column_int(stmt, 15)];
        [aPoi setHasSecureparking:sqlite3_column_int(stmt, 16)];
        [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 17)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 18)]autorelease];
        [aPoi setImage:temp_str];
        [array addObject:aPoi];
        [aPoi release];
    }
    sqlite3_finalize(stmt);
    
    return array;
}
- (NSArray *) searchPOIinRegion:(MKCoordinateRegion)region withCondition:(TTPOI *)poi_condition
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    TTPOI *aPoi = nil;
    NSString *temp_str = nil;
    NSString *sql = nil;
    sqlite3_stmt *stmt = nil;
    NSString *sql_region = nil;
    NSString *sql_name = nil;
    NSString *sql_address = nil;
    NSString *sql_city = nil;
    NSString *sql_state = nil;
    NSString *sql_zipcode = nil;
    NSString *sql_phone = nil;
    NSString *sql_wifi = nil;
    NSString *sql_idle = nil;
    NSString *sql_scale = nil;
    NSString *sql_service = nil;
    NSString *sql_wash = nil;
    NSString *sql_showers = nil;
    NSString *sql_secureparking = nil;
    NSString *sql_nightparkingonly = nil;
    //check if there is an region condition
    BOOL bRegion = NO;
    double top, bottom, left, right;    
    if (region.span.latitudeDelta) {
        bRegion = YES;
        top = region.center.latitude + region.span.latitudeDelta;
        bottom = region.center.latitude - region.span.latitudeDelta;
        left = region.center.longitude - region.span.longitudeDelta;
        right = region.center.longitude + region.span.longitudeDelta;
        sql_region = [NSString stringWithFormat:@"LAT > %f AND LAT < %f AND LON > %f AND LON < %f", bottom, top, left, right];
    }
    //check poi type
    bTypeMask[truck_stop] = bTypeMask[weighstation] = bTypeMask[truck_dealer] = bTypeMask[truck_parking] = FALSE;
    switch (poi_condition.type) {
        case truck_dealer:
            bTypeMask[truck_dealer] = TRUE;
            break;
            
        case truck_parking:
            bTypeMask[truck_parking] = TRUE;
            break;
            
        case truck_stop:
            bTypeMask[truck_stop] = TRUE;
            break;
            
        case weighstation:
            bTypeMask[weighstation] = TRUE;
            break;
            
        case all_poi:
            bTypeMask[truck_stop] = bTypeMask[weighstation] = bTypeMask[truck_dealer] = bTypeMask[truck_parking] = TRUE;
            break;
            
        default:
            break;
    }
    //check name
    if (poi_condition.name) {
        sql_name = [NSString stringWithFormat:@"NAME = '%@'", poi_condition.name];
    }
    //check address
    if (poi_condition.address) {
        sql_address = [NSString stringWithFormat:@"ADDRESS = '%@'", poi_condition.address];
    }
    //check city
    if (poi_condition.city) {
        sql_city = [NSString stringWithFormat:@"CITY = '%@'", poi_condition.city];
    }
    //check state
    if (poi_condition.state) {
        sql_state = [NSString stringWithFormat:@"STATE = '%@'", poi_condition.state];
    }
    //check zip code
    if (poi_condition.zipcode) {
        sql_zipcode = [NSString stringWithFormat:@"POSTCODE = '%@'", poi_condition.zipcode];
    }
    //check phone number
    if (poi_condition.number) {
        sql_phone = [NSString stringWithFormat:@"NUMBER = '%@'", poi_condition.number];
    }
    if (bTypeMask[truck_stop]) {
        if (poi_condition.hasWifi) {
            sql_wifi = @"WIFI = 1";
        }
        if (poi_condition.hasIdle) {
            sql_idle = @"IDLE = 1";
        }
        if (poi_condition.hasScale) {
            sql_scale = @"SCALE = 1";
        }
        if (poi_condition.hasService) {
            sql_service = @"SERVICE = 1";
        }
        if (poi_condition.hasWash) {
            sql_wash = @"WASH = 1";
        }
        if (poi_condition.showers > 0) {
            sql_showers = @"SHOWERS > 0";
        }
        if (poi_condition.hasSecureparking) {
            sql_secureparking = @"SECUREPARKING = 1";
        }
        if (poi_condition.isNightparkingonly) {
            sql_nightparkingonly = @"NIGHTPARKINGONLY = 1";
        }
    }
    
    //check 
//    sql = @"SELECT * FROM TRUCKDEALER WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
//    @"INSERT INTO TRUCKSTOP(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER, WIFI, IDLE, SCALE, SERVICE, WASH, SHOWERS, SECUREPARKING, NIGHTPARKINGONLY, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
    //start search
    if (bTypeMask[truck_stop]) {
        BOOL hasCondition = NO;
        sql = @"SELECT * FROM TRUCKSTOP WHERE";
        if (sql_region) {
            hasCondition = YES;
            sql = [sql stringByAppendingFormat:@" %@", sql_region];
        }
        if (sql_name) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_name];
        }
        if (sql_address) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_address];
        }
        if (sql_city) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_city];
        }
        if (sql_state) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_state];
        }
        if (sql_zipcode) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_zipcode];
        }
        if (sql_phone) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_phone];
        }
        if (sql_wifi) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_wifi];
        }
        if (sql_idle) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_idle];
        }
        if (sql_scale) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_scale];
        }
        if (sql_service) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_service];
        }
        if (sql_wash) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_wash];
        }
        if (sql_showers) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_showers];
        }
        if (sql_secureparking) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_secureparking];
        }
        if (sql_nightparkingonly) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_nightparkingonly];
        }
        
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_stop];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setNumber:temp_str];
            [aPoi setHasWifi:sqlite3_column_int(stmt, 9)];
            [aPoi setHasIdle:sqlite3_column_int(stmt, 10)];
            [aPoi setHasScale:sqlite3_column_int(stmt, 11)];
            [aPoi setHasService:sqlite3_column_int(stmt, 12)];
            [aPoi setHasWash:sqlite3_column_int(stmt, 13)];
            [aPoi setShowers:sqlite3_column_int(stmt, 14)];
            [aPoi setHasSecureparking:sqlite3_column_int(stmt, 15)];
            [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 16)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 17)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[weighstation]) {
        BOOL hasCondition = NO;
        sql = @"SELECT * FROM WEIGHSTATION WHERE";
        if (sql_region) {
            hasCondition = YES;
            sql = [sql stringByAppendingFormat:@" %@", sql_region];
        }
        if (sql_name) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_name];
        }
        if (sql_city) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_city];
        }
        if (sql_state) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_state];
        }
        if (sql_zipcode) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_zipcode];
        }    
        
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        // NAME, LAT, LON, CITY, STATE, POSTCODE
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:weighstation];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[truck_dealer]) {
        BOOL hasCondition = NO;
        sql = @"SELECT * FROM TRUCKDEALER WHERE";
        if (sql_region) {
            hasCondition = YES;
            sql = [sql stringByAppendingFormat:@" %@", sql_region];
        }
        if (sql_name) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_name];
        }
        if (sql_address) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_address];
        }
        if (sql_city) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_city];
        }
        if (sql_state) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_state];
        }
        if (sql_zipcode) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_zipcode];
        }
        if (sql_phone) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_phone];
        }
       
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        //NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_dealer];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setNumber:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];
        }
        sqlite3_finalize(stmt);
    }
    if (bTypeMask[truck_parking]) {
        BOOL hasCondition = NO;
        sql = @"SELECT * FROM TRUCKPARKING WHERE";
        if (sql_region) {
            hasCondition = YES;
            sql = [sql stringByAppendingFormat:@" %@", sql_region];
        }
        if (sql_name) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_name];
        }
        if (sql_address) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_address];
        }
        if (sql_city) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_city];
        }
        if (sql_state) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_state];
        }
        if (sql_zipcode) {
            if (hasCondition) {
                sql = [sql stringByAppendingString:@" AND"];
            }else {
                hasCondition = YES;
            }
            sql = [sql stringByAppendingFormat:@" %@", sql_zipcode];
        }
        
        if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
            sprintf(errMsg, "%s", sqlite3_errmsg(db));
            return nil;
        }
        //NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE
        while ( sqlite3_step(stmt) == SQLITE_ROW) {
            aPoi = [[[TTPOI alloc] init] autorelease];
            [aPoi setType:truck_parking];
            [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)]autorelease];
            [aPoi setName:temp_str];
            CLLocationCoordinate2D coord;
            coord.latitude = sqlite3_column_double(stmt, 2);
            coord.longitude = sqlite3_column_double(stmt, 3);
            [aPoi setCoord:coord];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)]autorelease];
            [aPoi setAddress:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
            [aPoi setCity:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
            [aPoi setState:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
            [aPoi setZipcode:temp_str];
            temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
            [aPoi setImage:temp_str];
            [array addObject:aPoi];
        }
        sqlite3_finalize(stmt);
    }
   
    return array;
}
- (NSArray *) searchPOIinRegion2:(MKCoordinateRegion)region withCondition:(TTPOI *)poi_condition
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    TTPOI *aPoi = nil;
    NSString *temp_str = nil;
    NSString *sql = nil;
    sqlite3_stmt *stmt = nil;
    NSString *sql_region = nil;
    NSString *sql_type = nil;
    NSString *sql_name = nil;
    NSString *sql_address = nil;
    NSString *sql_city = nil;
    NSString *sql_state = nil;
    NSString *sql_zipcode = nil;
    NSString *sql_phone = nil;
    NSString *sql_wifi = nil;
    NSString *sql_idle = nil;
    NSString *sql_scale = nil;
    NSString *sql_service = nil;
    NSString *sql_wash = nil;
    NSString *sql_showers = nil;
    //check if there is an region condition
    BOOL bRegion = NO;
    double top, bottom, left, right;
    if (region.span.latitudeDelta) {
        bRegion = YES;
        top = region.center.latitude + region.span.latitudeDelta;
        bottom = region.center.latitude - region.span.latitudeDelta;
        left = region.center.longitude - region.span.longitudeDelta;
        right = region.center.longitude + region.span.longitudeDelta;
        sql_region = [NSString stringWithFormat:@"LAT > %f AND LAT < %f AND LON > %f AND LON < %f", bottom, top, left, right];
    }
    //check poi type
    if (poi_condition.type != all_poi) {
        sql_type = [NSString stringWithFormat:@"TYPE = %d", poi_condition.type];
    }
    //check name
    if (poi_condition.name) {
        sql_name = [NSString stringWithFormat:@"NAME LIKE '%%%@%%'", poi_condition.name];
    }
    //check address
    if (poi_condition.address) {
        sql_address = [NSString stringWithFormat:@"ADDRESS = '%@'", poi_condition.address];
    }
    //check city
    if (poi_condition.city) {
        sql_city = [NSString stringWithFormat:@"CITY = '%@'", poi_condition.city];
    }
    //check state
    if (poi_condition.state) {
        sql_state = [NSString stringWithFormat:@"STATE = '%@'", poi_condition.state];
    }
    //check zip code
    if (poi_condition.zipcode) {
        sql_zipcode = [NSString stringWithFormat:@"POSTCODE = '%@'", poi_condition.zipcode];
    }
    //check phone number
    if (poi_condition.number) {
        sql_phone = [NSString stringWithFormat:@"NUMBER = '%@'", poi_condition.number];
    }
    if (poi_condition.type == truck_stop) {
        if (poi_condition.hasWifi) {
            sql_wifi = @"WIFI = 1";
        }
        if (poi_condition.hasIdle) {
            sql_idle = @"IDLE = 1";
        }
        if (poi_condition.hasScale) {
            sql_scale = @"SCALE = 1";
        }
        if (poi_condition.hasService) {
            sql_service = @"SERVICE = 1";
        }
        if (poi_condition.hasWash) {
            sql_wash = @"WASH = 1";
        }
        if (poi_condition.showers > 0) {
            sql_showers = @"SHOWERS > 0";
        }
    }
    
    //check
    //    sql = @"SELECT * FROM TRUCKDEALER WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
    //    @"INSERT INTO TRUCKSTOP(NAME, LAT, LON, ADDRESS, CITY, STATE, POSTCODE, NUMBER, WIFI, IDLE, SCALE, SERVICE, WASH, SHOWERS, SECUREPARKING, NIGHTPARKINGONLY, IMAGE) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    //start search
    BOOL hasCondition = NO;
    sql = @"SELECT * FROM POI WHERE";
    if (sql_region) {
        hasCondition = YES;
        sql = [sql stringByAppendingFormat:@" %@", sql_region];
    }
    if (sql_type) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_type];
    }
    if (sql_name) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_name];
    }
    if (sql_address) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_address];
    }
    if (sql_city) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_city];
    }
    if (sql_state) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_state];
    }
    if (sql_zipcode) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_zipcode];
    }
    if (sql_phone) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_phone];
    }
    if (sql_wifi) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_wifi];
    }
    if (sql_idle) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_idle];
    }
    if (sql_scale) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_scale];
    }
    if (sql_service) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_service];
    }
    if (sql_wash) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_wash];
    }
    if (sql_showers) {
        if (hasCondition) {
            sql = [sql stringByAppendingString:@" AND"];
        }else {
            hasCondition = YES;
        }
        sql = [sql stringByAppendingFormat:@" %@", sql_showers];
    }
                
    if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
        return nil;
    }
    while ( sqlite3_step(stmt) == SQLITE_ROW) {
        aPoi = [[[TTPOI alloc] init] autorelease];
        [aPoi setType:sqlite3_column_int(stmt, 1)];
        [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)]autorelease];
        [aPoi setName:temp_str];
        CLLocationCoordinate2D coord;
        coord.latitude = sqlite3_column_double(stmt, 3);
        coord.longitude = sqlite3_column_double(stmt, 4);
        [aPoi setCoord:coord];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
        [aPoi setAddress:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
        [aPoi setCity:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
        [aPoi setState:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
        [aPoi setZipcode:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
        [aPoi setNumber:temp_str];
        [aPoi setHasWifi:sqlite3_column_int(stmt, 10)];
        [aPoi setHasIdle:sqlite3_column_int(stmt, 11)];
        [aPoi setHasScale:sqlite3_column_int(stmt, 12)];
        [aPoi setHasService:sqlite3_column_int(stmt, 13)];
        [aPoi setHasWash:sqlite3_column_int(stmt, 14)];
        [aPoi setShowers:sqlite3_column_int(stmt, 15)];
        [aPoi setHasSecureparking:sqlite3_column_int(stmt, 16)];
        [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 17)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 18)]autorelease];
        [aPoi setImage:temp_str];
        [array addObject:aPoi];
    }
    sqlite3_finalize(stmt);
    
    return array;
}


//DEBUG
- (void)displayAll
{
    int count = 0;
    TTPOI *aPoi = nil;
    NSString *temp_str = nil;
    NSString *sql = @"SELECT * FROM POI";
    sqlite3_stmt *stmt = nil;
    if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
    }
    while ( sqlite3_step(stmt) == SQLITE_ROW) {
        aPoi = [[[TTPOI alloc] init] autorelease];
        [aPoi setType:sqlite3_column_int(stmt, 1)];
        [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)]autorelease];
        [aPoi setName:temp_str];
        CLLocationCoordinate2D coord;
        coord.latitude = sqlite3_column_double(stmt, 3);
        coord.longitude = sqlite3_column_double(stmt, 4);
        [aPoi setCoord:coord];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
        [aPoi setAddress:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
        [aPoi setCity:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
        [aPoi setState:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
        [aPoi setZipcode:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
        [aPoi setNumber:temp_str];
        [aPoi setHasWifi:sqlite3_column_int(stmt, 10)];
        [aPoi setHasIdle:sqlite3_column_int(stmt, 11)];
        [aPoi setHasScale:sqlite3_column_int(stmt, 12)];
        [aPoi setHasService:sqlite3_column_int(stmt, 13)];
        [aPoi setHasWash:sqlite3_column_int(stmt, 14)];
        [aPoi setShowers:sqlite3_column_int(stmt, 15)];
        [aPoi setHasSecureparking:sqlite3_column_int(stmt, 16)];
        [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 17)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 18)]autorelease];
        [aPoi setImage:temp_str];
        count++;
        NSLog(@"ID %d, Type %d, Name: %@, Coord %.1f, %.1f; Address: %@, City: %@, State: %@, Zipcode: %@, Phone: %@, Wifi %d, Idle %d, Scale %d, Service %d, Wash %d, Showers %d, SecureP %d, NightPOnly %d, Img: %@", aPoi.identifier, aPoi.type, aPoi.name, aPoi.coord.latitude, aPoi.coord.longitude, aPoi.address, aPoi.city, aPoi.state, aPoi.zipcode, aPoi.number, aPoi.hasWifi, aPoi.hasIdle, aPoi.hasScale, aPoi.hasService, aPoi.hasWash, aPoi.showers, aPoi.hasSecureparking, aPoi.isNightparkingonly, aPoi.image);
    }
    sqlite3_finalize(stmt);
    
    NSLog(@"count: %d",count);
}
-(NSArray *)getWeightStationByRegion:(MKCoordinateRegion)region
{
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    TTPOI *aPoi = nil;
    NSString *sql = nil;
    NSString *temp_str = nil;
    sqlite3_stmt *stmt = nil;
    double top = region.center.latitude + region.span.latitudeDelta;
    double bottom = region.center.latitude - region.span.latitudeDelta;
    double left = region.center.longitude - region.span.longitudeDelta;
    double right = region.center.longitude + region.span.longitudeDelta;
    NSLog(@"Top : %f",top);
    
    sql = @"SELECT * FROM POI WHERE LAT > ? AND LAT < ? AND LON > ? AND LON < ?";
    BOOL bAddType = NO;
    if (NO) {
        bAddType = YES;
        temp_str = @" AND (TYPE = 0";
    }
    if (YES) {
        if (bAddType) {
            temp_str = [temp_str stringByAppendingString:@" OR TYPE = 1"];
        }else {
            bAddType = YES;
            temp_str = @" AND (TYPE = 1";
        }
    }
    if (bAddType) {
        temp_str = [temp_str stringByAppendingString:@")"];
        sql = [sql stringByAppendingString:temp_str];
    }
    
    if ( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK ) {
        sprintf(errMsg, "%s", sqlite3_errmsg(db));
        return nil;
    }
    sqlite3_bind_double(stmt, 1, bottom);
    sqlite3_bind_double(stmt, 2, top);
    sqlite3_bind_double(stmt, 3, left);
    sqlite3_bind_double(stmt, 4, right);
    while ( sqlite3_step(stmt) == SQLITE_ROW) {
        aPoi = [[[TTPOI alloc] init] autorelease];
        [aPoi setType:sqlite3_column_int(stmt, 1)];
        [aPoi setIdentifier:sqlite3_column_int(stmt, 0)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)]autorelease];
        [aPoi setName:temp_str];
        CLLocationCoordinate2D coord;
        coord.latitude = sqlite3_column_double(stmt, 3);
        coord.longitude = sqlite3_column_double(stmt, 4);
        [aPoi setCoord:coord];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)]autorelease];
        [aPoi setAddress:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 6)]autorelease];
        [aPoi setCity:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 7)]autorelease];
        [aPoi setState:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 8)]autorelease];
        [aPoi setZipcode:temp_str];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 9)]autorelease];
        [aPoi setNumber:temp_str];
        [aPoi setHasWifi:sqlite3_column_int(stmt, 10)];
        [aPoi setHasIdle:sqlite3_column_int(stmt, 11)];
        [aPoi setHasScale:sqlite3_column_int(stmt, 12)];
        [aPoi setHasService:sqlite3_column_int(stmt, 13)];
        [aPoi setHasWash:sqlite3_column_int(stmt, 14)];
        [aPoi setShowers:sqlite3_column_int(stmt, 15)];
        [aPoi setHasSecureparking:sqlite3_column_int(stmt, 16)];
        [aPoi setIsNightparkingonly:sqlite3_column_int(stmt, 17)];
        temp_str = [[[NSString alloc]initWithUTF8String:(const char*)sqlite3_column_text(stmt, 18)]autorelease];
        [aPoi setImage:temp_str];
        [array addObject:aPoi];
    }
    sqlite3_finalize(stmt);
    
    return array;

}



@end