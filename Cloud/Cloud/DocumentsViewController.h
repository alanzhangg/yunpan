//
//  DocumentsViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;

@interface DocumentsViewController : UIViewController

@property (nonatomic, strong) FileData * fileData;
@property (nonatomic, assign) BOOL isDownload;

@end
