//
//  GEReminderVC.m
//  GETube
//
//  Created by Deepak on 06/11/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEReminderVC.h"
#import "GEServiceManager.h"
#import "NSDate+TimeAgo.h"
#import "GEVideoPlayerCtr.h"
#import "GELoadingFooter.h"
#import "UIImage+ImageMask.h"
#import "GEYoutubeResult.h"
#import "GEEventCell.h"
#import "Reachability.h"
#import "UserDataManager.h"
#import "SharedReminder.h"

@interface GEReminderVC ()
{
    BOOL        mRequesting;
}

- (void)loadData;
- (BOOL)checkForInternetConnection;
- (void)showDataNotAvailable;
- (IBAction)alertActionBtnClicked:(id)sender;

@end

@implementation GEReminderVC

@synthesize channelSource = mChannelSource;
@synthesize videoEventType = mVideoEventType;
@synthesize navigationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    mFullPageErrView.hidden = TRUE;
    self.view.backgroundColor = [UIColor colorWithRed: 245.0/255.0 green: 245.0/255.0 blue: 245.0/255.0 alpha: 1.0];
    mVideoListView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)loadData
{
    if (![self checkForInternetConnection])
        return;
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    
    if (mRequesting || lEventObj.eventListPages.count)
    {
        [mVideoListView reloadData];
        [self showDataNotAvailable];
        return;
    }
    
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
         
         if (mVideoEventType == EFetchEventsReminders)
             [self showDataNotAvailable];
     }];
}

- (BOOL)checkForInternetConnection
{
    Reachability* lNetReach = [Reachability reachabilityWithHostName: @"www.google.com"];
    NetworkStatus lNetStatus = [lNetReach currentReachabilityStatus];
    if (lNetStatus == NotReachable)
    {
        mFullPageErrView.titleLabel.text = @"No Connection";
        mFullPageErrView.descLabel.text = @"Please check your internet connectivity and try again.";
        mFullPageErrView.iconView.image = [UIImage imageNamed: @"networkerror.png"];
        [mFullPageErrView.actionBtn setTitle: @"" forState: UIControlStateNormal];
        [mFullPageErrView.actionBtn setImage: [UIImage imageNamed: @"retry-normal.png"] forState: UIControlStateNormal];
        [mFullPageErrView.actionBtn setImage: [UIImage imageNamed: @"retry-highlighted.png"] forState: UIControlStateHighlighted];
        
        [self.view bringSubviewToFront: mFullPageErrView];
        return NO;
    }
    
    [self.view bringSubviewToFront: mVideoListView];
    return YES;
}

- (void)showDataNotAvailable
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];

    BOOL lListBlank = !lEventObj.eventListPages.count;
    if (lEventObj.eventListPages.count) {
        GEEventListPage* lEventPage = [lEventObj.eventListPages objectAtIndex: 0];
        lListBlank = !lEventPage.eventList.count;
    }
    if (lListBlank)
    {
        mFullPageErrView.titleLabel.text = @"Reminder Upcomming Events";
        mFullPageErrView.descLabel.text = @"You have no reminder.";
        mFullPageErrView.iconView.image = [UIImage imageNamed: @"noData.png"];
        [mFullPageErrView.actionBtn setImage: [UIImage imageNamed: @"retry-normal.png"] forState: UIControlStateNormal];
        [mFullPageErrView.actionBtn setImage: [UIImage imageNamed: @"retry-highlighted.png"] forState: UIControlStateHighlighted];
        [mFullPageErrView.actionBtn setTitle: @"" forState: UIControlStateNormal];
        mFullPageErrView.hidden = FALSE;
        [self.view bringSubviewToFront: mFullPageErrView];
        return;
    }

    mFullPageErrView.hidden = TRUE;
    [self.view bringSubviewToFront: mVideoListView];
}

- (IBAction)alertActionBtnClicked:(id)sender
{
    [self loadData];
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
    static NSString *identifier = @"GEEventCellID";
    
    GEEventCell* lCell = (GEEventCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    lCell.delegate = self;
    lCell.videoPlayIcon.image = [UIImage imageWithName: @"play-Icon.png"];
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    NSObject <GEYoutubeResult>* lResult = [lEventPageObj.eventList objectAtIndex: indexPath.row];
    lCell.titleLabel.text = [lResult GETitle];
    NSString* lDateStr = [[lResult GEPublishedAt] dateString];
    lCell.statusLabel.hidden = TRUE;
    lCell.alarmBtn.hidden = TRUE;
    NSString* lStartOn = [[lResult eventStartStreamDate] dateString];
    lCell.timeLabel.text = lStartOn;
    
    if (mVideoEventType == EFetchEventsReminders) {
        lCell.statusLabel.text = @"Upcomming";
        lCell.videoPlayIcon.image = nil;
        lCell.timeLabelMaxX.constant = -30.0;
        lCell.alarmBtn.hidden = FALSE;
        SharedReminder* lReminder = [SharedReminder SharedRemider];
        lCell.alarmBtn.selected = [lReminder isInReminderList: lResult];
    }
    else
    {
        lCell.timeLabel.text = lDateStr;
    }
    
    NSURL* lThumbUrl = [NSURL URLWithString: [lResult GEThumbnailUrl]];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    
    return lCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        GELoadingFooter* lFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GELoadingFooterID" forIndexPath:indexPath];
        
        reusableview = lFooterView;
    }
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView* lHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEPlaylistHeaderID" forIndexPath:indexPath];
        
        reusableview = lHeaderView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 0);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    
    if (indexPath.section == lEventObj.eventListPages.count - 1)
    {
        if (![self checkForInternetConnection])
            return;
        
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
    CGFloat lWidth = self.view.bounds.size.width/2 - 3.0;
    CGFloat lHeight = 9.0*lWidth/16.0 + 90.0;
    if (mVideoEventType == EFetchEventsUpcomming) lHeight += 10.0;
    
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    if (lEventPageObj.eventList.count < 20 && lEventPageObj.eventList.count % 2 != 0 && indexPath.row == 0)
    {
        lWidth = self.view.bounds.size.width - 3.0;
        lHeight = 9.0*lWidth/16.0 + 80.0;
        lItemSize = CGSizeMake(lWidth, lHeight);
    }
    
    
    return lItemSize;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.videoEventType forSource: self.channelSource];
    
    BOOL lCanFetchMore = FALSE;
    [lManager pageTokenForEventOfType: self.videoEventType forSource: self.channelSource canFetchMore: &lCanFetchMore];
    
    if (!lCanFetchMore || (section < lEventObj.eventListPages.count - 1))
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2.0, 2.0, 0.0, 2.0);
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
    
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: mVideoEventType forSource: self.channelSource];
    GEEventListPage* lEventPage = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    NSObject<GEYoutubeResult>* lSearchResult = [lEventPage.eventList objectAtIndex: indexPath.row];
    
    UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GEVideoPlayerCtr* lGEVideoPlayerCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEVideoPlayerCtrID"];
    lGEVideoPlayerCtr.eventType = self.videoEventType;
    lGEVideoPlayerCtr.videoItem = lSearchResult;
    lGEVideoPlayerCtr.view.frame = self.view.bounds;
    
    if (self.navigationDelegate) {
        [self.navigationDelegate moveToViewController: lGEVideoPlayerCtr fromViewCtr: self];
        return;
    }
    
    [self.navigationController pushViewController: lGEVideoPlayerCtr animated: TRUE];
}

- (void)didSelectAlarmButtonInCell: (GEEventCell*)eventCell
{
    SharedReminder* lSharedReminder = [SharedReminder SharedRemider];
    NSIndexPath* lPath = [mVideoListView indexPathForCell: eventCell];
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: mVideoEventType forSource: self.channelSource];
    GEEventListPage* lEventPage = [lEventObj.eventListPages objectAtIndex: lPath.section];
    NSObject<GEYoutubeResult>* lSearchResult = [lEventPage.eventList objectAtIndex: lPath.row];
    
    if ([lSharedReminder isInReminderList: lSearchResult])
    {
        [lSharedReminder deleteReminderVideo: lSearchResult];
        [lManager removeReminderVideoItem: lSearchResult];
        
        [mVideoListView performBatchUpdates:^{
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:lPath.row inSection:lPath.section];
            [mVideoListView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            
        } completion:^(BOOL finished) {
            [self showDataNotAvailable];
        }];
            
        [mVideoListView reloadData];
    }
    else
    {
        [lSharedReminder addReminderVideo: lSearchResult];
        [lManager addReminderVideoItem: lSearchResult];
        [mVideoListView reloadData];
    }
}

@end