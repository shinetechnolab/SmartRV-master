//
//  TTHistoryViewController.h
//  TruckRoute
//
//  Created by admin on 10/8/12.
//  Copyright (c) 2012 admin. All rights reserved.
//
#import "TTConfig.h"
#import <UIKit/UIKit.h>
#import "TTRouteRequest.h"
@protocol HistoryBackButtonClick <NSObject>
-(void)backButtonClick:(id)sender;

@end
@protocol historyDelegate <NSObject>

- (void)createButtonPressed;

@end

@interface TTHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,HistoryBackButtonClick,historyDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    NSMutableArray *resultArray;
    NSMutableArray *favoriteArray;
    NSInteger idxSelected;
    
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *createRouteButton;
    IBOutlet UIView *containView;
    BOOL isShowingLandscapeView;
    //BOOL isVisible;
}
@property(nonatomic,assign)BOOL isVisible;
@property (retain,nonatomic)UIViewController *superViewController;
@property (retain, nonatomic)UIViewController *pViewController;
@property (retain, nonatomic)id<HistoryBackButtonClick> delegate;
@property (nonatomic, assign)BOOL isNotificationOn;
@property (retain, nonatomic) id <historyDelegate> myDelegate;
@property (retain, nonatomic) TTRouteRequest *route_request;
@property (assign, nonatomic) BOOL isDestination; //assign
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isEditing; //assign
@property (retain, nonatomic) IBOutlet UIButton *btnEdit;
@property (retain, nonatomic) IBOutlet UISwitch *sortSwitch;
@property (retain, nonatomic) IBOutlet UISearchBar * historySearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController * searchController;

- (IBAction)back:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)switchPressed:(id)sender;

-(void)updateAddress;
-(void)updateHistory;

@end
