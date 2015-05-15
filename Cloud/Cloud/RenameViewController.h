//
//  RenameViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/3.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileData.h"

typedef void (^RenameViewControllerBlock)();

@interface RenameViewController : UIViewController

@property (nonatomic, copy) RenameViewControllerBlock block;
@property (nonatomic, strong) FileData * fileData;
@property (nonatomic, assign) BOOL isXinjian;

@end
