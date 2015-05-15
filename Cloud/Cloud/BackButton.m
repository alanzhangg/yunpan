//
//  BackButton.m
//  WorkNetwork
//
//  Created by Team E Alanzhangg on 15/1/6.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "BackButton.h"

@implementation BackButton

- (CGRect)backgroundRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds{
    return bounds;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return contentRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 7, 25, 25);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
