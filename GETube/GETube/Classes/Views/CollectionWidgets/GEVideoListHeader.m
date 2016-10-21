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
@synthesize titleHeight;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.baseView.backgroundColor = [UIColor clearColor];
    self.listTitleLbl.textColor = [UIColor darkGrayColor];
    self.channelNameLbl.textColor = [UIColor darkGrayColor];;
    self.noOfVideosLbl.textColor = [UIColor darkGrayColor];;
    
    self.backgroundColor = [UIColor clearColor];
}

@end
