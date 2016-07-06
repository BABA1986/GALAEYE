//
//  GEMenuVC.m
//  GETube
//
//  Created by Deepak on 18/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEMenuVC.h"
#import "MenuListCell.h"
#import "GESharedMenu.h"
#import "GEConstants.h"

@interface GEMenuVC ()
{
    NSMutableArray*            mFooterItems;
}
- (void)initialiseFooterItems;
- (void)applyTheme;
@end

@implementation GEMenuVC

@synthesize delegate = mDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = TRUE;
    
    mMenuListView.backgroundColor = [UIColor clearColor];
    mFooterListView.backgroundColor = [UIColor clearColor];
    
    [self initialiseFooterItems];
}

- (void)initialiseFooterItems
{
    NSString* lBundlePath = [[NSBundle mainBundle] pathForResource:@"MenuFooter" ofType:@"json"];
    NSFileManager* lFileManager = [NSFileManager defaultManager];
    if (![lFileManager fileExistsAtPath: lBundlePath])
    return;

    NSData* lJsonData = [lFileManager contentsAtPath: lBundlePath];
    NSError* lError;

    if (lJsonData!=nil)
    {
        NSDictionary* lDict = [NSJSONSerialization JSONObjectWithData:lJsonData
                                                              options:kNilOptions error:&lError];
        NSArray* lFooters = [lDict objectForKey: @"Footers"];
        mFooterItems = [[NSMutableArray alloc] init];
        for (NSDictionary* lFooter in lFooters)
        {
            NSMutableDictionary* lMFooter = [NSMutableDictionary dictionaryWithDictionary: lFooter];
            [mFooterItems addObject: lMFooter];
        }
    }
}

- (void)applyTheme
{
    [mFooterListView reloadData];
    [mMenuListView reloadData];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    self.view.backgroundColor = lNavColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-
#pragma mark- UITableViewDelegate & UITableViewDataSource
#pragma mark-

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == mFooterListView)
        return 3;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == mFooterListView)
    {
        NSDictionary* lFooterItem = [mFooterItems objectAtIndex: section];
        BOOL lIsOpen = [[lFooterItem objectForKey: @"isopen"] boolValue];
        if (section == 0 && lIsOpen)
        {
            ThemeManager* lThemeManager = [ThemeManager themeManager];
            return lThemeManager.themes.count;
        }
        return 0;
    }
    
    GESharedMenu* lGESharedMenu = [GESharedMenu sharedMenu];
    return [lGESharedMenu.menus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* lCellIdentifier = @"MenuListCellID";
    
    MenuListCell* lCell = (MenuListCell*)[tableView dequeueReusableCellWithIdentifier:lCellIdentifier];
    if (lCell)
    {
        lCell.backgroundColor = [UIColor clearColor];
        lCell.contentView.backgroundColor = [UIColor clearColor];
        lCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ThemeManager* lThemeManager = [ThemeManager themeManager];
        UIColor* lNavColor = [lThemeManager selectedNavColor];
        UIColor* lNavTextColor = [lThemeManager selectedTextColor];

        if (tableView == mFooterListView)
        {
            lCell.menuTitleLbl.textColor = lNavTextColor;
            lCell.backgroundColor = lNavColor;
            ThemeInfo* lThemeInfo = [lThemeManager.themes objectAtIndex: indexPath.row];
            lCell.menuTitleLbl.text = lThemeInfo.themeName;
            lCell.contentView.backgroundColor = lThemeInfo.navColor;
            lCell.menuTitleLbl.textColor = lThemeInfo.navTextColor;
            lCell.menuTitleLbl.font = [UIFont systemFontOfSize: 13.0];
        }
        else
        {
            GESharedMenu* lGESharedMenu = [GESharedMenu sharedMenu];
            GEMenu* lMenu = [lGESharedMenu.menus objectAtIndex: indexPath.row];
            lCell.menuTitleLbl.text = lMenu.menuName;
            lCell.menuTitleLbl.textColor = lNavTextColor;
            lCell.menuTitleLbl.font = [UIFont systemFontOfSize: 17.0];
        }
    }
    
    return lCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == mFooterListView)
    {
        return 40.0;
    }
    
    return 0.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == mFooterListView)
    {
        CGRect lHeaderRect = tableView.bounds;
        lHeaderRect.size.height = 40.0;
        MenuListHeader* lHeaderView = [[MenuListHeader alloc] initWithFrame: lHeaderRect];
        ThemeManager* lThemeManager = [ThemeManager themeManager];
        UIColor* lNavColor = [lThemeManager selectedNavColor];
        UIColor* lNavTextColor = [lThemeManager selectedTextColor];
        lHeaderView.backgroundColor = lNavColor;
        NSDictionary* lFooterItem = [mFooterItems objectAtIndex: section];
        lHeaderView.titleLabel.text = [lFooterItem objectForKey: @"name"];
        lHeaderView.titleLabel.textColor = lNavTextColor;
        
        BOOL lCanOpen = [[lFooterItem objectForKey: @"canopen"] boolValue];
        lHeaderView.expandView.hidden = !lCanOpen;
        
        BOOL lIsOpen = [[lFooterItem objectForKey: @"isopen"] boolValue];
        UIImage* lImage = lIsOpen ? [UIImage imageNamed: @"uparrow"] : [UIImage imageNamed: @"downarrow"];
        lHeaderView.expandView.image = lImage;
        
        lHeaderView.sectionIndex = section;
        lHeaderView.delegate = self;
        return lHeaderView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != mFooterListView)
    {
        [self.delegate GEMenuVC: self didSelectAtIndex: indexPath];
    }
    else
    {
        ThemeManager* lThemeManager = [ThemeManager themeManager];
        lThemeManager.selectedIndex = indexPath.row;
        [self applyTheme];
    }
}

- (void)menuListHeader: (MenuListHeader*)header didSelectAtIndex: (NSUInteger)index
{
    NSMutableDictionary* lFooterItem = [mFooterItems objectAtIndex: index];
    BOOL lCanOpen = [[lFooterItem objectForKey: @"canopen"] boolValue];
    if (!lCanOpen)
        return;

    BOOL lIsOpen = [[lFooterItem objectForKey: @"isopen"] boolValue];
    UIImage* lImage = !lIsOpen ? [UIImage imageNamed: @"uparrow"] : [UIImage imageNamed: @"downarrow"];
    header.expandView.image = lImage;
    [lFooterItem setObject: [NSNumber numberWithBool: !lIsOpen] forKey: @"isopen"];

    NSMutableArray* lIndexPaths = [[NSMutableArray alloc] init];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    for (NSUInteger lIndex = 0; lIndex < lThemeManager.themes.count; ++lIndex)
    {
        NSIndexPath* lIndexPath = [NSIndexPath indexPathForItem: lIndex inSection: index];
        [lIndexPaths addObject: lIndexPath];
    }
    
    [mFooterListView beginUpdates];
    if (!lIsOpen)
    {
        [mFooterListView insertRowsAtIndexPaths: lIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [mFooterListView deleteRowsAtIndexPaths: lIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [mFooterListView endUpdates];
}

@end
