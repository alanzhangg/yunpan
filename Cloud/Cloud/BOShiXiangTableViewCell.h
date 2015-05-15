//
//  BOShiXiangTableViewCell.h
//  BrightOilPad
//
//  Created by Team E Alanzhangg on 9/3/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingButton.h"

@interface BOShiXiangTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) SettingButton * rightButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame;

@end
