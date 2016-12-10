//
//  GEThemeSelectionVC.m
//  GETube
//
//  Created by Deepak on 18/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GEThemeSelectionVC.h"
#import "ThemeManager.h"
#import "GEThemeCell.h"

@interface GEThemeSelectionVC ()

@end

@implementation GEThemeSelectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithRed: 245.0/255.0 green: 245.0/255.0 blue: 245.0/255.0 alpha: 1.0];
    mThemeListView.backgroundColor = [UIColor clearColor];
    mThemeListView.pagingEnabled = TRUE;
    self.title = @"Gala Themes";
    
    ThemeManager* lManager = [ThemeManager themeManager];
    mPageControl.numberOfPages = lManager.themes.count;
    mPageControl.pageIndicatorTintColor = [lManager selectedNavColor];
    mPageControl.currentPageIndicatorTintColor = [lManager selectedTextColor];
    mPageControl.currentPage = lManager.selectedIndex;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray* lThemes = [[ThemeManager themeManager] themes];
    return lThemes.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GEThemeCellID";
    
    GEThemeCell* lCell = (GEThemeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSArray* lThemes = [[ThemeManager themeManager] themes];
    ThemeInfo* lThemeInfo = [lThemes objectAtIndex: indexPath.section];
    lCell.navigationBar.backgroundColor = lThemeInfo.navColor;
    lCell.navigationTitleLbl.textColor = lThemeInfo.navTextColor;
    return lCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lWidth = CGRectGetWidth(collectionView.frame)*3.0/4.0;
    CGFloat lHeight = lWidth*1.57;
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    return lItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat lWidth = CGRectGetWidth(collectionView.frame)*3.0/4.0;
    CGFloat lHeight = lWidth*1.57;
    CGSize lItemSize = CGSizeMake(lWidth, lHeight);
    CGFloat lTop = (CGRectGetHeight(collectionView.frame) - lItemSize.height)/2;
    CGFloat lLeft = (CGRectGetWidth(collectionView.frame) - lItemSize.width)/2;

    return UIEdgeInsetsMake(lTop, lLeft, 0.0, lLeft);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    ThemeManager* lManager = [ThemeManager themeManager];
    int lIndexOfPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    lManager.selectedIndex = lIndexOfPage;
    mPageControl.numberOfPages = lManager.themes.count;
    mPageControl.pageIndicatorTintColor = [lManager selectedNavColor];
    mPageControl.currentPageIndicatorTintColor = [lManager selectedTextColor];
    mPageControl.currentPage = lIndexOfPage;
    
    UIColor* lNavTextColor = [lManager selectedTextColor];
    self.navigationController.navigationBar.barTintColor = [lManager selectedNavColor];
    self.navigationController.navigationBar.tintColor = lNavTextColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: lNavTextColor};

    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"onThemeChange" object: nil];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

@end
