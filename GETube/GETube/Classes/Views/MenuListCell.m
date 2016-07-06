//
//  MenuListCell.m
//  GETube
//
//  Created by Deepak on 19/06/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "MenuListCell.h"
#import "GEConstants.h"

@implementation MenuListCell

@synthesize menuTitleLbl;
@synthesize menuIconView;

- (void)awakeFromNib
{
    // Initialization code
    menuTitleLbl.textAlignment = NSTextAlignmentLeft;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
