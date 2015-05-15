//
//  BOTableViewHeaderFooterView.h
//  BrightOilPad
//
//  Created by Team E Alanzhangg on 9/22/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLiatData.h"
#import "SettingButton.h"

@protocol BOTableViewHeaderFooterViewDelegate;

@interface BOTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) SettingButton * detailButton;
@property (nonatomic, strong) NetworkLiatData * friendData;
@property (nonatomic, strong) UIButton * bgButton;;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, assign) id <BOTableViewHeaderFooterViewDelegate> delegate;
+ (instancetype)headViewWithTableView:(UITableView *)tableView;


@end

@protocol BOTableViewHeaderFooterViewDelegate <NSObject>

- (void)clickHeaderView:(NetworkLiatData *)data with:(BOTableViewHeaderFooterView *)view;
- (void)clickDetailButton;

@end