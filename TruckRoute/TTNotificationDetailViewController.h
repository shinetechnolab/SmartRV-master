//
//  TTNotificationDetailViewController.h
//  TruckRoute
//
//  Created by Alpesh55 on 10/18/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTNotificationDelegate <NSObject>

-(void)notificationLocation:(NSString *)lat longitute:(NSString *)lon;
@end

@interface TTNotificationDetailViewController : UIViewController
{
    
}
@property (nonatomic,retain)id <TTNotificationDelegate> delegate;
@property (nonatomic,retain)NSString *detailText;
@property (nonatomic,retain)NSString *latString;
@property (nonatomic,retain)NSString *lonString;
@property (nonatomic,retain)UILabel *detailLable;
@end
