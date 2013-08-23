//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by João Carreira on 8/22/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@end

@implementation CategoryPickerViewController

// ivar for list of categories
NSArray *categories;

// ivar to store the current selected category
NSIndexPath *selectedIndexPath;

@synthesize delegate, selectedCategoryName;


#pragma mark - standard TableViewController methods

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // loading the categories into the array
    categories = [[NSArray alloc] initWithObjects:
                  @"No Category",
                  @"Apple Store",
                  @"Bar",
                  @"Bookstore",
                  @"Club",
                  @"Grocery store",
                  @"Historic Building",
                  @"House",
                  @"Landmark",
                  @"Park",
                  @"Stadium",
                  nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation = UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // getting the category name for a cell and setting it up
    cell.textLabel.text = [categories objectAtIndex:indexPath.row];
    
    // setting the checkmark (if it's the case)
    if([[categories objectAtIndex:indexPath.row] isEqualToString:self.selectedCategoryName])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // saving the index path for the selected category
        selectedIndexPath = indexPath;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // when selecting a category that is currently not the selected one, we make it now the selected one
    if(indexPath.row != selectedIndexPath.row)
    {
        // new selected cell is checkmarked
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        // old cell is unchecked
        [tableView cellForRowAtIndexPath:selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
        
        // saving the new ivar status
        selectedIndexPath = indexPath;
        
        // sending the selected category to the delegate
        [self.delegate categoryPicker:self didPickCategory:[categories objectAtIndex:indexPath.row]];
    }
}

@end
