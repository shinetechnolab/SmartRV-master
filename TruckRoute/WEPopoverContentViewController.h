//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "TTNotificationDetailViewController.h"

@protocol WEPopoverDelegate <NSObject>

-(void)selectedLocationFromNotification:(NSString *)lat longitute:(NSString *)lon;

@end

@interface WEPopoverContentViewController : UITableViewController<TTNotificationDelegate> {

    NSMutableArray *hwyArray;
    NSMutableArray *descArray;
    NSMutableArray *latArray;
    NSMutableArray *lonArray;
}
@property (nonatomic,retain)id <WEPopoverDelegate> delegate;
@end
