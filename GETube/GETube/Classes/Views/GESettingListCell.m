//
//  GESettingListCell.m
//  GETube
//
//  Created by Deepak on 15/10/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "GESettingListCell.h"
#import "UIImage+ImageMask.h"
#import "ThemeManager.h"

@implementation GESettingListCell

@synthesize cellTitleLbl = mCellTitleLbl;
@synthesize disclosureImg = mDisclosureImg;
@synthesize onOffSwitch = mOnOffSwitch;
@synthesize selectedValLbl = mSelectedValLbl;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refereshWithData: (NSDictionary*)cellInfo
{
    mOnOffSwitch.hidden = TRUE;
    NSInteger lType = [[cellInfo objectForKey: @"type"] integerValue];
    mOnOffSwitch.hidden = (lType != 204);
    mSelectedValLbl.hidden = (lType != 202);
    mDisclosureImg.hidden = !(lType == 202 || lType == 203 || lType == 205);
    
    ThemeManager* lThemeManager = [ThemeManager themeManager];
    UIColor* lNavColor = [lThemeManager selectedNavColor];
    UIImage* lImage = [UIImage createImageFromMaskWithImageName: @"disclosureicon.png" withFillColor: lNavColor];
    self.disclosureImg.image = lImage;
    
    if (lType == 202)
    {
        NSArray* lValues = [cellInfo objectForKey: @"values"];
        for (NSDictionary* lValue in lValues)
        {
            if ([[lValue objectForKey: @"isSelected"] boolValue])
            {
                mSelectedValLbl.text = [lValue objectForKey: @"title"];
                break;
            }
        }
    }
    
    if (lType == 205)
    {
        BOOL lIsSelected = [[cellInfo objectForKey: @"isSelected"] boolValue];
        lImage = nil;
        if (lIsSelected)
        {
            lImage = [UIImage createImageFromMaskWithImageName: @"tick.png" withFillColor: lNavColor];
        }
        
        self.disclosureImg.image = lImage;
    }
}

@end
