//
//  TTOdoViewController.h
//  TruckRoute
//
//  Created by admin on 3/27/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTOdoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *arrayUSA;
    NSMutableArray *arrayCANADA;
    NSArray *sortedUSA;
    NSArray *sortedCANADA;
    BOOL isUnitMetric;
    NSTimer *timer;
}
@property (retain, nonatomic) IBOutlet UILabel *labelOdo;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)back:(id)sender;
- (IBAction)reset:(id)sender;

-(void)updateStateOdo;

@end
