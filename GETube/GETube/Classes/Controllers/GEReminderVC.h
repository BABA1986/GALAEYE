//
//  GEReminderVC.h
//  GETube
//
//  Created by Deepak on 06/11/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
#import "GTLYouTube.h"
#import "GEEventManager.h"
#import "GENavigatorProtocol.h"
#import "GEFullScreenAlert.h"
#import "GEEventCell.h"


@interface GEReminderVC : UIViewController <GEEventCellDelegate>
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
