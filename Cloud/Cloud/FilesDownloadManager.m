//
//  FilesDownloadManager.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/6.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "FilesDownloadManager.h"
#import "ASIFormDataRequest.h"
#import "FileData.h"
#import "CommonHelper.h"
#import "SQLCommand.h"

#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basePath]


@implementation FilesDownloadManager{
    ASINetworkQueue * queue;
    NSMutableArray * downinglist;
}

NSString * const DownloadDataChange = @"DownloadDataChange";

@synthesize basePath = _basePath, targetSubPath = _targetSubPath;

static FilesDownloadManager * sharedFilesDownManage = nil;

+ (FilesDownloadManager *)sharedFilesDownManage{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}

- (id)init{
    if ([super init]) {
        downinglist = [NSMutableArray new];
        _basePath = @"Download";
        _targetSubPath = @"folder";
        _downloadListArray = [NSMutableArray new];
    }
    return self;
}

- (void)getSqlData{
    _downloadListArray = [[SQLCommand shareSQLCommand] getDownloadListData];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataChange object:nil];
    [self addRequest];
}

- (void)addRequest{
    NSMutableArray * array = _downloadListArray[1];
    for (FileData * data in array) {
        if (![data.fileFormat isEqualToString:@"f"]) {
            NSArray * array = [queue operations];
            int i = 0;
            for (i = 0; i < array.count; i++) {
                ASIHTTPRequest * req = array[i];
                FileData * fileData = [req.userInfo objectForKey:@"File"];
                if ([fileData.fileID isEqualToString:data.fileID]) {
                    break;
                }
            }
            if (i >= array.count) {
                [self downloadFile:data];
            }
        }
    }
}

- (void)downloadFile:(FileData *)file{
    //    _fileInfo.isFirstReceived = YES;
    //临时路径
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    if (![file.fileFormat isEqualToString:@"f"]) {
        NSString * path= [CommonHelper getTargetPathWithBasepath:_basePath subpath:_targetSubPath];
        path = [path stringByAppendingPathComponent:file.fileName];
        file.targetPath = path ; //下载路径
        file.isDownloading=YES;
        file.willDownloading = YES;
        file.error = NO;
        if (file.downloadUrl.length > 3) {
            NSString * urlstr;
            if ([[file.downloadUrl substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [file.downloadUrl stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [file.downloadUrl stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            NSLog(@"%@", urlstr);
            //                         [ [FIleDownLoadManager sharedFilesDownManage] downFileUrl:urlstr filename:data.fileName filetarget:@"folder"];
            NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: file.fileName]  ;
            file.tempPath = tempfilePath;
            file.fileURL = urlstr;
            if (!queue){
                [self newASINetworkQueueWithUrl:file];
            }else{
                [self addNewRequestWithGuid:file];
            }
        }
    }
}

//初始化并继续下载
- (void)keepOnNewASINetworkQueueWithGuid:(FileData*)fileInfo
{
    if(queue==nil)
        queue = [[ASINetworkQueue alloc]init];
    [queue setDownloadProgressDelegate:self];
    [queue setShowAccurateProgress:YES];
    queue.maxConcurrentOperationCount = 1;
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setNumberOfTimesToRetryOnTimeout:2];
//    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    [request setContentLength:[fileInfo.fileSize longLongValue]];
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信
    
    [queue addOperation:request];
//    [downinglist addObject:request];
//    [queue go];
}
//继续下载
- (void)keepOnAddNewRequestWithGuid:(FileData*)fileInfo
{
    if(queue==nil)
        queue = [[ASINetworkQueue alloc]init];
    [queue setDownloadProgressDelegate:self];
    [queue setShowAccurateProgress:YES];
    queue.maxConcurrentOperationCount = 1;
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setNumberOfTimesToRetryOnTimeout:2];
//    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    [request setContentLength:[fileInfo.fileSize longLongValue]];
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信
    
    [queue addOperation:request];
//    [downinglist addObject:request];
}

//初始化队列，并向队列加入任务
- (void)newASINetworkQueueWithUrl:(FileData *)fileInfo
{
    if(queue==nil){
        queue = [[ASINetworkQueue alloc]init];
        [queue setDownloadProgressDelegate:self];
        [queue setShowAccurateProgress:YES];
        queue.maxConcurrentOperationCount = 1;
    }
    
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
     [request setAllowResumeForFileDownloads:YES];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setShowAccurateProgress:YES];
    [request setAllowResumeForFileDownloads:YES]; //支持断点续传
    NSLog(@"%lld", [fileInfo.fileSize longLongValue]);
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信
    [request setContentLength:[fileInfo.fileSize longLongValue]];
    [queue addOperation:request];
//    [downinglist addObject:request];
    [queue setShouldCancelAllRequestsOnFailure:NO];
    
    //只有从入口进去的才启动下载，只是打开页面不执行
    
    [queue go];
}

//向队列中加入任务
- (void)addNewRequestWithGuid:(FileData *)fileInfo
{
    if(queue==nil){
        queue = [[ASINetworkQueue alloc]init];
        [queue setDownloadProgressDelegate:self];
        [queue setShowAccurateProgress:YES];
        queue.maxConcurrentOperationCount = 1;
    }
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    [request setShowAccurateProgress:YES];
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信
    [request setContentLength:[fileInfo.fileSize longLongValue]];
    NSLog(@"%lld", [fileInfo.fileSize longLongValue]);
    [queue addOperation:request];
//    [downinglist addObject:request];
//    [queue go];
    
}


//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }else{
        if ([request isExecuting]) {
            [request cancel];
        }
        FileData * fileInfo = [request.userInfo objectForKey:@"File"];
        fileInfo.isHasDownload = @(0);
        fileInfo.downloadStatus = @(0);
        [[SQLCommand shareSQLCommand] updateDownloadData:@[fileInfo]];
        [self getSqlData];
    }
    
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    FileData *fileInfo=(FileData *)[request.userInfo objectForKey:@"File"];
    NSLog(@"%@ ============> 开始了!",fileInfo.fileName);
    
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    FileData *fileInfo=[request.userInfo objectForKey:@"File"];
    NSLog(@"%@ ============> 收到回复了！",fileInfo.fileName);
    
    NSLog(@"%@", responseHeaders);
    
    NSString *len = [NSString stringWithFormat:@"%@", fileInfo.fileSize];//
    
    [request setContentLength:[fileInfo.fileSize longLongValue]];
    
    NSLog(@"============================================>%@的大小为:%@",fileInfo.fileName,len );
    if ([fileInfo.fileSize longLongValue]> [len longLongValue])
    {
        return;
    }
}

static double zhongjianshijian = 0;

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FileData *fileInfo=[request.userInfo objectForKey:@"File"];
    if (zhongjianshijian == 0) {
        zhongjianshijian = [[NSDate date] timeIntervalSince1970];
    }else{
        double lingshishijian = [[NSDate date] timeIntervalSince1970];
        NSLog(@"下载速度 ＝＝》 %f", lingshishijian - zhongjianshijian);
        fileInfo.uploadSpeed = bytes / (lingshishijian - zhongjianshijian);
        zhongjianshijian = lingshishijian;
    }
    
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.hasDownloadSize =[NSString stringWithFormat:@"%lld",bytes];
    }
    else if(!fileInfo.isFirstReceived)
    {
        fileInfo.hasDownloadSize=[NSString stringWithFormat:@"%lld",[fileInfo.hasDownloadSize longLongValue]+bytes];
    }
    
    NSLog(@"%s %@,%lld", __func__,fileInfo.hasDownloadSize,bytes);
    if (_downloadDelegate && [_downloadDelegate respondsToSelector:@selector(updateCellProgress:)]) {
        [_downloadDelegate updateCellProgress:request];
    }
    
}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    
    FileData *fileInfo=(FileData *)[request.userInfo objectForKey:@"File"];
    fileInfo.isHasDownload = @(2);
    fileInfo.downloadStatus = @(0);
    [[SQLCommand shareSQLCommand] updateDownloadData:@[fileInfo]];
    [[SQLCommand shareSQLCommand] updateDownloadFolderQuantity:fileInfo];
    if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
    {
        [self.downloadDelegate finishedDownload:request];
    }
    [self getSqlData];
    NSLog(@"%@ ============> 下载结束了！",fileInfo.fileName);
    // NSLog(@"下载结束了");
//    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataChange object:nil];
}

- (void)setProgress:(float)newProgress{
    NSLog(@"%f", newProgress);
    
}

-(void)stopRequest:(FileData *)fileData{
    
    fileData.downloadStatus = @(1);
    [[SQLCommand shareSQLCommand] updateDownloadData:@[fileData]];
    NSArray * array = [queue operations];
    for (ASIHTTPRequest * req in array) {
        FileData * data = [req.userInfo objectForKey:@"File"];
        if ([data.fileID isEqualToString:fileData.fileID]) {
            [req cancel];
        }
    }
}

- (void)startRequest:(FileData *)fileData{
    if (fileData) {
        fileData.downloadStatus = @(0);
        [[SQLCommand shareSQLCommand] updateDownloadData:@[fileData]];
    }
//    NSArray * array = [queue operations];
//    if (array.count <= 0) {
    [self getSqlData];
//    }
}

- (void)deleteRequest:(FileData *)fileData{
    NSArray * resArray = [queue operations];
    for (ASIHTTPRequest * resquest in resArray) {
        FileData * data = [resquest.userInfo objectForKey:@"File"];
        if ([data.fileID isEqualToString:fileData.fileID]) {
            [resquest cancel];
        }
    }
}

@end
