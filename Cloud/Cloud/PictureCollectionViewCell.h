//
//  PictureCollectionViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/10.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIImageView * imageView;

- (void)settingFrame:(CGRect)rect withInter:(int)inter;

@end
