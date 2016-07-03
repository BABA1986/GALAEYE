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

@interface GEPlaylistVideoListCtr : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*      mVideoListView;
    DGActivityIndicatorView*        mIndicator;
    __weak GTLYouTubePlaylist*      mFromPlayList;
}

@property(nonatomic, weak)GTLYouTubePlaylist*       fromPlayList;

@end
