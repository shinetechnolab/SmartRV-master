//temporarily use MACRO/enum to define all configurations
//ttconfig.h

/////////////////////////////////////////////////
//first time running default values
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define isIpad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define DEFAULT_SETTINGS_VOICE          YES
#define DEFAULT_SETTINGS_AUTOZOOM       NO
#define DEFAULT_SETTINGS_AUTOREROUTE    YES
#define DEFAULT_SETTINGS_MAPMODE        0//STANDARD
#define DEFAULT_SETTINGS_UNIT_METRIC    NO//ENGLISH
#define DEFAULT_SETTINGS_TIME_24HOUR    NO//12 HOUR
#define DEFAULT_SETTINGS_NORTHUP        NO
#define DEFAULT_SETTINGS_SIMULATION     NO
#define DEFAULT_SETTINGS_ODOMETER       YES
//nav panel info type
#define DEFAULT_NAV_PANEL1_TYPE 0
#define DEFAULT_NAV_PANEL2_TYPE 5
#define DEFAULT_NAV_PANEL3_TYPE 2
//truck info default values
#define DEFAULT_WIDTH   8.6
#define DEFAULT_WEIGHT  30000
#define DEFAULT_LENGTH  25.0
#define DEFAULT_HEIGHT  12.6
#define DEFAULT_HAZMAT  2
//route request default values
#define DEFAULT_ROUTE_REQUEST_LOCATION_START_LATITUDE  42.357722 
#define DEFAULT_ROUTE_REQUEST_LOCATION_START_LONGITUDE  -71.059501
#define DEFAULT_ROUTE_REQUEST_LOCATION_END_LATITUDE 40.714554
#define DEFAULT_ROUTE_REQUEST_LOCATION_END_LONGITUDE    -74.007118
#define DEFAULT_ROUTE_REQUEST_ADDRESS_START @"Current Location"
//#define DEFAULT_ROUTE_REQUEST_ADDRESS_END   @"New York, NY"
#define DEFAULT_ROUTE_REQUEST_ADDRESS_END   @"Tap to Enter Destination"
#define DEFAULT_ROUTE_REQUEST_ROUTE_TYPE    8//TRUCK QUICKEST
#define DEFAULT_ROUTE_REQUEST_TOLL  0//ALLOW TOLL
#define DEFAULT_ROUTE_REQUEST_SPEED 0
#define DEFAULT_ROUTE_REQUEST_BEARING   -1
#define DEFAULT_ROUTE_REQUEST_FORMAT @"xml" //@"kmz"
//pois default settings
#define DEFAULT_POI_DISPLAY_TRUCKSTOP   1
#define DEFAULT_POI_DISPLAY_TRUCKPARKING   0
#define DEFAULT_POI_DISPLAY_TRUCKDEALER   0
#define DEFAULT_POI_DISPLAY_WEIGHSTATION   1
/////////////////////////////////////////////////

//find address view ui
#define RESULT_ANIMATION_DURATION   .5
//mapview ui
#define MENU_PANEL_ANIMATION_DURATION   .5

//waiting animation
#define WAITING_INTERVAL    .5
#define WAITING_ANIMATION_HALF_PERIOD   .5

//navigating
#define NAVIGATOR_INTERVAL  0.6//in seconds //0.6 last was 0.9
#define NAVIGATOR_ANIMATION_DURATION    0.6//in seconds
#define DEFAULT_LOW_SPEED 1//meter/second
#define DEFAULT_STANDARD_SPEED 30//in mph

//rerouting thresholds
#define REROUTE_THRESHOLD_OFFROUTE_COUNT    (int)(5.0/NAVIGATOR_INTERVAL)//about 5 seconds to trigger reroute
//#define REROUTE_THRESHOLD_DISTANCE_FROM_ROUTE 100//in meters
#define REROUTE_THRESHOLD_SPEED 5//in mph, no reroute in low speed case
#define REROUTE_THRESHOLD_DISTANCE_TO_DESTINATION 152//in meters, ~= 500 feet, if too close to destination, no reroute

//zoom
#define ZOOM_1_SPAN_LAT .0005
#define ZOOM_1_SPAN_LON .001
#define MAX_ZOOM    19
#define MIN_ZOOM    1
//ios 7 new zooming system
#ifdef __IPHONE_7_0
//altitude: 543.735491, dZoomLevel: 1.000000
#define ZOOM_1_ALTITUDE 543.735491
#endif

//zoom threshold of hide/show turn arrows
//#define ZOOM_THRESHOLD_FOR_TURNS_1 2.5
//#define ZOOM_THRESHOLD_FOR_TURNS_2 4
#define ZOOM_THRESHOLD_FOR_TURNS 4


//voice reminder
#define THRESHOLD_DISTANCE_TO_DESTINATION   30//in meters
#define THRESHOLD_TIME_ANNOUNCE 120//in seconds
#define THRESHOLD_TIME_REMIND   180//in seconds
#define THRESHOLD_TIME_WARN 10//in seconds
#define THRESHOLD_DISTANCE_OMIT_DIST_INFO 100//in meters
#define THRESHOLD_DIST_NEXT_TWO_INSTRUCTIONS 100//in meters

//route manager
#define THRESHOLD_DISTANCE_TO_ROUTE_SHAPE_GROUP 1.0//in lat/lon degrees

//#define THRESHOLD_MIN_DISTANCE_TO_ROUTE_SEGMENT 0.00085//in lat/lon degrees ~= 100m, the figure is calculated at lat:42.0 with average length per degree in lat and lon, it is not precise but good enough to use
#define THRESHOLD_MIN_DISTANCE_TO_ROUTE_SEGMENT 0.00085//in lat/lon degrees ~= 100m, the figure is calculated at lat:42.0 with average length per degree in lat and lon, it is not precise but good enough to use


#define MAX_SHAPES_IN_ROUTE_SHAPE_GROUP         100
#define THRESHOLD_JUDGE_BEARING 45

//simulation settings
#define SIMULATION_SPEED    20//in meters per second, 20 m/s ~= 40 mph

//poi updating setting
#define POI_UPDATE_INTERVAL 5//in seconds
#define ZOOM_THRESHOLD_FOR_POI 13
#define THRESHOLD_MAX_POIS 10
#define POI_THINNING_ROW 12
#define POI_THINNING_COLUMN 10

//odometer
#define ODOMETER_INTERVAL 2//in seconds
#define ODOMETER_DISTANCE_THRESHOLD 80//in meters, actually it is 40meters/sec ~ 90mph, which is impossible for vehicle

//public server ip address list
#define DEFAULT_CONNECTION_TIMEOUT 60//in seconds
#define SERVER_URL_MAIN @"http://50.78.6.246/truckroutes_ios/request.php"
#define SERVER_URL_BACKUP @"http://207.172.212.70/truckroutes_ios/request.php"
#define SERVER_URL_TESTING @"http://192.168.1.20/truckroutes_ios/request.php"

#define SERVER_URL_FOR_SUBSCRIPTION_MAIN @"http://50.78.6.246/truckroutes_ios/subscription_rv_ios.php" // RV App
//#define SERVER_URL_FOR_SUBSCRIPTION_MAIN @"http://50.78.6.246/truckroutes_ios/subscription_ios.php"
#define SERVER_URL_FOR_SUBSCRIPTION_BACKUP @"http://207.172.212.70/truckroutes_ios/subscription_ios.php"
#define SERVER_URL_FOR_SUBSCRIPTION_TESTING @"http://192.168.1.20/truckroutes_ios/subscription_ios.php"

//#define SERVER_URL_VERIFY_MAIN @"http://50.78.6.246/truckroutes_ios/iossubscription.php"
//#define SERVER_URL_VERIFY_BACKUP @"http://207.172.212.70/truckroutes_ios/iossubscription.php"
//#define SERVER_URL_VERIFY @"http://teletype.com/truckroutes/iossubscription2.php" // Original
//#define SERVER_URL_VERIFY @"http://teletype.com/truckroutes/iossubscription2_test.php"

#define SERVER_URL_VERIFY @"http://teletype.com/truckroutes/ios_rv_subscription.php" // RV App

//google places search app key
#define APPLICATION_KEY_FOR_GOOGLE_SEARCH @"AIzaSyDgjZBmvZry2-vWrzDZhiXlb3F_q9IRxuM"

//support email address
#define SUPPORT_EMAIL @"iphone@smarttruckroute.com"
//#define SUPPORT_EMAIL_TEST @"dch_1010@hotmail.com"

//gas search 
#define APPLICATION_KEY_FOR_GAS_STATION_SEARCH @"1fb0smzwz6"
#define SERVER_URL_FOR_GAS_STATION_SEARCH @"http://api.mygasfeed.com"
#define DEFAULT_RADIUS_FOR_GAS_STATION_SEARCH 10//in miles
#define DEFAULT_METHOD_FOR_GAS_STATION_SEARCH @"diesel"
#define ZOOM_THRESHOLD_FOR_GAS_STATION_HIGH 12
#define ZOOM_THRESHOLD_FOR_GAS_STATION_LOW 6

// Device Check
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )

