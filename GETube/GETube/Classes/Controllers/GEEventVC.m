//
//  GEEventVC.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEEventVC.h"
#import "GEEventCell.h"
#import "GEServiceManager.h"
#import "GEEventManager.h"
#import "NSDate+TimeAgo.h"
#import "GEVideoPlayerCtr.h"

@implementation GEEventVC

@synthesize navigationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    GEEventManager* lManager = [GEEventManager manager];
    if (lManager.eventListObjs.count)
    return;
    
    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadAllEventsForFirstPage: ^(FetchEventQueryType eventQueryType)
     {
         [mEventListView reloadData];
         [mIndicator stopAnimating];
         mIndicator.hidden = TRUE;
     }];
}

- (void)applyTheme
{
    [mEventListView reloadData];
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
    return lManager.eventListObjs.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager.eventListObjs objectAtIndex: section];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages firstObject];
    if (lEventPageObj.eventList.count > 4)
        return 4;
    
    return lEventPageObj.eventList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEEventCellID";
    
    GEEventCell* lCell = (GEEventCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager.eventListObjs objectAtIndex: indexPath.section];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages firstObject];
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

    NSURL* lThumbUrl = [NSURL URLWithString: lEvent.snippet.thumbnails.high.url];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    
    return lCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        GEEventHeader* lHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEEventHeaderID" forIndexPath:indexPath];
        if (indexPath.section == 0)
        {
            lHeaderView.titleLabel.text = @"Live";
        }
        else if (indexPath.section == 1)
        {
            lHeaderView.titleLabel.text = @"Upcomming";
        }
        else
        {
            lHeaderView.titleLabel.text = @"Completed";
        }

        GEEventManager* lManager = [GEEventManager manager];
        GEEventListObj* lEventObj = [lManager.eventListObjs objectAtIndex: indexPath.section];
        GEEventListPage* lEventPageObj = [lEventObj.eventListPages firstObject];
        lHeaderView.seeMoreBtn.hidden = (lEventPageObj.eventList.count <= 4);
        reusableview = lHeaderView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager.eventListObjs objectAtIndex: section];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages firstObject];
    if (!lEventPageObj.eventList.count)
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lWidth = self.view.bounds.size.width/2 - 3.0;
    CGFloat lHeight = 9.0*lWidth/16.0 + 50.0;
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager.eventListObjs objectAtIndex: indexPath.section];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages firstObject];
    if (lEventPageObj.eventList.count < 4 && lEventPageObj.eventList.count % 2 != 0 && indexPath.row == 0)
    {
        lWidth = self.view.bounds.size.width - 3.0;
        lHeight = 9.0*lWidth/16.0 + 50.0;
        lItemSize = CGSizeMake(lWidth, lHeight);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GEEventManager* lManager = [GEEventManager manager];
    
    FetchEventQueryType lQueryType = EFetchEventsLive;
    if (indexPath.section == 1)
        lQueryType = EFetchEventsCompleted;
    else if (indexPath.section == 2)
        lQueryType = EFetchEventsUpcomming;
    else
        lQueryType = EFetchEventsLive;
    
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: lQueryType forSource: kGEChannelID];
    GEEventListPage* lEventPage = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    GTLYouTubeSearchResult* lSearchResult = [lEventPage.eventList objectAtIndex: indexPath.row];
    UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GEVideoPlayerCtr* lGEVideoPlayerCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEVideoPlayerCtrID"];
    FetchEventQueryType lEventType = EFetchEventsNone;
    if (indexPath.section == 0) {
        lEventType = EFetchEventsLive;
    }
    else if (indexPath.section == 1) {
        lEventType = EFetchEventsUpcomming;
    }
    else {
        lEventType = EFetchEventsCompleted;
    }

    lGEVideoPlayerCtr.eventType = lEventType;
    lGEVideoPlayerCtr.videoItem = lSearchResult;
    lGEVideoPlayerCtr.view.frame = self.view.bounds;
    [self.navigationDelegate moveToViewController: lGEVideoPlayerCtr fromViewCtr: self];
}


#pragma mark-
#pragma mark- GEEventHeaderDelegate
#pragma mark-

- (void)didSelectSeeMoreOnGEEventHeader: (GEEventHeader*)header
{
    
}

@end
