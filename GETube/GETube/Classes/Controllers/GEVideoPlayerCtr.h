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

@interface GEVideoPlayerCtr : UIViewController<YTPlayerViewDelegate>
{
    IBOutlet UIView*                        mPlayerBaseView;
    IBOutlet UIImageView*                   mLoadingIconView;
    IBOutlet UIImageView*                   mBrandLogoView;
    IBOutlet YTPlayerView*                  mPlayerView;
    __weak id                               mVideoItem;
    FetchEventQueryType                     mEventType;
}

@property(nonatomic, weak)id                                 videoItem;
@property(nonatomic, assign)FetchEventQueryType              eventType;

@end
