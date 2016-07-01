//
//  GEEventHeader.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEEventHeader.h"
#import "GEConstants.h"

@implementation GEEventHeader

@synthesize titleLabel;
@synthesize seeMoreBtn;
@synthesize index = mIndex;
@synthesize delegate;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.backgroundColor = kDefaultThemeColor;
    self.titleLabel.textColor = kDefaultTitleColor;
    [self.seeMoreBtn setBackgroundColor: kDefaultTitleColor];
    [self.seeMoreBtn setTitleColor: kDefaultThemeColor forState: UIControlStateNormal];
}

- (IBAction)seeMoreBtnAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSeeMoreOnGEEventHeader:)])
    {
        [self.delegate didSelectSeeMoreOnGEEventHeader: self];
    }
}

@end
