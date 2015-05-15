//
//  TrachFunctionTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/31.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrachFunctionTableViewCellDelegate <NSObject>

- (void)functionAction:(NSIndexPath *)indexPath withTag:(NSInteger)tag;

@end

@interface TrachFunctionTableViewCell : UITableViewCell

@property (nonatomic, assign) id<TrachFunctionTableViewCellDelegate> actionDelegate;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIButton * returnButton;
@property (nonatomic, strong) NSIndexPath * indexPath;

@end
