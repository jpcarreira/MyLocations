//
//  HudView.h
//  MyLocations
//
//  Created by João on 8/23/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

// method to call the HUD in a view
+(HudView *)hudInView:(UIView *)view animated:(BOOL)animated;

// HUD's text
@property (nonatomic, strong) NSString *text;

@end
