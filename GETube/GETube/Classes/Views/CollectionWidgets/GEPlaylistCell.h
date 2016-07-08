//
//  GEPlaylistCell.h
//  GETube
//
//  Created by Deepak on 24/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEPlaylistCell : UICollectionViewCell

@property(nonatomic, strong)IBOutlet UIImageView*   thumbIconView;
@property(nonatomic, strong)IBOutlet UIImageView*   playlistIconView;
@property(nonatomic, strong)IBOutlet UILabel*       noOfVideoLbl;
@property(nonatomic, strong)IBOutlet UILabel*       videoLbl;
@property(nonatomic, strong)IBOutlet UILabel*       videoTileLbl;


- (void)loadVideoThumbFromUrl: (NSURL*)thumbUrl;

@end
