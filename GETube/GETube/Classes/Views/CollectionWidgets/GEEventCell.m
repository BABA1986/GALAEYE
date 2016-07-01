//
//  GEEventCell.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEEventCell.h"
#import "GEConstants.h"
#import "UIImageView+WebCache.h"

@implementation GEEventCell

@synthesize titleBaseView;
@synthesize titleLabel;
@synthesize timeLabel;
@synthesize statusLabel;
@synthesize videoIcon;

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleBaseView.backgroundColor = kDefaultTitleColor;
    self.titleLabel.textColor = kDefaultThemeColor;
    self.timeLabel.textColor = kDefaultThemeColor;
    self.statusLabel.alpha = 0.5;
    self.statusLabel.backgroundColor = kDefaultThemeColor;
    self.statusLabel.textColor = kDefaultTitleColor;
}

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl
{
    [self.videoIcon sd_setImageWithURL:thumbUrl placeholderImage:[UIImage imageNamed:@"loading_ds.png"] completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         self.videoIcon.image = image;
     }];
}

@end
