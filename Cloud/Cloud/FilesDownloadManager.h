//
//  FilesDownloadManager.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/6.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@class FileData;

#ifdef __cplusplus
#define DOWN_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define DOWN_EXTERN     extern __attribute__((visibility ("default")))
#endif

DOWN_EXTERN NSString * const DownloadDataChange;

@protocol DownloadDelegate <NSObject>
@optional
-(void)startDownload:(ASIHTTPRequest *)request;
-(void)updateCellProgress:(ASIHTTPRequest *)request;
-(void)finishedDownload:(ASIHTTPRequest *)request;
@end

@interface FilesDownloadManager : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>

@property(nonatomic,retain)id<DownloadDelegate> downloadDelegate;
@property (nonatomic, strong) NSMutableArray * downloadListArray;
@property (nonatomic, copy) NSString * basePath;
@property (nonatomic, copy) NSString * targetSubPath;

+(FilesDownloadManager *) sharedFilesDownManage;
- (void)downloadFile:(FileData *)file;
- (void)getSqlData;
-(void)stopRequest:(FileData *)fileData;
- (void)deleteRequest:(FileData *)fileData;
- (void)startRequest:(FileData *)fileData;

@end
