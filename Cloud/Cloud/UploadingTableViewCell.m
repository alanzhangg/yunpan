//
//  UploadingTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/30.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "UploadingTableViewCell.h"
#import "Global.h"
#import "CommonHelper.h"

@implementation UploadingTableViewCell{
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
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    _sizeLabel = [[UILabel alloc] init];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_sizeLabel];
    _sizeLabel.font = [UIFont systemFontOfSize:14];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    
    _functionButton = [[CircularProgressButton alloc]initWithFrame:CGRectMake(rectFrame.size.width - 100, 10, 40, 40)
                                                         backColor:[UIColor lightGrayColor]
                                                     progressColor:[UIColor greenColor]
                                                         lineWidth:8];
    
//    [_functionButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];;
//    _functionButton.selected = YES;
    [self.contentView addSubview:_functionButton];
    
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
    lineview.backgroundColor = RGB(224, 224, 224);
    [self.contentView addSubview:lineview];
}


- (void)layoutSubview:(NSDictionary *)dic{
    CGRect rect = lineview.frame;
    rect.origin.y = [[dic objectForKey:@"cellheight"] floatValue] - 1;
    lineview.frame = rect;
    
    _titleLabel.frame = CGRectMake(70, 10, rectFrame.size.width - 130, [[dic objectForKey:@"titleheight"] floatValue]);
    _timeLabel.frame = CGRectMake(70, 10 + _titleLabel.frame.size.height, 100, 20);
    _sizeLabel.frame = CGRectMake(_timeLabel.frame.size.width + _timeLabel.frame.origin.x + 10, _timeLabel.frame.origin.y, 70, 20);
    _functionButton.frame = CGRectMake(rectFrame.size.width - 60, 10, 40, 40);
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
