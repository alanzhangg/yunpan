//
//  ShareFunctionTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/1.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareFunctionTableViewCellDelegate <NSObject>

- (void)shareFunctions:(NSIndexPath *)indexPath;

@end

@interface ShareFunctionTableViewCell : UITableViewCell

@property (nonatomic, assign) id<ShareFunctionTableViewCellDelegate> shareDelegate;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIButton * deleteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame;

@end
