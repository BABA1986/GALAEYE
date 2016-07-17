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
#import "MMDrawerBarButtonItem.h"
#import "AppDelegate.h"

@interface GEPageRootVC ()
- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex;
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
    
    [self initialisePagesForLeftMenuIndex: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSortFilter
{
    CPDropDownSelector* lDropDown = [[CPDropDownSelector alloc] initWithFrame: CGRectMake( 0.0, 0.0, 80.0, 20.0)];
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
{
    if (mPageMenu) {
        [mPageMenu.view removeFromSuperview];
        [mPageMenu removeFromParentViewController];
        mPageMenu = nil;
    }
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: lNavColor,
                                 CAPSPageMenuOptionSelectionIndicatorColor: lNavTextColor,
                                 CAPSPageMenuOptionBottomMenuHairlineColor: lNavColor,
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: lNavTextColor,
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: lNavTextColor,
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:15.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    NSArray* lCtrs = [self pageCtrsForLeftMenuIndex: leftMenuIndex];
    mPageMenu = [[CAPSPageMenu alloc] initWithViewControllers:lCtrs frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:mPageMenu.view];
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
        else if ([lCtr isKindOfClass: [GEEventVC class]])
        {
            if ([lCtr respondsToSelector: @selector(applyTheme)])
            {
                [(GEEventVC*)lCtr applyTheme];
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
    }
}

- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex
{
    GESharedMenu* lSharedMenu = [GESharedMenu sharedMenu];
    GEMenu* lMenus = [lSharedMenu.menus objectAtIndex: leftMenuIndex];
    if (![lMenus.menuName isEqualToString: @"Gala Eye"])
        [self addSortFilter];
    else
        [self removeSortFilter];
    
    self.title = lMenus.menuName;
    NSMutableArray* lPageCtrs = [[NSMutableArray alloc] init];
    
    for (GESubMenu* lPageMenu in lMenus.subMenus)
    {
        if ([lPageMenu.subMenuType isEqualToString: @"events"])
        {
            GEEventVC* lGEEventVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEEventVCID"];
            lGEEventVC.title = lPageMenu.subMenuName;
            [lPageCtrs addObject: lGEEventVC];
            continue;
        }
        else if ([lPageMenu.subMenuType isEqualToString: @"playlist"])
        {
//            GEVideoListVC* lGEVideoListVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEVideoListVCID"];
//            lGEVideoListVC.title = lPageMenu.subMenuName;
//            lGEVideoListVC.channelSource = lPageMenu.subMenuSrc;
//            [lPageCtrs addObject: lGEVideoListVC];
            
            GEPlaylistVC* lGEPlaylistVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GEPlaylistVCID"];
            lGEPlaylistVC.title = lPageMenu.subMenuName;
            lGEPlaylistVC.navigationDelegate = self;
            lGEPlaylistVC.listSource = lPageMenu.subMenuSrc;
            [lPageCtrs addObject: lGEPlaylistVC];
            continue;
        }
        
        UIViewController* lCtr = [[UIViewController alloc] init];
        lCtr.title = lPageMenu.subMenuName;
        [lPageCtrs addObject: lCtr];
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
    return 30.0;
}

- (void)dropDownSelector:(CPDropDownSelector*)selector didSelectedRow:(NSInteger)row
{
    
}

- (void)dropDownSelector:(CPDropDownSelector*)selector didSelected:(BOOL)selected row:(NSInteger)row
{
    
}

- (BOOL)dropDownSelector:(CPDropDownSelector*)selector  shouldShowSelectedRow:(NSInteger)row;
{
    return YES;
}



@end
