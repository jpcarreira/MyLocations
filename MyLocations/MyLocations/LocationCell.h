//
//  LocationCell.h
//  MyLocations
//
//  Created by João Carreira on 8/30/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

// thumbnail
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
