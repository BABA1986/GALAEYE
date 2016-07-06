//
//  GEMenuVC.h
//  GETube
//
//  Created by Deepak on 18/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuListHeader.h"

@class GEMenuVC;
@protocol GEMenuVCDelegate <NSObject>

- (void)GEMenuVC: (GEMenuVC*)menuVC didSelectAtIndex: (NSIndexPath*)indexPath;

@end

@interface GEMenuVC : UIViewController <UITableViewDataSource, UITableViewDelegate, MenuListHeaderDelegate>
{
    IBOutlet UITableView*           mMenuListView;
    IBOutlet UITableView*           mFooterListView;
    
    __weak id<GEMenuVCDelegate>     mDelegate;
}

@property(nonatomic, weak)id<GEMenuVCDelegate>     delegate;

@end
