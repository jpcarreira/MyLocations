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

// ivar that indicates whether the app is updating GPS coordinates or not
BOOL updatingLocation;

// ivar to store any error from Core Location
NSError *lastLocationError;


# pragma mark - standard ViewController methods

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
    // starting location manager
    [self startLocationManager];
    
    // updating labels
    [self updateLabels];
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
    // labels text before getting a GPS coordinate or when dealing with error
    else
    {
        // before getting a valid GPS coordinate
        self.messageLabel.text = @"Press the button to start";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        
        // when getting a Core Location error
        NSString *statusMessage;
        
        // error situation
        if(lastLocationError != nil)
        {
            // error is user not enabling location services for this app
            if([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied)
            {
                statusMessage = @"Location services are disabled!";
            }
            // other errors
            else
            {
                statusMessage = @"Error getting location";
            }
        }
        
        // when the user disables location services for the device
        else if(![CLLocationManager locationServicesEnabled])
        {
            statusMessage = @"Location services are disabled!";
        }
        
        // if the app is still trying to get GPS coordinates
        else if(updatingLocation)
        {
            statusMessage = @"Searching ...";
        }
        
        else
        {
            statusMessage = @"Press the button to start";
        }
        
        // updating the message label
        self.messageLabel.text = statusMessage;
    }
}


/**
 * starts the retrieval of GPS coordinates
 */
-(void)startLocationManager
{
    // checking that the device has location services enabled
    if([CLLocationManager locationServicesEnabled])
    {
        // this view controller is set as delegate of Core Location
        locationManager.delegate = self;
        
        // setting accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        // updates location
        [locationManager startUpdatingLocation];
    
        // setting ivar to true
        updatingLocation = YES;
    }
}


/**
 * stops the retrieval of GPS coordinates (in case of error)
 */
-(void)stopLocationManager
{
    if(updatingLocation)
    {
        // stopping updating location
        [locationManager stopUpdatingLocation];
        
        locationManager.delegate = nil;
        
        // turns the ivar to no (meaning we're not updating location anymore)
        updatingLocation = NO;
    }
}


#pragma  mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // prints the error
    NSLog(@"Did fail with error: %@", error);
    
    // when the app can't find immediatly a GPS location it will keep trying (return allows to exit this method); more serious errors are dealt below
    if(error.code == kCLErrorLocationUnknown)
    {
        return;
    }
    
    // here we deal with more serious errors
    
    // stopping the retrieval of GPS coordinates
    [self stopLocationManager];
    
    // storing the error in the ivar
    lastLocationError = error;
    
    // updating the labels for the error situation
    [self updateLabels];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // prints new location
    NSLog(@"Did update location: %@", newLocation);
    
    // in case we had a previous error we need to clear it because now there's sucess getting GPS coordinates
    lastLocationError = nil;
    
    // storing the new location
    location = newLocation;
    
    // updating screen labels
    [self updateLabels];
}

@end
