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

- (void)viewDidLoad
{
    [super viewDidLoad];	
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

#pragma mark - instance methods

/**
 * gets current GPS location
 */
-(IBAction)getLocation:(id)sender
{
    
}

@end
