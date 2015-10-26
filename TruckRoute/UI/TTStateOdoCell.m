//
//  TTStateOdoCell.m
//  TruckRoute
//
//  Created by admin on 3/29/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTStateOdoCell.h"

@implementation TTStateOdoCell

@synthesize labelState, labelDist, labelUnit;

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
    [labelState release];
    [labelDist release];
    [labelUnit release];
    [super dealloc];
}
@end
