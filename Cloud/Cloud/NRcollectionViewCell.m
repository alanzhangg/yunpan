//
//  NRcollectionViewCell.m
//  NeedsReport
//
//  Created by Team E Alanzhangg on 10/14/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import "NRcollectionViewCell.h"

@implementation NRcollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bgImageView];
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_selectedBtn];
        [_selectedBtn setImage:[UIImage imageNamed:@"untitled.png"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)settingFrame:(CGSize)rect{
    
    _bgImageView.frame = CGRectMake(0, 0, rect.width, rect.height);
    _selectedBtn.frame = CGRectMake(rect.width - 32, 0, 32, 32);
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
