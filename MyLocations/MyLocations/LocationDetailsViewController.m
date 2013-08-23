//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by João on 8/21/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "LocationDetailsViewController.h"
//#import "CategoryPickerViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController

@synthesize descriptionTextView, categoryLabel, latitudeLabel, longitudeLabel, addressLabel, dateLabel, coordinate, placemark;

// ivar for user's description
NSString *descriptionText;

// ivar to store category name
NSString *categoryName;


# pragma mark - inits

/**
 * init with coder
 */
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        descriptionText = @"";
        categoryName = @"No Category";
    }
    return self;
}


# pragma mark - standard table view controller methods

-(void)viewDidLoad
{
    [super viewDidLoad];
        
    // updating the text view text
    self.descriptionTextView.text = descriptionText;
    
    // updating the category label
    self.categoryLabel.text = categoryName;
    
    // updating screen labels
    self.descriptionTextView.text = @"";
    self.categoryLabel.text = @"";
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    
    // checking if placemark has a valid address
    if(self.placemark != nil)
    {
        // calling instance method to get a string address from CLPlacemark
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    }
    else
    {
        self.addressLabel.text = @"No address found";
    }
    
    // calling instance method to get a string date from NSDate
    self.dateLabel.text = [self formatDate:[NSDate date]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PickCategory"])
    {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.selectedCategoryName = categoryName;
    }
}

# pragma mark - instance methods

/**
 * closes the screen
 */
-(void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 * gets an address string from a placemark object
 */
-(NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
            // house number
            thePlacemark.subThoroughfare,
            // street name
            thePlacemark.thoroughfare,
            // city
            thePlacemark.locality,
            // state / province
            thePlacemark.administrativeArea,
            // zip code / postal code
            thePlacemark.postalCode,
            // country
            thePlacemark.country];
}


/**
 * gets a date string from a NSDate object
 */
-(NSString *)formatDate:(NSDate *)theDate
{
    // creating the memory-expensive NSDateFormatter with "lazy loading"
    // static makes the object persist even when this method ends
    static NSDateFormatter *formatter = nil;
    // this condition is necessary due to the static declaration above
    if(formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return [formatter stringFromDate:theDate];
}

# pragma mark - IBActions

/**
 * done button
 */
-(IBAction)done:(id)sender
{
    // testing description text
    NSLog(@"DESCRIPTION: %@", descriptionText);
    
    // calling close screen
    [self closeScreen];
}


/**
 * cancel button
 */
-(IBAction)cancel:(id)sender
{
    // calling close screen
    [self closeScreen];
}


# pragma mark - UITableViewDelegate


/**
 * cell's height
 */
-(CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // height for description cell
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        return 88;
    }
    
    // height for address cell
    if(indexPath.section == 2 && indexPath.row == 2)
    {
        // CGRech is a struct that defines a rectangle
        // CGRectMake takes 4 parameters: X coordinate, Y coordinate, width and height
        // X and Y are the same as set on the storyboard; heigth is big enough to handle a lot of text
        CGRect rect = CGRectMake(100, 10, 190, 1000);
        
        // resizing the label to the defined rectangle
        // it automatically word-wraps any text
        self.addressLabel.frame = rect;
        
        // same as "size to fit content" from the storyboard
        [self.addressLabel sizeToFit];
        
        // the rect height is set the current "size to fit" address label
        // now we have 100-10-190 and heigth exactly to fit content
        rect.size.height = self.addressLabel.frame.size.height;
        
        // with the height correctly calculated we set the final frame
        self.addressLabel.frame = rect;
        
        // adding a 10 point margin (10 top, 10 down)
        return (self.addressLabel.frame.size.height + 20);
    }
    
    // height for other rows
    else
    {
        return 44;
    }
}


/**
 * using this method to decide which cells are "tapable"
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first two sections are "tapable"
    if(indexPath.section == 0 || indexPath.section == 1)
    {
        return indexPath;
    }
    
    // the third section is "read-only" so user can't tap
    else
    {
        return nil;
    }
}


/**
 * using this method to launch keyboard once the description textview cell's is tapped
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        [self.descriptionTextView becomeFirstResponder];
    }
}


#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // updating the ivar whenever the user inputs text
    descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    descriptionText = theTextView.text;
}


#pragma mark - CategoryPickerViewControllerDelegate

-(void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)theCategoryName
{
    // updating the ivar and label
    categoryName = theCategoryName;
    self.categoryLabel.text = categoryName;
    
    // closing the category picker screen
    [self.navigationController popViewControllerAnimated:YES];
}



@end
