//
//  Alert.h
//  AWSMobilePortal
//
//  Created by zyc on 14-6-23.
//  Copyright (c) 2014年 zyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Alert : NSObject

+(void)showAlertWithTitle:(NSString*)title MSG:(NSString*)msg;

+(void)showHUDWihtTitle:(NSString *)title;

@end
