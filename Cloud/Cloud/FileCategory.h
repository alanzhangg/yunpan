//
//  FileCategory.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/20.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FileCategoryFolder,
    FileCategoryPicture,
    FileCategoryMovie,
    FileCategoryPDF,
    FileCategoryZIP,
    FileCategoryMusic,
    FileCategoryEXCEL,
    FileCategoryPPT,
    FileCategoryTXT,
    FileCategoryWord,
    FileCategoryOther
} FileCategoryMenu;

@interface FileCategory : NSObject

+ (FileCategoryMenu)fileInformation:(NSString *)format;

@end
