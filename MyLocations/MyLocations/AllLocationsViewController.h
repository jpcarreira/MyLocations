//
//  AllLocationsViewController.h
//  MyLocations
//
//  Created by João on 8/28/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllLocationsViewController : UITableViewController

// object needed to read data from the database
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
