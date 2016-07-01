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

@implementation GEPlaylistCell

@synthesize thumbIconView;
@synthesize playlistIconView;
@synthesize noOfVideoLbl;
@synthesize videoLbl;
@synthesize videoTileLbl;

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.noOfVideoLbl.textColor = kDefaultThemeColor;
    self.videoLbl.textColor = kDefaultThemeColor;
    self.videoTileLbl.textColor = kDefaultThemeColor;
}

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl
{
    [self.thumbIconView sd_setImageWithURL:thumbUrl placeholderImage:[UIImage imageNamed:@"loading_ds.png"] completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         self.thumbIconView.image = image;
     }]; 
}

@end
