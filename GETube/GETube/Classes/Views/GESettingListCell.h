//
//  GESettingListCell.h
//  GETube
//
//  Created by Deepak on 15/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GESettingListCell : UITableViewCell
{
    IBOutlet UILabel*        mCellTitleLbl;
    IBOutlet UIImageView*    mDisclosureImg;
    IBOutlet UISwitch*       mOnOffSwitch;
    IBOutlet UILabel*        mSelectedValLbl;
}

@property(nonatomic, strong)UILabel*        cellTitleLbl;
@property(nonatomic, strong)UIImageView*    disclosureImg;
@property(nonatomic, strong)UISwitch*       onOffSwitch;
@property(nonatomic, strong)UILabel*        selectedValLbl;

- (void)refereshWithData: (NSDictionary*)cellInfo;

@end
