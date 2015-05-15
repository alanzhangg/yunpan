//
//  PhotoData.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/27.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoData : NSObject

@property (nonatomic, copy) NSString * groupName;
@property (nonatomic, assign) NSUInteger numbers;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSMutableArray * groupArray;;

@end
