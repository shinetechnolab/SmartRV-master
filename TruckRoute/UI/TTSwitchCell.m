//
//  TTSwitchCell.m
//  TruckRoute
//
//  Created by admin on 11/6/12.
//  Copyright (c) 2012 admin. All rights reserved.
//

#import "TTSwitchCell.h"

@implementation TTSwitchCell

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
    [_label release];
    [_mySwitch release];
    [super dealloc];
}

@end
