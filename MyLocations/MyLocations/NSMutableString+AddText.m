//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by João Carreira on 9/15/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

/**
 * auxiliary method to use with stringFromPlacemark
 * adds text to a mutable string with an optional separator
 */
-(void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if(text != nil)
    {
        if([self length] > 0)
        {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
