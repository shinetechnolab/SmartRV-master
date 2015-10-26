//
//  TTTravelAlertView.h
//  TruckRoute
//
//  Created by Alpesh55 on 10/16/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
@interface TTTravelAlertView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *hwyArray;
    NSMutableArray *descArray;
    
    UITableView *notificationTableView;
    UILabel *detailLbl;
}
-(void)reloadTableView;
@end
