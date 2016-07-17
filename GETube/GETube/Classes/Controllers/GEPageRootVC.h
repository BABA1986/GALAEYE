//
//  GEPageRootVC.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"
#import "GENavigatorProtocol.h"
#import "CPDropDownSelector.h"

@interface GEPageRootVC : UIViewController<CAPSPageMenuDelegate, GENavigatorProtocol, CPDropDownSelectorDataSource, CPDropDownSelectorDelegate>
{
    CAPSPageMenu*               mPageMenu;
}

- (void)initialisePagesForLeftMenuIndex: (NSInteger)leftMenuIndex;
- (void)applyTheme;
@end
