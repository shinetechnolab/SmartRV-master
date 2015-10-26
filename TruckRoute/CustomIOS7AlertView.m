//
//  CustomIOS7AlertView.m
//  CustomIOS7AlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOS7AlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomIOS7AlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOS7AlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kCustomIOS7AlertViewCornerRadius              = 7;
const static CGFloat kCustomIOS7MotionEffectExtent                 = 10.0;

@implementation CustomIOS7AlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize containerView, dialogView, buttonView;


- (id)initWithParentView: (UIView *)_parentView
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)init
{
    return [self initWithParentView:NULL];
}
-(void)show
{
    UIView *view=[self createContainerView];
    view.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    dialogView.layer.opacity = 1.0f;
    dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 14,75, 75)];
    [imageView setImage:[UIImage imageNamed:@"Weigh-Station.png"]];
    [view addSubview:imageView];
    [imageView release];
    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(95, 14, 175,75)];
    lbl.text=@"Weigh Station within 7 Miles";
    lbl.numberOfLines=3;
    [view addSubview:lbl];
    [lbl release];
    [self addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];

}
-(void)dismissAlert
{
    [self removeFromSuperview];
}

- (UIView *)createContainerView
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    buttonHeight= kCustomIOS7AlertViewDefaultButtonHeight;
    buttonSpacerHeight = kCustomIOS7AlertViewDefaultButtonSpacerHeight;
    
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
    }

    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height;// + buttonHeight + buttonSpacerHeight;

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

//    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
//        CGFloat tmp = screenWidth;
//        screenWidth = screenHeight;
//        screenHeight = tmp;
//    }

    // For the black background
    [self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];

    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - dialogHeight) / 2, dialogWidth, dialogHeight)];

    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0f] CGColor],
                       nil];

    CGFloat cornerRadius = kCustomIOS7AlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];

    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    // Add the custom container if there is any
    dialogContainer.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
                                        );
    [dialogContainer addSubview:containerView];

   

    return dialogContainer;
}

- (void)addButtonsToView: (UIView *)container
{
    //CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];

    //for (int i=0; i<[buttonTitles count]; i++) {

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [closeButton setFrame:CGRectMake(0, container.bounds.size.height - buttonHeight,container.frame.size.width, buttonHeight)];

        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:1];

        [closeButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [closeButton.layer setCornerRadius:kCustomIOS7AlertViewCornerRadius];

        [container addSubview:closeButton];
   // }
}
-(void)close
{
    [self removeFromSuperview];
}
-(void)customIOS7dialogButtonTouchUpInside:(id)sender
{
    [self removeFromSuperview];
}

@end
