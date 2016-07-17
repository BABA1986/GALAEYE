//
//  CPDropDownSelector.h
//  ColorPicker
//
//  Created by Amit Jangirh on 06/06/13.
//  Copyright (c) 2014 wincere Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectorTitle      @"Playlists"

/////////////////////////////////////// CPDropDownSelectorDataSource ////////////////////////////////////

@class CPDropDownSelector;
@protocol CPDropDownSelectorDataSource <NSObject>
- (NSInteger)numberOfRowsInDropDownSelector:(CPDropDownSelector*)selector;
- (NSString*)dropDownSelector:(CPDropDownSelector*)selector textForRow:(NSInteger)row;
@optional // For Mutiselect
- (CGFloat)dropDownSelector:(CPDropDownSelector*)selector heightForRow:(NSInteger)row;
@end

/////////////////////////////////////// CPDropDownSelectorDelegate //////////////////////////////////////

@protocol CPDropDownSelectorDelegate <NSObject>
@optional
- (void)dropDownSelector:(CPDropDownSelector*)selector didSelectedRow:(NSInteger)row;
- (void)dropDownSelector:(CPDropDownSelector*)selector didSelected:(BOOL)selected row:(NSInteger)row;
- (BOOL)dropDownSelector:(CPDropDownSelector*)selector  shouldShowSelectedRow:(NSInteger)row;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CPDropDownSelector :UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet id<CPDropDownSelectorDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<CPDropDownSelectorDataSource> dataSource;

@property (nonatomic, assign) CGFloat animDuration;              // content view show - hide animation duration, Default 0.2
@property (nonatomic, assign) NSInteger selectedIndex;           // Default Index 0,
@property (nonatomic, assign) BOOL allowMultiSelection;          // Default NO,
@property (nonatomic, retain) NSString* selectorTitle;
@property (nonatomic, assign) BOOL      shouldHideSelectLabel;          // Default NO,

- (id)initWithFrame:(CGRect)frame;

- (void)hideDrop;       // use it to force fully remove Dropdown menu,
- (void)setFont:(UIFont*)font;
- (void)setText:(NSString*)text;
- (NSString*)getText;
- (void)reloadData;
- (void)makeEnable:(BOOL)enable;

@end