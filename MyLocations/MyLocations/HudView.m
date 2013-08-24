//
//  HudView.m
//  MyLocations
//
//  Created by João on 8/23/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "HudView.h"

@implementation HudView

@synthesize text;


#pragma mark - instance methods

/**
 * drawRect
 */
-(void)drawRect:(CGRect)rect
{
    // making a square w/ 96 by 96 points
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    // making the square to be aligned in the center of the screen
    // the size of the HudView is given by self.bounds.size
    CGRect boxRect = CGRectMake(
            // horizontal position
            roundf(self.bounds.size.width - boxWidth) / 2.0f,
            // vertical position
            roundf(self.bounds.size.height - boxHeight) / 2.0f,
            // width
            boxWidth,
            // height
            boxHeight);
    
    // setting up a rounded square
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    
    // setting up a 75% opaque black color
    [[UIColor colorWithWhite:0.0f alpha:0.75] setFill];
    [roundedRect fill];
    
    // adding checkmark image
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    
    // setting the image to show in the center of the hud
    CGPoint imagePoint = CGPointMake(
        self.center.x - roundf(image.size.width / 2.0f),
        self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f
    );
    [image drawAtPoint:imagePoint];
    
    // setting the text in the hud
    [[UIColor whiteColor] set];
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGSize textSize = [self.text sizeWithFont:font];
    CGPoint textPoint = CGPointMake(
        self.center.x - roundf(textSize.width / 2.0f),
        self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f
    );
    [self.text drawAtPoint:textPoint withFont:font];
    
}

#pragma mark - class methods

/**
 * Convenience constructor
 * (displays HUD in screen)
 */
+(HudView *)hudInView:(UIView *)view animated:(BOOL)animated
{
    // being a convenience construtor the first thing we need is to instantiate HudView
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    // putting the HudView on top of the view passed as parameter
    [view addSubview:hudView];
    
    // disabling user interaction with the view that calls this hud
    view.userInteractionEnabled = NO;
    
    // setting backgroung color (just for test purpose to see the area occupied by the hud; test color (50% transparent red)
    //hudView.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.5f];
    
    // adding animation to hud by calling our instance method
    [hudView showAnimated:YES];
    
    return hudView;
}


/**
 * hudview animation
 */
-(void)showAnimated:(BOOL)animated
{
    // any animation consists in 4 steps
    if(animated)
    {
        // step 1: status before animation starts
        // view fully transparent
        self.alpha = 0.0f;
        // view initially stretched out
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        // step 2: calling the animation and setting its duration attribute
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        // step 3:
        // view is fully opaque
        self.alpha = 1.0f;
        // scaling back to normal
        self.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
    }
}

@end
