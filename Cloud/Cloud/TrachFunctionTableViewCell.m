//
//  TrachFunctionTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/31.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "TrachFunctionTableViewCell.h"

@implementation TrachFunctionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.frame = CGRectMake(40, 0, 50, 50);
    [self.contentView addSubview:_returnButton];
    [_returnButton setTitle:@"还原" forState:UIControlStateNormal];
    [_returnButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    _returnButton.tag = 100;
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(100, 0, 50, 50);
    [self.contentView addSubview:_deleteButton];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.tag = 200;
    
}

- (void)setting:(UIButton *)sender{
    NSString * str;
    if (sender.tag == 100) {
        str = @"确定要还原该文件或文件夹吗?";
    }else if (sender.tag == 200){
        str = @"文件或文件夹删除后将无法恢复，您确认要彻底删除吗?";
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    alert.tag = sender.tag;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(functionAction:withTag:)]) {
            [_actionDelegate functionAction:_indexPath withTag:alertView.tag];
        }
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
