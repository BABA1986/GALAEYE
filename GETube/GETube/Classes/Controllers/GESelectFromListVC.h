//
//  GESelectFromListVC.h
//  GETube
//
//  Created by Deepak on 16/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GESelectFromListVC;
@protocol GESelectFromListVCDelegate <NSObject>

- (void)GESelectFromListVC: (GESelectFromListVC*)listVC didSelectItemAtIndex: (NSUInteger)index;

@end

@interface GESelectFromListVC : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView*    mListView;
    NSMutableArray*          mValues;
    NSString*                mHeaderTitle;
}

@property(nonatomic, strong)NSMutableArray*      values;
@property(nonatomic, copy)NSString*              headerTitle;

@end
