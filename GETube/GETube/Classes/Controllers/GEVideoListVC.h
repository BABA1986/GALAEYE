//
//  GEVideoListVC.h
//  GETube
//
//  Created by Deepak on 16/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GTLYouTube.h"
#import "GEEventManager.h"

@interface GEVideoListVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*      mVideoListView;
    DGActivityIndicatorView*        mIndicator;
    __weak GTLYouTubePlaylist*      mFromPlayList;
    
    NSString*                       mChannelSource;
    FetchEventQueryType             mVideoEventType;
}

@property(nonatomic, copy)NSString*                     channelSource;
@property(nonatomic, assign)FetchEventQueryType         videoEventType;

- (void)applyTheme;

@end