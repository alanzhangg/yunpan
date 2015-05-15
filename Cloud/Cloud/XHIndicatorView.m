//
//  XHIndicatorView.m
//  XHScrollMenu
//
//  Created by 曾 宪华 on 14-3-8.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "XHIndicatorView.h"

@implementation XHIndicatorView

- (void)setIndicatorWidth:(CGFloat)indicatorWidth {
    _indicatorWidth = indicatorWidth;
    CGRect indicatorRect = self.frame;
    indicatorRect.size.width = _indicatorWidth;
    self.frame = indicatorRect;
}

+ (instancetype)initIndicatorView {
    XHIndicatorView *indicatorView = [[XHIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, kXHIndicatorViewHeight)];
    indicatorView.layer.masksToBounds = YES;
    indicatorView.layer.cornerRadius = 1;
    return indicatorView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor colorWithRed:0.752 green:0.026 blue:0.034 alpha:1.000];
        self.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:132.0/255.0 blue:255.0/255.0 alpha:1.0];
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
