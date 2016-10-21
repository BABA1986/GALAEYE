//
//  GEIntoductionViewCtr.h
//  GETube
//
//  Created by Deepak on 09/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"

@class GEIntoductionViewCtr;
@protocol GEIntoductionViewCtrDelegate <NSObject>

- (void)introductionDidFinish: (GEIntoductionViewCtr*)introCtr;
- (void)introductionDidSkip: (GEIntoductionViewCtr*)introCtr;
- (void)clickLoginOnIntroduction: (GEIntoductionViewCtr*)introCtr;

@end

@interface GEIntoductionViewCtr : UIViewController<MYIntroductionDelegate>
{
    MYBlurIntroductionView*                     mGEIntroView;
    __weak id<GEIntoductionViewCtrDelegate>     mDelegate;
}

@property(nonatomic, weak)id<GEIntoductionViewCtrDelegate> delegate;

@end
