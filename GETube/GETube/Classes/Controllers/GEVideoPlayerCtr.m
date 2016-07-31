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
    mBrandLogoView.image = [UIImage imageWithName: @"smalllogo.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    NSString* lChannelTitle = [self.videoItem GETitle];
    self.title = lChannelTitle;
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = FALSE;
    [super viewWillDisappear: animated];
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
    
    NSString* lVideoId = [self.videoItem GEId];
    [mPlayerView loadWithVideoId: lVideoId playerVars: lPlayerVars];
    
    [mPlayerIndicator startAnimating];
}

- (IBAction)backButtonAction: (id)sender
{
    [self.navigationController popViewControllerAnimated: TRUE];
}

#pragma mark-
#pragma mark- YTPlayerViewDelegate
#pragma mark-

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [mPlayerIndicator stopAnimating];
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
    return [UIColor blackColor];
}

- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull YTPlayerView *)playerView
{
    UIImageView* lPlaceHolderView = [[UIImageView alloc] initWithImage: [UIImage imageWithName: @"loadingthumbnailurl.png"]];
    lPlaceHolderView.backgroundColor = [UIColor blackColor];
    return lPlaceHolderView;
}

@end
