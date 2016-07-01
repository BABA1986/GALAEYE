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

@end

@implementation GEMenuVC

@synthesize delegate = mDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = TRUE;
    
    self.view.backgroundColor = kDefaultThemeColor;
    mMenuListView.backgroundColor = [UIColor clearColor];
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
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        GESharedMenu* lGESharedMenu = [GESharedMenu sharedMenu];
        GEMenu* lMenu = [lGESharedMenu.menus objectAtIndex: indexPath.row];
        lCell.menuTitleLbl.text = lMenu.menuName;
    }
    
    return lCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate GEMenuVC: self didSelectAtIndex: indexPath];
}


@end
