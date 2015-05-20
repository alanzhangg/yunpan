//
//  FileCategory.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/20.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "FileCategory.h"

@implementation FileCategory

+ (FileCategoryMenu)fileInformation:(NSString *)format{
    if ([format isEqualToString:@"txt"]) {
        return FileCategoryTXT;
    }
    if ([format isEqualToString:@"pdf"]) {
        return FileCategoryPDF;
    }
    if ([format isEqualToString:@"f"]) {
        return FileCategoryFolder;
    }
    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
    NSRange range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryPicture;
    }
    typeStr = @"avi,mpg,wmv,3gp,mkv,asf,swf,mov,xv,rmvb,rm,mp4,flv";
    range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryMovie;
    }
    typeStr = @"mp3,ape,wma,wav,mpeg";
    range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryMusic;
    }
    typeStr = @"doc,docx,";
    range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryWord;
    }
    typeStr = @"ppt,pptx";
    range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryPPT;
    }
    typeStr = @"xls,xlsx";
    range = [typeStr rangeOfString:format];
    if (range.location != NSNotFound) {
        return FileCategoryEXCEL;
    }
    
    return FileCategoryOther;
}

@end
