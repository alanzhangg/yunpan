//
//  UploadFailTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/30.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UploadFailTableViewCellDelegate <NSObject>

- (void)shangchuan:(NSIndexPath *)indexPath;

@end

@interface UploadFailTableViewCell : UITableViewCell

@property (nonatomic, assign) id<UploadFailTableViewCellDelegate> delegate;
@property (nonatomic, strong) UIImageView * headPhoto;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * detailLabel;
@property (nonatomic, strong) UIButton * functionButton;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame;
- (void)layoutSubview:(NSDictionary *)dic;

@end
