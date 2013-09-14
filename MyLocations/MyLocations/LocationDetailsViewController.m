//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by João on 8/21/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "LocationDetailsViewController.h"
//#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController

@synthesize descriptionTextView, categoryLabel, latitudeLabel, longitudeLabel, addressLabel, dateLabel, coordinate, placemark, managedObjectContext, locationToEdit, imageView, photoLabel;

// ivar for user's description
NSString *descriptionText;

// ivar to store category name
NSString *categoryName;

// ivar to store current date (neeeded to store in Location object to import for DB)
NSDate *date;

// ivar to store to object containing the photo
UIImage *image;

// ivar for the action sheet
UIActionSheet *actionSheet;

// ivar for the imagePicker
UIImagePickerController *imagePicker;

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
        date = [NSDate date];
    
        // setting this view controller has observer for UIApplicationDidEnterBackgroundNotification so that NSNotificationCenter can call applicationDidEnterBackground when home button is pressed when the action sheet or image picker are on the screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    // removing the observer (after the tag! button is pressed)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


# pragma mark - standard table view controller methods

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // checking whether we're adding or editing a Location
    // if we're editing a location
    if(self.locationToEdit != nil)
    {
        // setting the title to "edit"
        self.title = @"Edit Location";
        
        // setting the bar button to "done" (using target-action pattern)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
        // if the location being edited has a photo then we display it
        // (we also verify image == nil as viewDidLoad may be called after a low-memory situation)
        if([self.locationToEdit hasPhoto] && image == nil)
        {
            UIImage *existingImage = [self.locationToEdit photoImage];
            
            // this is a defensive condition, to protect from situations where the image doesn't exist in the documents folder or is corrupted
            if(existingImage != nil)
            {
                [self showImage:existingImage];
            }
        }
    }
    
    // calling showImage when we already have an image (this only happens in low-memory situations)
    if(image != nil)
    {
        [self showImage:image];
    }
    
    // updating the text view text
    self.descriptionTextView.text = descriptionText;
    
    // updating the category label
    self.categoryLabel.text = categoryName;
    
    // updating screen labels
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = categoryName;
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
    self.dateLabel.text = [self formatDate:date];
    
    // dismissing the keyboard if user tap elsewhere but the TextView cell
    // hideKeyboard is implemented in this .m file
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // the following simulates view unload in simulated memory warning situations
    // (we're doing this as in iOS6 views do not unload from memory)
    if([self isViewLoaded] && self.view.window == nil)
    {
        self.view = nil;
    }
    
    // setting all outlets to nil to save memory
    if(![self isViewLoaded])
    {
        self.descriptionTextView = nil;
        self.categoryLabel = nil;
        self.latitudeLabel = nil;
        self.longitudeLabel = nil;
        self.addressLabel = nil;
        self.dateLabel = nil;
        self.imageView = nil;
        self.photoLabel = nil;
    }
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


/**
 * dismisses the keyboard unless the tap occurs in the cell containing the TextView
 */
-(void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    // getting a precise point from the screen
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    
    // getting the corresponding indexpath
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    // not dismissing the keyboard if the cell is the one with the TextView
    if(indexPath != nil && indexPath.section == 0 && indexPath.row == 0)
    {
        return;
    }
    
    // the keyboard is the first responder
    [self.descriptionTextView resignFirstResponder];
}


/**
 * locationToEdit setter (used to edit an existing location)
 * (in the prepareForSegue of AllLocationsViewController we have controller.locationToEdit = .... so when this is done this setter is automatically
 * called and by overriding the default setter we can put the desired data in it's properties so it shows the correct information when this
 * screen comes up)
 */
-(void)setLocationToEdit:(Location *)newLocationToEdit
{
    if(locationToEdit != newLocationToEdit)
    {
        locationToEdit = newLocationToEdit;
        descriptionText = locationToEdit.locationDescription;
        categoryName = locationToEdit.category;
        self.coordinate = CLLocationCoordinate2DMake([locationToEdit.latitude doubleValue], [locationToEdit.longitude doubleValue]);
        self.placemark = locationToEdit.placemark;
        date = locationToEdit.date;
    }
}


/**
 * presents an action sheet to choose from either the camera of photo library
 */
-(void)showPhotoMenu
{
    // verifies if the device has a camera
    // uncomment below to test the action sheet in the simulator
    //if(YES){
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // presents the action sheet
        actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take Photo", @"Choose from library", nil];
        
        [actionSheet showInView:self.view];
    }
    else
    {
        [self choosePhotoFromLibrary];
    }
}

/**
 * uses the UIImagePickerController to get a photo from the photo library
 */
-(void)choosePhotoFromLibrary
{
    // UIImagePickerController is a view controller that allows to take new pictures or picking them from the library
    imagePicker = [[UIImagePickerController alloc] init];
    
    // setting this LocationDetailsViewController as delegate for UIImagePickerController
    // (this way, end the user closes the image picker screen the delegate methods will pass information to this LocationDetailsViewController)
    imagePicker.delegate = self;
    
    // setting some properties for UIImagePickerController
    // allows user to move and scale a photo
    imagePicker.allowsEditing = YES;
    // defining the source solely as Photo Library
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // presenting the UIImagePickerController
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

/**
 * uses the UIImagePickerController to get a photo with the camera
 */
-(void)takePhoto
{
    // UIImagePickerController is a view controller that allows to take new pictures or picking them from the library
    imagePicker = [[UIImagePickerController alloc] init];
    
    // setting this LocationDetailsViewController as delegate for UIImagePickerController
    // (this way, end the user closes the image picker screen the delegate methods will pass information to this LocationDetailsViewController)
    imagePicker.delegate = self;
    
    // setting some properties for UIImagePickerController
    // allows user to move and scale a photo
    imagePicker.allowsEditing = YES;
    // defining the source solely as Photo Library
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // presenting the UIImagePickerController
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

/**
 * shows an image in the "add photo" cell and defines some of its properties
 */
-(void)showImage:(UIImage *)theImage
{
    self.imageView.image = theImage;
    // as we have set as hidden in the storyboard now we revert it
    self.imageView.hidden = NO;
    // defining a frame for the image
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    // hiding the photo label
    self.photoLabel.hidden = YES;
}

-(void)applicationDidEnterBackground
{
    // dismissing this view controller when we have a image picker on the screen
    if(imagePicker != nil)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        imagePicker = nil;
    }
    
    // the same for the action sheet
    if(actionSheet != nil)
    {
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
        actionSheet = nil;
    }
    
    [self.descriptionTextView resignFirstResponder];
}

/**
 * returns a unique photo Id
 */
-(int)nextPhotoId
{
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] setInteger:photoId + 1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}

# pragma mark - IBActions

/**
 * done button
 */
-(IBAction)done:(id)sender
{
    // calling the hud when pressing the done button and setting it's text
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    // Location object to be used either in adding or editing mode
    Location *location = nil;
    
    // if editing we do not call insertNewObjectForEntityForName
    if(locationToEdit != nil)
    {
        hudView.text = @"Updated!";
        location = self.locationToEdit;
    }
    // if adding a new Location we call insertNewObjectForEntityForName
    else
    {
        hudView.text = @"Tagged!";
        // setting up the Location object and importing it to the database
        // creating a new location object (as it is a MANAGER object the creation process differs from standard alloc-init)
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        // setting the new location photo id to -1
        location.photoId = [NSNumber numberWithInt:-1];
    }
    
    // setting up location object properties
    location.locationDescription = descriptionText;
    location.category = categoryName;
    location.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble:self.coordinate.longitude];
    location.date = date;
    location.placemark = self.placemark;

    // saving the user's picked photo in the app's documents directory (in case user did select an image)
    if(image != nil)
    {
        // if the location doesn't have a photo we need to assign a new ID
        // (ie, if the location already has a photo, which happens when editing a location, we keep the photo ID and replaced only the image)
        if(![location hasPhoto])
        {
            location.photoId = [NSNumber numberWithInt:[self nextPhotoId]];
        }
        
        // converting the image to a png format
        NSData *data = UIImagePNGRepresentation(image);
        
        // probing for any error
        NSError *error;
        if(![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error])
        {
            NSLog(@"Error writing to file!");
        }
        
        // this fixes the bug of displaying the same image on all locations after adding a new location with a image
        image = nil;
    }
    
    // saving to SQLite with error verification
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        // using the macro defined on MyLocations-Info.plist to handle any SQLite error
        FATAL_CORE_DATA_ERROR(error);
        // sends the fataDataCoreError message to the application delegate
        [(id)[[UIApplication sharedApplication] delegate] performSelector:@selector(fatalCoreDataError:) withObject:error];
        return;
    }

    // calling close screen
    // we can't just call closeScreen as we have to waint until the animation finishes; as the animation takes 0.3 seconds we give it another 0.3 and set the delay to 0.6
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
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
    
    // height for photo cell
    else if(indexPath.section == 1)
    {
        // if there's no image the size is the default 44
        if(self.imageView.hidden == YES)
        {
            return 44;
        }
        // if we have a image we adjust it's size a little more than the value defined in showImage
        else
        {
            return 280;
        }
    }
    
    // height for address cell
    else if(indexPath.section == 2 && indexPath.row == 2)
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
 * defining which actions occur in each row
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // launch keyboard once the description textview cell's is tapped
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        [self.descriptionTextView becomeFirstResponder];
    }
    
    // taking a photo
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        // deselecting the row (to turn it's blue color off)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
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


#pragma mark - UIImagePickerControllerDelegate

/**
 * this method is called when the user selects an image
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // the info dictionary contains information regarding the object containing the image picked by the user and we'll use the image selected and edited by the user
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // first we check if view is loaded (this handles low memory situations
    if([self isViewLoaded])
    {
        // showing the image
        [self showImage:image];
        // this call is necessary to adjust the photo cell height
        [self.tableView reloadData];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    // setting to nil so we don't keep a reference to something that no longer exists
    imagePicker = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    // setting to nil so we don't keep a reference to something that no longer exists
    imagePicker = nil;
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self takePhoto];
    }
    else if(buttonIndex == 1)
    {
        [self choosePhotoFromLibrary];
    }
    
    // setting to nil so we don't keep a reference to something that no longer exists
    actionSheet = nil;
}

@end
