//
//  UploadNetwork.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/28.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UploadData;

@protocol UploadNetworkDelegate <NSObject>

- (void)updatingCellData:(UploadData *)data;

@end

@interface UploadNetwork : NSObject

@property (nonatomic, assign) id<UploadNetworkDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * listArray;
@property (nonatomic, strong) UploadData * uploadData;

+ (UploadNetwork *)shareUploadNetwork;
- (void)getUploadData;
- (void)startUpload;
- (void)cancleUpload;

@end
