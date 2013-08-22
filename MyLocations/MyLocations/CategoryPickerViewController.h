//
//  CategoryPickerViewController.h
//  MyLocations
//
//  Created by João Carreira on 8/22/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate is need to know which categoty was picked
@class CategoryPickerViewController;
@protocol CategoryPickerViewControllerDelegate<NSObject>
-(void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)categoryName;
@end

@interface CategoryPickerViewController : UITableViewController

@property(nonatomic, weak) id <CategoryPickerViewControllerDelegate> delegate;

@property(nonatomic, strong) NSString *selectedCategoryName;

@end
