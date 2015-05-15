//
//  FolderViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/7.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;

@interface FolderViewController : UIViewController

@property (nonatomic, copy) NSString * categoryName;
@property (nonatomic, strong) FileData * fileDta;
@property (nonatomic, copy) NSString * searchName;
@property (nonatomic, copy) NSString * titleName;

@end
