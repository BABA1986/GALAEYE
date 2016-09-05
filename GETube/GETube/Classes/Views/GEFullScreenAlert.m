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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [mActionBtn setImage: [UIImage imageWithName: @"networkerror.png"] forState: UIControlStateNormal];
    [mActionBtn setImage: [UIImage imageWithName: @"networkerror.png"] forState: UIControlStateHighlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
