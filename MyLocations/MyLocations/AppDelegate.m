//
//  AppDelegate.m
//  MyLocations
//
//  Created by João Carreira on 8/19/13.
//  Copyright (c) 2013 João Carreira. All rights reserved.
//

#import "AppDelegate.h"
// import needed to get the NSManagedObjectContext from LocationDetailsViewController
#import "CurrentLocationViewController.h"
// the same but for AllLocationsViewController
#import "AllLocationsViewController.h"
// the same for map view
#import "MapViewController.h"

// extending the class to work with CoreData
@interface AppDelegate()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation AppDelegate

// synthesizing the extended properties for CoreData
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // assigning this managedObjectContext to the property in CurrentLocationViewController
    UITabBarController *tabBarController =(UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:0];
    CurrentLocationViewController *currentLocationViewController = (CurrentLocationViewController *)[[navigationController viewControllers]objectAtIndex:0];
    // we can do self.managedObjectContext because we have the getter below
    currentLocationViewController.managedObjectContext = self.managedObjectContext;
    
    // doing the same but for the property in AllLocationsViewController
    navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:1];
    AllLocationsViewController *allLocationsViewController = (AllLocationsViewController *)[[navigationController viewControllers] objectAtIndex:0];
    allLocationsViewController.managedObjectContext = self.managedObjectContext;
    
    // doing the same but for the property in MapViewController
    MapViewController *mapViewController = (MapViewController *)[[tabBarController viewControllers] objectAtIndex:2];
    mapViewController.managedObjectContext = self.managedObjectContext;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Core Data

-(NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel == nil)
    {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}


-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentsDirectory);
    return documentsDirectory;
}


-(NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}


-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(persistentStoreCoordinator == nil)
    {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        //NSLog(@"%@", storeURL);
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error;
        if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Error adding persistence store %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return persistentStoreCoordinator;
}

/**
 * getter for ManagedObjectContext
 */
-(NSManagedObjectContext *) managedObjectContext
{
    // the first time this method is called, managedObjectContext is nil so we instantiate it
    // (another example of lazy loading)
    if(managedObjectContext == nil)
    {
        // this is the object that handles the SQLite data store
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if(coordinator != nil)
        {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    // once it's created, this method will always return the managedObjectContext
    return managedObjectContext;
}


# pragma mark - SQLite error handling

-(void)fatalCoreDataError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc]
        initWithTitle:NSLocalizedString(@"Internal error", nil)
        message:NSLocalizedString(@"There was a fatal error and the app cannot continue\nPress OK to terminate\nSorry for the inconvenience", nil)
        delegate:self
        cancelButtonTitle:NSLocalizedString(@"OK", nil)
        otherButtonTitles:nil, nil];

    [alertView show];
}


# pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    abort();
}

@end
