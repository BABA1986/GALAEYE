//
//  GEVideoPlayerCtr.h
//  GETube
//
//  Created by Deepak on 10/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLYouTube.h"
#import "YTPlayerView.h"
#import "GEEventManager.h"
#import "GEYoutubeResult.h"

@interface GEVideoPlayerCtr : UIViewController<YTPlayerViewDelegate>
{
    IBOutlet UIView*                        mPlayerBaseView;
    IBOutlet UIImageView*                   mBrandLogoView;
    IBOutlet YTPlayerView*                  mPlayerView;
    __weak NSObject<GEYoutubeResult>*       mVideoItem;
    FetchEventQueryType                     mEventType;
    
    IBOutlet UIImageView*                   mTestImageView;
    IBOutlet UIButton*                      mBackBtn;
    IBOutlet UIActivityIndicatorView*       mPlayerIndicator;
}

@property(nonatomic, weak)NSObject<GEYoutubeResult>*         videoItem;
@property(nonatomic, assign)FetchEventQueryType              eventType;

- (IBAction)backButtonAction: (id)sender;

@end
