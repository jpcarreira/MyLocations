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
@dynamic photoId;


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


#pragma mark - class methods

/**
 * verifiies if a Location object has a photo associated with it
 * (returns true if it's ID is != than -1)
 */
-(BOOL)hasPhoto
{
    return (self.photoId != nil) && ([self.photoId intValue] != -1);
}

/**
 * returns the full path to the png file corresponding to the photo
 */
-(NSString *)photoPath
{
    // every photo will have a name "Photo-XXX.png", where XXX is the ID
    NSString *fileName = [NSString stringWithFormat:@"Photo-%d.png", [self.photoId intValue]];
    return [[self documentsDirectory] stringByAppendingPathComponent:fileName];
}

/**
 * returns the app's Document's directory
 */
-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/**
 * returns a UIImage object corresponding the photo; that image is loaded from the app's document's directory
 */
-(UIImage *)photoImage
{
    NSAssert(self.photoId != nil, @"No photoID set!");
    NSAssert([self.photoId intValue] != -1, @"PhotoID is -1!");
    
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

/**
 * removes a photo file from the app's documents directory
 */
-(void)removePhotoFile
{
    NSString *path = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        NSError *error;
        if(![fileManager removeItemAtPath:path error:&error])
        {
            NSLog(@"Error removing file!");
        }
    }
}

@end
