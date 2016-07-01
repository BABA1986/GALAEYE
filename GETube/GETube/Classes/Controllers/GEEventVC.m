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

//Layout Optimisation

@implementation GEEventVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    UICollectionViewFlowLayout* lLayout = (UICollectionViewFlowLayout*) mEventListView.collectionViewLayout;
    CGFloat lLength = self.view.bounds.size.width/2 - 3.0;
    lLayout.itemSize = CGSizeMake(lLength, 0.85*lLength);
    lLayout.sectionInset = UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0);
    lLayout.minimumInteritemSpacing = 0.0;
    lLayout.minimumLineSpacing = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
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

- (void)addIndicatorView
{
    [mIndicator removeFromSuperview];
    mIndicator = nil;
    mIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots tintColor:kDefaultThemeColor size:20.0f];
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
        else if (indexPath.section == 0)
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

#pragma mark-
#pragma mark- GEEventHeaderDelegate
#pragma mark-

- (void)didSelectSeeMoreOnGEEventHeader: (GEEventHeader*)header
{
    
}

@end
