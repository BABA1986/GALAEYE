//
//  GEPageRootVC.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEPageRootVC.h"
#import "GESharedMenu.h"
#import "GEConstants.h"
#import "GEEventVC.h"
#import "GEPlaylistVC.h"
#import "GEPlaylistVideoListCtr.h"
#import "GEVideoListVC.h"
#import "GEVideoPlayerCtr.h"
#import "MMDrawerBarButtonItem.h"
#import "AppDelegate.h"

@interface GEPageRootVC ()
{
    NSUInteger          mLeftMenuIndex;
}
- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex
                          withFilter: (NSString*)filter;
- (void)addSortFilter;
- (void)removeSortFilter;
@end

@implementation GEPageRootVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MMDrawerBarButtonItem* lItem = [[MMDrawerBarButtonItem alloc] initWithTarget: self action: @selector(leftDrawerOpenClose:)];
    lItem.image = [UIImage imageNamed: @"menuicon.png"];
    self.navigationItem.leftBarButtonItem = lItem;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if (mPageMenu)
        return;
    
    [self initialisePagesForLeftMenuIndex: 0 withFilter: @""];
}

- (void)initialisePagesForLeftMenuIndex: (NSInteger)leftMenuIndex
{
    if (leftMenuIndex != 0)
        [self addSortFilter];
    else
        [self removeSortFilter];

    NSString* lFilter = (leftMenuIndex != 0) ? @"Playlists" : @"";
    [self initialisePagesForLeftMenuIndex: leftMenuIndex withFilter: lFilter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSortFilter
{
    CPDropDownSelector* lDropDown = [[CPDropDownSelector alloc] initWithFrame: CGRectMake( 0.0, 0.0, 90.0, 30.0)];
    lDropDown.shouldHideSelectLabel = TRUE;
    lDropDown.delegate = self; lDropDown.dataSource = self;
    MMDrawerBarButtonItem* lDropDownItem = [[MMDrawerBarButtonItem alloc] initWithCustomView: lDropDown];
    self.navigationItem.rightBarButtonItem = lDropDownItem;
}

- (void)removeSortFilter
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)initialisePagesForLeftMenuIndex: (NSInteger)leftMenuIndex
                             withFilter: (NSString*)filter
{
    NSUInteger lCurrentIndex = mPageMenu.currentPageIndex;
    if (mPageMenu) {
        [mPageMenu.view removeFromSuperview];
        [mPageMenu removeFromParentViewController];
        mPageMenu = nil;
    }
    
    mLeftMenuIndex = leftMenuIndex;
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: lNavColor,
                                 CAPSPageMenuOptionSelectionIndicatorColor: lNavTextColor,
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: lNavTextColor,
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: lNavTextColor,
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:15.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    NSArray* lCtrs = [self pageCtrsForLeftMenuIndex: leftMenuIndex withFilter: filter];
    mPageMenu = [[CAPSPageMenu alloc] initWithViewControllers:lCtrs frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:mPageMenu.view];
    
    if (leftMenuIndex != 0) {
        [mPageMenu moveToPage: lCurrentIndex];
    }
}

- (void)applyTheme
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    mPageMenu.selectedMenuItemLabelColor = lNavTextColor;
    mPageMenu.unselectedMenuItemLabelColor = lNavTextColor;
    mPageMenu.selectionIndicatorColor = lNavTextColor;
    mPageMenu.bottomMenuHairlineColor = lNavTextColor;
    mPageMenu.scrollMenuBackgroundColor = lNavColor;
    
    NSArray* lControllers = mPageMenu.controllerArray;
    for (UIViewController* lCtr in lControllers)
    {
        if ([lCtr isKindOfClass: [GEPlaylistVC class]])
        {
            if ([lCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEPlaylistVC*)lCtr applyTheme];
            }
        }
        else if ([lCtr isKindOfClass: [GEVideoListVC class]])
        {
            if ([lCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEVideoListVC*)lCtr applyTheme];
            }
        }
        else if ([lCtr isKindOfClass: [GEEventVC class]])
        {
            if ([lCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEEventVC*)lCtr applyTheme];
            }
        }
        else if ([lCtr isKindOfClass: [GEVideoPlayerCtr class]])
        {
            if ([lCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEVideoPlayerCtr*)lCtr applyTheme];
            }
        }
    }
    
    NSArray* lNavControllers = self.navigationController.viewControllers;
    for (UIViewController* lNavCtr in lNavControllers)
    {
        if ([lNavCtr isKindOfClass: [GEPlaylistVideoListCtr class]])
        {
            if ([lNavCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEPlaylistVideoListCtr*)lNavCtr applyTheme];
            }
        }
        else if ([lNavCtr isKindOfClass: [GEVideoListVC class]])
        {
            if ([lNavCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEVideoListVC*)lNavCtr applyTheme];
            }
        }
        else if ([lNavCtr isKindOfClass: [GEVideoPlayerCtr class]])
        {
            if ([lNavCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEVideoPlayerCtr*)lNavCtr applyTheme];
            }
        }
    }
    
    CPDropDownSelector* lDropDown = (CPDropDownSelector*)self.navigationItem.rightBarButtonItem.customView;
    if (lDropDown && [lDropDown isKindOfClass: [CPDropDownSelector class]]){
        [lDropDown setNeedsDisplay];
    }
}

- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex withFilter: (NSString*)filter
{
    GESharedMenu* lSharedMenu = [GESharedMenu sharedMenu];
    GEMenu* lMenus = [lSharedMenu.menus objectAtIndex: leftMenuIndex];
    self.title = lMenus.menuName;
    NSMutableArray* lPageCtrs = [[NSMutableArray alloc] init];
    
    for (GESubMenu* lPageMenu in lMenus.subMenus)
    {
        if ([lPageMenu.subMenuType isEqualToString: @"events"])
        {
            if([lPageMenu.subMenuName isEqualToString: @"All Events"])
            {
                GEEventVC* lGEEventVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEEventVCID"];
                lGEEventVC.title = lPageMenu.subMenuName;
                lGEEventVC.navigationDelegate = self;
                [lPageCtrs addObject: lGEEventVC];
            }
            else if([lPageMenu.subMenuName isEqualToString: @"Popular"])
            {
                GEVideoListVC* lGEVideoListVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEVideoListVCID"];
                lGEVideoListVC.title = lPageMenu.subMenuName;
                lGEVideoListVC.channelSource = kGEChannelID;
                lGEVideoListVC.navigationDelegate = self;
                lGEVideoListVC.videoEventType = EFetchEventsPopularCompleted;
                [lPageCtrs addObject: lGEVideoListVC];
            }
            else
            {
                UIViewController* lCtr = [[UIViewController alloc] init];
                lCtr.title = lPageMenu.subMenuName;
                [lPageCtrs addObject: lCtr];
            }
        }
        else if ([lPageMenu.subMenuType isEqualToString: @"playlist"])
        {
            if ([filter isEqualToString: @"Playlists"])
            {
                GEPlaylistVC* lGEPlaylistVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEPlaylistVCID"];
                lGEPlaylistVC.title = lPageMenu.subMenuName;
                lGEPlaylistVC.navigationDelegate = self;
                lGEPlaylistVC.listSource = lPageMenu.subMenuSrc;
                [lPageCtrs addObject: lGEPlaylistVC];
            }
            else
            {
                GEVideoListVC* lGEVideoListVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEVideoListVCID"];
                lGEVideoListVC.title = lPageMenu.subMenuName;
                lGEVideoListVC.videoEventType = EFetchEventsNone;
                lGEVideoListVC.channelSource = lPageMenu.subMenuSrc;
                lGEVideoListVC.navigationDelegate = self;
                [lPageCtrs addObject: lGEVideoListVC];
            }
        }
    }
    
    return lPageCtrs;
}

- (void)leftDrawerOpenClose: (id)sender
{
    AppDelegate* lAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [lAppDelegate openCloseLeftMenuDrawer];
}

#pragma mark-
#pragma mark- GENavigatorProtocol
#pragma mark-

- (void)moveToViewController: (id)toViewController fromViewCtr: (id)fromViewCtr
{
    [self.navigationController pushViewController: toViewController animated: TRUE];
}

#pragma mark-
#pragma mark-
#pragma mark-

- (NSInteger)numberOfRowsInDropDownSelector:(CPDropDownSelector*)selector
{
    return 2;
}

- (NSString*)dropDownSelector:(CPDropDownSelector*)selector textForRow:(NSInteger)row
{
    if (row == 0) {
        return @"Playlists";
    }
    return @"Videos";
}

- (CGFloat)dropDownSelector:(CPDropDownSelector*)selector heightForRow:(NSInteger)row
{
    return 44.0;
}

- (void)dropDownSelector:(CPDropDownSelector*)selector didSelectedRow:(NSInteger)row
{
    NSString* lFilter = (row == 0) ? @"Playlists" : @"Videos";
    selector.selectorTitle = lFilter;
    [self initialisePagesForLeftMenuIndex: mLeftMenuIndex  withFilter: lFilter];
}

- (void)dropDownSelector:(CPDropDownSelector*)selector didSelected:(BOOL)selected row:(NSInteger)row
{
    
}

- (BOOL)dropDownSelector:(CPDropDownSelector*)selector  shouldShowSelectedRow:(NSInteger)row;
{
    return YES;
}



@end
