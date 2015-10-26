//
//  TTRouteDetailsViewController.h
//  TruckRoute
//
//  Created by admin on 10/23/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRouteAnalyzer.h"
#import "TTMapViewController.h"
#import "GADBannerView.h"
@protocol RouteDetailBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@interface TTRouteDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,RouteDetailBackButtonClick, MFMailComposeViewControllerDelegate>{
    NSArray *instructions;
    GADBannerView *bannerView_;
    IBOutlet UIView *topView;
    IBOutlet UITableView *tableView;
    IBOutlet UITableView *tableView_landscape;
    BOOL isShowingLandscapeView;
    
    IBOutlet UIView *mainLandscapeView;
    //BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)id<RouteDetailBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
@property (retain, nonatomic) IBOutlet UILabel *labelSummary;
@property (retain, nonatomic) IBOutlet UILabel *labelInfo;

@property (retain, nonatomic) IBOutlet UILabel *labelSummary_landscape;
@property (retain, nonatomic) IBOutlet UILabel *labelInfo_landscape;

@property (nonatomic, assign) TTRouteAnalyzer *routeAnalyzer;
@property (nonatomic, assign) TTMapViewController *parentVC;
@property (nonatomic, assign) CGPoint routeDetailsContentOffset;
@property (nonatomic, assign) CGPoint routeDetailsContentOffset_landscape;
@property (nonatomic, retain) NSString * stateBorderInfoText;

- (IBAction)ok:(id)sender;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition :(UITableViewScrollPosition)scrollPosition;
@end
