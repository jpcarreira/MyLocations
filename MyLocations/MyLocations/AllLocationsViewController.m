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
// import needed to reuse the edit screen
#import "LocationDetailsViewController.h"
// need to resize image
#import "UIImage+Resize.h"

@interface AllLocationsViewController ()

@end

@implementation AllLocationsViewController

@synthesize managedObjectContext;

// ivar to store the Location objects retrived by fetching
// (deprecated once started using NSFetchedResultsController)
//NSArray *locations;

// ivar to store fetch from SQLite
NSFetchedResultsController *fetchedResultsController;

#pragma mark - Standard View Controller methods

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
    
    // enabling edit button to delete/move Location objects
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // performing an initial fetch when view is loaded as well as when there are changes in the DB
    [self performFecth];
    
    // bellow is deprecated since using fetchedResultsController
    /*
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
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditLocation"])
    {
        // getting the following navigation controller
        UINavigationController *navigationController = segue.destinationViewController;
        // getting the LocationDetailsViewController
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        
        // passing the context
        controller.managedObjectContext = self.managedObjectContext;
        
        // passing the Location object corresponding to the tapped row
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.locationToEdit = location;
    }
}

-(void)dealloc
{
    // dealloc is called whenever this view controller is destroyed so we should nil out the delegate when that happens
    fetchedResultsController.delegate = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    // calling class method to set cells description and address labels
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // swipe to delete
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // getting the object from the index path and deleting it from the data store
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // deleting the corresponding file
        [location removePhotoFile];
        
        [self.managedObjectContext deleteObject:location];
        // at this points the NSFetchedResultsController should be triggered to send a message to NSFetchedResultsChangeDelete which will update the table by deleting it's row
        
        // dealing with errors
        NSError *error;
        if(![self.managedObjectContext save:&error])
        {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}


#pragma mark - class methods

/**
 * configures a cell using the custom cell subclass
 */
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // cast is need as cell passed as parameter is a UITableViewCell object
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
    
    // setting the thumbnail image
    UIImage *image = nil;
    // in case location has a photo we save it in the local var
    if([location hasPhoto])
    {
        image = [location photoImage];
        
        // resizing image to 66 x 66
        if(image != nil)
        {
            image = [image resizedImageWithBounds:CGSizeMake(66, 66)];
        }
    }
    // displaying the thumbail
    locationCell.imageView.image = image;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    // lazy loading
    if(fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // sorter for category
        NSSortDescriptor *sortDescriptorByCategory = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        // sorter for date
        NSSortDescriptor *sortDescriptorByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        // sorting by category first and in each category sorting by date
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorByCategory, sortDescriptorByDate, nil]];
        
        // setting to 20 the maximum of objects fetched at a given time
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                    initWithFetchRequest:fetchRequest
                    managedObjectContext:self.managedObjectContext
                    // the results will be grouped based on the value of 'category'
                    sectionNameKeyPath:@"category"
                    // setting a cache name allows a fast-load from cache if the app quits
                    cacheName:@"Locations"];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

-(void)performFecth
{
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error])
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller will change content");
    [self.tableView beginUpdates];
}


-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            NSLog(@"Controller did change object: NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        case NSFetchedResultsChangeDelete:
            NSLog(@"Controller did change object: NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Controller did change object: NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"Controller did change object: NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            NSLog(@"Controller did change section: NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        case NSFetchedResultsChangeDelete:
            NSLog(@"Controller did change section: NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller did change content");
    [self.tableView endUpdates];
}

@end
