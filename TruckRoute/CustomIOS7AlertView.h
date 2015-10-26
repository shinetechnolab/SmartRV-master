//
//  CustomIOS7AlertView.h
//  CustomIOS7AlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>


@interface CustomIOS7AlertView : UIView

//@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog


//@property (copy) void (^onButtonTouchUpInside)(CustomIOS7AlertView *alertView, int buttonIndex) ;

- (id)initWithParentView: (UIView *)_parentView;
- (id)init;

- (void)show;
- (void)close;

@end
