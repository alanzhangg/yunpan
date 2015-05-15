//
//  PictureBigShowViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/10.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;
@class UploadData;

@interface PictureBigShowViewController : UIViewController

@property (nonatomic, strong) FileData * fileData;
@property (nonatomic, strong) NSMutableArray * pictureArray;

@property (nonatomic, strong) UploadData * uploadData;
@property (nonatomic, strong) NSMutableArray * uploadArray;
@property (nonatomic, assign) BOOL isUpload;

@end
