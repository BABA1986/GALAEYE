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
#import "GENavigatorProtocol.h"
#import "GEFullScreenAlert.h"
#import "GEEventCell.h"

@interface GEVideoListVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, GEEventCellDelegate>
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
- (void)onLoginLogout: (BOOL)isLoggedIn;
- (void)loadData;

@end
