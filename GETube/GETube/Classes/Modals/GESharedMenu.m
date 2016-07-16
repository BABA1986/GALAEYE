//
//  GESharedMenu.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESharedMenu.h"

@implementation GEMenu
@synthesize menuId;
@synthesize menuName;
@synthesize menuCountry;
@synthesize menuImageIcon;
@synthesize subMenus;

- (GEMenu*)initWithDict: (NSDictionary*)menuDict
            withCountry: (NSDictionary*)countryInfo
{
    self = [super init];
    if (self) {
        self.menuId = [menuDict objectForKey: @"id"];
        self.menuName = [menuDict objectForKey: @"name"];
        self.menuCountry = [countryInfo objectForKey: @"name"];
        self.menuCountryCode = [countryInfo objectForKey: @"code"];
        self.menuImageIcon = [menuDict objectForKey: @"image"];
        NSArray* lSubMenus = [menuDict objectForKey: @"submenus"];
        NSMutableArray* lGESubMenus = [[NSMutableArray alloc] init];
        for (NSDictionary* lSubMenu in lSubMenus) {
            GESubMenu* lGESubMenu = [[GESubMenu alloc] initWithDict: lSubMenu];
            [lGESubMenus addObject: lGESubMenu];
        }
        
        self.subMenus = [[NSArray alloc] initWithArray: lGESubMenus];
    }
    
    return self;
}

@end

@implementation GESubMenu
@synthesize subMenuId;
@synthesize subMenuName;
@synthesize subMenuSrc;
@synthesize subMenuType;

- (GESubMenu*)initWithDict: (NSDictionary*)subMenuDict
{
    self = [super init];
    if (self) {
        self.subMenuId = [subMenuDict objectForKey: @"id"];
        self.subMenuName = [subMenuDict objectForKey: @"name"];
        self.subMenuSrc = [subMenuDict objectForKey: @"src"];
        self.subMenuType = [subMenuDict objectForKey: @"type"];
    }
    
    return self;
}

@end

@interface GESharedMenu ()
- (void)initialiseMenu;
@end

@implementation GESharedMenu

@synthesize menus = mMenus;

+ (id)sharedMenu
{
    static dispatch_once_t once;
    static GESharedMenu* sGESharedMenu = nil;
    dispatch_once(&once, ^
                  {
                      sGESharedMenu = [[self alloc] init];
                      [sGESharedMenu initialiseMenu];
                  });
    
    return sGESharedMenu;
}

- (void)initialiseMenu
{
    NSString* lBundlePath = [[NSBundle mainBundle] pathForResource:@"GalaMenuMetaData" ofType:@"json"];
    NSFileManager* lFileManager = [NSFileManager defaultManager];
    if (![lFileManager fileExistsAtPath: lBundlePath])
        return;
    
    NSData* lJsonData = [lFileManager contentsAtPath: lBundlePath];
    NSError* lError;
    
    if (lJsonData!=nil)
    {
        NSMutableArray* lGEMenus = [[NSMutableArray alloc] init];
        NSDictionary* lDict = [NSJSONSerialization JSONObjectWithData:lJsonData
                                                              options:kNilOptions error:&lError];
        NSArray* lCountries = [lDict objectForKey: @"countries"];
        for (NSDictionary* lCountry in lCountries)
        {
            NSArray* lMenus = [lCountry objectForKey: @"menus"];
            for (NSDictionary* lMenu in lMenus)
            {
                GEMenu* lGEMenu = [[GEMenu alloc] initWithDict: lMenu withCountry: lCountry];
                [lGEMenus addObject: lGEMenu];
            }
        }
        
        mMenus = [[NSArray alloc] initWithArray: lGEMenus];
    }
}

@end
