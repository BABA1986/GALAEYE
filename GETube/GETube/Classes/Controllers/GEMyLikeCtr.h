//
//  GEMyLikeCtr.h
//  GETube
//
//  Created by Deepak on 26/09/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GTLYouTube.h"
#import "GEEventManager.h"
#import "GENavigatorProtocol.h"
#import "GEFullScreenAlert.h"


@interface GEMyLikeCtr : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*      mVideoListView;
    IBOutlet GEFullScreenAlert*     mFullPageErrView;
    
    DGActivityIndicatorView*        mIndicator;
    NSString*                       mChannelSource;
    FetchEventQueryType             mVideoEventType;
}

@property(nonatomic, copy)NSString*                     channelSource;
@property(nonatomic, assign)FetchEventQueryType         videoEventType;
@property(nonatomic, weak)id<GENavigatorProtocol>       navigationDelegate;

- (void)applyTheme;

@end
