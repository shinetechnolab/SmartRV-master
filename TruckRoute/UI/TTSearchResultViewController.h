//
//  TTSearchResultViewController.h
//  TruckRoute
//
//  Created by admin on 4/24/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <Mapkit/Mapkit.h>
#import <UIKit/UIKit.h>
#import "TTUtilities.h"
@protocol SearchButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end

@interface TTSearchResultViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,SearchButtonClick> {
    TTUtilities *uti;
    CLLocationManager *locationManager;
    BOOL isMetric;
    IBOutlet UITableView *searchResultTable;
    IBOutlet UIImageView *mainBgImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    BOOL isShowingLandscapeView;
    //BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<SearchButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;

@property (nonatomic, retain) NSArray *results;
- (IBAction)back:(id)sender;
- (IBAction)view:(id)sender;

@end
