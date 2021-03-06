//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by João on 8/21/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>
// import needed to work with Core Location Framework
// deprecated since added the below import to MyLocations-Prefix.pch
//#import <CoreLocation/CoreLocation.h>
#import "CategoryPickerViewController.h"

// needed to edit Location objects in this same screen
@class Location;

// conforming with UITextViewDelegate for user's description
@interface LocationDetailsViewController : UITableViewController
    <UITextViewDelegate,
    CategoryPickerViewControllerDelegate,
    /* the following two delegates are needed for the UIImagePicker */
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    /* needed for the action sheet */
    UIActionSheetDelegate>

// text view to enter location description
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;

// category label
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;

// latitude label
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;

// longitude label
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;

// address label
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

// date label
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

// struct containing latitude and longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// object containing the address for reverse geocoding
@property (nonatomic, strong) CLPlacemark *placemark;

// object needed for Core Data
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// object needed to edit location
@property (nonatomic, strong) Location *locationToEdit;

// imageview to display photo
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

// photo label
@property (nonatomic, strong) IBOutlet UILabel *photoLabel;

// done button in the navigation bar
-(IBAction)done:(id)sender;

// cancel button in the navigation bar
-(IBAction)cancel:(id)sender;

@end
