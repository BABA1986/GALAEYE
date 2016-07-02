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

@interface GEPageRootVC ()
- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex;
@end

@implementation GEPageRootVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self initialisePagesForLeftMenuIndex: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialisePagesForLeftMenuIndex: (NSInteger)leftMenuIndex
{
    if (mPageMenu) {
        [mPageMenu.view removeFromSuperview];
        [mPageMenu removeFromParentViewController];
        mPageMenu = nil;
    }
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: kDefaultThemeColor,
                                 CAPSPageMenuOptionSelectionIndicatorColor: kDefaultTitleColor,
                                 CAPSPageMenuOptionBottomMenuHairlineColor: kDefaultThemeColor,
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    NSArray* lCtrs = [self pageCtrsForLeftMenuIndex: leftMenuIndex];
    mPageMenu = [[CAPSPageMenu alloc] initWithViewControllers:lCtrs frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:mPageMenu.view];
}

- (NSArray*)pageCtrsForLeftMenuIndex: (NSInteger)leftMenuIndex
{
    GESharedMenu* lSharedMenu = [GESharedMenu sharedMenu];
    GEMenu* lMenus = [lSharedMenu.menus objectAtIndex: leftMenuIndex];
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

#pragma mark-
#pragma mark- GENavigatorProtocol
#pragma mark-

- (void)moveToViewController: (id)toViewController fromViewCtr: (id)fromViewCtr
{
    [self.navigationController pushViewController: toViewController animated: TRUE];
}

@end
