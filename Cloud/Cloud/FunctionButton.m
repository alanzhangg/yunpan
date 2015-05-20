//
//  FunctionButton.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/20.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "FunctionButton.h"

@implementation FunctionButton

- (CGRect)backgroundRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 40, contentRect.size.width, 10);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width / 2 - 17.5, 0, 35, 35);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
