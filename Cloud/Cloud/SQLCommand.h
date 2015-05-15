//
//  SQLCommand.h
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/5.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileData;
@class UploadData;

@interface SQLCommand : NSObject

+ (id)shareSQLCommand;

+ (void)updatedata:(NSArray *)array withlistArray:(NSArray *)listArray;

- (void)insertData:(NSArray *)array;

- (NSArray *)getHomepageData;
- (NSArray *)getCategoryData:(NSArray *)array;
- (NSArray *)getFolderData:(NSString *)dirID;
- (NSArray *)getFolder:(NSString *)PID withMoveData:(NSArray *)array;
- (NSArray *)getIdFolderData:(NSString *)fileId;
- (NSArray *)getOtherFolderData:(NSArray *)array;

- (void)updateFileName:(FileData *)fileData;
- (void)updateFileData:(NSArray *)array;

- (void)deleteFileData:(NSArray *)array;

- (void)moveFile:(NSArray *)array toTargetFolder:(NSString *)dataid;

//download

- (void)insertDownloadData:(NSArray *)array;
- (void)updateDownloadDataStatus:(NSArray *)array;
- (void)updateDownloadDataHaveDown:(NSArray *)array;
- (void)updateDownloadData:(NSArray *)array;
- (void)updateDownloadFolderQuantity:(FileData *)data;
- (NSMutableArray *)getDownloadListData;
- (void)deleteDownloadData:(NSArray *)array;
- (BOOL)checkIsAddDownloadList:(NSString *)fileId;
- (NSArray *)getDeleteDownloadData:(NSString *)fileID;
- (NSArray *)getCloudTableFolderData:(NSString *)fileId;
- (NSArray *)getSubfolders:(NSString *)fileId;
- (NSMutableArray *)getSubFilesUndownload:(NSString *)fileId;

- (NSString *)exchangeDownloadListSid:(NSString *)str;

//upload
- (void)insertUploadData:(NSArray *)array;
- (void)updateUploadData:(UploadData *)data;
- (void)deleteUploadData:(NSArray *)array;
- (BOOL)checkFileOnly:(UploadData *)data;
- (NSMutableArray *)selectUploadData;

- (BOOL)createDB;
- (BOOL)openDB;
- (void)closeDB;

@end
