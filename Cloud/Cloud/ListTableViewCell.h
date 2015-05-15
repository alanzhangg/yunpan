//
//  ListTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListTableViewCellDelegate <NSObject>

- (void)settingFunction:(NSIndexPath *)index;

@end

@interface ListTableViewCell : UITableViewCell

@property (nonatomic, assign) id<ListTableViewCellDelegate> funcDelegate;
@property (nonatomic, strong) UIImageView * headPhoto;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * sizeLabel;
@property (nonatomic, strong) UIButton * functionButton;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame;

- (void)layoutSubview:(NSDictionary *)dic;
- (NSString *)setLength:(float)length;

@end
