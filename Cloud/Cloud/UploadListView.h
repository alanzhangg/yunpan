//
//  UploadListView.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/29.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadListView : UIView

@property (nonatomic, assign) BOOL isDuoxuan;
@property (nonatomic, assign) id parentVc;

- (void)reloadDatas;
- (BOOL)duoxuan:(BOOL)isYes;
- (void)duoxuanShanchu;

@end
