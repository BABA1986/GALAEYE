//
//  GEVideoPlayerCtr.h
//  GETube
//
//  Created by Deepak on 10/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GTLYouTube.h"
#import "YTPlayerView.h"
#import "GEEventManager.h"
#import "GEYoutubeResult.h"

@interface GEVideoPlayerCtr : UIViewController<YTPlayerViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UIView*                        mPlayerBaseView;
    IBOutlet UIImageView*                   mBrandLogoView;
    IBOutlet YTPlayerView*                  mPlayerView;
    __weak NSObject<GEYoutubeResult>*       mVideoItem;
    FetchEventQueryType                     mEventType;
    
    IBOutlet UIButton*                      mBackBtn;
    IBOutlet UIActivityIndicatorView*       mPlayerIndicator;
    
    IBOutlet UICollectionView*              mVideoListView;
    DGActivityIndicatorView*                mIndicator;    
}

@property(nonatomic, weak)NSObject<GEYoutubeResult>*         videoItem;
@property(nonatomic, assign)FetchEventQueryType              eventType;

- (IBAction)backButtonAction: (id)sender;

@end
