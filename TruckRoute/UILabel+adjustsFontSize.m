//
//  UILabel+adjustsFontSize.m
//  TruckRoute
//
//  Created by Alpesh55 on 7/30/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "UILabel+adjustsFontSize.h"

@implementation UILabel (adjustsFontSize)
-(void)adjustsFontSizeToFitWidthAndHeight
{
    for (int i = 32; i>3; i--) {
        CGSize size = [self.text sizeWithFont:[UIFont boldSystemFontOfSize:(CGFloat)i] constrainedToSize:CGSizeMake(self.frame.size.width, 9999) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.height < self.frame.size.height)
        {
           // NSLog(@"font size : %i",i);
            self.font = [UIFont boldSystemFontOfSize:(CGFloat)i];
            break;
        }
    }

}
@end
