//
//  AllLocationsViewController.m
//  MyLocations
//
//  Created by João on 8/28/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "AllLocationsViewController.h"
// import needed to data source
#import "Location.h"
// import needed for custom cell subclass
#import "LocationCell.h"

@interface AllLocationsViewController ()

@end

@implementation AllLocationsViewController

@synthesize managedObjectContext;

// ivar to store the Location objects retrived by fetching
NSArray *locations;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this class will acknowledge the location objects by fectching
    // NSFetchRequest describes which objects we're fetching from the DB
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    // the fetch request will consist in asking the managed object a list for all location objects in the data store, sorted by date
    // NSEntityDescription specifies that we'll look for Location objects
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // sorting on the date attribute (objects added first will appear on top)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    // once we have the location objects we ask the context to process them
    NSError *error;
    // executeFetchRequest returns nil in case of error
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // verifying if the DB has objects
    if(foundObjects == nil)
    {
        // using the same macro used on CurrentLocationViewController to handle any error
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    // assigning found objects to ivar
    locations = foundObjects;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    // calling class method to set cells description and address labels
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - class methods

/**
 * configures a cell using the custom cell subclass
 */
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // cast is need as cell passed as parameter is a UITableViewCell object
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location = [locations objectAtIndex:indexPath.row];
    
    // checking if the given location has a description
    if([location.locationDescription length] > 0)
    {
        locationCell.descriptionLabel.text = location.locationDescription;
    }
    else
    {
        locationCell.descriptionLabel.text = @"(no description)";
    }
    
    // checking if we have a placemark
    if(location.placemark != nil)
    {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@",
                                          location.placemark.subThoroughfare,
                                          location.placemark.thoroughfare,
                                          location.placemark.locality];
    }
    // else we give it's coordinates
    else
    {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f, Long: %.8f", [location.latitude doubleValue], [location.longitude doubleValue]];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
