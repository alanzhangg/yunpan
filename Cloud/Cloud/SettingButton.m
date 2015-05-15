//
//  SettingButton.m
//  BrightOil
//
//  Created by Team E Alanzhangg on 14-8-13.
//  Copyright (c) 2014年 Team E Alanzhangg. All rights reserved.
//

#import "SettingButton.h"

@implementation SettingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(5, 5, 30, 30);
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
