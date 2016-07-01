//
//  GEPlaylistVC.m
//  GETube
//
//  Created by Deepak on 23/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPlaylistVC.h"
#import "GEPlaylistCell.h"
#import "GEPlaylistFooter.h"
#import "GEServiceManager.h"
#import "GESharedPlaylist.h"
#import "GEPlaylistVideoListCtr.h"

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
    
    UICollectionViewFlowLayout* lLayout = (UICollectionViewFlowLayout*) mPlaylistListView.collectionViewLayout;
    CGFloat lLength = self.view.bounds.size.width/2 - 3.0;
    lLayout.itemSize = CGSizeMake(lLength, 0.9*lLength);
    lLayout.sectionInset = UIEdgeInsetsMake(2.0, 2.0, 0.0, 2.0);
    lLayout.minimumInteritemSpacing = 0.0;
    lLayout.minimumLineSpacing = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if (mRequesting)
        return;

    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    
    mRequesting = TRUE;
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadPlaylistFromSource: self.listSource onCompletion: ^(BOOL success)
     {
         [mPlaylistListView reloadData];
          mRequesting = FALSE;
        [mIndicator stopAnimating];
         mIndicator.hidden = TRUE;
     }];
}

- (void)addIndicatorView
{
    [mIndicator removeFromSuperview];
    mIndicator = nil;
    mIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots tintColor:kDefaultThemeColor size:40.0f];
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
    
    GTLYouTubePlaylist* lPlayList = [lPlaylistListPage.playlistList objectAtIndex: indexPath.row];
    NSURL* lThumbUrl = [NSURL URLWithString: lPlayList.snippet.thumbnails.high.url];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    lCell.videoTileLbl.text = lPlayList.snippet.title;
    lCell.noOfVideoLbl.text = [lPlayList.contentDetails.itemCount stringValue];
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
        GEPlaylistFooter* lFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GEPlaylistFooterID" forIndexPath:indexPath];
        
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector: @selector(moveToViewController:fromViewCtr:)])
    {
//        Main.storyboard
        UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GEPlaylistVideoListCtr* lVideoListCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEPlaylistVideoListCtrID"];
        [self.navigationDelegate moveToViewController: lVideoListCtr fromViewCtr: self];
    }
}

@end
