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
#import "UIImageView+WebCache.h"
#import "UIImage+ImageMask.h"
#import "UserDataManager.h"

@interface GEMenuVC ()
{
    NSMutableArray*            mFooterItems;
    
    IBOutlet UIView*            mLoginBaseView;
    IBOutlet UIImageView*       mProfileImgView;
    IBOutlet UILabel*           mWelcomeLbl;
    IBOutlet UIButton*          mLoginBtn;
    IBOutlet UIView*            mSeperatorView;
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
    mProfileImgView.image = [UIImage imageWithName: @"userprofile.png"];
    [self initialiseFooterItems];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    mProfileImgView.clipsToBounds = YES;
    mProfileImgView.layer.cornerRadius = mProfileImgView.frame.size.width/2.0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)onSucessfullLogin: (NSNotification*)notification
{
    [self onLoginUpdate];
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
    self.view.backgroundColor = [UIColor clearColor];
    [mFooterListView reloadData];
    [mMenuListView reloadData];
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lTextColor = [lThemeManager selectedTextColor];
    mWelcomeLbl.textColor = lTextColor;
    [mLoginBtn setTitleColor: lTextColor forState: UIControlStateNormal];
    mSeperatorView.backgroundColor = lTextColor;
    [self onLoginUpdate];
}

- (void)onLoginUpdate
{
    UIImage* lPlaceholderImg = [UIImage imageWithName: @"userprofile.png"];
    UserDataManager* lUserManager = [UserDataManager userDataManager];
    NSURL* lPicUrl = [lUserManager.userData imageUrl];
    if (lUserManager.userData.userId)
    {
        mWelcomeLbl.text = [lUserManager.userData.name capitalizedString];
        mLoginBtn.selected = TRUE;
    }
    else
    {
        mWelcomeLbl.text = @"Welcome!";
        mLoginBtn.selected = FALSE;
    }
    
    [mProfileImgView sd_setImageWithURL:lPicUrl placeholderImage:lPlaceholderImg completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonClicked:(id)sender
{
    if (!mLoginBtn.isSelected) {
        [[GIDSignIn sharedInstance] signIn];
        return;
    }

    mLoginBtn.selected = FALSE;
    [[GIDSignIn sharedInstance] signOut];
    [[UserDataManager userDataManager] flushUserData];
    [self onLoginUpdate];
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
    if (tableView == mFooterListView)
    {
        return 35.0;
    }
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
            lCell.menuIconView.image = [UIImage imageWithName: [lFooterItem objectForKey: @"image"]];
        }
        else
        {
            GESharedMenu* lGESharedMenu = [GESharedMenu sharedMenu];
            GEMenu* lMenu = [lGESharedMenu.menus objectAtIndex: indexPath.row];
            lCell.menuTitleLbl.text = lMenu.menuName;
            lCell.menuTitleLbl.textColor = lNavTextColor;
            lCell.menuTitleLbl.font = [UIFont systemFontOfSize: 17.0];
            lCell.menuIconView.image = [UIImage imageWithName: lMenu.menuImageIcon];
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
        UINavigationController* lNavCtr = [[UINavigationController alloc] initWithRootViewController: lGESettingViewCtr];
        lGESettingViewCtr.view.frame = self.view.bounds;
        [self presentViewController: lNavCtr animated: TRUE completion: nil];
    }
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
