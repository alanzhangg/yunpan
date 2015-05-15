//
//  DownloadListView.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/13.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;

@interface DownloadListView : UIView

@property (nonatomic, copy) NSString * categoryName;
@property (nonatomic, assign) BOOL isDuoXuan;
@property (nonatomic, assign) id parentVC;

- (void)reloadDatas;
- (BOOL)duoxuan:(BOOL)isYes;
- (void)duoxuanShanchu;
-(void)removeASIRequst:(ASIHTTPRequest*)req;

@end
