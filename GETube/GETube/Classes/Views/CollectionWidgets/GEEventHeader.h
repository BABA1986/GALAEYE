//
//  GEEventHeader.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GEEventHeader;
@protocol GEEventHeaderDelegate <NSObject>

- (void)didSelectSeeMoreOnGEEventHeader: (GEEventHeader*)header;

@end

@interface GEEventHeader : UICollectionReusableView
{
    NSUInteger              mIndex;
}

@property(nonatomic, strong)IBOutlet UILabel*       titleLabel;
@property(nonatomic, strong)IBOutlet UIButton*      seeMoreBtn;

@property(nonatomic, assign)NSUInteger              index;
@property(nonatomic, weak)id<GEEventHeaderDelegate> delegate;

- (IBAction)seeMoreBtnAction:(id)sender;

@end
