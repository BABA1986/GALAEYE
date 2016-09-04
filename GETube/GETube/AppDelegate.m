//
//  AppDelegate.m
//  GETube
//
//  Created by Deepak on 18/06/16.
//  Copyright © 2016 Deepak. All rights reserved.//

#import "AppDelegate.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "GEConstants.h"
#import "UIImage+ImageMask.h"
#import "UIImageView+WebCache.h"
#import "ThemeManager.h"
#import "UserDataManager.h"
#import "GEServiceManager.h"
#import "MBProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize showLoginToast = mShowLoginToast;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mShowLoginToast = FALSE;
    
    SDImageCache* lImageCache = [SDImageCache sharedImageCache];
    [lImageCache clearMemory];
    [lImageCache clearDisk];
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    lThemeManager.selectedIndex = 2;
    [self createIconsForTheme];

    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:lNavColor];
    [[UINavigationBar appearance] setTintColor:lNavTextColor];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: lNavTextColor}];

    UIStoryboard* lSb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    mDrawerCenterCtr = (GEPageRootVC*)[lSb instantiateViewControllerWithIdentifier:@"GEPageRootVCID"];
    MMNavigationController* lCenterNavCtr = [[MMNavigationController alloc] initWithRootViewController: mDrawerCenterCtr];
            
    mDrawerLeftMenuCtr = (GEMenuVC*)[lSb instantiateViewControllerWithIdentifier:@"GEMenuVCID"];
    mDrawerLeftMenuCtr.delegate = self;
    MMNavigationController* lLeftNavCtr = [[MMNavigationController alloc] initWithRootViewController: mDrawerLeftMenuCtr];
    mAppDrawer = [[MMDrawerController alloc] initWithCenterViewController: lCenterNavCtr leftDrawerViewController: lLeftNavCtr];
    
    [mAppDrawer setShowsShadow:NO];
    [mAppDrawer setRestorationIdentifier:@"MMDrawer"];
    [mAppDrawer setMaximumLeftDrawerWidth:160.0];
    [mAppDrawer setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [mAppDrawer setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [mAppDrawer
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:mAppDrawer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onThemeChange:)
                                                 name:@"onThemeChange"
                                               object:nil];
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/youtube", @"https://www.googleapis.com/auth/youtubepartner", @"https://www.googleapis.com/auth/youtube.force-ssl", nil]];
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signInSilently];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)createIconsForTheme
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    
    NSString* lBundlePath = [[NSBundle mainBundle] pathForResource:@"MaskImages" ofType:@"json"];
    NSFileManager* lFileManager = [NSFileManager defaultManager];
    if (![lFileManager fileExistsAtPath: lBundlePath])
        return;
    
    NSData* lJsonData = [lFileManager contentsAtPath: lBundlePath];
    NSError* lError;
    
    if (lJsonData!=nil)
    {
        NSDictionary* lDict = [NSJSONSerialization JSONObjectWithData:lJsonData
                                                              options:kNilOptions error:&lError];
        NSArray* lImages = [lDict objectForKey: @"Images"];
        for (NSDictionary* lImageInfo in lImages)
        {
            NSString* lImageName = [lImageInfo objectForKey: @"name"];
            [UIImage createImageFromMaskOfImageName: lImageName withFillColor: lNavTextColor needCache: TRUE];
        }
    }
}

- (void)onThemeChange: (NSNotification*)notification
{
    [self createIconsForTheme];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    mDrawerCenterCtr.navigationController.navigationBar.barTintColor = lNavColor;
    mDrawerCenterCtr.navigationController.navigationBar.tintColor = lNavTextColor;
    mDrawerCenterCtr.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: lNavTextColor};
    [mDrawerCenterCtr applyTheme];
    
    mDrawerLeftMenuCtr.navigationController.navigationBar.barTintColor = lNavColor;
    mDrawerLeftMenuCtr.navigationController.navigationBar.tintColor = lNavTextColor;
    mDrawerLeftMenuCtr.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: lNavTextColor};

    [mDrawerLeftMenuCtr applyTheme];
    [self.window setTintColor:lNavColor];
}

- (void)openCloseLeftMenuDrawer
{
    [mAppDrawer toggleDrawerSide: MMDrawerSideLeft animated: TRUE completion: nil];
}

#pragma mark-
#pragma mark- GEMenuVCDelegate
#pragma mark-

- (void)GEMenuVC: (GEMenuVC*)menuVC didSelectAtIndex: (NSIndexPath*)indexPath
{
    [mDrawerCenterCtr initialisePagesForLeftMenuIndex: indexPath.row];
    [mAppDrawer closeDrawerAnimated: TRUE completion: nil];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Cresearance.GETube" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GETube" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GETube.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)showLoginSuccessMsg
{
    if (mShowLoginToast)
    {
        MBProgressHUD* lHud = [MBProgressHUD showHUDAddedTo:self.window  animated:YES];
        lHud.mode = MBProgressHUDModeText;
        lHud.labelText = @"Logged in successfull.";
        lHud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        lHud.removeFromSuperViewOnHide = YES;
        lHud.yOffset = CGRectGetMidY(self.window.frame) - 55.0;
        [lHud hide:YES afterDelay:1];
        mShowLoginToast = FALSE;
    }
}

#pragma mark-
#pragma mark- GIDSignInDelegate
#pragma mark-

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error) {
        return;
    }
    // Perform any operations on signed in user here.
    UserDataManager* lManager = [UserDataManager userDataManager];
    [lManager setUserId: user.userID];
    [lManager setClientId: user.authentication.clientID];
    [lManager setIdToken: user.authentication.idToken];
    [lManager setIdTokenExpDate: user.authentication.idTokenExpirationDate];
    [lManager setAccessToken: user.authentication.accessToken];
    [lManager setAccessTokenExpDate: user.authentication.accessTokenExpirationDate];
    [lManager setName: user.profile.name];
    [lManager setEmail: user.profile.email];
    [lManager setImageUrl: [user.profile imageURLWithDimension: 100]];
    [lManager setRefreshToken: user.authentication.refreshToken];
    
    [mDrawerLeftMenuCtr onLoginUpdate];
    GEServiceManager* lGEServiceManager = [GEServiceManager sharedManager];
    [lGEServiceManager loginDone];
    [self showLoginSuccessMsg];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error
{
    // Perform any operations when the user disconnects from app here.
    // ...
}

@end
