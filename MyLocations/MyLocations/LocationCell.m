//
//  LocationCell.m
//  MyLocations
//
//  Created by João Carreira on 8/30/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

@synthesize descriptionLabel, addressLabel, imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
