//
//  FileData.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/25.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileData : NSObject

@property (nonatomic, copy) NSString * fileID;
@property (nonatomic, copy) NSString * filePID;
@property (nonatomic, copy) NSString * fileType;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * fileOldName;
@property (nonatomic, copy) NSString * fileTimeStr;
@property (nonatomic, copy) NSString * fileFormat;
@property (nonatomic, strong) NSNumber * fileSize;
@property (nonatomic, copy) NSString * fileDeepPath;
@property (nonatomic, strong) NSNumber * fileDirLevel;
@property (nonatomic, copy) NSString * fileOrgid;
@property (nonatomic, strong) NSNumber * fileIsdel;
@property (nonatomic, copy) NSString * createTime;
@property (nonatomic, copy) NSString * createUser;
@property (nonatomic, copy) NSString * updateTime;
@property (nonatomic, copy) NSString * updateUser;
@property (nonatomic, copy) NSString * downloadUrl;
@property (nonatomic, copy) NSString * thumDownloadUrl;
@property (nonatomic, assign) BOOL function;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) long long uploadSpeed;
@property (nonatomic, copy) NSString * downloadFolder;
@property (nonatomic, strong) NSNumber * downloadQuantity;

//download

@property (nonatomic, strong) NSString * hasDownloadSize;
@property (nonatomic, strong) NSNumber * isHasDownload;
@property (nonatomic, strong) NSNumber * downloadStatus;

@property(nonatomic)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,retain)NSString *fileReceivedSize;
@property(nonatomic,retain)NSMutableData *fileReceivedData;//接受的数据
@property(nonatomic,retain)NSString *fileURL;
@property(nonatomic,retain)NSString *time;
@property(nonatomic,retain)NSString *targetPath;
@property(nonatomic,retain)NSString *tempPath;
@property(nonatomic)BOOL isDownloading;//是否正在下载
@property(nonatomic)BOOL  willDownloading;
@property(nonatomic)BOOL error;
@property(nonatomic)BOOL isP2P;//是否是p2p下载
@property BOOL post;
@property int PostPointer;
@property(nonatomic,retain)NSString *postUrl;
@property (nonatomic,retain)NSString *fileUploadSize;
@property(nonatomic,retain)NSString *usrname;
@property(nonatomic,retain)NSString *MD5;
@property(nonatomic,retain)UIImage *fileimage;

- (void)transformDictionary:(NSDictionary *)dic;

@end
