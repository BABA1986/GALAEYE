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
#import <Google/SignIn.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, GEMenuVCDelegate, GIDSignInDelegate>
{
    MMDrawerController*             mAppDrawer;
    GEMenuVC*                       mDrawerLeftMenuCtr;
    GEPageRootVC*                   mDrawerCenterCtr;
    
    BOOL                            mShowLoginToast;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign)BOOL         showLoginToast;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;
- (void)openCloseLeftMenuDrawer;


@end

