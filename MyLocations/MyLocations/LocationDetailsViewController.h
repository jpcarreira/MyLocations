//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by João on 8/21/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailsViewController : UITableViewController

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

// done button in the navigation bar
-(IBAction)done:(id)sender;

// cancel button in the navigation bar
-(IBAction)cancel:(id)sender;

@end
