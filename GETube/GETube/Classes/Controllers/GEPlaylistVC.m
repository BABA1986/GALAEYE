//
//  GEPlaylistVC.m
//  GETube
//
//  Created by Deepak on 23/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPlaylistVC.h"
#import "GEPlaylistCell.h"
#import "GELoadingFooter.h"
#import "GEServiceManager.h"
#import "GESharedPlaylist.h"
#import "GEPlaylistVideoListCtr.h"
#import "GEYoutubeResult.h"

@interface GEPlaylistVC ()
{
    BOOL        mRequesting;
}
@end

@implementation GEPlaylistVC

@synthesize listSource;
@synthesize navigationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];

    if (mRequesting || lPlaylistObject.playlistListPages.count)
        return;

    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    
    mRequesting = TRUE;
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadPlaylistFromSource: self.listSource onCompletion: ^(BOOL success)
     {
         [mPlaylistListView reloadData];
        [mIndicator stopAnimating];
         mIndicator.hidden = TRUE;
         mRequesting = FALSE;
     }];
}

- (void)applyTheme
{
    [mPlaylistListView reloadData];
}

- (void)addIndicatorView
{
    [mIndicator removeFromSuperview];
    mIndicator = nil;
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    
    mIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots tintColor:lNavColor size:40.0f];
    CGRect lIndicatorFrame = self.view.bounds;
    lIndicatorFrame.size.width = 100.0;
    lIndicatorFrame.size.height = 100.0;
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
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];
    return lPlaylistObject.playlistListPages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];
    GEPlaylistListPage* lPlaylistListPage = [lPlaylistObject.playlistListPages objectAtIndex: section];
    return lPlaylistListPage.playlistList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEPlaylistCellID";
    
    GEPlaylistCell* lCell = (GEPlaylistCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];
    GEPlaylistListPage* lPlaylistListPage = [lPlaylistObject.playlistListPages objectAtIndex: indexPath.section];
    
    NSObject <GEYoutubeResult>* lPlayList = [lPlaylistListPage.playlistList objectAtIndex: indexPath.row];
    NSURL* lThumbUrl = [NSURL URLWithString: [lPlayList GEThumbnailUrl]];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    lCell.videoTileLbl.text = [lPlayList GETitle];
    lCell.noOfVideoLbl.text = [NSString stringWithFormat: @"%ld", [lPlayList GETotalItemCount]];
    return lCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];

    if (elementKind == UICollectionElementKindSectionFooter && indexPath.section == lPlaylistObject.playlistListPages.count - 1)
    {
        if (mRequesting)
            return;
        
        mRequesting = TRUE;
        GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
        [lServiceMngr loadPlaylistFromSource: self.listSource onCompletion: ^(BOOL success)
         {
             [mPlaylistListView reloadData];
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
        UICollectionReusableView* lHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEPlaylistHeaderID" forIndexPath:indexPath];
        
        reusableview = lHeaderView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];

    BOOL lCanFetchMore = FALSE;
    [lSharedPlaylist pageTokenForPlaylistForSource: self.listSource canFetchMore: &lCanFetchMore];
    
    if (!lCanFetchMore || (section < lPlaylistObject.playlistListPages.count - 1))
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lWidth = self.view.bounds.size.width/2 - 3.0;
    CGFloat lHeight = 9.0*lWidth/16.0 + 30.0;
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    
    GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
    GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];
    GEPlaylistListPage* lPlaylistListPage = [lPlaylistObject.playlistListPages objectAtIndex: indexPath.section];
    if (lPlaylistListPage.playlistList.count < 4 && lPlaylistListPage.playlistList.count % 2 != 0 && indexPath.row == 0)
    {
        lWidth = self.view.bounds.size.width - 3.0;
        lHeight = 9.0*lWidth/16.0 + 30.0;
        lItemSize = CGSizeMake(lWidth, lHeight);
        return lItemSize;
    }
    
    return lItemSize;
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
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector: @selector(moveToViewController:fromViewCtr:)])
    {
        GESharedPlaylistList* lSharedPlaylist = [GESharedPlaylistList sharedPlaylistList];
        GEPlaylistListObj* lPlaylistObject =  [lSharedPlaylist playlistObjForChannelSource: self.listSource];
        GEPlaylistListPage* lPlaylistListPage = [lPlaylistObject.playlistListPages objectAtIndex: indexPath.section];
        
        NSObject <GEYoutubeResult>* lPlayList = [lPlaylistListPage.playlistList objectAtIndex: indexPath.row];
        
        UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GEPlaylistVideoListCtr* lVideoListCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEPlaylistVideoListCtrID"];
        lVideoListCtr.fromPlayList = lPlayList;
        [self.navigationDelegate moveToViewController: lVideoListCtr fromViewCtr: self];
    }
}

@end
