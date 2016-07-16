//
//  GESettingViewCtr.m
//  GETube
//
//  Created by Deepak on 06/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESettingViewCtr.h"
#import "GESettingHeader.h"
#import "GESettingThemeCell.h"
#import "ThemeManager.h"

@interface GESettingViewCtr ()

@end

@implementation GESettingViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    UICollectionViewFlowLayout* lLayout = (UICollectionViewFlowLayout*) mCollectionView.collectionViewLayout;
    CGFloat lLength = self.view.bounds.size.width/3 - 3.0;
    lLayout.itemSize = CGSizeMake(lLength, lLength);
    lLayout.sectionInset = UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0);
    lLayout.minimumInteritemSpacing = 0.0;
    lLayout.minimumLineSpacing = 5.0;
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
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        ThemeManager* lThemeManager = [ThemeManager themeManager];
        return lThemeManager.themes.count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GESettingThemeCellID";
    
    GESettingThemeCell* lCell = (GESettingThemeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    ThemeInfo* lThemeInfo = [lThemeManager.themes objectAtIndex: indexPath.row];
    lCell.themeTileView.backgroundColor = lThemeInfo.navColor;
    lCell.textLabel.textColor = lThemeInfo.navTextColor;
    
    if (lThemeManager.selectedIndex == indexPath.row)
    {
        lCell.themeTileView.layer.borderWidth = 3.0;
        lCell.themeTileView.layer.borderColor = [lThemeInfo.navTextColor CGColor];
    }
    else
    {
        lCell.themeTileView.layer.borderWidth = 0.0;
    }
    return lCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        GESettingHeader* lHeaderView = (GESettingHeader*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GESettingHeaderID" forIndexPath:indexPath];
        
        if (indexPath.section == 0)
        {
            lHeaderView.titleLabel.text = @"Select Theme";
        }
        else
        {
            lHeaderView.titleLabel.text = @"Filter Channel";
        }
        
        reusableview = lHeaderView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    lThemeManager.selectedIndex = indexPath.row;
    
    [mCollectionView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"onThemeChange" object: nil];
}

@end
