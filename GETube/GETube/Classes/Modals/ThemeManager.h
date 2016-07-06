//
//  ThemeManager.h
//  GETube
//
//  Created by Deepak on 05/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ThemeInfo : NSObject
@property(nonatomic, strong)UIColor*        navColor;
@property(nonatomic, strong)UIColor*        navTextColor;
@property(nonatomic, copy)NSString*         themeId;
@property(nonatomic, copy)NSString*         themeName;

- (instancetype)initWithDict: (NSDictionary*)themeDict;

@end

@interface ThemeManager : NSObject
{
    NSArray*            mThemes;
    NSUInteger          mSelectedIndex;
}

@property(nonatomic, assign)NSUInteger      selectedIndex;
@property(nonatomic, strong)NSArray*        themes;

+ (id)themeManager;
- (UIColor*)selectedNavColor;
- (UIColor*)selectedTextColor;

@end
