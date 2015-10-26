//
//  TTCellCursorView.m
//  TruckRoute
//
//  Created by Alpesh55 on 12/18/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "TTCellCursorView.h"

@implementation TTCellCursorView

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
    [_titleLbl release];
    [_cursorImage release];
    [super dealloc];
}
@end
