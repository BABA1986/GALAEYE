//
//  GEVideoListHeader.h
//  GETube
//
//  Created by Deepak on 03/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEVideoListHeader : UICollectionReusableView
{
    
}

@property(nonatomic, strong)IBOutlet UIView*        baseView;
@property(nonatomic, strong)IBOutlet UILabel*       listTitleLbl;
@property(nonatomic, strong)IBOutlet UILabel*       channelNameLbl;
@property(nonatomic, strong)IBOutlet UILabel*       noOfVideosLbl;
@property(nonatomic, strong)IBOutlet NSLayoutConstraint*       titleHeight;

@end
