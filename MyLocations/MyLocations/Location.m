//
//  Location.m
//  MyLocations
//
//  Created by João Carreira on 8/27/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;


#pragma mark - MKAnnotation

/**
 * getter for coordinate
 */
-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

/**
 * getter for title
 */
-(NSString *)title
{
    if([self.locationDescription length] > 0)
    {
        return self.locationDescription;
    }
    else
    {
        return @"(no description)";
    }
}

/**
 * getter for subtitle
 */
-(NSString *)subtitle
{
    return self.category;
}
@end
