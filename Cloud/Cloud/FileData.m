//
//  FileData.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/25.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "FileData.h"

@implementation FileData

- (id)init{
    if (self = [super init]) {
        _fileID = @"";
        _isHasDownload = @(1);
        _hasDownloadSize = @"";
        _downloadFolder = @"0";
        _downloadStatus = @(0);
        _downloadQuantity = @(0);
    }
    return self;
}

- (void)transformDictionary:(NSDictionary *)dic{
    self.fileID = [dic objectForKey:@"fileId"];
    self.filePID = [dic objectForKey:@"filePid"];
    self.fileDeepPath = [dic objectForKey:@"fileDeepPath"];
    self.fileDirLevel = [NSNumber numberWithInt:[[dic objectForKey:@"fileDirLevel"] intValue]];
    self.fileIsdel = [NSNumber numberWithInt:[[dic objectForKey:@"fileIsDel"] intValue]];
    self.fileName = [dic objectForKey:@"fileName"];
    self.fileOldName = [dic objectForKey:@"fileOldName"];
    self.fileOrgid = [dic objectForKey:@"fileOrgId"];
    self.fileFormat = [dic objectForKey:@"fileFormat"];
    self.fileSize = [NSNumber numberWithInt:[[dic objectForKey:@"fileSize"] intValue]];
    self.fileTimeStr = [dic objectForKey:@"fileTimeStr"];
    self.fileType = [dic objectForKey:@"fileType"];
    self.createTime = [dic objectForKey:@"createTime"];
    self.createUser = [dic objectForKey:@"createUser"];
    self.updateTime = [dic objectForKey:@"updateTime"];
    self.updateUser = [dic objectForKey:@"updateUser"];
    self.downloadUrl = [dic objectForKey:@"downloadUrl"];
    self.thumDownloadUrl = [dic objectForKey:@"thumDownloadUrl"];
}

@end
