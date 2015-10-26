//
//  TTRouteDetailCell.h
//  TruckRoute
//
//  Created by admin on 10/31/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTRouteDetailCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *lableInstruction;
@property (retain, nonatomic) IBOutlet UILabel *labelDistance;
@property (retain, nonatomic) IBOutlet UIImageView *imageDirection;

@end
