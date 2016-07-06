//
//  GEEventVC.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GEEventHeader.h"
#import "DGActivityIndicatorView.h"


@interface GEEventVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GEEventHeaderDelegate>
{
    IBOutlet UICollectionView*          mEventListView;
    DGActivityIndicatorView*            mIndicator;
}

- (void)applyTheme;

@end
