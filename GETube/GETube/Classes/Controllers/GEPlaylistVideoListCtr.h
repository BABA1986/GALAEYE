//
//  GEPlaylistVideoListCtr.h
//  GETube
//
//  Created by Deepak on 01/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GTLYouTube.h"
#import "GEYoutubeResult.h"

@interface GEPlaylistVideoListCtr : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*              mVideoListView;
    DGActivityIndicatorView*                mIndicator;
    __weak NSObject <GEYoutubeResult>*      mFromPlayList;
}

@property(nonatomic, weak)NSObject <GEYoutubeResult>*       fromPlayList;

- (void)applyTheme;
- (void)onLoginLogout: (BOOL)isLoggedIn;

@end
