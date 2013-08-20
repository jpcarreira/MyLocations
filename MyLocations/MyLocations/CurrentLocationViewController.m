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

// ivar for the Geocoder object
CLGeocoder *geocoder;

// ivar for the object that will contain the address result
CLPlacemark *placemark;

// ivar that indicates whether reverse geocoding is taking place
BOOL performingReverseGeocoding;

// ivar to store any error from reverse geocoding
NSError *lastGeocodingError;


# pragma mark - standard ViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this needs to called in order to present proper text in the labels when there's still no GPS coordinates
	[self updateLabels];
    
    [self configureGetButton];
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
        
        // creating the geocoder object
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}


#pragma mark - instance methods

/**
 * gets current GPS location (if the app is not updating location) or stops getting GPS coordinates (if the app is updating)
 */
-(IBAction)getLocation:(id)sender
{
    // if the app is currently getting a location, pressing this button should stop the updating process
    if(updatingLocation)
    {
        [self stopLocationManager];
    }
    
    // if the app is not updating, pressing the button should start the update process
    else
    {
        // "clearing" previous location and location error
        location = nil;
        lastLocationError = nil;
        
        [self startLocationManager];
    }
    
    // no matter what the app is doing, labels and the get button are updated accordingly
    [self updateLabels];
    [self configureGetButton];
}


/**
 * configures properties of the "Get Location" button
 */
-(void)configureGetButton
{
    // if the app is updating the current location
    if(updatingLocation)
    {
        [self.getButton setTitle:@"Stop!" forState:UIControlStateNormal];
    }
    // if we already have a valid GPS location
    else
    {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
    }
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
    
    [self configureGetButton];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // prints new location
    NSLog(@"Did update location: %@", newLocation);
    
    // if the time at which the location object was determined is longer than 5 seconds ago, instead of returning a new location fix, the location manager gives the most recent found location assuming that the user hasn't moved much since 5 seconds ago (i.e., we're ignoring cached results)
    if([newLocation.timestamp timeIntervalSinceNow] < -5.0)
    {
        return;
    }
    
    // we're using horizontal accuracy to evaluate the accuracy of the location reading; when it's value is less than 0 it is invalid and we should ignore it
    if(newLocation.horizontalAccuracy < 0)
    {
        return;
    }
    
    // this condition evaluates that the new reading is more accurate than the previous one
    if(location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy)
    {
        // in case we had a previous error we need to clear it because now there's sucess getting GPS coordinates
        lastLocationError = nil;
        
        // storing the new location
        location = newLocation;
        
        // updating screen labels
        [self updateLabels];
        
        // if the new location accuracy is equal or better than the desired accuracy we set location manager to stop updating
        if(newLocation.horizontalAccuracy <= locationManager.desiredAccuracy)
        {
            NSLog(@"We're done!");
            [self stopLocationManager];
            
            [self configureGetButton];
        }
        
        // code to support reverse geocoding
        // we only want to perform reverse geocoding once so we check if we can do it using the ivar
        if(!performingReverseGeocoding)
        {
            NSLog(@"Going to reverse geocode");
            
            // setting reverse geocoding flag to true
            performingReverseGeocoding = YES;
            
            // CLGeocoder uses a block instead of a delegate
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 NSLog(@"Found placemarks: %@\nError: %@", placemarks, error);
                 
                 // saving eventual error to the ivar
                 lastGeocodingError = error;
                 
                 // if there are no errors and we have objects inside the array we'll keep the last object of that array as a placemark
                 // (usually there's only one object in the array but sometimes one location coordinate may correspond to more than one address)
                 if(error == nil && [placemarks count] > 0)
                 {
                     // as said before we save the last object
                     placemark = [placemarks lastObject];
                 }
                 else
                 {
                     // setting placemark to nill if reverse geocoding didn't work
                     placemark = nil;
                 }
                 
                 // setting the flag value to false
                 performingReverseGeocoding = NO;
                 
                 // updating labels
                 [self updateLabels];
             }
             ];
        }
    }
}

@end
