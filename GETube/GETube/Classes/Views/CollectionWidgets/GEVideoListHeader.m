//
//  GEVideoListHeader.m
//  GETube
//
//  Created by Deepak on 03/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEVideoListHeader.h"
#import "GEConstants.h"

@implementation GEVideoListHeader

@synthesize baseView;
@synthesize listTitleLbl;
@synthesize channelNameLbl;
@synthesize noOfVideosLbl;

- (void)layoutSubviews
{
    [super layoutSubviews];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    self.baseView.backgroundColor = lNavColor;
    self.listTitleLbl.textColor = lNavTextColor;
    self.channelNameLbl.textColor = lNavTextColor;
    self.noOfVideosLbl.textColor = lNavTextColor;
}

@end
