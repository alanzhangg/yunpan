
//
//  ListFunctionTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ListFunctionTableViewCell.h"
#import "Global.h"
#import "AppDelegate.h"

@interface ListFunctionTableViewCell ()<UIActionSheetDelegate>

@end

@implementation ListFunctionTableViewCell{
    CGRect rectFrame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = RGB(224, 224, 224);
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    NSArray * array = @[@"下载", @"移动", @"重命名", @"更多"];
    for (int i = 0; i < 4; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10 * (i + 1) + 60 * i, 5, 60, 40);
        btn.tag = 100 + (100 * i);
        [self.contentView addSubview:btn];
        [btn addTarget:self action:@selector(actionFunction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:array[i] forState:UIControlStateNormal];
    }
}

- (void)actionFunction:(UIButton *)sender{
    NSLog(@"%ld", (long)sender.tag);
    if (sender.tag <= 300) {
        if (_allDelegate && [_allDelegate respondsToSelector:@selector(functionAction:withTag:)]) {
            [_allDelegate functionAction:_indexPath withTag:sender.tag];
        }
    }else{
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", @"分享到工作网络", nil];
        AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController * tabbarcon = (UITabBarController *)delegate.window.rootViewController;
        [actionSheet showFromTabBar:tabbarcon.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld", (long)buttonIndex);
    if (_allDelegate && [_allDelegate respondsToSelector:@selector(functionAction:withTag:)]) {
        [_allDelegate functionAction:_indexPath withTag:400 + (100 * buttonIndex)];
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
