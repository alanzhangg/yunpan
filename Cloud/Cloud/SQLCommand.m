//
//  SQLCommand.m
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/5.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "SQLCommand.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FileData.h"
#import "UploadData.h"

@implementation SQLCommand{
    NSString * path;
    FMDatabase * db;
    FMDatabaseQueue * dbQueue;
    NSString * securityKey;
}

+ (id)shareSQLCommand{
    static SQLCommand * sqlCommand = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sqlCommand = [[SQLCommand alloc] init];
    });
    return sqlCommand;
}

+ (void)updatedata:(NSArray *)array withlistArray:(NSArray *)listArray{
    
    NSMutableArray * dataArray = [NSMutableArray new];
    for (NSDictionary * dict in array) {
        FileData * data = [[FileData alloc] init];
        [data transformDictionary:dict];
        [dataArray addObject:data];
    }
    NSMutableArray * updateArray = [NSMutableArray new];
    NSMutableArray * insertArray = [NSMutableArray new];
    NSMutableArray * deleteArray = [NSMutableArray new];
    int j = -1;
    for (int i = 0 ; i < dataArray.count; i++) {
        FileData * data = dataArray[i];
        NSArray * array = [[SQLCommand shareSQLCommand] getIdFolderData:data.fileID];
        if (array.count == 0) {
            [insertArray addObject:data];
        }else
            [updateArray addObject:data];
    }
    j = -1;
    for (int i = 0; i < listArray.count; i++) {
        FileData * data = listArray[i];
        for (j = 0; j < dataArray.count; j++) {
            FileData * fileData = dataArray[j];
            if ([data.fileID isEqualToString:fileData.fileID]) {
                break;
            }
        }
        if (j == dataArray.count) {
            [deleteArray addObject:data];
        }
    }
//    [[SQLCommand shareSQLCommand] updateFileData:updateArray];
    [[SQLCommand shareSQLCommand] insertData:insertArray];
    [[SQLCommand shareSQLCommand] deleteFileData:deleteArray];
    
}

- (BOOL)createDB{
    securityKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"securityKey"];
    path = NSHomeDirectory();
    NSLog(@"%@", path);
    path = [path stringByAppendingPathComponent:@"Documents/notepad.db"];
    dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    db = [FMDatabase databaseWithPath:path];
    BOOL res = [db open];
    if (res) {
        NSLog(@"%@  %@  打开成功", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }else{
        NSLog(@"%@  %@  打开失败", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    
    [self createTable];
    
    return res;
}

- (void)createTable{
    db = [FMDatabase databaseWithPath:path];
    BOOL res = [db open];
    if (!res) {
        NSLog(@"%@  %@  open error", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UPDATETIME (updatetime DATETIME)"];
    if (!res) {
        NSLog(@"%@  %@ UPDATETIME create error", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS CLOUD (ID CHAR(36) PRIMARY KEY, PID CHAR(36), FILETYPE CHAR(1), FILENAME VARCHAR(126), FILEOLDNAME VARCHAR(126), TIMESTR VARCHAR(20), FILEFORMAT VARCHAR(20), FILESIZE INT(16), DEEPPATH VARCHAR(1000), DIRLEVEL INT(5), ORGID CHAR(36), ISDEL INT(1), CREATETIME DATETIME, CREATEUSER VARCHAR(36), UPDATETIME DATETIME, UPDATEUSER VARCHAR(36), DOWNLOADURL VARCHAR(1000), THUMDOWNLOADURL VARCHAR(1000))"];
    if (!res) {
        NSLog(@"%@  %@ CLOUD create error", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS DOWNLOADLIST (ID CHAR(36) PRIMARY KEY, PID CHAR(36), FILETYPE CHAR(1), FILENAME VARCHAR(126), FILEOLDNAME VARCHAR(126), TIMESTR VARCHAR(20), FILEFORMAT VARCHAR(20), FILESIZE INT(16), DEEPPATH VARCHAR(1000), DIRLEVEL INT(5), ORGID CHAR(36), ISDEL INT(1), CREATETIME DATETIME, CREATEUSER VARCHAR(36), UPDATETIME DATETIME, UPDATEUSER VARCHAR(36), DOWNLOADURL VARCHAR(1000), THUMDOWNLOADURL VARCHAR(1000), HASDOWNSIZE INT(16), ISHAVEDONE INT(1), DOWNLOADSTATUS INT(1), DOWNLOADFOLDER CHAR(1), DOWNLOADQUANTITY INT(16))"];
    if (!res) {
        NSLog(@"%@  %@ DOWNLOADLIST create error", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UPLOAD (ID CHAR(36) PRIMARY KEY, FILENAME VARCHAR(126), STATUS INT(1), FILESIZE INT(16), UPLOADTIME DATETIME, THUMBNAIL VARCHAR(1000), PARENTID CHAR(36))"];
    [db close];
}

- (void)insertUploadData:(NSArray *)array{
    
    for (UploadData * data in array) {
        @autoreleasepool {
            [db executeUpdate:@"INSERT INTO UPLOAD VALUES(?,?,?,?,?,?,?)", data.fileID, data.fileName, data.status, data.fileSize, data.UPLOADtIME, data.thumbNail, data.parentID];
        }
    }
    
}

- (void)updateUploadData:(UploadData *)data{
    
    [db executeUpdate:@"UPDATE UPLOAD SET STATUS = ?, UPLOADTIME = ? WHERE ID = ?", data.status, data.UPLOADtIME, data.fileID];
}

- (void)deleteUploadData:(NSArray *)array{
    for (FileData * data in array) {
        @autoreleasepool {
            NSLog(@"%d", [db executeUpdate:@"DELETE FROM UPLOAD WHERE ID = ?", data.fileID]);
        }
    }
}

- (BOOL)checkFileOnly:(UploadData *)data{
    
//    [dbQueue inDatabase:^(FMDatabase *dbs) {
//        [dbs open];
//        
//        [dbs open];
//    }];
    
    FMResultSet * set = [db executeQuery:@"SELECT * FROM UPLOAD WHERE FILENAME = ?", data.fileName];
    NSMutableArray * array = [NSMutableArray new];
    while ([set next]) {
        [array addObject:@"1"];
    }
    return array.count ? NO : YES;
}

- (NSMutableArray *)selectUploadData{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM UPLOAD"];
    NSMutableArray * array = [NSMutableArray new];
    NSMutableArray * errArray = [NSMutableArray new];
    NSMutableArray * doingArray = [NSMutableArray new];
    NSMutableArray * doneArray = [NSMutableArray new];
    while ([set next]) {
        UploadData * data = [[UploadData alloc] init];
        data.fileID = [set objectForColumnName:@"ID"];
        data.fileName = [set objectForColumnName:@"FILENAME"];
        data.fileSize = [set objectForColumnName:@"FILESIZE"];
        data.status = [set objectForColumnName:@"STATUS"];
        data.UPLOADtIME = [set objectForColumnName:@"UPLOADTIME"];
        data.thumbNail = [set objectForColumnName:@"THUMBNAIL"];
        data.parentID = [set objectForColumnName:@"PARENTID"];
        if ([data.status intValue] == 0) {
            [errArray addObject:data];
        }else if ([data.status intValue] == 1){
            [doingArray addObject:data];
        }else{
            [doneArray addObject:data];
        }
    }
    [array addObject:errArray];
    [array addObject:doingArray];
    [array addObject:doneArray];
    return array;
}

- (void)insertData:(NSArray *)array{
    
    for (FileData * data in array) {
        @autoreleasepool {
            [db executeUpdate:@"INSERT INTO CLOUD VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", data.fileID, data.filePID, data.fileType, data.fileName, data.fileOldName, data.fileTimeStr, data.fileFormat, data.fileSize, data.fileDeepPath, data.fileDirLevel, data.fileOrgid, data.fileIsdel, data.createTime, data.createUser, data.updateTime, data.updateUser, data.downloadUrl, data.thumDownloadUrl];
            
        }
    }
}

- (void)updateFileName:(FileData *)fileData{
    [db executeUpdate:@"UPDATE CLOUD SET FILENAME = ? WHERE ID = ?", fileData.fileName, fileData.fileID];
}

- (void)updateFileData:(NSArray *)array{
    
    for (FileData * data in array) {
        @autoreleasepool {
            [db executeUpdate:@"UPDATE CLOUD SET ID = ?, PID = ?, FILETYPE = ?, FILENAME = ?, FILEOLDNAME = ?, TIMESTR = ?, FILEFORMAT = ?, FILESIZE = ?, DEEPPATH = ?, DIRLEVEL = ?, ORGID = ?, ISDEL = ?, CREATETIME = ?, CREATEUSER = ?, UPDATETIME = ?, UPDATEUSER = ?, DOWNLOADURL = ?, THUMDOWNLOADURL = ? WHERE ID = ?", data.fileID, data.filePID, data.fileType, data.fileName, data.fileOldName, data.fileTimeStr, data.fileFormat, data.fileSize, data.fileDeepPath, data.fileDirLevel, data.fileOrgid, data.fileIsdel, data.createTime, data.createUser, data.updateTime, data.updateUser, data.downloadUrl, data.thumDownloadUrl, data.fileID];
        }
    }
    
}

- (void)deleteFileData:(NSArray *)array{
    
    for (FileData * data in array) {
        if ([data.fileFormat isEqualToString:@"f"]) {
            NSArray * array = [self getFolderData:data.fileID];
            [self deleteFileData:array];
        }
    }
    for (FileData * data in array) {
        @autoreleasepool {
            NSLog(@"%d", [db executeUpdate:@"DELETE FROM CLOUD WHERE ID = ?", data.fileID]);
        }
    }
}

- (NSArray *)getIdFolderData:(NSString *)fileId{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM CLOUD WHERE ID = ?", fileId];
    return [self getFileData:set];
}

- (NSArray *)getHomepageData{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM CLOUD WHERE PID = '' ORDER BY FILETYPE DESC, UPDATETIME DESC"];
    
    return  [self getFileData:set];
}

- (NSArray *)getFolder:(NSString *)PID withMoveData:(NSArray *)array{
    NSMutableString * str = [[NSMutableString alloc] init];
    for (FileData * data in array) {
        [str appendFormat:@" ID != '%@' AND ", data.fileID];
    }
//    if (PID.length == 0) {
//        PID = @"null";
//    }
    NSString * sqlStr = [NSString stringWithFormat:@"SELECT * FROM CLOUD WHERE PID = '%@' AND %@  FILEFORMAT = 'f'", PID, str];
    FMResultSet * set = [db executeQuery:sqlStr];
    return [self getFileData:set];
}

- (NSArray *)getFolderData:(NSString *)dirID{
    NSLog(@"%@", dirID);
    FMResultSet * set = [db executeQuery:@"SELECT * FROM CLOUD WHERE PID = ? ORDER BY FILETYPE DESC, UPDATETIME DESC", dirID];
    return [self getFileData:set];
}

- (NSArray *)getCategoryData:(NSArray *)array{
    NSMutableString * sqlstr = [NSMutableString new];
    for (NSString * str in array) {
        [sqlstr appendFormat:@"FILEFORMAT='%@' OR ", str];
    }
    if (sqlstr.length > 4) {
        [sqlstr deleteCharactersInRange:NSMakeRange(sqlstr.length - 4, 4)];
    }
    
    sqlstr = (NSMutableString *)[NSString stringWithFormat:@"SELECT * FROM CLOUD WHERE %@", sqlstr];
    NSLog(@"%@", sqlstr);
//    NSString * str = @"FILEFORMAT='doc'";
    FMResultSet * set = [db executeQuery:sqlstr];
    return [self getFileData:set];
}

- (NSArray *)getOtherFolderData:(NSArray *)array{
    NSMutableString * sqlstr = [NSMutableString new];
    for (NSString * str in array) {
        [sqlstr appendFormat:@"FILEFORMAT!='%@' AND ", str];
    }
    if (sqlstr.length > 4) {
        [sqlstr deleteCharactersInRange:NSMakeRange(sqlstr.length - 5, 5)];
    }
    sqlstr = (NSMutableString *)[NSString stringWithFormat:@"SELECT * FROM CLOUD WHERE %@", sqlstr];
    NSLog(@"%@", sqlstr);
    //    NSString * str = @"FILEFORMAT='doc'";
    FMResultSet * set = [db executeQuery:sqlstr];
    return [self getFileData:set];
}

- (void)moveFile:(NSArray *)array toTargetFolder:(NSString *)dataid{
    for (FileData * data in array) {
        [db executeUpdate:@"UPDATE CLOUD SET PID = ? WHERE ID = ?", dataid, data.fileID];
    }
}

- (NSMutableArray *)getFileData:(FMResultSet *)set{
    NSMutableArray * array = [NSMutableArray new];
    while ([set next]) {
        FileData * data = [[FileData alloc] init];
        data.fileID = [set objectForColumnName:@"ID"];
        data.filePID = [set objectForColumnName:@"PID"];
        data.fileType = [set objectForColumnName:@"FILETYPE"];
        data.fileName = [set objectForColumnName:@"FILENAME"];
        data.fileOldName = [set objectForColumnName:@"FILEOLDNAME"];
        data.fileTimeStr = [set objectForColumnName:@"TIMESTR"];
        data.fileFormat = [set objectForColumnName:@"FILEFORMAT"];
        data.fileSize = [set objectForColumnName:@"FILESIZE"];
        data.fileDeepPath = [set objectForColumnName:@"DEEPPATH"];
        data.fileDirLevel = [set objectForColumnName:@"DIRLEVEL"];
        data.fileOrgid = [set objectForColumnName:@"ORGID"];
        data.fileIsdel = [set objectForColumnName:@"ISDEL"];
        data.createTime = [set objectForColumnName:@"CREATETIME"];
        data.createUser = [set objectForColumnName:@"CREATEUSER"];
        data.updateTime = [set objectForColumnName:@"UPDATETIME"];
        data.updateUser = [set objectForColumnName:@"UPDATEUSER"];
        data.downloadUrl = [self exchangeDownloadListSid:[set objectForColumnName:@"DOWNLOADURL"]];
        data.thumDownloadUrl = [self exchangeDownloadListSid:[set objectForColumnName:@"THUMDOWNLOADURL"]];
        if (![set columnIsNull:@"HASDOWNSIZE"]) {
            data.hasDownloadSize = [set objectForColumnName:@"HASDOWNSIZE"];
        }
        if (![set columnIsNull:@"ISHAVEDONE"]) {
            data.isHasDownload = [set objectForColumnName:@"ISHAVEDONE"];
        }
        if (![set columnIsNull:@"DOWNLOADSTATUS"]) {
            data.downloadStatus = [set objectForColumnName:@"DOWNLOADSTATUS"];
        }
        if (![set columnIsNull:@"DOWNLOADFOLDER"]) {
            data.downloadFolder = [set objectForColumnName:@"DOWNLOADFOLDER"];
        }
        if (![set columnIsNull:@"DOWNLOADQUANTITY"]) {
            data.downloadQuantity = [set objectForColumnName:@"DOWNLOADQUANTITY"];
        }
        [array addObject:data];
    }
    return array;
}

#pragma mark - download

- (void)insertDownloadData:(NSArray *)array{
    for (FileData * data in array) {
        @autoreleasepool {
            [db executeUpdate:@"INSERT INTO DOWNLOADLIST VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", data.fileID, data.filePID, data.fileType, data.fileName, data.fileOldName, data.fileTimeStr, data.fileFormat, data.fileSize, data.fileDeepPath, data.fileDirLevel, data.fileOrgid, data.fileIsdel, data.createTime, data.createUser, data.updateTime, data.updateUser, data.downloadUrl, data.thumDownloadUrl, data.hasDownloadSize, data.isHasDownload, data.downloadStatus, data.downloadFolder, data.downloadQuantity];
        }
    }
}

- (void)updateDownloadDataStatus:(NSArray *)array{
    for (FileData * data in array) {
        [db executeUpdate:@"UPDATE DOWNLOADLIST SET DOWNLOADSTATUS = ?, HASDOWNSIZE = ? WHERE ID = ?", data.downloadStatus, data.hasDownloadSize, data.fileID];
    }
}

- (void)updateDownloadDataHaveDown:(NSArray *)array{
    for (FileData * data in array) {
        [db executeUpdate:@"UPDATE DOWNLOADLIST SET ISHAVEDONE = ?, HASDOWNSIZE = ? WHERE ID = ?", data.isHasDownload, data.hasDownloadSize, data.fileID];
    }
}

- (void)updateDownloadData:(NSArray *)array{
    for (FileData * data in array) {
        [db executeUpdate:@"UPDATE DOWNLOADLIST SET HASDOWNSIZE = ?, ISHAVEDONE = ?, HASDOWNSIZE = ?,DOWNLOADSTATUS = ?, DOWNLOADFOLDER = ?, DOWNLOADQUANTITY = ? WHERE ID = ?", data.hasDownloadSize, data.isHasDownload, data.hasDownloadSize, data.downloadStatus, data.downloadFolder, data.downloadQuantity, data.fileID];
    }
}

- (void)updateDownloadFolderQuantity:(FileData *)data{
    
    if (![data.filePID isEqualToString:@""]) {
        FileData *filedata = [self getDownloadUpData:data];
        if (filedata) {
            [self updateDownloadFolderQuantity:filedata];
        }
    }else{
        int quantity = [data.downloadQuantity intValue];
        quantity--;
        if (quantity <= 0) {
            data.isHasDownload = @(2);
        }
        data.downloadQuantity = @(quantity);
        data.downloadFolder = @"1";
        [self updateDownloadData:@[data]];
    }
}

- (FileData *)getDownloadUpData:(FileData *)data{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE ID = ?", data.filePID];
    NSArray * array = [self getFileData:set];
    if (array.count>0) {
        return array[0];
    }
    return nil;
}

- (FileData *)getShangchengFolder:(FileData *)fileData{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE ID = ?", fileData.filePID];
    NSArray * array = [self getFileData:set];
    if (array.count > 0) {
        FileData * data = array[0];
        if (data.filePID.length > 0) {
            fileData = [self getShangchengFolder:data];
        }else{
            fileData = data;
        }
    }
    return fileData;
}

- (NSMutableArray *)getDownloadListData{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST ORDER BY ISHAVEDONE DESC"];
    NSArray * array = [self getFileData:set];
    NSMutableArray * errorArray = [NSMutableArray new];
    NSMutableArray * downloadingArray = [NSMutableArray new];
    NSMutableArray * downloadedArray = [NSMutableArray new];
    for (FileData * data in array) {
        if ([data.isHasDownload intValue] == 0) {
            [errorArray addObject:data];
        }if ([data.isHasDownload intValue] == 1 && [data.downloadQuantity intValue] >= 0){
            [downloadingArray addObject:data];
        }if ([data.isHasDownload intValue] == 2 || [data.downloadFolder intValue] == 1){
            [downloadedArray addObject:data];
        }
//         NSLog(@"%@, %@", data.fileName, data.downloadFolder);
    }
    NSMutableArray * listArray = [NSMutableArray new];
    [listArray addObject:errorArray];
    [listArray addObject:downloadingArray];
    [listArray addObject:downloadedArray];
    return listArray;
}

- (void)deleteDownloadData:(NSArray *)array{
    
    for (FileData * data in array) {
        @autoreleasepool {
            NSLog(@"%d", [db executeUpdate:@"DELETE FROM DOWNLOADLIST WHERE ID = ?", data.fileID]);
        }
    }
}

- (NSArray *)getDeleteDownloadData:(NSString *)fileID{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE PID = ?", fileID];
    NSArray * array = [self getFileData:set];
    NSMutableArray * listArray = [NSMutableArray arrayWithArray:array];
    for (FileData * data in array) {
        if ([data.fileFormat isEqualToString:@"f"]) {
            [listArray addObjectsFromArray:[self getCloudTableFolderData:data.fileID]];
        }
    }
    return listArray;
}

//

- (NSArray *)getCloudTableFolderData:(NSString *)fileId{
    
    FMResultSet * set = [db executeQuery:@"SELECT * FROM CLOUD WHERE PID = ?", fileId];
    NSArray * array = [self getFileData:set];
    NSMutableArray * listArray = [NSMutableArray arrayWithArray:array];
    for (FileData * data in array) {
        if ([data.fileFormat isEqualToString:@"f"]) {
            [listArray addObjectsFromArray:[self getCloudTableFolderData:data.fileID]];
        }
    }
    return listArray;
}

- (NSArray *)getSubfolders:(NSString *)fileId{
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE PID = ? AND ISHAVEDONE = 2 ORDER BY FILETYPE DESC, UPDATETIME DESC", fileId];
    return [self getFileData:set];
}

- (NSMutableArray *)getSubFilesUndownload:(FileData *)fileData{
    NSMutableArray * array = [NSMutableArray new];
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE PID = ? ORDER BY FILETYPE DESC, UPDATETIME DESC", fileData.fileID];
    [array addObjectsFromArray:[self getFileData:set]];
    for (int i = 0; i < array.count; i++) {
        FileData * data = array[i];
        if ([data.fileFormat isEqualToString:@"f"]) {
            [array addObjectsFromArray:[self getSubFilesUndownload:data]];
        }
    }
    return array;
}

- (BOOL)checkIsAddDownloadList:(NSString *)fileId{
    
    FMResultSet * set = [db executeQuery:@"SELECT * FROM DOWNLOADLIST WHERE ID = ?", fileId];
    return [set next];
}

- (BOOL)openDB{
    db = [FMDatabase databaseWithPath:path];
    BOOL res = [db open];
    if (!res) {
        NSLog(@"%@  %@  open error", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    return res;
}

- (void)closeDB{
    [db close];
    
}

- (NSString *)exchangeDownloadListSid:(NSString *)str{
    if (str) {
//        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
//        NSString * sidstr = [ud objectForKey:@"sid"];
//        NSString * theStr = [NSString stringWithFormat:@"sid=%@&", sidstr];
//        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"sid=[\\S\\s]{1,}&" options:0 error:nil];
//        str = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:theStr];
    }
    return str;
}

@end
