//
//  GEPlaylistVC.h
//  GETube
//
//  Created by Deepak on 23/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GENavigatorProtocol.h"

@class GEFullScreenAlert;
@interface GEPlaylistVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*          mPlaylistListView;
    DGActivityIndicatorView*            mIndicator;
    
    IBOutlet GEFullScreenAlert*         mConnectionErrView;
}

@property(nonatomic, copy)NSString*                         listSource;
@property(nonatomic, weak)id<GENavigatorProtocol>           navigationDelegate;

- (void)applyTheme;
- (void)onLoginLogout: (BOOL)isLoggedIn;

@end
