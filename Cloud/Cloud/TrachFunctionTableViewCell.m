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
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    CGRect rect = [[UIScreen mainScreen] bounds];
    _returnButton = [FunctionButton buttonWithType:UIButtonTypeCustom];
    _returnButton.frame = CGRectMake(rect.size.width/4 - 25, 5, 50, 50);
    [self.contentView addSubview:_returnButton];
    [_returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _returnButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_returnButton setImage:[UIImage imageNamed:@"huanyuan.png"] forState:UIControlStateNormal];
    [_returnButton setTitle:@"还原" forState:UIControlStateNormal];
    _returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_returnButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    _returnButton.tag = 100;
    
    _deleteButton = [FunctionButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(rect.size.width * 3 / 4 - 25, 5, 50, 50);
    [_deleteButton setImage:[UIImage imageNamed:@"chedishanchu.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    _deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
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
