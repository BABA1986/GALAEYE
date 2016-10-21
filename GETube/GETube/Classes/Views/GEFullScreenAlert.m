//
//  GEFullScreenAlert.m
//  GETube
//
//  Created by Deepak on 05/09/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEFullScreenAlert.h"
#import "UIImage+ImageMask.h"

@implementation GEFullScreenAlert

@synthesize titleLabel = mTitleLabel;
@synthesize descLabel = mDescLabel;
@synthesize iconView = mIconView;
@synthesize actionBtn = mActionBtn;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    mTitleLabel.textColor = [UIColor darkGrayColor];
    mDescLabel.textColor = [UIColor darkGrayColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
