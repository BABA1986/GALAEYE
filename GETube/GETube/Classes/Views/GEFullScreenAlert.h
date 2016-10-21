//
//  GEFullScreenAlert.h
//  GETube
//
//  Created by Deepak on 05/09/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEFullScreenAlert : UIView
{
    IBOutlet UILabel*            mTitleLabel;
    IBOutlet UILabel*            mDescLabel;
    IBOutlet UIImageView*        mIconView;
    IBOutlet UIButton*           mActionBtn;
}

@property(nonatomic, strong)UILabel*        titleLabel;
@property(nonatomic, strong)UILabel*        descLabel;
@property(nonatomic, strong)UIImageView*    iconView;
@property(nonatomic, strong)UIButton*       actionBtn;

@end
