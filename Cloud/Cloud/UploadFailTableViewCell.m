//
//  UploadFailTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/30.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "UploadFailTableViewCell.h"
#import "Global.h"

@implementation UploadFailTableViewCell{
    UIView * lineview;
    CGRect rectFrame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews:frame];
        rectFrame = frame;
    }
    return self;
}

- (void)initSubViews:(CGRect)frame{
    _headPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
    [self.contentView addSubview:_headPhoto];
    _headPhoto.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.textColor =  RGB(254, 121, 125);
    [self.contentView addSubview:_detailLabel];
    _detailLabel.text = @"上传失败";
    _detailLabel.font = [UIFont systemFontOfSize:14];
    
    _functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_functionButton];
    [_functionButton setImage:[UIImage imageNamed:@"out.png"] forState:UIControlStateNormal];
    _functionButton.tag =  200;
    [_functionButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
    lineview.backgroundColor = RGB(224, 224, 224);
    [self.contentView addSubview:lineview];
}

- (void)showSetting:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(shangchuan:)]) {
        [_delegate shangchuan:_indexPath];
    }
}

- (void)layoutSubview:(NSDictionary *)dic{
    CGRect rect = lineview.frame;
    rect.origin.y = [[dic objectForKey:@"cellheight"] floatValue] - 1;
    lineview.frame = rect;
    
    _titleLabel.frame = CGRectMake(70, 10, rectFrame.size.width - 130, [[dic objectForKey:@"titleheight"] floatValue]);
    _detailLabel.frame = CGRectMake(70, 10 + _titleLabel.frame.size.height, rectFrame.size.width - 200, 20);
    _functionButton.frame = CGRectMake(rect.size.width - 50, [[dic objectForKey:@"cellheight"] floatValue]/2 - 20, 40, 40);
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
