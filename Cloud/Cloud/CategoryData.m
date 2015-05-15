//
//  CategoryData.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "CategoryData.h"

@implementation CategoryData

+ (CategoryData *)shareCategoryData{
    static CategoryData * data = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        data = [[CategoryData alloc] init];
    });
    return data;
}

@end
