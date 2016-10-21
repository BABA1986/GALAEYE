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
@synthesize titleBaseView;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];

    self.titleBaseView.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    [self.seeMoreBtn setBackgroundColor: lNavColor];
    [self.seeMoreBtn setTitleColor: lNavTextColor forState: UIControlStateNormal];
}

- (IBAction)seeMoreBtnAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSeeMoreOnGEEventHeader:)])
    {
        [self.delegate didSelectSeeMoreOnGEEventHeader: self];
    }
}

@end
