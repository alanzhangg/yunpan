//
//  MenuButton.m
//  WorkNetwork
//
//  Created by Team E Alanzhangg on 14/12/24.
//  Copyright (c) 2014年 Team E Alanzhangg. All rights reserved.
//

#import "MenuButton.h"

@implementation MenuButton

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

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
