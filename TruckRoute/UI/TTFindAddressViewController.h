//
//  TTFindAddressViewController.h
//  TruckRoute
//
//  Created by admin on 10/4/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "CustomPlacemark.h"
#import "TTRouteRequest.h"
#import "TTFindMenuViewController.h"

@interface TTFindAddressViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, BSForwardGeocoderDelegate, UITableViewDelegate, UITableViewDataSource>{
    BSForwardGeocoder *forwardGeocoder;
    NSMutableArray *resultArray;
    NSInteger idxSelected;
    
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
}
@property (retain,nonatomic) CLGeocoder *geoCoder;
@property (retain, nonatomic) TTRouteRequest *route_request;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) BOOL isDestination;
@property (assign, nonatomic) BOOL isTableViewHidden;
@property (retain, nonatomic) BSForwardGeocoder *forwardGeocoder;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;

//for poi search
@property (assign, nonatomic) BOOL isFromPOISearch;
@property (assign, nonatomic) TTFindMenuViewController *parentVC;

- (IBAction)back:(id)sender;
- (IBAction)ok:(id)sender;

-(void)resultAnimation:(BOOL)isHidden;
-(void)updateHistory;
-(void)updateAddress;

//geocoder completion handler
//- (void)displayError:(NSError*)error;
//- (void)displayPlacemarks:(NSArray *)results;

@end
