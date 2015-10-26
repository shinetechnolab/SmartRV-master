//
//  TTOdometerCell.m
//  TruckRoute
//
//  Created by Sahil Saini on 12/11/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "TTOdometerCell.h"

@implementation TTOdometerCell

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
-(void)dealloc{
    [_titleLabel release];
    [_imgView release];
    [super dealloc];
}
@end
