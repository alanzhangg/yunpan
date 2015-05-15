//
//  ShangchuanViewController.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/27.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ShangchuanViewControllerBlock) (id filedata);

@interface ShangchuanViewController : UINavigationController

@property (nonatomic, assign) id fileData;
@property (nonatomic, copy) ShangchuanViewControllerBlock block;

@end
