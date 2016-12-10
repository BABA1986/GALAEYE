//
//  GEVideoPlayerCtr.m
//  GETube
//
//  Created by Deepak on 10/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEVideoPlayerCtr.h"
#import "UIImage+ImageMask.h"
#import "GEServiceManager.h"
#import "NSDate+TimeAgo.h"
#import "GEVideoPlayerCtr.h"
#import "GELoadingFooter.h"
#import "GEYoutubeResult.h"
#import "GEEventCell.h"
#import "UserDataManager.h"
#import "MBProgressHUD.h"
#import <Google/SignIn.h>
#import "AppDelegate.h"
#import "GEEventManager.h"
#import "MBProgressHUD.h"

@interface GEVideoPlayerCtr ()
{
    BOOL        mRequesting;
    NSString*   mSource; //It may ChannelID OR PlaylistID
    
    IBOutlet UIView*                    mTitleBaseView;
    IBOutlet UILabel*                   mTitleLbl;
    IBOutlet UILabel*                   mNoOfViewLbl;
    IBOutlet UITextView*                mDescriptionView;
    IBOutlet UIButton*                  mExpandBtn;
    
    IBOutlet UILabel*                   mLikeCountLbl;
    IBOutlet UIButton*                  mLikeBtn;
    IBOutlet UIView*                    mLikeBaseView;
    
    IBOutlet UILabel*                   mDisLikeCountLbl;
    IBOutlet UIButton*                  mDisLikeBtn;
    IBOutlet UIView*                    mDisLikeBaseView;

    
    IBOutlet NSLayoutConstraint*     mTitleBaseHeight;
    IBOutlet NSLayoutConstraint*     mTitleHeight;
    IBOutlet NSLayoutConstraint*     mDislikeBaseWidth;
    BOOL                             mIsHeaderExpanded;
}

@property(nonatomic, copy)NSString*     listSource;

- (IBAction)titleExpandCollapseAction:(id)sender;

- (void)addIndicatorView;
- (CGSize)sizeOfString: (NSString*)str
              withFont: (UIFont*)font
           inContWidth: (CGFloat)constWidth;
- (void)loadTitleAndDescription;
- (void)getRating;
- (void)raiseLiginAlert;
@end

@implementation GEVideoPlayerCtr

@synthesize videoItem = mVideoItem;
@synthesize eventType = mEventType;
@synthesize listSource = mSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mBrandLogoView.image = [UIImage imageWithName: @"smalllogo.png"];
    
    UITapGestureRecognizer* lLikeGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(likeActionFound:)];
    [mLikeBaseView addGestureRecognizer: lLikeGesture];
    
    UITapGestureRecognizer* lDisLikeGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dislikeActionFound:)];
    [mDisLikeBaseView addGestureRecognizer: lDisLikeGesture];
    
    self.view.backgroundColor = [UIColor colorWithRed: 245.0/255.0 green: 245.0/255.0 blue: 245.0/255.0 alpha: 1.0];
    mVideoListView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem* lRightItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithName: @"shareIcon.png"] style: UIBarButtonItemStylePlain target: self action: @selector(shareButtonClicked:)];
    lRightItem.imageInsets = UIEdgeInsetsMake(2, -10, 0, 10);
    self.navigationItem.rightBarButtonItem = lRightItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    NSString* lChannelTitle = [self.videoItem GEChannelTitle];
    self.title = lChannelTitle;
    
    [self loadTitleAndDescription];
//    [self getRating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    YTPlayerState lState = mPlayerView.playerState;
    if (lState != kYTPlayerStateUnknown)
        return;
    
    [self reloadVideo];
    
    
    [mPlayerIndicator startAnimating];
    
    if (mRequesting)
        return;
    
    mRequesting = TRUE;
    
    [self addIndicatorView];
    [mIndicator startAnimating];
    mIndicator.hidden = FALSE;
    self.listSource = self.videoItem.GEChannelId;
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr loadVideosFromChannelSource: self.listSource eventType: self.eventType onCompletion: ^(BOOL success)
     {
         [mVideoListView reloadData];
         [mIndicator stopAnimating];
         mIndicator.hidden = TRUE;
         mRequesting = FALSE;
     }];
}

- (void)reloadVideo
{
    NSDictionary* lPlayerVars = @{
                                  @"playsinline" : @1,
                                  @"enablejsapi": @1,
                                  @"autohide" : @1,
                                  @"controls" : @1,
                                  @"showinfo" : @1,
                                  @"modestbranding" : @1,
                                  @"autoplay" : @1,
                                  @"origin" : @"https://www.google.com",
                                  };
    
    mPlayerView.delegate = self;
    mPlayerView.translatesAutoresizingMaskIntoConstraints = TRUE;
    
    NSString* lVideoId = [self.videoItem GEId];
    [mPlayerView loadWithVideoId: lVideoId playerVars: lPlayerVars];
    
    [self loadTitleAndDescription];
    [self getRating];
}

- (void)applyTheme
{
    [mVideoListView reloadData];
    [self loadTitleAndDescription];
}

- (void)onLoginLogout: (BOOL)isLoggedIn
{
    
}

- (void)loadTitleAndDescription
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];    
    mTitleBaseView.backgroundColor = [UIColor clearColor];
    mTitleLbl.textColor = [UIColor darkGrayColor];
    mNoOfViewLbl.textColor = [UIColor darkGrayColor];
    mDescriptionView.textColor = [UIColor darkGrayColor];
    mLikeCountLbl.textColor = [UIColor darkGrayColor];
    mDisLikeCountLbl.textColor = [UIColor darkGrayColor];
    
    mTitleLbl.text = self.videoItem.GETitle;
    mDescriptionView.text = self.videoItem.GEDescription;
    mNoOfViewLbl.text = [NSString stringWithFormat: @"Views %ld", self.videoItem.GETotalViews];
    mLikeCountLbl.text = self.videoItem.GETotalLikes;
    mDisLikeCountLbl.text = self.videoItem.GETotalDisLikes;
    
    if (self.eventType == EFetchEventsLive)
        mNoOfViewLbl.text = [NSString stringWithFormat: @"Views %ld", self.videoItem.GETotalLiveViewers];
    
    UIFont* lFont = [UIFont fontWithName: @"HelveticaNeue" size: 15.0];
    CGSize lTitleSize = [self sizeOfString: self.videoItem.GETitle withFont: lFont inContWidth: self.view.frame.size.width - 50.0];

    mTitleHeight.constant = lTitleSize.height + 10.0;
    mTitleBaseHeight.constant = lTitleSize.height + 35.0;
    mDescriptionView.hidden = !mIsHeaderExpanded;
    
    CGSize lDislikeCountSize = [self sizeOfString: mDisLikeCountLbl.text withFont: mDisLikeCountLbl.font inContWidth: 80.0];
    mDislikeBaseWidth.constant = lDislikeCountSize.width + 35.0;
    
    [mExpandBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"downarrow.png"] withFillColor: lNavColor] forState: UIControlStateNormal];
    [mExpandBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"uparrow.png"] withFillColor: lNavColor] forState: UIControlStateSelected];
    
    [mLikeBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"like-unselected.png"] withFillColor: lNavColor] forState: UIControlStateNormal];
    [mLikeBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"like-selected.png"] withFillColor: lNavColor] forState: UIControlStateSelected];
    
    [mDisLikeBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"dislike-unselected.png"] withFillColor: lNavColor] forState: UIControlStateNormal];
    [mDisLikeBtn setImage: [UIImage createImageFromMask: [UIImage imageNamed: @"dislike-selected.png"] withFillColor: lNavColor] forState: UIControlStateSelected];
}

- (void)getRating
{
    mLikeBtn.selected = FALSE;
    mDisLikeBtn.selected = FALSE;
    
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr getMyRatingForVideo: self.videoItem onCompletion: ^(NSString* myRating)
     {
         if ([myRating isEqualToString: @"like"])
         {
             mLikeBtn.selected = TRUE;
         }
         else if ([myRating isEqualToString: @"dislike"])
         {
             mDisLikeBtn.selected = TRUE;
         }
     }];
}

- (void)shareButtonClicked: (id)sender
{
    NSString* lVideoUrl = [NSString stringWithFormat: @"http://www.youtube.com/watch?v=%@", mVideoItem.GEId];
    NSArray* lPostItems = @[lVideoUrl];
    UIActivityViewController* lActivityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:lPostItems
                                            applicationActivities:nil];
    
    [self presentViewController:lActivityVC animated:YES completion:^{
        
    }];

    [lActivityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray* retItems, NSError* error)
     {
         if(completed)
         {
         }
     }];
}

- (IBAction)titleExpandCollapseAction:(id)sender
{
    UIFont* lFont = [UIFont fontWithName: @"Helvetica-Light" size: 15.0];
    CGSize lDescSize = [self sizeOfString: self.videoItem.GEDescription withFont: lFont inContWidth: self.view.frame.size.width - 25.0];
    [mTitleBaseView layoutIfNeeded];

    [self.view layoutIfNeeded];
    if (!mIsHeaderExpanded)
    {
        mTitleBaseHeight.constant = mTitleBaseHeight.constant + lDescSize.height;
    }
    else
    {
        mTitleBaseHeight.constant = mTitleBaseHeight.constant - lDescSize.height;
    }
    
    mIsHeaderExpanded = !mIsHeaderExpanded;
    [UIView animateWithDuration:0.2
                     animations:^{
                             [self.view layoutIfNeeded];
                            mExpandBtn.selected = !mExpandBtn.selected;
                     } completion: ^(BOOL sussecc){
                         mDescriptionView.hidden = !mIsHeaderExpanded;
                     }];
}

- (void)likeActionFound: (UITapGestureRecognizer*)gesture
{
    if (mLikeBtn.selected)
        return;
    
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    if (!lUserManager.userData.userId.length)
    {
        [self raiseLiginAlert];
        return;
    }
    
    [self.videoItem GESetLike];
    mLikeCountLbl.text = self.videoItem.GETotalLikes;
    mLikeBtn.selected = TRUE;
    
    if (mDisLikeBtn.selected)
    {
        [self.videoItem GESetMyDisLikeRemove];
        mDisLikeCountLbl.text = self.videoItem.GETotalDisLikes;
        mDisLikeBtn.selected = FALSE;
    }

    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr addMyRating: @"like" forVideo: self.videoItem onCompletion: ^(bool success)
     {
         if (!success)
         {
             [self.videoItem GESetDisLike];
             
             if (mLikeBtn.selected)
             {
                 [self.videoItem GESetMyLikeRemove];
                 mLikeCountLbl.text = self.videoItem.GETotalLikes;
                 mLikeBtn.selected = FALSE;
             }
             
             mDisLikeCountLbl.text = self.videoItem.GETotalDisLikes;
             mDisLikeBtn.selected = TRUE;
         }
         else
         {
             MBProgressHUD* lHud = [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
             lHud.mode = MBProgressHUDModeText;
             lHud.labelText = @"Added to liked videos";
             lHud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
             lHud.removeFromSuperViewOnHide = YES;
             lHud.yOffset = CGRectGetMidY(self.view.frame) - 55.0;
             [lHud hide:YES afterDelay:1];
             
             GEEventManager* lManager = [GEEventManager manager];
             [lManager likeCachedVideoItem: self.videoItem];
         }
     }];
}

- (void)dislikeActionFound: (UITapGestureRecognizer*)gesture
{
    if (mDisLikeBtn.selected)
        return;
    
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    if (!lUserManager.userData.userId.length)
    {
        [self raiseLiginAlert];
        return;
    }
    
    [self.videoItem GESetDisLike];
    
    if (mLikeBtn.selected)
    {
        [self.videoItem GESetMyLikeRemove];
        mLikeCountLbl.text = self.videoItem.GETotalLikes;
        mLikeBtn.selected = FALSE;
    }
    
    mDisLikeCountLbl.text = self.videoItem.GETotalDisLikes;
    mDisLikeBtn.selected = TRUE;

    
    GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
    [lServiceMngr addMyRating: @"dislike" forVideo: self.videoItem onCompletion: ^(bool success)
     {
         if (!success)
         {
             [self.videoItem GESetLike];
             mLikeCountLbl.text = self.videoItem.GETotalLikes;
             mLikeBtn.selected = TRUE;
             
             if (mDisLikeBtn.selected)
             {
                 [self.videoItem GESetMyDisLikeRemove];
                 mDisLikeCountLbl.text = self.videoItem.GETotalDisLikes;
                 mDisLikeBtn.selected = FALSE;
             }
         }
         else
         {
             MBProgressHUD* lHud = [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
             lHud.mode = MBProgressHUDModeText;
             lHud.labelText = @"You dislike this video";
             lHud.yOffset = CGRectGetMidY(self.view.frame) - 55.0;
             lHud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
             lHud.removeFromSuperViewOnHide = YES;
             [lHud hide:YES afterDelay:1];
             GEEventManager* lManager = [GEEventManager manager];
             [lManager unlikeCachedVideoItem: self.videoItem];
         }
     }];
}

- (void)raiseLiginAlert
{
    UIAlertView* lAlertView = [[UIAlertView alloc] initWithTitle: @"SignIn Required" message: @"To like or dislike this video. Please do google signin." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Google Signin", nil];
    lAlertView.tag = 101;
    [lAlertView show];
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
    lIndicatorFrame.origin.y = CGRectGetMinY(mVideoListView.frame) +(CGRectGetHeight(mVideoListView.bounds) - lIndicatorFrame.size.height)/2;
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

- (IBAction)backButtonAction: (id)sender
{
    [self.navigationController popViewControllerAnimated: TRUE];
}

#pragma mark-
#pragma mark- YTPlayerViewDelegate
#pragma mark-

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [mPlayerIndicator stopAnimating];
    [mPlayerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    
}

- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(YTPlayerView *)playerView
{
    return [UIColor blackColor];
}

- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull YTPlayerView *)playerView
{
    UIImageView* lPlaceHolderView = [[UIImageView alloc] initWithImage: [UIImage imageWithName: @"loadingthumbnailurl.png"]];
    lPlaceHolderView.backgroundColor = [UIColor blackColor];
    return lPlaceHolderView;
}

#pragma mark-
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    return lEventObj.eventListPages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: section];
    return lEventPageObj.eventList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEPlayerCellID";
    
    GEEventCell* lCell = (GEEventCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    lCell.videoPlayIcon.image = [UIImage imageWithName: @"play-Icon.png"];
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    GEEventListPage* lEventPageObj = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    NSObject <GEYoutubeResult>* lResult = [lEventPageObj.eventList objectAtIndex: indexPath.row];
    lCell.titleLabel.text = [lResult GETitle];
    NSString* lDateStr = [[lResult GEPublishedAt] dateString];

    lCell.videoPlayIcon.image = [UIImage imageWithName: @"play-Icon.png"];
    lCell.statusLabel.hidden = TRUE;
    lCell.alarmBtn.hidden = TRUE;
    lCell.timeLabelMaxX.constant = 0.0;
    NSString* lStartOn = [[lResult eventStartStreamDate] dateString];
    lCell.timeLabel.text = lStartOn;
    
    if (self.eventType == EFetchEventsLive) {
        lCell.statusLabel.text = @"Live";
    }
    else if (self.eventType == EFetchEventsUpcomming) {
        lCell.statusLabel.text = @"Upcomming";
        lCell.videoPlayIcon.image = nil;
        lCell.timeLabelMaxX.constant = -30.0;
        lCell.alarmBtn.hidden = FALSE;
    }
    else if (self.eventType == EFetchEventsCompleted) {
        lCell.statusLabel.text = @"Completed";
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
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    
    if (indexPath.section == lEventObj.eventListPages.count - 1)
    {
        if (mRequesting)
            return;
        
        mRequesting = TRUE;
        GEServiceManager* lServiceMngr = [GEServiceManager sharedManager];
        [lServiceMngr loadVideosFromChannelSource: self.listSource eventType: self.eventType onCompletion: ^(BOOL success)
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
    if (self.eventType == EFetchEventsUpcomming) lHeight += 10.0;
    
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    
    GEEventManager* lManager = [GEEventManager manager];
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
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
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    
    BOOL lCanFetchMore = FALSE;
    [lManager pageTokenForEventOfType: self.eventType forSource: self.listSource canFetchMore: &lCanFetchMore];
    
    if (!lCanFetchMore || (section < lEventObj.eventListPages.count - 1))
        return CGSizeMake(collectionView.frame.size.width, 0);
    
    return CGSizeMake(collectionView.frame.size.width, 40);
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
    
    GEEventListObj* lEventObj = [lManager eventListObjForEventType: self.eventType forSource: self.listSource];
    GEEventListPage* lEventPage = [lEventObj.eventListPages objectAtIndex: indexPath.section];
    NSObject<GEYoutubeResult>* lSearchResult = [lEventPage.eventList objectAtIndex: indexPath.row];
    self.eventType = self.eventType;
    self.videoItem = lSearchResult;
    
    [self reloadVideo];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UIApplication* lApplication = [UIApplication sharedApplication];
        AppDelegate* lAppDelegate = (AppDelegate*)[lApplication delegate];
        lAppDelegate.showLoginToast = TRUE;
        
        [[GIDSignIn sharedInstance] signIn];
    }
}

@end
