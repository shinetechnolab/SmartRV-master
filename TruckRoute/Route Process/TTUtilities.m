#import "TTUtilities.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "TTDefinition.h"

@implementation TTUtilities

-(BOOL)distanceBetweenCoordinate:(CLLocationCoordinate2D)aCoordinate andSegmentFromCoordinate:(CLLocationCoordinate2D)segStartCoordinate segmentToCoordinate:(CLLocationCoordinate2D)segEndCoordinate returnCoordinate:(CLLocationCoordinate2D *)returnCoordinate distanceInDegrees:(double *)distance
{
    double seg_length = hypot(segStartCoordinate.longitude - segEndCoordinate.longitude, segStartCoordinate.latitude - segEndCoordinate.latitude);
    if(0 == seg_length)
    {
        returnCoordinate->latitude = segStartCoordinate.latitude;
        returnCoordinate->longitude = segStartCoordinate.longitude;
        *distance = hypot(segStartCoordinate.longitude - aCoordinate.longitude, segStartCoordinate.latitude - aCoordinate.latitude);
    }else {
        double U = (((aCoordinate.longitude - segStartCoordinate.longitude)*(segEndCoordinate.longitude - segStartCoordinate.longitude)) + ((aCoordinate.latitude - segStartCoordinate.latitude)*(segEndCoordinate.latitude - segStartCoordinate.latitude)))/(seg_length * seg_length);
        if(U < 0 || U > 1)
        {
            double l1 = hypot(segStartCoordinate.longitude - aCoordinate.longitude, segStartCoordinate.latitude - aCoordinate.latitude);
            double l2 = hypot(segEndCoordinate.longitude - aCoordinate.longitude, segEndCoordinate.latitude - aCoordinate.latitude);
            if(l1>l2)
            {
                returnCoordinate->latitude = segEndCoordinate.latitude;
                returnCoordinate->longitude = segEndCoordinate.longitude;
                *distance = l2;
            }else {
                returnCoordinate->latitude = segStartCoordinate.latitude;
                returnCoordinate->longitude = segStartCoordinate.longitude;
                *distance = l1;
            }
        }else {
            returnCoordinate->longitude = segStartCoordinate.longitude + U * (segEndCoordinate.longitude - segStartCoordinate.longitude);
            returnCoordinate->latitude = segStartCoordinate.latitude + U *(segEndCoordinate.latitude - segStartCoordinate.latitude);
            *distance = hypot(aCoordinate.longitude - returnCoordinate->longitude, aCoordinate.latitude - returnCoordinate->latitude);
        }
    }
    return YES;
}

//calculate distance (in meters) between 2 locations
-(double)distanceFromCoordinate:(CLLocationCoordinate2D)aCoordinate toCoordinate:(CLLocationCoordinate2D)anotherCoordinate
{
    CLLocation *loc_a = [[CLLocation alloc]initWithLatitude:aCoordinate.latitude longitude:aCoordinate.longitude];
    CLLocation *loc_b = [[CLLocation alloc]initWithLatitude:anotherCoordinate.latitude longitude:anotherCoordinate.longitude];
    double dist = [loc_a distanceFromLocation:loc_b];
    [loc_a release];
    [loc_b release];
    return dist;
}

//in degrees
-(double)headingFromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate
{
    if(toCoordinate.latitude == fromCoordinate.latitude && toCoordinate.longitude == fromCoordinate.longitude)
        return -1;//same coordinate
    
    CLLocation *NorthPoint = [[CLLocation alloc]initWithLatitude:toCoordinate.latitude longitude:fromCoordinate.longitude];
    CLLocation *loc_from = [[CLLocation alloc]initWithLatitude:fromCoordinate.latitude longitude:fromCoordinate.longitude];
    CLLocation *loc_to = [[CLLocation alloc]initWithLatitude:toCoordinate.latitude longitude:toCoordinate.longitude];
    double l = [loc_from distanceFromLocation:loc_to];
    double from_np = [loc_from distanceFromLocation:NorthPoint];
    
    //get absolute degree
    double degree = RADIANS_TO_DEGREES(acos(from_np/l));
    [NorthPoint release];
    [loc_from release];
    [loc_to release];
    
    //adjust degree
    double deltaLon = toCoordinate.longitude - fromCoordinate.longitude;
    if(deltaLon < -180)
        deltaLon += 360;
    else if(deltaLon > 180)
        deltaLon -= 360;
    double deltaLat = toCoordinate.latitude - fromCoordinate.latitude;

    if(deltaLon >= 0 && deltaLat >=0)
    {
        //0 to 90
        //no change
    }else if(deltaLon >=0 && deltaLat < 0)
    {
        //90 to 180
        degree = 180 - degree;
    }else if(deltaLon < 0 && deltaLat < 0)
    {
        //180 to 270
        degree += 180;
    }else {
        //270 to 360
        degree = 360 - degree;
    }
    
    return degree;
}
#pragma mark odometer
+(void)initStatePolygons
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //fast check
    if ([userDefaults objectForKey:@"US_MA_bound"]) {
        return;
    }
    NSArray *state_array = [[NSArray alloc]initWithObjects:@"US_AL", @"US_AK", @"US_AZ", @"US_AR", @"US_CA", @"US_CO", @"US_CT", @"US_DE", @"US_DC", @"US_FL", @"US_GA", @"US_HI", @"US_ID", @"US_IL", @"US_IN", @"US_IA", @"US_KS", @"US_KY", @"US_LA", @"US_ME", @"US_MD", @"US_MA", @"US_MI", @"US_MN", @"US_MS", @"US_MO", @"US_MT", @"US_NE", @"US_NV", @"US_NH", @"US_NJ", @"US_NM", @"US_NY", @"US_NC", @"US_ND", @"US_OH", @"US_OK", @"US_OR", @"US_PA", @"US_RI", @"US_SC", @"US_SD", @"US_TN", @"US_TX", @"US_UT", @"US_VT", @"US_VA", @"US_WA", @"US_WV", @"US_WI", @"US_WY", @"CA_AB", @"CA_BC", @"CA_MB", @"CA_NB", @"CA_NL", @"CA_NT", @"CA_NS", @"CA_NU", @"CA_ON", @"CA_PE", @"CA_QC", @"CA_SK", @"CA_YT", nil];
    //developing mode - read data from us_state.csv to fill the polygon
    for (int i=0; i<state_array.count; i++) {
        //open file name.csv
        NSString *name = [state_array objectAtIndex:i];
        NSString *filename = [NSString stringWithFormat:@"%@.csv", name];
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultPath];
        if (fileHandle) {
            NSString *temp_str = nil;
            NSString *key = nil;
            NSData *data = [fileHandle readDataToEndOfFile];
            
            NSString *string = [[[NSString alloc]initWithData:data  encoding:NSUTF8StringEncoding] autorelease];
            //                NSString *string = [[NSString alloc]initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            NSArray *array = [string componentsSeparatedByString:@","];
            {
                MKMapRect rect = MKMapRectNull;
                for (int j = 0; j<array.count; j+=2) {
                    MKMapRect pointRect = MKMapRectMake([[array objectAtIndex:j+1]doubleValue], [[array objectAtIndex:j]doubleValue], 0, 0);
                    rect = MKMapRectUnion(rect, pointRect);
                }
                temp_str = [NSString stringWithFormat:@"%.4f,%.4f,%.4f,%.4f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];//left,bottom,width,height
                key = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:i]];
                [userDefaults removeObjectForKey:key];
                [userDefaults setObject:temp_str forKey:key];
            }
            [userDefaults removeObjectForKey:[state_array objectAtIndex:i]];
            [userDefaults setObject:array forKey:[state_array objectAtIndex:i]];
            NSLog(@"+++++ adding polygon: %@ is done! %@: %@", [state_array objectAtIndex:i], key, temp_str);
            [fileHandle closeFile];
        }else {
            NSLog(@"missing state csv file: %@", filename);
        }
    }
#ifdef DEBUG
    //check the bounds
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc]init]autorelease];
    for (int i=0; i<state_array.count; i++) {
        NSString *temp_str = nil;
        NSString *key = nil;
        key = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:i]];
        temp_str = [userDefaults objectForKey:key];
        [dic setObject:temp_str forKey:key];
        NSLog(@"+++++ checking bounds: %@ %@", key, temp_str);
    }
    //save dictionary to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[[NSFileManager alloc]init]autorelease];
    NSError *err;
    [fileManager createDirectoryAtPath:docDirectory withIntermediateDirectories:NO attributes:nil error:&err];    
    NSString *path = [docDirectory stringByAppendingPathComponent:@"state_bounds.data"];    
    if([fileManager createFileAtPath:path contents:(NSData*)dic attributes:nil])
    {
//        int correct = 3;
    }
#endif
}
-(NSArray *)preparePolygon:(NSString*)name
{
    NSArray *array = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *filename = [NSString stringWithFormat:@"%@.csv", name];
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultPath];
    if (fileHandle) {
        NSData *data = [fileHandle readDataToEndOfFile];        
        NSString *string = [[NSString alloc]initWithData:data  encoding:NSUTF8StringEncoding];
        array = [string componentsSeparatedByString:@","];
        [userDefaults removeObjectForKey:name];
        [userDefaults setObject:array forKey:name];
        NSLog(@"+++++ adding polygon: %@ is done!", name);
        [fileHandle closeFile];
    }else {
        NSLog(@"missing state csv file: %@", filename);
    }
    return array;
}
-(NSString *)getStateWithCoord:(CLLocationCoordinate2D)coord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    static int index = 0;
    static NSArray *state_array = nil;
    if (!state_array) {
        state_array = [[NSArray alloc]initWithObjects:@"US_AL", @"US_AK", @"US_AZ", @"US_AR", @"US_CA", @"US_CO", @"US_CT", @"US_DE", @"US_DC", @"US_FL", @"US_GA", @"US_HI", @"US_ID", @"US_IL", @"US_IN", @"US_IA", @"US_KS", @"US_KY", @"US_LA", @"US_ME", @"US_MD", @"US_MA", @"US_MI", @"US_MN", @"US_MS", @"US_MO", @"US_MT", @"US_NE", @"US_NV", @"US_NH", @"US_NJ", @"US_NM", @"US_NY", @"US_NC", @"US_ND", @"US_OH", @"US_OK", @"US_OR", @"US_PA", @"US_RI", @"US_SC", @"US_SD", @"US_TN", @"US_TX", @"US_UT", @"US_VT", @"US_VA", @"US_WA", @"US_WV", @"US_WI", @"US_WY", @"CA_AB", @"CA_BC", @"CA_MB", @"CA_NB", @"CA_NL", @"CA_NT", @"CA_NS", @"CA_NU", @"CA_ON", @"CA_PE", @"CA_QC", @"CA_SK", @"CA_YT", nil];
    }
    //check last polygon first
    NSArray *polygon = [userDefaults arrayForKey:[state_array objectAtIndex:index]];//polygon array: lat0,lon0,lat1,lon1,.
    if (nil == polygon) {
        //first time running, add the current state polyon
        polygon = [self preparePolygon:[state_array objectAtIndex:index]];
#ifdef DEBUG
        //developing mode - read data from us_state.csv to fill the polygon
/*        for (int i=0; i<state_array.count; i++) {
            //open file name.csv
            NSString *name = [state_array objectAtIndex:i];
            NSString *filename = [NSString stringWithFormat:@"%@.csv", name];
            NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultPath];
            if (fileHandle) {
                NSString *temp_str = nil;
                NSString *key = nil;
                NSData *data = [fileHandle readDataToEndOfFile];

                NSString *string = [[NSString alloc]initWithData:data  encoding:NSUTF8StringEncoding];
//                NSString *string = [[NSString alloc]initWithData:data encoding:NSNonLossyASCIIStringEncoding];
                NSArray *array = [string componentsSeparatedByString:@","];
                {
                    MKMapRect rect = MKMapRectNull;
                    for (int j = 0; j<array.count; j+=2) {
                        MKMapRect pointRect = MKMapRectMake([[array objectAtIndex:j+1]doubleValue], [[array objectAtIndex:j]doubleValue], 0, 0);
                        rect = MKMapRectUnion(rect, pointRect);
                    }
                    temp_str = [NSString stringWithFormat:@"%.4f,%.4f,%.4f,%.4f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];//left,bottom,width,height
                    key = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:i]];
                    [userDefaults removeObjectForKey:key];
                    [userDefaults setObject:temp_str forKey:key];
                }
                [userDefaults removeObjectForKey:[state_array objectAtIndex:i]];
                [userDefaults setObject:array forKey:[state_array objectAtIndex:i]];
                NSLog(@"+++++ adding polygon: %@ is done! %@: %@", [state_array objectAtIndex:i], key, temp_str);
                [fileHandle closeFile];
            }else {
                NSLog(@"missing state csv file: %@", filename);
            }
        }
        //check the bounds
        for (int i=0; i<state_array.count; i++) {
            NSString *temp_str = nil;
            NSString *key = nil;
            key = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:i]];
            temp_str = [userDefaults objectForKey:key];
            NSLog(@"+++++ checking bounds: %@ %@", key, temp_str);
        }

        return @"UNKNOWN_STATE";*/
#endif
    }
    
#ifdef DEBUG
/*    NSString *key1 = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:random()%state_array.count]];
    NSString *bound1 = [userDefaults objectForKey:key1];
    NSArray *buf_array1 = [bound1 componentsSeparatedByString:@","];
    MKMapRect rect1 = MKMapRectMake([[buf_array1 objectAtIndex:0]doubleValue], [[buf_array1 objectAtIndex:1]doubleValue], [[buf_array1 objectAtIndex:2]doubleValue], [[buf_array1 objectAtIndex:3]doubleValue]);
    coord = CLLocationCoordinate2DMake(rect1.origin.y + rect1.size.height/2, rect1.origin.x + rect1.size.width/2);*/
#endif    
    
    if ([self isCoord:coord inPolygon:polygon]) {
        return [state_array objectAtIndex:index];
    }else {
        for (int i = 0; i<state_array.count; i++) {            
            //check bound first
            NSString *key = [NSString stringWithFormat:@"%@_bound", [state_array objectAtIndex:i]];
            NSString *bound = [userDefaults objectForKey:key];
            NSArray *buf_array = [bound componentsSeparatedByString:@","];
            MKMapRect rect = MKMapRectMake([[buf_array objectAtIndex:0]doubleValue], [[buf_array objectAtIndex:1]doubleValue], [[buf_array objectAtIndex:2]doubleValue], [[buf_array objectAtIndex:3]doubleValue]);
            MKMapPoint pt = MKMapPointMake(coord.longitude, coord.latitude);
                //MKMapRect::origin is actuall the left-bottom coord of the rect
                //so here the MKMAPRECTCONTAINSPOINT not working
//                if ( MKMapRectContainsPoint(rect, pt) ) {
            
            if (pt.x > rect.origin.x && pt.x < rect.origin.x + rect.size.width && pt.y > rect.origin.y && pt.y < rect.origin.y + rect.size.height) {
                polygon = [userDefaults arrayForKey:[state_array objectAtIndex:i]];
                if (nil == polygon) {
                    polygon = [self preparePolygon:[state_array objectAtIndex:i]];
                }
                if ([self isCoord:coord inPolygon:polygon]) {
                    index = i;
                    return [state_array objectAtIndex:index];
                }
            }            
        }
    }
    return @"UNKNOWN_STATE";
}
-(BOOL)isCoord:(CLLocationCoordinate2D)coord inPolygon:(NSArray *)polygon
{//polygon array: lat0,lon0,lat1,lon1,...
#ifdef DEBUG
    int count = 0;
#endif
    BOOL bRet = NO;
    double x_i, y_i, x_j, y_j;
    for (int i=0, j=polygon.count-2; i<polygon.count; j=i, i+=2) {
        x_i = [[polygon objectAtIndex:i+1]doubleValue];
        y_i = [[polygon objectAtIndex:i]doubleValue];
        x_j = [[polygon objectAtIndex:j+1]doubleValue];
        y_j = [[polygon objectAtIndex:j]doubleValue];
        if ( ( (y_i > coord.latitude) != (y_j > coord.latitude) ) && ( coord.longitude < (x_j - x_i)*(coord.latitude - y_i)/(y_j - y_i)+ x_i ) ) {
            bRet = !bRet;
#ifdef DEBUG
            count++;
            if (count > 10) {
                int wrong = 3;
            }
#endif
        }
    }
#ifdef DEBUG
//    NSLog(@"count: %d", count);
#endif
    return bRet;
}
+(NSString *)generateFakeUUID
{
    //32 digits UUID
    NSMutableString *UUID = [[[NSMutableString alloc]init]autorelease];
    while ([UUID length]<32) {
        char c = ((arc4random() % (26)) + 97);
        [UUID appendFormat:@"%c", c];
    }
    NSLog(@"generated new UUID: %@", UUID);
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"Fake_UUID"];
    [userDefault setObject:UUID forKey:@"Fake_UUID"];
    
    return UUID;
}
+(NSString *)getFakeUUID
{
    NSString *UUID = nil;    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    UUID = [userDefault objectForKey:@"Fake_UUID"];
    if (!UUID) {
        UUID = [self generateFakeUUID];
    }
    return UUID;
}

+(NSString *)getSerialNumberString
{
    KeychainItemWrapper *saveValue= [[KeychainItemWrapper alloc] initWithIdentifier:@"Credit" accessGroup:nil];
    NSString *smsCredits=[saveValue objectForKey:(__bridge id)kSecAttrService];
    //int newCredit=[smsCredits intValue] +SmsCount;
    
    //hash to 32 digits UUID
    if (NSClassFromString(@"ASIdentifierManager") && ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
    {
        if (smsCredits.length > 10) {
            return smsCredits;
        }
        else{
            NSString *UUID =[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            UUID = [UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [saveValue setObject:UUID forKey: (__bridge id)kSecAttrService];
            return UUID;
        }
    }
    else
    {
        if (smsCredits.length > 10) {
            return smsCredits;
        }
        else{
            NSString *UUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
            UUID = [UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [saveValue setObject:UUID forKey: (__bridge id)kSecAttrService];
            return UUID;
        }
    }
}

- (BOOL)isAdvertisingTrackingEnabled
{
    if (NSClassFromString(@"ASIdentifierManager") && ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return NO;
    }
    return YES;
}
//abbreviations
+(NSString *)getAbbreviation:(NSString *)state
{
    static NSDictionary *dic = nil;//allocate once and never release till app quits
    if (nil == dic) {
        dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"AL", @"Alabama", @"AK", @"Alaska", @"AZ", @"Arizona", @"AR", @"Arkansas", @"CA", @"California", @"CO", @"Colorado", @"CT", @"Connecticut", @"DE", @"Delaware", @"DC", @"District of Columbia", @"FL", @"Florida", @"GA", @"Georgia", @"HI", @"Hawaii", @"ID", @"Idaho", @"IL", @"Illinois", @"IN", @"Indiana", @"IA", @"Iowa", @"KS", @"Kansas", @"KY", @"Kentucky", @"LA", @"Louisiana", @"ME", @"Maine", @"MD", @"Maryland", @"MA", @"Massachusetts", @"MI", @"Michigan", @"MN", @"Minnesota", @"MS", @"Mississippi", @"MO", @"Missouri", @"MT", @"Montana", @"NE", @"Nebraska", @"NV", @"Nevada", @"NH", @"New Hampshire", @"NJ", @"New Jersey", @"NM", @"New Mexico", @"NY", @"New York", @"NC", @"North Carolina", @"ND", @"North Dakota", @"OH", @"Ohio", @"OK", @"Oklahoma", @"OR", @"Oregon", @"PA", @"Pennsylvania", @"RI", @"Rhode Island", @"SC", @"South Carolina", @"SD", @"South Dakota", @"TN", @"Tennessee", @"TX", @"Texas", @"UT", @"Utah", @"VT", @"Vermont", @"VA", @"Virginia", @"WA", @"Washington", @"WV", @"West Virginia", @"WI", @"Wisconsin", @"WY", @"Wyoming", @"AB", @"Alberta", @"BC", @"British Columbia", @"MB", @"Manitoba", @"NB", @"New Brunswick", @"NL", @"Newfoundland and Labrador", @"NT", @"Northwest Territories", @"NS", @"Nova Scotia", @"NU", @"Nunavut", @"ON", @"Ontario", @"PE", @"Prince Edward Island", @"QC", @"Quebec", @"SK", @"Saskatchewan", @"YT", @"Yukon", nil];
    }
    NSString *str = [dic objectForKey:state];
    if (str) {
        return str;
    }else {
        return state;//if failed
    }
}

+(NSString *)getStateName:(NSString *)abbreviatedString
{
    static NSDictionary *dic = nil;//allocate once and never release till app quits
    if (nil == dic) {
        dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"Alabama",@"AL", @"Alaska",@"AK", @"Arizona",@"AZ", @"Arkansas",@"AR", @"California",@"CA", @"Colorado",@"CO", @"Connecticut",@"CT", @"Delaware",@"DE", @"District of Columbia",@"DC", @"Florida",@"FL",  @"Georgia",@"GA", @"Hawaii",@"HI", @"Idaho",@"ID", @"Illinois",@"IL", @"Indiana",@"IN", @"Iowa",@"IA", @"Kansas",@"KS", @"Kentucky",@"KY", @"Louisiana",@"LA", @"Maine",@"ME", @"Maryland",@"MD", @"Massachusetts",@"MA", @"Michigan",@"MI", @"Minnesota",@"MN", @"Mississippi",@"MS", @"Missouri",@"MO", @"Montana",@"MT", @"Nebraska",@"NE", @"Nevada",@"NV", @"New Hampshire",@"NH", @"New Jersey",@"NJ", @"New Mexico",@"NM", @"New York",@"NY", @"North Carolina",@"NC", @"North Dakota",@"ND", @"Ohio",@"OH", @"Oklahoma",@"OK", @"Oregon",@"OR", @"Pennsylvania",@"PA", @"Rhode Island",@"RI", @"South Carolina",@"SC", @"South Dakota",@"SD", @"Tennessee",@"TN", @"Texas",@"TX", @"Utah",@"UT", @"Vermont",@"VT", @"Virginia",@"VA", @"Washington",@"WA", @"West Virginia",@"WV", @"Wisconsin",@"WI", @"Wyoming",@"WY", @"Alberta",@"AB", @"British Columbia",@"BC", @"Manitoba",@"MB", @"New Brunswick",@"NB", @"Newfoundland and Labrador",@"NL", @"Northwest Territories",@"NT", @"Nova Scotia",@"NS", @"Nunavut",@"NU", @"Ontario",@"ON", @"Prince Edward Island",@"PE", @"Quebec",@"QC", @"Saskatchewan",@"SK", @"Yukon",@"YT", nil];
    }
    NSString *str = [dic objectForKey:abbreviatedString];
    if (str) {
        return str;
    }else {
        return abbreviatedString;//if failed
    }
}


//process phone number
+(NSString *)processPhoneNumber:(NSString *)number
{
    NSString *new_number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    new_number = [new_number stringByReplacingOccurrencesOfString:@"+" withString:@""];
    new_number = [new_number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    new_number = [new_number stringByReplacingOccurrencesOfString:@")" withString:@""];
    int length = [new_number length];
    if (length > 11) {
        new_number = [NSString stringWithFormat:@"     +%@", new_number];
    }else {
        NSRange range1, range2, range3, range4;
        if (length == 11) {//+1(888)777-8765
            range1.location = 0;
            range1.length = 1;
            range2.location = 1;
            range2.length = 3;
            range3.location = 4;
            range3.length = 3;
            range4.location = 7;
            range4.length = 4;
            new_number = [NSString stringWithFormat:@"     +%@(%@) %@-%@", [new_number substringWithRange:range1], [new_number substringWithRange:range2], [new_number substringWithRange:range3], [new_number substringWithRange:range4]];
        }else if (length == 10) {//(888)777-9999
            range1.location = 0;
            range1.length = 3;
            range2.location = 3;
            range2.length = 3;
            range3.location = 6;
            range3.length = 4;
            new_number = [NSString stringWithFormat:@"     (%@) %@-%@", [new_number substringWithRange:range1], [new_number substringWithRange:range2], [new_number substringWithRange:range3]];
        }
        //else do nothing
    }
    return new_number;
}
@end