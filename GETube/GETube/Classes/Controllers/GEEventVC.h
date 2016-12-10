//
//  GEEventVC.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GEEventHeader.h"
#import "GEEventCell.h"
#import "DGActivityIndicatorView.h"
#import "GENavigatorProtocol.h"

@class GEFullScreenAlert;
@interface GEEventVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GEEventHeaderDelegate, GEEventCellDelegate>
{
    IBOutlet UICollectionView*          mEventListView;
    DGActivityIndicatorView*            mIndicator;
    
    IBOutlet GEFullScreenAlert*         mConnectionErrView;
}

@property(nonatomic, weak)id<GENavigatorProtocol>           navigationDelegate;

- (void)applyTheme;
- (void)onLoginLogout: (BOOL)isLoggedIn;

@end
