//
//  AppDelegate.h
//  GETube
//
//  Created by Deepak on 18/06/16.
//  Copyright © 2016 Deepak. All rights reserved.


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMNavigationController.h"

#import "GEMenuVC.h"
#import "GEPageRootVC.h"

#import <QuartzCore/QuartzCore.h>

//123Layout Optimisation
//123

@interface AppDelegate : UIResponder <UIApplicationDelegate, GEMenuVCDelegate>
{
    MMDrawerController*             mAppDrawer;
    GEMenuVC*                       mDrawerLeftMenuCtr;
    GEPageRootVC*                   mDrawerCenterCtr;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

