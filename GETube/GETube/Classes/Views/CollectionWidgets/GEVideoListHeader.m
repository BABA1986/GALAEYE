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
    
    self.baseView.backgroundColor = kDefaultThemeColor;
    self.listTitleLbl.textColor = kDefaultTitleColor;
    self.channelNameLbl.textColor = kDefaultTitleColor;
    self.noOfVideosLbl.textColor = kDefaultTitleColor;
}

@end
