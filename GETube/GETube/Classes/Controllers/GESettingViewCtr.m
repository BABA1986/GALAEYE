//
//  GESettingViewCtr.m
//  GETube
//
//  Created by Deepak on 06/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESettingViewCtr.h"
#import "GESettingHeader.h"
#import "GESettingListCell.h"
#import "GESelectFromListVC.h"
#import "ThemeManager.h"
#import "UserDataManager.h"
#import "GEThemeSelectionVC.h"

@interface GESettingViewCtr ()
- (void)applyTheme;
- (void)initSettingData;
@end

@implementation GESettingViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Setting";
    
    UIBarButtonItem* lDoneBtn = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:UIBarButtonItemStylePlain target: self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = lDoneBtn;
    [self applyTheme];
    
    self.view.backgroundColor = [UIColor colorWithRed: 245.0/255.0 green: 245.0/255.0 blue: 245.0/255.0 alpha: 1.0];
    mSettingListView.backgroundColor = [UIColor clearColor];
    [self initSettingData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSucessfullLogin:)
                                                 name:@"onSucessfullLogin"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [GIDSignIn sharedInstance].uiDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];    
}

- (void)applyTheme
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIColor* lNavTextColor = [lThemeManager selectedTextColor];
    self.navigationController.navigationBar.barTintColor = lNavColor;
    self.navigationController.navigationBar.tintColor = lNavTextColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: lNavTextColor};
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSettingData
{
    NSString* lBundlePath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"json"];
    NSFileManager* lFileManager = [NSFileManager defaultManager];
    if (![lFileManager fileExistsAtPath: lBundlePath])
        return;
    
    NSData* lJsonData = [lFileManager contentsAtPath: lBundlePath];
    NSError* lError;
    
    if (lJsonData!=nil)
    {
        NSDictionary* lDict = [NSJSONSerialization JSONObjectWithData:lJsonData
                                                              options:kNilOptions error:&lError];
        NSArray* lSettingItems = [lDict objectForKey: @"groups"];
        mSettingList = [[NSMutableArray alloc] initWithArray: lSettingItems];
    }
}

#pragma mark-
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return mSettingList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary* lGroupInfo = [mSettingList objectAtIndex: section];
    NSArray* lGrpItems = [lGroupInfo objectForKey: @"items"];
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    
    if (section == 0 && !lUserManager.userData.userId)
        return lGrpItems.count - 1;
    
    return lGrpItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kCellIdentifier = @"SettingCellIdentifier";
    
    GESettingListCell* lCell = (GESettingListCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    NSDictionary* lGroupInfo = [mSettingList objectAtIndex: indexPath.section];
    NSArray* lGrpItems = [lGroupInfo objectForKey: @"items"];
    NSDictionary* lListItem = [lGrpItems objectAtIndex: indexPath.row];
    
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    if (indexPath.section == 0 && !lUserManager.userData.userId)
    {
        lCell.cellTitleLbl.text = @"Google SignIn";
        [lCell refereshWithData: lListItem];
        return lCell;
    }
    if (indexPath.section == 0 && lUserManager.userData.userId)
    {
        if (indexPath.row == 0)
        {
            lCell.cellTitleLbl.text = [NSString stringWithFormat: @"%@", lUserManager.userData.email];
        }
        else
        {
            lCell.cellTitleLbl.text = [lListItem objectForKey: @"title"];
        }
        
        [lCell refereshWithData: lListItem];
        return lCell;
    }
    
    lCell.cellTitleLbl.text = [lListItem objectForKey: @"title"];
    [lCell refereshWithData: lListItem];
    return lCell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* lGroupInfo = [mSettingList objectAtIndex: section];
    NSString* lGrpTitle = [lGroupInfo objectForKey: @"title"];
    UILabel* lLabel = [[UILabel alloc] init];
    lLabel.numberOfLines = 0;
    lLabel.backgroundColor = [UIColor clearColor];
    UIFont* lFont = [UIFont fontWithName: @"Helvetica" size: 16.0];
    lLabel.font = lFont;
    lLabel.text = lGrpTitle;
    lLabel.textColor = [UIColor darkGrayColor];
    
    UIView* lView = [[UIView alloc] init];
    lView.backgroundColor = [UIColor colorWithRed: 245.0/255.0 green: 245.0/255.0 blue: 245.0/255.0 alpha: 1.0];
    [lView addSubview: lLabel];
    
    CGRect lLblRect = lLabel.frame;
    lLblRect.origin.x = 15.0; lLblRect.origin.y = 0.0;
    lLblRect.size.width = CGRectGetWidth(tableView.frame);
    lLblRect.size.height = 35.0;
    lLabel.frame = lLblRect;
    
    return lView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    if (indexPath.section == 0 && !lUserManager.userData.userId)
    {
        [[GIDSignIn sharedInstance] signIn];
        return;
    }
    if (indexPath.section == 0 && lUserManager.userData.userId)
    {
        [[GIDSignIn sharedInstance] signOut];
        [lUserManager flushUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"onSucessfullLogin" object: nil];
        return;
    }
    
    NSDictionary* lGroupInfo = [mSettingList objectAtIndex: indexPath.section];
    NSInteger lGrpType = [[lGroupInfo objectForKey: @"type"] integerValue];
    NSArray* lGrpItems = [lGroupInfo objectForKey: @"items"];
    NSDictionary* lListItem = [lGrpItems objectAtIndex: indexPath.row];
    NSInteger lCellId = [[lListItem objectForKey: @"id"] integerValue];
    
    UIStoryboard* lStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if(lGrpType == 101 && lCellId == 1)
    {
        GESelectFromListVC* lGESelectFromListVC = [lStoryBoard instantiateViewControllerWithIdentifier: @"GESelectFromListVCID"];
        lGESelectFromListVC.values = [lListItem objectForKey: @"values"];
        lGESelectFromListVC.headerTitle = [lListItem objectForKey: @"description"];
        [self.navigationController pushViewController: lGESelectFromListVC animated: TRUE];
    }
    else if(lGrpType == 101 && lCellId == 2)
    {
        GEThemeSelectionVC* lGEThemeSelectionVC = [lStoryBoard instantiateViewControllerWithIdentifier: @"GEThemeSelectionVCID"];
        [self.navigationController pushViewController: lGEThemeSelectionVC animated: TRUE];
    }
}

- (void)doneButtonPressed: (id)sender
{
    [self dismissViewControllerAnimated: TRUE completion: nil];
}

- (void)onSucessfullLogin: (NSNotification*)notification
{
    [mSettingListView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationFade];
}

#pragma mark-
#pragma mark- GIDSignInDelegate
#pragma mark-

// Implement these methods only if the GIDSignInUIDelegate is not a subclass of
// UIViewController.

// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
