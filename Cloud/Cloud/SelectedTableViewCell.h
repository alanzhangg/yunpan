//
//  SelectedTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/31.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * headPhoto;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIImageView * selectedImageView;
@property (nonatomic, strong) UILabel * sizeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame;

- (void)layoutSubview:(NSDictionary *)dic;
- (NSString *)setLength:(float)length;

@end
