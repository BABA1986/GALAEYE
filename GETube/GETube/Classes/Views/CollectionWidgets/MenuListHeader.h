//
//  MenuListHeader.h
//  GETube
//
//  Created by Deepak on 06/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuListHeader;
@protocol MenuListHeaderDelegate <NSObject>

- (void)menuListHeader: (MenuListHeader*)header didSelectAtIndex: (NSUInteger)index;

@end

@interface MenuListHeader : UIView
{
    UILabel*                                mTitleLabel;
    UIImageView*                            mExpandView;
    NSUInteger                              mSectionIndex;
    
    __weak id<MenuListHeaderDelegate>       mDelegate;
}

@property(nonatomic, strong)UILabel*                    titleLabel;
@property(nonatomic, strong)UIImageView*                expandView;
@property(nonatomic, assign)NSUInteger                  sectionIndex;
@property(nonatomic, weak)id<MenuListHeaderDelegate>    delegate;

@end
