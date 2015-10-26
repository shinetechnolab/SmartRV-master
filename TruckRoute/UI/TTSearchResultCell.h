//
//  TTSearchResultCell.h
//  TruckRoute
//
//  Created by admin on 4/24/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSearchResultCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *distance;
@property (retain, nonatomic) IBOutlet UILabel *info;
@property (retain, nonatomic) IBOutlet UIImageView *image;

@end
