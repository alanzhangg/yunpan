//
//  Alert.m
//  AWSMobilePortal
//
//  Created by zyc on 14-6-23.
//  Copyright (c) 2014年 zyc. All rights reserved.
//

#import "Alert.h"
#import "AppDelegate.h"

static MBProgressHUD * hud;

@implementation Alert

+(void)showAlertWithTitle:(NSString*)title MSG:(NSString*)msg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

+(void)showHUDWihtTitle:(NSString *)title
{
    
    AppDelegate *dele = [[UIApplication sharedApplication] delegate];
    
    //    static MBProgressHUD * hud = nil;
    //    static dispatch_once_t pre;
    //    dispatch_once(&pre, ^{
    hud = [[MBProgressHUD alloc] initWithView:dele.window];
    [dele.window addSubview:hud];
    UIView *cc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [cc setBackgroundColor:[UIColor clearColor]];
    hud.customView = cc;
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    //	HUD.delegate = self;
    
    //    });
    
    hud.labelText = title;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
    
}

@end
