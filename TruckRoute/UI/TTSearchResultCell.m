//
//  TTSearchResultCell.m
//  TruckRoute
//
//  Created by admin on 4/24/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTSearchResultCell.h"

@implementation TTSearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc
{
    [_name release];
    [_distance release];
    [_info release];
    [_image release];
    [super dealloc];
}
@end
