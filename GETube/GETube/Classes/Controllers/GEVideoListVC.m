//
//  GEEventVC.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEVideoListVC.h"
#import "GEEventCell.h"
#import "GEServiceManager.h"
#import "NSDate+TimeAgo.h"

@interface GEVideoListVC ()
{
    BOOL        mRequesting;
}
@end

@implementation GEVideoListVC

@synthesize channelSource = mChannelSource;
@synthesize videoEventType = mVideoEventType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    mVideoEventType = EFetchEventsNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    GEEventManager* lManager = [GEEventManager manager];
    if (mRequesting)
        return;

    mRequesting = TRUE;

    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadVideosFromChannelSource: self.channelSource eventType: mVideoEventType onCompletion: ^(BOOL success)
     {
         [mVideoListView reloadData];
         [mIndicator stopAnimating];
         mIndicator.hidden = TRUE;
         mRequesting = FALSE;
     }];
}

- (void)applyTheme
{
    [mVideoListView reloadData];
}

- (void)addIndicatorView
{
    [mIndicator removeFromSuperview];
    mIndicator = nil;
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    
    mIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots tintColor:lNavColor size:40.0f];
    CGRect lIndicatorFrame = self.view.bounds;
    lIndicatorFrame.size.width = 50.0;
    lIndicatorFrame.size.height = 50.0;
    lIndicatorFrame.origin.x = (CGRectGetWidth(self.view.bounds) - lIndicatorFrame.size.width)/2;
    lIndicatorFrame.origin.y = (CGRectGetHeight(self.view.bounds) - lIndicatorFrame.size.height)/2;
    mIndicator.frame = lIndicatorFrame;
    [self.view addSubview: mIndicator];
}

#pragma mark-
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    return lEventObj.eventListPages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: section];
    return lEventPageObj.eventList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GESearchVideoCellID";
    
    GEEventCell* lCell = (GEEventCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    GTLYouTubeSearchResult* lEvent = [lEventPageObj.eventList objectAtIndex: indexPath.row];
    
    lCell.titleLabel.text = lEvent.snippet.title;
    lCell.timeLabel.text = [lEvent.snippet.publishedAt.date dateTimeAgo];
    if (indexPath.section == 0) {
        lCell.statusLabel.text = @"Live";
    }
    else if (indexPath.section == 1) {
        lCell.statusLabel.text = @"Upcomming";
    }
    else if (indexPath.section == 2) {
        lCell.statusLabel.text = @"Completed";
    }
    
    NSURL* lThumbUrl = [NSURL URLWithString: lEvent.snippet.thumbnails.medium.url];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    
    return lCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];

    if (indexPath.section == lEventObj.eventListPages.count - 1)
    {
        if (mRequesting)
            return;
        
        mRequesting = TRUE;
        GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
        [lServiceMngr loadVideosFromChannelSource: self.channelSource eventType: mVideoEventType onCompletion: ^(BOOL success)
         {
             [mVideoListView reloadData];
             mRequesting = FALSE;
         }];
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lLength = self.view.bounds.size.width/2 - 3.0;
    CGSize lItemSize = CGSizeMake(lLength, 0.90*lLength);
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    if (lEventPageObj.eventList.count < 4 && lEventPageObj.eventList.count % 2 != 0 && indexPath.row == 0)
    {
        lLength += self.view.bounds.size.width/2;
        lItemSize = CGSizeMake(lLength, 0.50*lLength);
        return lItemSize;
    }
    
    return lItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}

@end
