//
//  GESharedMenu.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GEMenu : NSObject
@property(nonatomic, copy)NSString*     menuId;
@property(nonatomic, copy)NSString*     menuName;
@property(nonatomic, copy)NSString*     menuCountry;
@property(nonatomic, copy)NSString*     menuCountryCode;
@property(nonatomic, copy)NSString*     menuImageIcon;
@property(nonatomic, strong)NSArray*    subMenus;
- (GEMenu*)initWithDict: (NSDictionary*)menuDict
            withCountry: (NSDictionary*)countryInfo;
@end

@interface GESubMenu : NSObject
@property(nonatomic, copy)NSString*     subMenuId;
@property(nonatomic, copy)NSString*     subMenuName;
@property(nonatomic, copy)NSString*     subMenuSrc;
@property(nonatomic, copy)NSString*     subMenuType;
- (GESubMenu*)initWithDict: (NSDictionary*)subMenuDict;
@end

@interface GESharedMenu : NSObject
{
    NSArray*                mMenus;
}
@property(nonatomic, strong)NSArray*    menus;
+ (id)sharedMenu;
@end
