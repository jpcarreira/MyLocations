//
//  Location.h
//  MyLocations
//
//  Created by João Carreira on 8/27/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// conforming this class to MKAnnotation so we can display pins in a map
@interface Location : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) CLPlacemark * placemark;
@property (nonatomic, retain) NSNumber * photoId;

// methods needed to handle photos of a Location
-(BOOL)hasPhoto;
-(NSString *)photoPath;
-(UIImage *)photoImage;
-(void)removePhotoFile;

@end
