//
//  GESettingViewCtr.h
//  GETube
//
//  Created by Deepak on 06/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>

@interface GESettingViewCtr : UIViewController<UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate>
{
    IBOutlet UITableView*      mSettingListView;
    NSMutableArray*            mSettingList;
}

@end
