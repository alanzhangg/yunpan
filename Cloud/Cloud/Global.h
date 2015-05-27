//
//  Global.h
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/5.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#ifndef NotePad_Global_h
#define NotePad_Global_h

#define IS_IOS7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define SOURCEAPPID @"com.actionsoft.apps.mydriver"
#define CMD @"API_CALL_ASLP"

//返回网盘分类信息列表
#define QUERY_FILE_CATEGORY @"aslp://com.actionsoft.apps.mydriver/queryFileCategory"
//返回某文件分类下的列表
#define QUERY_FILE_BY_CATEGORY @"aslp://com.actionsoft.apps.mydriver/queryFileByCategory"
//返回搜索列表
#define QUERY_FILE_BY_SEARCH @"aslp://com.actionsoft.apps.mydriver/queryFileBySearch"
//返回所有数据
#define QUERY_ALL_FILE @"aslp://com.actionsoft.apps.mydriver/queryAllFile"
//返回回收站文件列表
#define QUERY_RECYCLE_BINFILE @"aslp://com.actionsoft.apps.mydriver/queryRecycleBinFile"
//从回收站还原文件
#define RESTORE_FILE @"aslp://com.actionsoft.apps.mydriver/restoreFile"
//彻底删除文件信息
#define DELETE_THROUGH_FILE @"aslp://com.actionsoft.apps.mydriver/deleteThroughFile"
//取消文件分享
#define CANCEL_SHARE_FILE @"aslp://com.actionsoft.apps.mydriver/cancelShareFile"
//重命名文件夹
#define RENAME_FILE @"aslp://com.actionsoft.apps.mydriver/renameFile"
//创建文件夹
#define SAVE_FOLDER @"aslp://com.actionsoft.apps.mydriver/saveFolder"
//移动文件
#define MOVE_FOLDER @"aslp://com.actionsoft.apps.mydriver/moveFile"
//将文件删除到回收站
#define DELETE_FILE @"aslp://com.actionsoft.apps.mydriver/deleteFile"
//查询工作网络列表
#define QUERY_NETWORKS @"aslp://com.actionsoft.apps.network/queryNetworks"
//查询某用户在某工作网络下有权限的小组列表
#define QUERY_TEAMS @"aslp://com.actionsoft.apps.network/queryTeams"
//分享到工作网络
#define SHARE_TO_NETWORK @"aslp://com.actionsoft.apps.mydriver/shareToNetwork"
//创建一条网盘文件信息
#define CREATE_FILE_DBDATA @"aslp://com.actionsoft.apps.mydriver/createMyDriverFileDBData"
//获取需下载的文件列表
#define QUERY_DOWNLOAD_FILE @"aslp://com.actionsoft.apps.mydriver/queryDownloadFile"


#endif
