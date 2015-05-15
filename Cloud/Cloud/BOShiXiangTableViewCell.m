//
//  BOShiXiangTableViewCell.m
//  BrightOilPad
//
//  Created by Team E Alanzhangg on 9/3/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import "BOShiXiangTableViewCell.h"
#import "Global.h"


@implementation BOShiXiangTableViewCell{
    UIView * lineView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initSubViews:frame];
        
    }
    return self;
}

- (void)initSubViews:(CGRect)frame{
    
    
    UIImageView * bgImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 53)];
//    bgImagView.backgroundColor = [UIColor redColor];
    bgImagView.image = [UIImage imageNamed:@"lef01.png"];
    self.backgroundView = bgImagView;
    
//    UIImageView * selectedBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 53)];
//    selectedBgView.image = [UIImage imageNamed:@"lef02.png"];
//    self.selectedBackgroundView = selectedBgView;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frame.size.width - 20, 50)];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    _rightButton = [SettingButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(frame.size.width - 50, 5, 39, 39);
    [_rightButton setImage:[UIImage imageNamed:@"lefsan.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:_rightButton];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 53, frame.size.width, 1)];
    [self.contentView addSubview:lineView];
    lineView.backgroundColor = RGB(211, 210, 212);
    [self.contentView bringSubviewToFront:lineView];
    
//    _rightButton.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
