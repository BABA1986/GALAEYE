//
//  ThemeManager.m
//  GETube
//
//  Created by Deepak on 05/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "ThemeManager.h"
#import "UIColor+HexColors.h"

@implementation ThemeInfo

@synthesize navColor;
@synthesize navTextColor;
@synthesize themeId;
@synthesize themeName;

- (instancetype)initWithDict: (NSDictionary*)themeDict
{
    self = [super init];
    if (self)
    {
        self.themeId = [themeDict objectForKey: @"id"];
        self.themeName = [themeDict objectForKey: @"themename"];
        NSString* lHexString = [themeDict objectForKey: @"navcolor"];
        self.navColor = [UIColor colorWithHexString: lHexString];
        lHexString = [themeDict objectForKey: @"navtextcolor"];
        self.navTextColor = [UIColor colorWithHexString: lHexString];
    }
    return self;
}
@end

@interface ThemeManager (private)
- (void)initiaiseThemes;
@end

@implementation ThemeManager

@synthesize themes = mThemes;
@synthesize selectedIndex = mSelectedIndex;

+ (id)themeManager
{
    static dispatch_once_t once;
    static ThemeManager* sThemeManager = nil;
    dispatch_once(&once, ^
                  {
                      sThemeManager = [[self alloc] init];
                      [sThemeManager initiaiseThemes];
                  });
    
    return sThemeManager;
}

- (void)initiaiseThemes
{
    NSString* lBundlePath = [[NSBundle mainBundle] pathForResource:@"ThemeColor" ofType:@"json"];
    NSFileManager* lFileManager = [NSFileManager defaultManager];
    if (![lFileManager fileExistsAtPath: lBundlePath])
    return;
    
    NSData* lJsonData = [lFileManager contentsAtPath: lBundlePath];
    NSError* lError;
    
    if (lJsonData != nil)
    {
        NSMutableArray* lThemes = [[NSMutableArray alloc] init];
        NSDictionary* lDict = [NSJSONSerialization JSONObjectWithData:lJsonData
                                                              options:kNilOptions error:&lError];
        NSArray* lThemesDict = [lDict objectForKey: @"Themes"];
        for (NSDictionary* lTheme in lThemesDict)
        {
            ThemeInfo* lThemeInfo = [[ThemeInfo alloc] initWithDict: lTheme];
            [lThemes addObject: lThemeInfo];
        }
        
        mThemes = [[NSArray alloc] initWithArray: lThemes];
    }
}

- (UIColor*)selectedNavColor
{
    ThemeInfo* lThemeInfo = [mThemes objectAtIndex: mSelectedIndex];
    return lThemeInfo.navColor;
}

- (UIColor*)selectedTextColor
{
    ThemeInfo* lThemeInfo = [mThemes objectAtIndex: mSelectedIndex];
    return lThemeInfo.navTextColor;
}

@end
