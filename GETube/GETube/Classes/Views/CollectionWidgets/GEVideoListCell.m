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
    
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.timeLabel.textColor = [UIColor darkGrayColor];
    self.statusLabel.alpha = 0.5;
    self.statusLabel.textColor = [UIColor blackColor];
    self.videoPlayIcon.image = [UIImage imageWithName: @"play-Icon.png"];
    self.contentView.backgroundColor = [UIColor whiteColor];
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
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIImage* lLoadingImage = [UIImage createImageFromMask: [UIImage imageNamed: @"loadingthumbnailurl.png"] withFillColor: lNavColor];
    
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
