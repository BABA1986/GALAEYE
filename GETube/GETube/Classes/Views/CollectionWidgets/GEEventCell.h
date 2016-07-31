//
//  GEEventCell.h
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEEventCell : UICollectionViewCell
@property(nonatomic, strong)IBOutlet UIView*                titleBaseView;
@property(nonatomic, strong)IBOutlet UILabel*               titleLabel;
@property(nonatomic, strong)IBOutlet UILabel*               timeLabel;
@property(nonatomic, strong)IBOutlet UILabel*               statusLabel;
@property(nonatomic, strong)IBOutlet UIImageView*           videoIcon;
@property(nonatomic, strong)IBOutlet UIImageView*           videoPlayIcon;
@property(nonatomic, strong)IBOutlet UIButton*              alarmBtn;
@property(nonatomic, strong)IBOutlet NSLayoutConstraint*    timeLabelMaxX;

- (IBAction)alarmBtnClicked:(id)sender;

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl;

@end
