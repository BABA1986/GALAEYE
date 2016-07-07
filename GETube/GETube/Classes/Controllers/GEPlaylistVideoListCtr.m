//
//  GEPlaylistVideoListCtr.m
//  GETube
//
//  Created by Deepak on 01/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPlaylistVideoListCtr.h"
#import "GEServiceManager.h"
#import "GESharedVideoList.h"
#import "GEVideoListCell.h"
#import "GELoadingFooter.h"
#import "GEVideoListHeader.h"
#import "NSDate+TimeAgo.h"

@interface GEPlaylistVideoListCtr ()
{
    BOOL        mRequesting;
}
@end

@implementation GEPlaylistVideoListCtr

@synthesize fromPlayList = mFromPlayList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout* lLayout = (UICollectionViewFlowLayout*) mVideoListView.collectionViewLayout;
    CGFloat lLength = self.view.bounds.size.width/2 - 3.0;
    lLayout.itemSize = CGSizeMake(lLength, lLength);
    lLayout.sectionInset = UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0);
    lLayout.minimumInteritemSpacing = 0.0;
    lLayout.minimumLineSpacing = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.title = self.fromPlayList.snippet.channelTitle;
    
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];

    if (mRequesting || lListObject.videoListPages.count)
        return;

    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    mRequesting = TRUE;
    
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadVideolistFromSource: self.fromPlayList onCompletion: ^(BOOL success)
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
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];
    return lListObject.videoListPages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: section];
    return lGEVideoListPage.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEVideoListCellID";
    
    GEVideoListCell* lCell = (GEVideoListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: indexPath.section];
    
    GTLYouTubeVideo* lVideo = [lGEVideoListPage.videoList objectAtIndex: indexPath.row];
    NSURL* lThumbUrl = [NSURL URLWithString: lVideo.snippet.thumbnails.medium.url];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    lCell.timeLabel.text = [lVideo.snippet.publishedAt.date dateTimeAgo];
    lCell.titleLabel.text = lVideo.snippet.title;
    return lCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];
    
    if (elementKind == UICollectionElementKindSectionFooter && indexPath.section == lListObject.videoListPages.count - 1)
    {
        if (mRequesting)
            return;
        
        mRequesting = TRUE;
        GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
        [lServiceMngr loadVideolistFromSource: self.fromPlayList onCompletion: ^(BOOL success)
         {
             [mVideoListView reloadData];
             mRequesting = FALSE;
         }];
    }
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
        GEVideoListHeader* lHeaderView = (GEVideoListHeader*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEVideoListHeaderID" forIndexPath:indexPath];
        
        lHeaderView.channelNameLbl.text = self.fromPlayList.snippet.channelTitle;
        lHeaderView.listTitleLbl.text = self.fromPlayList.snippet.title;
        
        NSString* lTotalVideo = [self.fromPlayList.contentDetails.itemCount stringValue];
        lHeaderView.noOfVideosLbl.text = [NSString stringWithFormat: @"%@ Videos", lTotalVideo];
        reusableview = lHeaderView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(collectionView.frame.size.width, 44);
    }
    return CGSizeMake(collectionView.frame.size.width, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: self.fromPlayList.identifier];
    
    BOOL lCanFetchMore = FALSE;
    [lSharedList pageTokenForVideoListForSource: self.fromPlayList.identifier canFetchMore: &lCanFetchMore];
    
    if (!lCanFetchMore || (section < lListObject.videoListPages.count - 1))
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector: @selector(moveToViewController:fromViewCtr:)])
//    {
//        //        Main.storyboard
//        UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        GEPlaylistVideoListCtr* lVideoListCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEPlaylistVideoListCtrID"];
//        [self.navigationDelegate moveToViewController: lVideoListCtr fromViewCtr: self];
//    }
}

@end
