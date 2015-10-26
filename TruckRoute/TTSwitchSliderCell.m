//
//  TTSwitchSliderCell.m
//  TruckRoute
//
//  Created by Alpesh55 on 12/9/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTSwitchSliderCell.h"

@implementation TTSwitchSliderCell

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
    [_pitchLbl release];
    [_rateLbl release];
    [_titleLbl release];
    [_subTitleLbl1 release];
    [_subTitleLbl2 release];
    [_rateSlider release];
    [_pitchSlider release];
    [_mySwitch retain];
    [super dealloc];
}
@end
