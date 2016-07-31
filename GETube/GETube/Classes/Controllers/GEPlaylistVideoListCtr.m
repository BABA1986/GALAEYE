//
//  GEPlaylistVideoListCtr.m
//  GETube
//
//  Created by Deepak on 01/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPlaylistVideoListCtr.h"
#import "GEVideoPlayerCtr.h"
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

- (CGSize)sizeOfString: (NSString*)str
              withFont: (UIFont*)font
           inContWidth: (CGFloat)constWidth;

@end

@implementation GEPlaylistVideoListCtr

@synthesize fromPlayList = mFromPlayList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.title = [self.fromPlayList GEChannelTitle];
    
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];

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

- (CGSize)sizeOfString: (NSString*)str
              withFont: (UIFont*)font
           inContWidth: (CGFloat)constWidth
{
    // set paragraph style
    NSMutableParagraphStyle* lStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [lStyle setLineBreakMode:NSLineBreakByWordWrapping];
    // make dictionary of attributes with paragraph style
    NSDictionary* lSizeAttributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName: lStyle};
    // get the CGSize
    CGSize lAdjustedSize = CGSizeMake(constWidth, CGFLOAT_MAX);

    // alternatively you can also get a CGRect to determine height
    CGRect lRect = [str boundingRectWithSize:lAdjustedSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:lSizeAttributes
                                             context:nil];
    
    return CGSizeMake(lRect.size.width, lRect.size.height);
}

#pragma mark-
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    return lListObject.videoListPages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: section];
    return lGEVideoListPage.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEVideoListCellID";
    
    GEVideoListCell* lCell = (GEVideoListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: indexPath.section];
    
    GTLYouTubePlaylistItem* lVideo = [lGEVideoListPage.videoList objectAtIndex: indexPath.row];
    NSURL* lThumbUrl = [NSURL URLWithString: lVideo.snippet.thumbnails.medium.url];
    [lCell loadVideoThumbFromUrl: lThumbUrl];
    lCell.timeLabel.text = [lVideo.snippet.publishedAt.date dateTimeAgo];
    lCell.titleLabel.text = lVideo.snippet.title;
    return lCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    
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
        
        lHeaderView.channelNameLbl.text = [self.fromPlayList GEChannelTitle];
        lHeaderView.listTitleLbl.text = [self.fromPlayList GETitle];
        
        NSString* lTotalVideo = [NSString stringWithFormat: @"%d", [self.fromPlayList GETotalItemCount]];
        lHeaderView.noOfVideosLbl.text = [NSString stringWithFormat: @"%@ Videos", lTotalVideo];
        reusableview = lHeaderView;
        
        if (indexPath.section == 0) {
            NSString* lPlaylistTitle = [self.fromPlayList GETitle];
            UIFont* lFont = [UIFont fontWithName: @"HelveticaNeue" size: 15.0];
            CGSize lPlaylistSize = [self sizeOfString: lPlaylistTitle withFont: lFont inContWidth: collectionView.frame.size.width];
            lHeaderView.titleHeight.constant = lPlaylistSize.height + 5.0;
        }
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString* lChannelTitle = [self.fromPlayList GEChannelTitle];
        NSString* lPlaylistTitle = [self.fromPlayList GETitle];
        UIFont* lFont = [UIFont fontWithName: @"HelveticaNeue" size: 15.0];
        CGSize lPlaylistSize = [self sizeOfString: lPlaylistTitle withFont: lFont inContWidth: collectionView.frame.size.width];
        lFont = [UIFont fontWithName: @"HelveticaNeue-Light" size: 14.0];
        CGSize lChannelSize = [self sizeOfString: lChannelTitle withFont: lFont inContWidth: collectionView.frame.size.width/2];
        
        CGFloat lTotalHeight = lChannelSize.height + lPlaylistSize.height;
        
        lTotalHeight = (lTotalHeight < 40.0) ? 40.0 : lTotalHeight;
        lTotalHeight += 10.0;
        return CGSizeMake(collectionView.frame.size.width, lTotalHeight);
    }
    return CGSizeMake(collectionView.frame.size.width, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    
    BOOL lCanFetchMore = FALSE;
    [lSharedList pageTokenForVideoListForSource: [self.fromPlayList GEId] canFetchMore: &lCanFetchMore];
    
    if (!lCanFetchMore || (section < lListObject.videoListPages.count - 1))
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lWidth = self.view.bounds.size.width/2 - 3.0;
    CGFloat lHeight = 9.0*lWidth/16.0 + 80.0;
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: indexPath.section];
    if (lGEVideoListPage.videoList.count < 20 && lGEVideoListPage.videoList.count % 2 != 0 && indexPath.row == 0)
    {
        lWidth = self.view.bounds.size.width - 3.0;
        lHeight = 9.0*lWidth/16.0 + 70.0;
        lItemSize = CGSizeMake(lWidth, lHeight);
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
    GESharedVideoList* lSharedList = [GESharedVideoList sharedVideoList];
    GEVideoListObj* lListObject =  [lSharedList videoListObjForChannelSource: [self.fromPlayList GEId]];
    GEVideoListPage* lGEVideoListPage = [lListObject.videoListPages objectAtIndex: indexPath.section];
    
    NSObject<GEYoutubeResult>* lVideo = [lGEVideoListPage.videoList objectAtIndex: indexPath.row];
    
    UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GEVideoPlayerCtr* lGEVideoPlayerCtr = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEVideoPlayerCtrID"];
    lGEVideoPlayerCtr.eventType = EFetchEventsNone;
    lGEVideoPlayerCtr.videoItem = lVideo;
    lGEVideoPlayerCtr.view.frame = self.view.bounds;
    [self.navigationController pushViewController: lGEVideoPlayerCtr animated: TRUE];
}

@end
