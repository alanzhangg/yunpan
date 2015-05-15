//
//  MoveFolderViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/8.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileData.h"

typedef void (^MoveFolderViewControllerBlock) ();
typedef void (^MoveFolderViewControllerShangchuanBlock) (FileData * data);

@interface MoveFolderViewController : UIViewController

@property (nonatomic, copy) MoveFolderViewControllerBlock block;
@property (nonatomic, copy) MoveFolderViewControllerShangchuanBlock uploadBlock;
@property (nonatomic, copy) NSString * folderId;
@property (nonatomic, strong) NSArray * moveFileDataArray;
@property (nonatomic, assign) BOOL shangchuan;
@property (nonatomic, strong) FileData * fileData;
@property (nonatomic, copy) NSString * navTitle;

- (IBAction)createFolder:(UIButton *)sender;

@end
