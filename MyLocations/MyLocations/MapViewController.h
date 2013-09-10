//
//  MapViewController.h
//  MyLocations
//
//  Created by João Carreira on 9/10/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

// setting this view controller as delegate of map view
@interface MapViewController : UIViewController<MKMapViewDelegate>

// managed object context
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// map view
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

-(IBAction)showUser;

-(IBAction)showLocations;

@end
