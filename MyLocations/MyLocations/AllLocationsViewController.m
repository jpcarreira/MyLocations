//
//  AllLocationsViewController.m
//  MyLocations
//
//  Created by João on 8/28/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "AllLocationsViewController.h"

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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Locations";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
    descriptionLabel.text = @"testing description";
    
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
    addressLabel.text = @"testing address\ntesting address";
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
