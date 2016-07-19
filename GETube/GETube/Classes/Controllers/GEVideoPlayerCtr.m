//
//  GEVideoPlayerCtr.m
//  GETube
//
//  Created by Deepak on 10/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEVideoPlayerCtr.h"
#import "UIImage+ImageMask.h"
#import "UIImage+ImageMask.h"

@interface GEVideoPlayerCtr ()

@end

@implementation GEVideoPlayerCtr

@synthesize videoItem = mVideoItem;
@synthesize eventType = mEventType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mLoadingIconView.image = [UIImage imageWithName: @"loadingthumbnailurl.png"];
    mBrandLogoView.image = [UIImage imageWithName: @"smalllogo.png"];
    
    UIBarButtonItem* lBackItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithName: @"backarrow.png"]
                                                                  style: UIBarButtonItemStyleDone
                                                                 target: self
                                                                 action: @selector(backButtonAction:)];
    
    self.navigationItem.leftBarButtonItem = lBackItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    NSString* lChannelTitle = @"";
    
    if (self.eventType == EFetchEventsNone) {
        GTLYouTubePlaylistItem* lVideoItem = (GTLYouTubePlaylistItem*)mVideoItem;
        lChannelTitle = lVideoItem.snippet.channelTitle;
    }
    else {
        GTLYouTubeSearchResult* lVideoItem = (GTLYouTubeSearchResult*)mVideoItem;
        lChannelTitle = lVideoItem.snippet.channelTitle;
    }
    self.title = lChannelTitle;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    NSDictionary* lPlayerVars = @{
                                  @"playsinline" : @1,
                                  @"enablejsapi": @1,
                                  @"autohide" : @0,
                                  @"controls" : @1,
                                  @"showinfo" : @1,
                                  @"modestbranding" : @1,
                                  @"autoplay" : @1,
                                  @"origin" : @"https://www.google.com",
                                  };
    
    mPlayerView.delegate = self;
    mPlayerView.translatesAutoresizingMaskIntoConstraints = TRUE;
    
    NSString* lVideoId = @"";
    if (self.eventType == EFetchEventsNone) {
        GTLYouTubePlaylistItem* lVideoItem = (GTLYouTubePlaylistItem*)mVideoItem;
        lVideoId = lVideoItem.contentDetails.videoId;
    }
    else {
        GTLYouTubeSearchResult* lVideoItem = (GTLYouTubeSearchResult*)mVideoItem;
        lVideoId = lVideoItem.identifier.videoId;
    }
    
    [mPlayerView loadWithVideoId: lVideoId playerVars: lPlayerVars];
    [self.view bringSubviewToFront: mPlayerBaseView];
}

- (void)backButtonAction: (id)sender
{
    [self.navigationController popViewControllerAnimated: TRUE];
}

#pragma mark-
#pragma mark- YTPlayerViewDelegate
#pragma mark-

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [mPlayerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{

}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    
}

- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(YTPlayerView *)playerView
{
    return [UIColor clearColor];
}

- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull YTPlayerView *)playerView
{
    return mLoadingIconView;
}

@end
