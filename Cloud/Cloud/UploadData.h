//
//  UploadData.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/28.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadData : NSObject

@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * parentID;
@property (nonatomic, strong) NSNumber * fileSize;
@property (nonatomic, copy) NSString * UPLOADtIME;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, copy) NSString * fileID;
@property (nonatomic, copy) NSString * thumbNail;
@property (nonatomic, assign) long long uploadSize;
@property (nonatomic, assign) BOOL isUploading;
@property (nonatomic, assign) long long uploadSpeed;
@property (nonatomic, assign) BOOL isSelected;

@end
