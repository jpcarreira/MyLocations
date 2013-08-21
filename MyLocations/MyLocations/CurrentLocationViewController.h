//
//  CurrentLocationViewController.h
//  (originally FirstViewController.h)
//  MyLocations
//
//  Created by João Carreira on 8/19/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>
// import needed to work with Core Location Framework
// (deprecated after editing the prefix pch file
//#import <CoreLocation/CoreLocation.h>

// Core Location works with a delegate therefore we need to make this view controller to conform with the CLLocationManagerDelegate protocol
@interface CurrentLocationViewController : UIViewController<CLLocationManagerDelegate>

// label for status messages
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

// label to display latitude
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;

// label to display longitude
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;

// label to display address
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

// connected to "Tag Location" button
@property (nonatomic, strong) IBOutlet UIButton *tagButton;

// connected to "Get My Location" button
@property (nonatomic, strong) IBOutlet UIButton *getButton;

// connected to "Get My Location" button using "touch up inside" event
-(IBAction)getLocation:(id)sender;

@end
