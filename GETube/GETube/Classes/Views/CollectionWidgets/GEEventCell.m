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
@synthesize alarmBtn;
@synthesize delegate = mDelegate;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ThemeManager* lManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lManager selectedNavColor];
    UIColor* lNavTextColor = [lManager selectedTextColor];

    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.timeLabel.textColor = [UIColor darkGrayColor];
    self.statusLabel.backgroundColor = [lNavColor colorWithAlphaComponent: 0.5];
    self.statusLabel.textColor = lNavTextColor;
    
    UIImage* lNormalImg = [UIImage createImageFromMask: [UIImage imageNamed: @"alarmOff.png"] withFillColor: lNavColor];
    [self.alarmBtn setImage: lNormalImg forState: UIControlStateNormal];
    
    UIImage* lSelectedImg = [UIImage createImageFromMask: [UIImage imageNamed: @"alarmOn.png"] withFillColor: lNavColor];
    [self.alarmBtn setImage: lSelectedImg forState: UIControlStateSelected];
    
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

- (IBAction)alarmBtnClicked:(id)sender
{
    UIButton* lAlarmBtn = (UIButton*)sender;
    lAlarmBtn.selected = !lAlarmBtn.selected;
    
    if(mDelegate && [mDelegate respondsToSelector: @selector(didSelectAlarmButtonInCell:)])
    {
        [mDelegate didSelectAlarmButtonInCell: self];
    }
}

@end
