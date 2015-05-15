//
//  CategoryData.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryData : NSObject

@property (nonatomic, strong) NSMutableArray * categoryArray;

+ (CategoryData *)shareCategoryData;

@end
