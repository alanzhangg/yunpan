//
//  ShareView.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/1.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView

@property (nonatomic, assign) id parentVC;
@property (nonatomic, copy) NSString * shareCategory;
@property (nonatomic, assign) BOOL isDuoXuan;

- (void)launchView;
- (BOOL)duoxuan:(BOOL)isYes;
- (void)quxiaoGongXuan;
- (void)duoxuanDownload;

@end
