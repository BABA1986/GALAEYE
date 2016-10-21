//
//  GEPlaylistCell.m
//  GETube
//
//  Created by Deepak on 24/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPlaylistCell.h"
#import "GEConstants.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageMask.h"

@implementation GEPlaylistCell

@synthesize thumbIconView;
@synthesize playlistIconView;
@synthesize overlayView;
@synthesize noOfVideoLbl;
@synthesize videoLbl;
@synthesize videoTileLbl;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    self.overlayView.backgroundColor = [lNavColor colorWithAlphaComponent: 0.5];
    self.noOfVideoLbl.textColor = lNavTextColor;
    self.videoLbl.textColor = lNavTextColor;
    self.videoTileLbl.textColor = [UIColor darkGrayColor];
    self.playlistIconView.image = [UIImage imageWithName: @"playlistIcon.png"];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl
{
    SDImageCache* lShCacheImage = [SDImageCache sharedImageCache];
    SDWebImageManager* lManager = [SDWebImageManager sharedManager];
    NSString* lKey= [lManager cacheKeyForURL: thumbUrl];
    UIImage* lImage = [lShCacheImage imageFromDiskCacheForKey: lKey];
    if (lImage) {
        self.thumbIconView.image = lImage;
        return;
    }
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIImage* lLoadingImage = [UIImage createImageFromMask: [UIImage imageNamed: @"loadingthumbnailurl.png"] withFillColor: lNavColor];
    
    [self.thumbIconView sd_setImageWithURL:thumbUrl placeholderImage:lLoadingImage completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             [UIView transitionWithView:self.thumbIconView
                               duration:0.3
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^{
                                 [self.thumbIconView setImage:image];
                             } completion:NULL];
         }
     }];
}

@end
