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
#import "UIImage+ImageMask.h"

@implementation GEEventCell

@synthesize titleBaseView;
@synthesize titleLabel;
@synthesize timeLabel;
@synthesize statusLabel;
@synthesize videoIcon;
@synthesize videoPlayIcon;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ThemeManager* lManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lManager selectedNavColor];
    UIColor* lNavTextColor = [lManager selectedTextColor];

    self.titleLabel.textColor = [UIColor blackColor];
    self.timeLabel.textColor = [UIColor blackColor];
    self.statusLabel.backgroundColor = [lNavColor colorWithAlphaComponent: 0.5];
    self.statusLabel.textColor = lNavTextColor;
    self.contentView.backgroundColor = [lNavColor colorWithAlphaComponent: 0.2];
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
