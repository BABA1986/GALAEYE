//
//  MenuListHeader.m
//  GETube
//
//  Created by Deepak on 06/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "MenuListHeader.h"

@implementation MenuListHeader

@synthesize titleLabel = mTitleLabel;
@synthesize expandView = mExpandView;
@synthesize sectionIndex = mSectionIndex;
@synthesize delegate = mDelegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect lTitleRect = self.bounds;
        lTitleRect.size.width -= 45.0;
        lTitleRect.origin.x = 10.0;
        mTitleLabel = [[UILabel alloc] initWithFrame: lTitleRect];
        [self addSubview: mTitleLabel];
        
        CGRect lIconRect = CGRectZero;
        lIconRect.size.width = 30.0; lIconRect.size.height = 30.0;
        lIconRect.origin.x = CGRectGetWidth(self.bounds) - 30.0;
        lIconRect.origin.y = (CGRectGetHeight(self.bounds) - 30.0)/2;
        mExpandView = [[UIImageView alloc] initWithFrame: lIconRect];
        [self addSubview: mExpandView];
        
        UITapGestureRecognizer* lTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
        [self addGestureRecognizer: lTapGesture];
    }
    return self;
}

- (void)tapOnView: (UITapGestureRecognizer*)gesture
{
    [mDelegate menuListHeader: self didSelectAtIndex: self.sectionIndex];
}

@end
