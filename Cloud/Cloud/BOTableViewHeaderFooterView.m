//
//  BOTableViewHeaderFooterView.m
//  BrightOilPad
//
//  Created by Team E Alanzhangg on 9/22/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import "BOTableViewHeaderFooterView.h"
#import "Global.h"

@implementation BOTableViewHeaderFooterView{
    
    UIView * lineView;
}

@synthesize bgButton;

+ (instancetype)headViewWithTableView:(UITableView *)tableView{
    static NSString * headIdentifier = @"header";
    
    BOTableViewHeaderFooterView * headerView = [tableView dequeueReusableCellWithIdentifier:headIdentifier];
    if (headerView == nil) {
        headerView = [[BOTableViewHeaderFooterView alloc] initWithReuseIdentifier:headIdentifier];
    }
    return headerView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
//        self.contentView.userInteractionEnabled = YES;
        bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
//        [bgButton setBackgroundImage:[UIImage imageNamed:@"sectionHeader.png"] forState:UIControlStateNormal];
//        [bgButton setBackgroundImage:[UIImage imageNamed:@"lef02.png"] forState:UIControlStateSelected];
        [bgButton addTarget:self action:@selector(searchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        
        _detailButton = [SettingButton buttonWithType:UIButtonTypeCustom];
        [_detailButton setImage:[UIImage imageNamed:@"lefsan.png"] forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(showDetailData:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_detailButton];
        
        lineView = [[UIView alloc] init];
        [self addSubview:lineView];
        lineView.backgroundColor = RGB(211, 210, 212);
    }
    return self;
}

- (void)searchButton:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(clickHeaderView: with:)]) {
        [_delegate clickHeaderView:_friendData with:self];
    }
}

- (void)showDetailData:(UIButton *)sender{
    _friendData.isOpen = !_friendData.isOpen;
    
    if (_delegate && [_delegate respondsToSelector:@selector(clickDetailButton)]) {
        [_delegate clickDetailButton];
    }
}

- (void)layoutSubviews{
//    bgButton.frame = self.bounds;
    lineView.frame = CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 1);
    bgButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _titleLabel.frame = CGRectMake(5, 0, self.frame.size.width - 40, self.bounds.size.height);
    _detailButton.frame = CGRectMake(self.frame.size.width - 45, 5, 40, 40);
}

- (void)didMoveToSuperview{
    _detailButton.transform = _friendData.isOpen ?  CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformMakeRotation(0);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
