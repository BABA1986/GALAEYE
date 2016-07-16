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

@synthesize playListItem = mPlayListItem;

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
    self.title = self.playListItem.snippet.channelTitle;
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
    NSString* lVideoId = self.playListItem.contentDetails.videoId;
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
