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
#import "UIImage+ImageMask.h"


@implementation GEVideoListCell

@synthesize titleBaseView;
@synthesize titleLabel;
@synthesize timeLabel;
@synthesize statusLabel;
@synthesize videoIcon;
@synthesize videoPlayIcon;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    self.contentView.backgroundColor = [lNavColor colorWithAlphaComponent: 0.2];
    self.titleLabel.textColor = [UIColor blackColor];
    self.timeLabel.textColor = [UIColor blackColor];
    self.statusLabel.alpha = 0.5;
    self.statusLabel.textColor = [UIColor blackColor];
    self.videoPlayIcon.image = [UIImage imageWithName: @"playlistIcon.png"];
}

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl
{
    SDImageCache* lShCacheImage = [SDImageCache sharedImageCache];
    SDWebImageManager* lManager = [SDWebImageManager sharedManager];
    NSString* lKey= [lManager cacheKeyForURL: thumbUrl];
    UIImage* lImage = [lShCacheImage imageFromDiskCacheForKey: lKey];
    if (lImage) {
        self.videoIcon.image = lImage;
        return;
    }
    
    UIImage* lLoadingImage = [UIImage imageWithName: @"loadingthumbnailurl.png"];    
    [self.videoIcon sd_setImageWithURL:thumbUrl placeholderImage:lLoadingImage completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             [UIView transitionWithView:self.videoIcon
                               duration:0.3
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^{
                                 [self.videoIcon setImage:image];
                             } completion:NULL];
         }
     }];
}

@end
