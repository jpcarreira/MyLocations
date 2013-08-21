//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by João on 8/21/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController

@synthesize descriptionTextView, categoryLabel, latitudeLabel, longitudeLabel, addressLabel, dateLabel;


# pragma mark - instance methods

/**
 * closes the screen
 */
-(void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


# pragma mark - IBActions

/**
 * done button
 */
-(IBAction)done:(id)sender
{
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

@end
