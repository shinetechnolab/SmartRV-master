//
//  TTRouteDetailCell.m
//  TruckRoute
//
//  Created by admin on 10/31/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTRouteDetailCell.h"

@implementation TTRouteDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_lableInstruction release];
    [_labelDistance release];
    [_imageDirection release];
    [super dealloc];
}
@end
