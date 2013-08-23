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
    
    // setting backgroung color
    // test color (50% transparent red)
    hudView.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.5f];
    
    return hudView;
}

@end
