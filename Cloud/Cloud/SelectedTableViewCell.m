//
//  SelectedTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/31.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "SelectedTableViewCell.h"
#import "Global.h"

@implementation SelectedTableViewCell{
    UIView * lineview;
    CGRect rectFrame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
        rectFrame = frame;
        UIEdgeInsets insert = UIEdgeInsetsMake(0, 0, 0, 0);
        self.separatorInset = insert;
    }
    return self;
}

- (void)initSubViews{
    _headPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 40, 40)];
    [self.contentView addSubview:_headPhoto];
    _headPhoto.image = [UIImage imageNamed:@"folder.png"];
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
    
    _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [self.contentView addSubview:_selectedImageView];
    _selectedImageView.image = [UIImage imageNamed:@"check-box-outline-blank.png"];
    _selectedImageView.backgroundColor = [UIColor clearColor];
    
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, rectFrame.size.height - 1, rectFrame.size.width, 1)];
    lineview.backgroundColor = RGB(224, 224, 224);
    [self.contentView addSubview:lineview];
}

- (void)layoutSubview:(NSDictionary *)dic{
    CGRect rect = lineview.frame;
    rect.origin.y = [[dic objectForKey:@"cellheight"] floatValue] - 1;
    lineview.frame = rect;
    
    _titleLabel.frame = CGRectMake(120, 10, rectFrame.size.width - 130, [[dic objectForKey:@"titleheight"] floatValue]);
    _timeLabel.frame = CGRectMake(120, 10 + _titleLabel.frame.size.height, rectFrame.size.width - 210, 20);
    _sizeLabel.frame = CGRectMake(_timeLabel.frame.size.width + _timeLabel.frame.origin.x + 10, _timeLabel.frame.origin.y, 70, 20);
    _selectedImageView.frame = CGRectMake(10, 10, 40, 40);
    
}

- (NSString *)setLength:(float)length
{
    NSString *strLength;
    float len = length;
    if (len > 1024) {
        len = len /1024;
        if (len > 1024) {
            len = len /1024;
            if (len > 1024) {
                len = len /1024;
                if (len > 1024) {
                    len = len /1024;
                }else{
                    strLength = [NSString stringWithFormat:@"%.2fG",len];
                }
            }else{
                strLength = [NSString stringWithFormat:@"%.2fM",len];
            }
        }else{
            strLength = [NSString stringWithFormat:@"%.2fK",len];
        }
    }else{
        strLength = [NSString stringWithFormat:@"%.2fB",len];
    }
    return strLength;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
