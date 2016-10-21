//
//  GESelectFromListVC.m
//  GETube
//
//  Created by Deepak on 16/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESelectFromListVC.h"
#import "GESettingListCell.h"

@interface GESelectFromListVC ()

@end

@implementation GESelectFromListVC

@synthesize values = mValues;
@synthesize headerTitle = mHeaderTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Setting";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [mListView reloadData];
}

- (void)setValues:(NSMutableArray *)values
{
    NSMutableArray* lValues = [[NSMutableArray alloc] init];
    for (NSDictionary* lValue in values)
    {
        NSMutableDictionary* lMValue = [[NSMutableDictionary alloc] initWithDictionary: lValue];
        [lValues addObject: lMValue];
    }
    
    mValues = [[NSMutableArray alloc] initWithArray: lValues];
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
#pragma mark- UICollectionViewDelegate and UICollectionViewDatasource
#pragma mark-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kCellIdentifier = @"SettingCellIdentifier";
    
    GESettingListCell* lCell = (GESettingListCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    NSDictionary* lListItem = [mValues objectAtIndex: indexPath.row];
    lCell.cellTitleLbl.text = [lListItem objectForKey: @"title"];
    [lCell refereshWithData: lListItem];
    return lCell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 64.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lLabel = [[UILabel alloc] init];
    lLabel.numberOfLines = 0;
    lLabel.backgroundColor = [UIColor clearColor];
    UIFont* lFont = [UIFont fontWithName: @"Helvetica" size: 14.0];
    lLabel.font = lFont;
    lLabel.text = mHeaderTitle;
    lLabel.textColor = [UIColor darkGrayColor];
    
    UIView* lView = [[UIView alloc] init];
    lView.backgroundColor = [UIColor clearColor];
    [lView addSubview: lLabel];
    
    CGRect lLblRect = lLabel.frame;
    lLblRect.origin.x = 15.0; lLblRect.origin.y = 0.0;
    lLblRect.size.width = CGRectGetWidth(tableView.frame) - 30.0;
    lLblRect.size.height = 64.0;
    lLabel.frame = lLblRect;
    
    return lView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSMutableDictionary* lValue in mValues)
    {
        [lValue setValue: [NSNumber numberWithBool: FALSE] forKey: @"isSelected"];
    }
    
    NSMutableDictionary* lSelValue = [mValues objectAtIndex: indexPath.row];
    [lSelValue setValue: [NSNumber numberWithBool: TRUE] forKey: @"isSelected"];

    [mListView reloadData];
}

@end
