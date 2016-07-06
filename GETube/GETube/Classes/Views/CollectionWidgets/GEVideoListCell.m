//
//  GEVideoListCell.m
//  GETube
//
//  Created by Deepak on 03/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEVideoListCell.h"
#import "GEConstants.h"
#import "UIImageView+WebCache.h"


@implementation GEVideoListCell

@synthesize titleBaseView;
@synthesize titleLabel;
@synthesize timeLabel;
@synthesize statusLabel;
@synthesize videoIcon;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.textColor = [UIColor blackColor];
    self.timeLabel.textColor = [UIColor blackColor];
    self.statusLabel.alpha = 0.5;
    self.statusLabel.textColor = [UIColor blackColor];
}

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl
{
    [self.videoIcon sd_setImageWithURL:thumbUrl placeholderImage:[UIImage imageNamed:@"loading_ds.png"] completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         self.videoIcon.image = image;
     }];
}

@end
