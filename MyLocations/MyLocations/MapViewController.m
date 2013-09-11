//
//  MapViewController.m
//  MyLocations
//
//  Created by João Carreira on 9/10/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

// ivar to store location objects
NSArray *locations;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateLocations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - class methods

/**
 * performs a fecth from the datastore and saves the location objects in the ivar
 */
-(void)updateLocations
{
    // performing a fetch request and saving it in the locations ivar
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // verifying if datastore is empty
    if(foundObjects == nil)
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    // removing all annotations (pins) from previous array
    if(locations != nil)
    {
        [self.mapView removeAnnotations:locations];
    }
    
    // loading all new annotations from the fetch request and displaying in the map
    locations = foundObjects;
    [self.mapView addAnnotations:locations];
}


#pragma mark - IBActions

-(void)showUser
{
    // zooming the map 1000 by 1000 meters around users location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


-(void)showLocations
{
    
}


@end
