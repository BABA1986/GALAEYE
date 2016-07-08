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
#import "GESettingViewCtr.h"
#import "UIImage+ImageMask.h"

@interface GEMenuVC ()
{
    NSMutableArray*            mFooterItems;
}
- (void)initialiseFooterItems;

@end

@implementation GEMenuVC

@synthesize delegate = mDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = TRUE;
    [self applyTheme];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == mFooterListView)
    {
        return mFooterItems.count;
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
        UIColor* lNavTextColor = [lThemeManager selectedTextColor];

        if (tableView == mFooterListView)
        {
            NSDictionary* lFooterItem = [mFooterItems objectAtIndex: indexPath.row];
            BOOL lCanOpen = [[lFooterItem objectForKey: @"canopen"] boolValue];

            lCell.disclosureIconView.hidden = !lCanOpen;
            lCell.disclosureIconView.image = [UIImage imageWithName: @"disclosureicon.png"];
            lCell.menuTitleLbl.textColor = lNavTextColor;
            lCell.menuTitleLbl.text = [lFooterItem objectForKey: @"name"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != mFooterListView)
    {
        [self.delegate GEMenuVC: self didSelectAtIndex: indexPath];
    }
    else
    {
        GESettingViewCtr* lGESettingViewCtr = [self.storyboard instantiateViewControllerWithIdentifier: @"GESettingViewCtrID"];
        [self.navigationController pushViewController: lGESettingViewCtr animated: TRUE];
    }
}

@end
