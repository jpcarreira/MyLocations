//
//  MapViewController.m
//  MyLocations
//
//  Created by João Carreira on 9/10/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "MapViewController.h"

// needed for MKMapViewDelegate
#import "Location.h"

@interface MapViewController ()

@end

@implementation MapViewController

// ivar to store location objects
NSArray *locations;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateLocations];
    
    // enabling showing user's location by default
    if([locations count] > 0)
    {
        [self showLocations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - class methods

/**
 * performs a fecth from the datastore and saves the location objects in the ivar
 */
-(void)updateLocations
{
    // performing a fetch request and saving it in the locations ivar
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // verifying if datastore is empty
    if(foundObjects == nil)
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    // removing all annotations (pins) from previous array
    if(locations != nil)
    {
        [self.mapView removeAnnotations:locations];
    }
    
    // loading all new annotations from the fetch request and displaying in the map
    locations = foundObjects;
    [self.mapView addAnnotations:locations];
}

/**
 * defines a region around user's saved locations
 * (note that this method doesn't work in Location objects, it assumes that the objects in the annotations array conform in the MKAnnotation protocol
 */
-(MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
    MKCoordinateRegion region;
    
    // if there are no annotation the map is centered in user's current location
    if([annotations count] == 0)
    {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    }
    
    // if there's only one annotation the map is centered in that annotation
    else if([annotations count] == 1)
    {
        id<MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    }
    
    // if there's 2 or more locations we calculate the extent they reach and add some padding
    else
    {
        // top left coordinate
        CLLocationCoordinate2D topLeftCoordinate;
        topLeftCoordinate.latitude = -90;
        topLeftCoordinate.longitude = 180;
        
        // bottom right coordinate
        CLLocationCoordinate2D bottomRightCoordinate;
        bottomRightCoordinate.latitude = 90;
        bottomRightCoordinate.longitude = -180;
        
        // fast enumeration for update the default coordinates above
        for(id<MKAnnotation> annotation in annotations)
        {
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude);
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude);
            
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude);
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude);
        }
        
        // defining the padding
        const double extraSpace = 1.1;
        
        region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) / 2.0;
        region.center.longitude = topLeftCoordinate.longitude - (topLeftCoordinate.longitude - bottomRightCoordinate.longitude) / 2.0;
        
        region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoordinate.longitude - bottomRightCoordinate.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}


-(void)showLocationDetails:(UIButton *)button
{
    
}


#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // making sure the annotation object is a Location object
    // (because MKAnnotation is a protocol there are other objects other than Location objects that could be included, such as the blue pin representing the user's current location and we want to leave these objects alone)
    if([annotation isKindOfClass:[Location class]])
    {
        // defining an identifier
        static NSString *identifier = @"Location";
        
        // creating a new pin
        // (we're not limited to MKPinAnnotationView, we could subclass MKAnnotationView and do our own class)
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        // constructing and configuring the annotation view
        // (reusing the annotation view object)
        if(annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            
            // creating an object similar to a disclosure button
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            // using the target-action pattern to hook the button's "touch up inside" event with showLocationDetailsMethod
            [rightButton addTarget:self action:@selector(showLocationDetails:) forControlEvents:UIControlEventTouchUpInside];
            
            // adding the button to annotation view's accessory view
            annotationView.rightCalloutAccessoryView = rightButton;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        // getting a reference to the detail disclosure button built above
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        
        // setting a tag to that button so we can locate the respective Location object when showLocationDetails is called 
        button.tag = [locations indexOfObject:(Location *)annotation];
        
        return annotationView;
    }
    return nil;
}


#pragma mark - IBActions

-(void)showUser
{
    // zooming the map 1000 by 1000 meters around users location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


-(void)showLocations
{
    // zooming the map around saved locations
    MKCoordinateRegion region = [self regionForAnnotations:locations];
    [self.mapView setRegion:region animated:YES];
}


@end
