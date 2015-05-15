//
//  ListHiddenTableView.h
//  WorkNetwork
//
//  Created by Team E Alanzhangg on 14/11/28.
//  Copyright (c) 2014年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ListHiddenTableViewBlock) (NSInteger index);

@interface ListHiddenTableView : UIView

@property (nonatomic, strong) NSArray * buttonArray;
@property (nonatomic, copy) ListHiddenTableViewBlock block;

- (void)showOperationView;
- (void)reloadData;

@end
