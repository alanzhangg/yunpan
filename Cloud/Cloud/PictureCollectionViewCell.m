//
//  PictureCollectionViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/10.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "PictureCollectionViewCell.h"

@implementation PictureCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        
        
        [self addSubview:_scrollView];
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _backView.backgroundColor = [UIColor clearColor];;
        [_scrollView addSubview:_backView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        [_backView addSubview:_imageView];
    }
    return self;
}

- (void)settingFrame:(CGRect)rect withInter:(int)inter{
    _scrollView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    _scrollView.zoomScale = 1.0;
    _scrollView.zoomScale = 1.0;
    if (_imageView.image) {
        _backView.frame = CGRectMake(0, (_scrollView.frame.size.height - _imageView.image.size.height * _scrollView.frame.size.width/ _imageView.image.size.width) / 2, _scrollView.frame.size.width, _imageView.image.size.height * _scrollView.frame.size.width/ _imageView.image.size.width);
        _imageView.frame = CGRectMake(0, 0, _backView.frame.size.width, _backView.frame.size.height);
    }else{
        _backView.frame = CGRectMake(0, 0, 10, 10);
        _imageView.frame = CGRectZero;
    }
    
    
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sscrollView{
    return _backView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sscrollView withView:(UIView *)view atScale:(CGFloat)scale{
    CGRect viewRect = sscrollView.frame;
    CGRect rect = view.frame;
    if (sscrollView.frame.size.height > view.frame.size.height) {
        rect.origin.y = (viewRect.size.height - rect.size.height)/2;
    }else{
        rect.origin.y = 0;
    }
    view.frame = rect;
}

@end
