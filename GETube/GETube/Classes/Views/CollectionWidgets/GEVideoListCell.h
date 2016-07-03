//
//  GEVideoListCell.h
//  GETube
//
//  Created by Deepak on 03/07/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEVideoListCell : UICollectionViewCell

@property(nonatomic, strong)IBOutlet UIView*        titleBaseView;
@property(nonatomic, strong)IBOutlet UILabel*       titleLabel;
@property(nonatomic, strong)IBOutlet UILabel*       timeLabel;
@property(nonatomic, strong)IBOutlet UILabel*       statusLabel;
@property(nonatomic, strong)IBOutlet UIImageView*   videoIcon;

- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl;


@end
