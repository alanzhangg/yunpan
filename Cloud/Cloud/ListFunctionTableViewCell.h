//
//  ListFunctionTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListFunctionTableViewCellDelegate <NSObject>

- (void)functionAction:(NSIndexPath *)indexPath withTag:(NSInteger)tag;

@end

@interface ListFunctionTableViewCell : UITableViewCell

@property (nonatomic, assign) id<ListFunctionTableViewCellDelegate> allDelegate;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame;

@end
