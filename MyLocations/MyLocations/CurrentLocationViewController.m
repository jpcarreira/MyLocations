//
//  CurrentLocationViewController.m
//  (originally FirstViewController.m)
//  MyLocations
//
//  Created by João Carreira on 8/19/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController

@synthesize messageLabel, latitudeLabel, longitudeLabel, addressLabel, tagButton, getButton;

// ivar responsible to give GPS coordinates
CLLocationManager *locationManager;

// ivar to store location
CLLocation *location;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this needs to called in order to present proper text in the labels when there's still no GPS coordinates
	[self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // forcing portrait orientation only
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload
{
    [self setGetButton:nil];
    [super viewDidUnload];
}


# pragma mark - inits

/**
 * init with coder (as we're dealing with a storyboard)
 */
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        // creating the CLLocationManager object 
        locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}


#pragma mark - instance methods

/**
 * gets current GPS location
 */
-(IBAction)getLocation:(id)sender
{
    // making the current view controller a delegate of Core Location
    locationManager.delegate = self;
    
    // setting GPS accuracy
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // call to receive GPS coordinates (these coordinates are sent to the delegate defined above)
    [locationManager startUpdatingLocation];
}


/**
 * updates screen labels with the location stored in the ivar
 */
-(void)updateLabels
{
    // only updates if location is valid
    if(location != nil)
    {
        self.messageLabel.text = @"GPS coordinates";
        // for both latitude and longitude we'll accept 8 decimal numbers
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        self.tagButton.hidden = NO;
    }
    // labels text before getting a GPS coordinate
    else
    {
        self.messageLabel.text = @"Press the button to start";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
    }
}


#pragma  mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // prints the error
    NSLog(@"Did fail with error: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // prints new location
    NSLog(@"Did update location: %@", newLocation);
    
    // storing the new location
    location = newLocation;
    
    // updating screen labels
    [self updateLabels];
}

@end
