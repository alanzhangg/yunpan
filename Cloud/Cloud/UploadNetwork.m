//
//  UploadNetwork.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/28.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "UploadNetwork.h"
#import "AFNetworking.h"
#import "SQLCommand.h"
#import "UploadData.h"
#import "NetWorkingRequest.h"
#import "JSONKit.h"
#import "Alert.h"

static UploadNetwork * uploadNetwork = nil;

@implementation UploadNetwork{
    AFHTTPClient * uploadFileClient;
    AFHTTPRequestOperation * fileUploadOp;
    NSTimer * statusTimer;
}

+ (UploadNetwork *)shareUploadNetwork{
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        uploadNetwork = [[UploadNetwork alloc] init];
        [uploadNetwork getUploadData];
    });
    return uploadNetwork;
}

- (void)getUploadData{
    uploadFileClient = [AFHTTPAPIClient shareClient];
    _listArray = [[SQLCommand shareSQLCommand] selectUploadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"listChange" object:nil];
}

- (void)startUpload{
    
    if ([fileUploadOp isExecuting]) {
        return;
    }
    
    NSLog(@"%d", uploadFileClient.networkReachabilityStatus);
    
    if (uploadFileClient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"非wifi环境确认上传" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
        [alertView show];
    }else if (uploadFileClient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || uploadFileClient.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [self upload];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

- (void)upload{
    NSArray * array = _listArray[1];
    if (array.count > 0) {
        UploadData * data = array[0];
        _uploadData = data;
        data.isUploading = YES;
        if (!uploadFileClient) {
            uploadFileClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
            uploadFileClient.allowsInvalidSSLCertificate = YES;
        }
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyM"];
        NSString * timeString = [dateFormatter stringFromDate:[NSDate date]];
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * string = [NSString stringWithFormat:@"%@/r/uf?sid=%@&groupValue=%@&repositoryName=-myfile&appId=com.actionsoft.apps.mydriver&fileValue=%@", [ud objectForKey:@"server"], [ud objectForKey:@"sid"], [ud objectForKey:@"uid"], timeString];
        //            NSString * string = @"http://www.baidu.com";
        NSLog(@"%@", string);
        NSString * path = NSHomeDirectory();
        NSString * strPath = [NSString stringWithFormat:@"Documents/upload/%@", data.fileName];
        path = [path stringByAppendingPathComponent:strPath];
        NSLog(@"path = %@", [NSURL URLWithString:path]);
        
        NSMutableURLRequest * request = [uploadFileClient multipartFormRequestWithMethod:@"POST" path:string parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError * err = nil;
            
            NSLog(@"%@", [[NSURL fileURLWithPath:path] pathExtension]);
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:data.fileName error:&err];
            
            if (err) {
                NSLog(@"file = %@", [err localizedDescription]);
            }
        }];
        NSLog(@"%@", request);
        fileUploadOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        __weak UploadNetwork * weakSelf = self;
        __block double zhongjianshijian = 0;
        
        [fileUploadOp setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            if (zhongjianshijian == 0) {
                zhongjianshijian = [[NSDate date] timeIntervalSince1970];
            }else{
                double lingshishijian = [[NSDate date] timeIntervalSince1970];
                NSLog(@"下载速度 ＝＝》 %f", lingshishijian - zhongjianshijian);
                data.uploadSpeed = bytesWritten / (lingshishijian - zhongjianshijian);
                zhongjianshijian = lingshishijian;
            }
            
            data.uploadSize = totalBytesWritten;
            NSLog(@"上传大小 ＝ %lu   %lld     %lld  ", (unsigned long)bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
        
        [fileUploadOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            data.isUploading = NO;
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            data.UPLOADtIME = [formatter stringFromDate:[NSDate date]];
            
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            //        [[UploadNetwork shareUploadNetwork] updateServer:data];
            NSLog(@"res = %@", responseObject);
            NSLog(@"dic = %@", dic);
            if (dic) {
                [[UploadNetwork shareUploadNetwork] updateServer:data withDic:dic];
            }else{
                data.status = @(0);
                [[SQLCommand shareSQLCommand] updateUploadData:data];
                [[UploadNetwork shareUploadNetwork] getUploadData];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            data.status = @(0);
            data.isUploading = NO;
            [[SQLCommand shareSQLCommand] updateUploadData:data];
            [[UploadNetwork shareUploadNetwork] getUploadData];
            NSLog(@"op =  %@", error.localizedDescription);
        }];
        [self setStatusTimer:[NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(updateStatus:) userInfo:nil repeats:YES]];
        [[NSRunLoop currentRunLoop] addTimer:statusTimer forMode:NSRunLoopCommonModes];
        [fileUploadOp start];
    }else{
        [fileUploadOp cancel];
    }
}

- (void)updateStatus:(NSTimer *)time{
    if (_delegate && [_delegate respondsToSelector:@selector(updatingCellData:)]) {
        [self.delegate updatingCellData:_uploadData];
    }
}

- (void)setStatusTimer:(NSTimer *)timer
{
    // We must invalidate the old timer here, not before we've created and scheduled a new timer
    // This is because the timer may be the only thing retaining an asynchronous request
    if (statusTimer && timer != statusTimer) {
        [statusTimer invalidate];
    }
    statusTimer = timer;
}

- (void)updateServer:(UploadData *)pdata withDic:(NSDictionary *)dict{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [formatter dateFromString:pdata.UPLOADtIME];
    [formatter setDateFormat:@"yyyyM"];
    NSString * str = [formatter stringFromDate:date];
    NSString * param = [NSString stringWithFormat:@"params={\"dirId\":\"%@\",\"fileName\":\"%@\",\"oldName\":\"%@\",\"fileSize\":\"%@\",\"timeStr\":\"%@\"}", pdata.parentID, pdata.fileName, [[[[dict objectForKey:@"data"] objectForKey:@"data"] objectForKey:@"attrs"] objectForKey:@"fileName"], [[dict objectForKey:@"files"] objectForKey:@"size"], str];
    NSDictionary * dic = @{@"param":param, @"aslp":CREATE_FILE_DBDATA};
    
    [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
        if (error) {
            NSLog(@"%@", error.description);
        }else{
            //            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%s %@", __func__, dic);
            NSLog(@"%@", [dic objectForKey:@"msg"]);
            if ([[dic objectForKey:@"result"] isEqualToString:@"ok"]) {
                pdata.status = @(2);
                [[SQLCommand shareSQLCommand] updateUploadData:pdata];
            }else{
                pdata.status = @(0);
                [[SQLCommand shareSQLCommand] updateUploadData:pdata];
            }
            
        }
        [uploadNetwork getUploadData];
        [uploadNetwork startUpload];
    }];
}

- (void)cancleUpload{
    [fileUploadOp cancel];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self upload];
    }
}

@end
