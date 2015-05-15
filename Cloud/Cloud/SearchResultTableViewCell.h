//
//  SearchResultTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/9.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * headPhoto;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * sizeLabel;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame;

- (void)layoutSubview:(NSDictionary *)dic;
- (CGFloat)calculateSize:(CGFloat)size;

@end
