//
//  CurrentLocationViewController.m
//  (originally FirstViewController.m)
//  MyLocations
//
//  Created by João Carreira on 8/19/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "CurrentLocationViewController.h"
// import needed for segue
#import "LocationDetailsViewController.h"
#import "NSMutableString+AddText.h"
// import needed for sound effects
#import <AudioToolbox/AudioServices.h>

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController

@synthesize messageLabel, latitudeLabel, longitudeLabel, addressLabel, tagButton, getButton, managedObjectContext;

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

// ivar for the progress indicator
UIActivityIndicatorView *spinner;

// ivar for sound effect
SystemSoundID soundId;

# pragma mark - standard ViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this needs to called in order to present proper text in the labels when there's still no GPS coordinates
	[self updateLabels];
    
    [self configureGetButton];
    
    [self loadSoundEffect];
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


/**
 * prepareForSegue
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // identifying the segue that corresponds to press the "Tag Location" button
    if([segue.identifier isEqualToString:@"TagLocation"])
    {
        // getting the navigation controller following the segue
        UINavigationController *navigationController = segue.destinationViewController;
        
        // getting the LocationDetailsViewController of the navigation controller
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        
        // coordinate property in LocationDetailsViewController is hold the coordinates obtained here
        controller.coordinate = location.coordinate;
        
        // same for placemark
        controller.placemark = placemark;
        
        // same for managedObjectContext
        controller.managedObjectContext = self.managedObjectContext;
    }
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
        
        // "clearing" previous reverse geocoding ivars
        placemark = nil;
        lastGeocodingError = nil;
        
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
        
        // adding "spinner effect"
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        // positioning the spinner inside the button
        spinner.center = CGPointMake(self.getButton.bounds.size.width - spinner.bounds.size.width / 2.0f - 10.0f, self.getButton.bounds.size.height - spinner.bounds.size.height / 2.0f);
        
        // starting anitmation and making it visible
        [spinner startAnimating];
        [self.getButton addSubview:spinner];
    }
    // if we already have a valid GPS location
    else
    {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
        
        // "reverting" spinner animation
        [spinner removeFromSuperview];
        spinner = nil;
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
        
        // updating the address label with reverse geocoding data
        if(placemark != nil)
        {
            // calling instance method to get an address string from a placemark
            self.addressLabel.text = [self stringFromPlacemark:placemark];
        }
        // when the app is still performing reverse geocoding
        else if(performingReverseGeocoding)
        {
            self.addressLabel.text = @"Searching for address ...";
        }
        // when reverse geocoding got an error
        else if(lastGeocodingError != nil)
        {
            self.addressLabel.text = @"Error getting an address";
        }
        // no address found
        else
        {
            self.addressLabel.text = @"No address found";
        }
        
        // showing latitude and longitude labels when searching for GPS coordinate
        self.latitudeTextLabel.hidden = NO;
        self.longitudeTextLabel.hidden = NO;
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
        
        // hiding latitude and longitude labels when searching for GPS coordinate
        self.latitudeTextLabel.hidden = YES;
        self.longitudeTextLabel.hidden = YES;
    }
}


/**
 * gets an address string from a placemark object
 * (using NSMutableString+AddText)
 */
-(NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    /*
     line1: subthoroughfare thoroughfare
     line2: locality administrativearea postalcode
     line3: country
     */
    
    
    // building line 1
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [line1 addText:thePlacemark.subThoroughfare withSeparator:@" "];
    [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];
    
    // building line 2
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [line2 addText:thePlacemark.locality withSeparator:@" "];
    [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
    [line2 addText:thePlacemark.postalCode withSeparator:@" "];
    
    // buiding line 3
    NSMutableString *line3 = [NSMutableString stringWithCapacity:100];
    [line3 addText:thePlacemark.country withSeparator:@" "];
    
    // building the final string
    [line1 appendString:@"\n"];
    [line1 appendString:line2];
    [line1 appendString:@"\n"];
    [line1 appendString:line3];
    return line1;
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
        
        // setting a 60-second time-out
        // the OS will send a didTimeOut: message 60 seconds after startLocationManager was called
        // this means we need to cancel this message in stopLocationManager
        // the didTimeOut: can be found below
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}


/**
 * stops the retrieval of GPS coordinates (in case of error)
 */
-(void)stopLocationManager
{
    if(updatingLocation)
    {
        // "calling-off" the 60-second timeout
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        // stopping updating location
        [locationManager stopUpdatingLocation];
        
        locationManager.delegate = nil;
        
        // turns the ivar to no (meaning we're not updating location anymore)
        updatingLocation = NO;
    }
}


/**
 * this is the timeout message that is sent after in startLocationManager
 */
-(void)didTimeOut:(id)obj
{
    NSLog(@"Time out...");
    
    if(location == nil)
    {
        // stopping the location manager
        [self stopLocationManager];
        
        // creating an error object and giving it to the ivar
        lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorsDomain" code:1 userInfo:nil];
        
        // updating labels and configuring the getButton
        // (we can update the labels directly as we created an error above and updateLabels is prepared to deal w/ an error object)
        [self updateLabels];
        [self configureGetButton];
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
    
    // calculating the distance accuracy between the new reading and the previous one if there was any
    // initial distance for the first distance is set to maximum possible
    CLLocationDistance distance = MAXFLOAT;
    if(location != nil)
    {
        distance = [newLocation distanceFromLocation:location];
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
        
            // if we haven't seen this location before (as it's > 0) we force another reverse geocoding event setting the flag to FALSE
            // as we want the address for the final location, which is the most accurate and this way we force the reverse geocoding even if we already had a previou location
            if(distance > 0)
            {
                performingReverseGeocoding = NO;
            }
            
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
                     // only plays sound the first time it geocodes
                     if(placemark == nil)
                     {
                         NSLog(@"First geocoding");
                         [self playSoundEffect];
                     }
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
        
        // if the distance is not significant and 10 seconds have already passed since the previous reading we'll accept that we won't get a better accuracy and stop the process of getting a new location
        // this optimization is crutial for devices that get locations through wi-fi such as the iPod touch
        else if (distance < 1.0)
        {
            NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
            if(timeInterval > 10)
            {
                NSLog(@"Force done!");
                [self stopLocationManager];
                [self updateLabels];
                [self configureGetButton];
            }
        }
    }
}


# pragma mark - Sound effect

-(void)loadSoundEffect
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sound.caf" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    
    if(fileURL == nil)
    {
        NSLog(@"NSURL is nil for path %@", path);
        return;
    }
    
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundId);
    
    if(error != kAudioServicesNoError)
    {
        NSLog(@"Error code %ld loading sound at path %@", error, path);
        return;
    }
}


-(void)unloadSoundEffect
{
    AudioServicesDisposeSystemSoundID(soundId);
    soundId = 0;
}


-(void)playSoundEffect
{
    AudioServicesPlaySystemSound(soundId);
}

@end
