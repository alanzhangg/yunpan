//
//  ShareFunctionTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/1.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ShareFunctionTableViewCell.h"

@implementation ShareFunctionTableViewCell{
    CGRect rectFrame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(100, 0, 100, 50);
    [self.contentView addSubview:_deleteButton];
    [_deleteButton setTitle:@"分享" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.tag = 200;
}

- (void)setting:(UIButton *)sender{
    if (_shareDelegate && [_shareDelegate respondsToSelector:@selector(shareFunctions:)]) {
        [_shareDelegate shareFunctions:_indexPath];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
