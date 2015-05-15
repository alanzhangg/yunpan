//
//  NRcollectionViewCell.h
//  NeedsReport
//
//  Created by Team E Alanzhangg on 10/14/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRcollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * bgImageView;
@property (nonatomic, strong) UIButton * selectedBtn;
- (void)settingFrame:(CGSize)rect;

@end
