//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import "UIView+Glow.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Used to identify the associating glowing view
static char* GLOWVIEW_KEY = "GLOWVIEW";

@implementation UIView (Glow)

// Get the glowing view attached to this one.

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(20,20 ), 10,
                                [UIColor whiteColor].CGColor);
    [super drawRect:rect];
    CGContextRestoreGState(context);
}
-(void)setGlow
{
    [self setNeedsDisplay];
//    CALayer *viewLayer = [self layer];
//    CALayer* maskLayer = [CALayer layer];
//    
//    maskLayer.bounds = viewLayer.bounds;
//    
//    //[maskLayer setPosition:CGPointMake(CGRectGetWidth(viewLayer.frame)/2.0, CGRectGetHeight(viewLayer.frame)/2.0)];
//    [maskLayer setPosition:CGPointMake(CGRectGetWidth(viewLayer.frame)/2.0, -20)];
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate (NULL, viewLayer.bounds.size.width, 20, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
//    
//    CGFloat colors[] = {
//        0.0, 0.0, 0.0, 1.0, //BLACK
//        0.5, 0.5, 0.5, 0.0, //BLACK
//
//    };
//    
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
//    CGColorSpaceRelease(colorSpace);
//    
//    NSUInteger gradientH = 20;
//    NSUInteger gradientHPos = 0;
//    //CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
////    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
////    CGContextFillRect(context, CGRectMake(0, gradientHPos + gradientH, CGRectGetWidth(maskLayer.frame), CGRectGetHeight(maskLayer.frame)));
////    
////    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
////   // CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
////    CGContextFillRect(context, CGRectMake(0, -20, 320, gradientHPos));
//    
//    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, gradientHPos), CGPointMake(0, gradientHPos + gradientH), 0);
//    
//    CGGradientRelease(gradient);
//    
//    CGImageRef contextImage = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    
//    [maskLayer setContents:(__bridge id)contextImage];
//    
//    CGImageRelease (contextImage);
//    
//    viewLayer.masksToBounds = YES;
//    viewLayer.mask = maskLayer;
}
- (UIView*) glowView {
    return objc_getAssociatedObject(self, GLOWVIEW_KEY);
}

// Attach a view to this one, which we'll use as the glowing view.
- (void) setGlowView:(UIView*)glowView {
    objc_setAssociatedObject(self, GLOWVIEW_KEY, glowView, OBJC_ASSOCIATION_RETAIN);
}

- (void)startGlowingWithColor:(UIColor *)color intensity:(CGFloat)intensity {
    [self startGlowingWithColor:color fromIntensity:0.1 toIntensity:intensity repeat:YES];
}

- (void) startGlowingWithColor:(UIColor*)color fromIntensity:(CGFloat)fromIntensity toIntensity:(CGFloat)toIntensity repeat:(BOOL)repeat {
    
    // If we're already glowing, don't bother
    if ([self glowView])
        return;
    
    // The glow image is taken from the current view's appearance.
    // As a side effect, if the view's content, size or shape changes, 
    // the glow won't update.
    UIImage* image;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale); {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        [color setFill];
        
        [path fillWithBlendMode:kCGBlendModeSourceAtop alpha:1.0];
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    // Make the glowing view itself, and position it at the same
    // point as ourself. Overlay it over ourself.
    UIView* glowView = [[UIImageView alloc] initWithImage:image];
    glowView.center = self.center;
    [self.superview insertSubview:glowView aboveSubview:self];
    
    // We don't want to show the image, but rather a shadow created by
    // Core Animation. By setting the shadow to white and the shadow radius to 
    // something large, we get a pleasing glow.
    glowView.alpha = 0;
    glowView.layer.shadowColor = color.CGColor;
    glowView.layer.shadowOffset = CGSizeZero;
    glowView.layer.shadowRadius = 10;
    glowView.layer.shadowOpacity = 1.0;
    
    // Create an animation that slowly fades the glow view in and out forever.
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(fromIntensity);
    animation.toValue = @(toIntensity);
    animation.repeatCount = repeat ? HUGE_VAL : 0;
    animation.duration = 1.0;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [glowView.layer addAnimation:animation forKey:@"pulse"];
    
    // Finally, keep a reference to this around so it can be removed later
    [self setGlowView:glowView];
}

- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView*)view {
    [self startGlowingWithColor:[UIColor whiteColor] fromIntensity:0 toIntensity:0.6 repeat:NO];
    
    [self glowView].center = point;
    [view addSubview:[self glowView]];
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopGlowing];
    });
}

- (void)glowOnce {
    [self startGlowing];
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopGlowing];
    });
    
}

// Create a pulsing, glowing view based on this one.
- (void) startGlowing {
    [self startGlowingWithColor:[UIColor whiteColor] intensity:0.6];
}

// Stop glowing by removing the glowing view from the superview 
// and removing the association between it and this object.
- (void) stopGlowing {
    [[self glowView] removeFromSuperview];
    [self setGlowView:nil];
}

@end