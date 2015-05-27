//
//  AppDelegate.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/20.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "Alert.h"
#import "JSONKit.h"
#import "SQLCommand.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CommonHelper.h"
#import "Global.h"
#import "PictureDisplayViewController.h"
#import "UploadNetwork.h"
#import "FilesDownloadManager.h"

@interface AppDelegate (){
    Reachability *hostReach;
    UILabel *label;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //     Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //    开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];//可以以多种形式初始化
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 30)];
    [label setText:@"请从移动门户启动"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setCenter:self.window.center];
    [self.window addSubview:label];
    [self.window makeKeyAndVisible];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
//    NSLog(@"%@", NSHomeDirectory());
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud setObject:@"https://192.168.1.183:443/portal/" forKey:@"server"];
//    [ud setObject:@"982dfc02-2c70-436e-aa83-e92dd3a5f2bb" forKey:@"sid"];
//    [ud setObject:@"zhy" forKey:@"uid"];
//    [ud setObject:@"admin" forKey:@"securityKey"];
//    [ud synchronize];
//    [self layoutUploadView];

    
    return YES;
}

//监听到网络状态改变
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    [self updateInterfaceWithReachability: curReach];
    
}
//处理连接改变后的情况
- (void) updateInterfaceWithReachability: (Reachability*) curReach

{
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if(status == ReachableViaWWAN)
    {
        printf("\n3g/2G\n");
        [Alert showHUDWihtTitle:@"已切换到2G/3G网络"];
    }
    else if(status == ReachableViaWiFi)
    {
        printf("\nwifi\n");
    }else if(status == NotReachable)
    {
        printf("\n无网络\n");
        
        [Alert showHUDWihtTitle:@"网络未连接,请检查网络设置"];
    }
    
}

- (void)layoutUploadView{
    
    _uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [self.window addSubview:_uploadView];
    _uploadView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenSelf)];
    [_uploadView addGestureRecognizer:tap];
    
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _uploadView.frame.size.width, _uploadView.frame.size.height)];
    backView.backgroundColor = [UIColor blackColor];
    [_uploadView addSubview:backView];
    backView.alpha = 0.5;
    
    UIView * functionView = [[UIView alloc] initWithFrame:CGRectMake(0, -200, _uploadView.frame.size.width, 200)];
    functionView.backgroundColor = [UIColor whiteColor];
    [_uploadView addSubview:functionView];
    functionView.tag = 100;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, _uploadView.frame.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [functionView addSubview:lineView];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _uploadView.frame.size.width, 40)];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = @"选择上传";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [functionView addSubview:titleLabel];
    
    NSArray * array = @[@"上传图片", @"上传视频"];
    NSArray * picArray = @[@"selectPicture.png", @"selectVideo.png"];
    NSArray * lightArray = @[@"pictureLight.png", @"videoLight.png"];
    for (int i = 0; i < 2; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 5;
        [functionView addSubview:btn];
        btn.frame = CGRectMake((functionView.frame.size.width - 100) / 3 * (i + 1) + 50 * i, 90, 50, 50);
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:picArray[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:lightArray[i]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(uploadFiles:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + 100 * i;
        
        UILabel * btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x - 20, 160, 90, 20)];
        btnLabel.text = array[i];
        btnLabel.backgroundColor = [UIColor clearColor];
        [functionView addSubview:btnLabel];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        btnLabel.font = [UIFont systemFontOfSize:15];
    }
}

- (void)uploadFiles:(UIButton *)sender{
    
    PictureDisplayViewController * pvc = [[PictureDisplayViewController alloc] init];
    if (sender.tag == 100) {
        pvc.isVideo = NO;
    }else{
        pvc.isVideo = YES;
    }
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pvc];
    UIViewController * root = self.window.rootViewController;
    [root presentViewController:nav animated:YES completion:^{
        
    }];
    [self hiddenSelf];
}

- (void)hiddenSelf{
    UIViewController * con = self.window.rootViewController;
    UIView * view = [_uploadView viewWithTag:100];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = view.frame;
        rect.origin.y = -200;
        view.frame = rect;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, 1.0);
        con.view.transform = scaleTransform;
    } completion:^(BOOL finished) {
        _uploadView.hidden = YES;
        [_window sendSubviewToBack:_uploadView];
    }];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    //    com.actionsoft.apps.entaddress.ios://https://192.168.1.183:443/portal&c7f6e134-a5b5-4c20-9d34-3346324ef7a0&admin
    NSString *params = [url absoluteString];
    //    NSString *params = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"params from portal is:%@", params);
    [label removeFromSuperview];
    [self layoutUploadView];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [self paramsHandle:params];
    
    return YES;
}

-(void)paramsHandle:(NSString*)url
{
    
    NSLog(@"%@    %@    %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), url);
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSRange range = [url rangeOfString:@"://param="];
    if (range.location == NSNotFound) {
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyBoard instantiateInitialViewController];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        return;
    }
    
    NSArray *arr = [url componentsSeparatedByString:@"://param="];
    
    NSString *ip = nil;
    NSString *sid = nil;
    NSString *uid = nil;
    NSString *secretkey = nil;
    NSString * userid = @"";
    
    if ([[arr lastObject] hasPrefix:@"{"]) {
        
        //此处用了jsonkit的方法objectFromJSONString
        NSDictionary *paraDic = [[arr lastObject] objectFromJSONString];
        ip = [paraDic objectForKey:@"ip"];
        sid = [paraDic objectForKey:@"sid"];
        uid = [paraDic objectForKey:@"uid"];
        secretkey = [paraDic objectForKey:@"key"];
        userid = [paraDic objectForKey:@"appid"];
        
    }else
    {
        NSArray *paArr = [[arr lastObject] componentsSeparatedByString:@"&"];
        
        ip = [paArr firstObject];
        sid = [paArr objectAtIndex:1];
        uid = [paArr objectAtIndex:2];
        if ([paArr count]>3) {
            secretkey = [paArr objectAtIndex:3];
        }
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:secretkey forKey:@"securityKey"];
    [ud setObject:ip forKey:@"server"];
    [ud setObject:sid forKey:@"sid"];
    [ud setObject:uid forKey:@"uid"];
    [ud setObject:userid forKey:@"appid"];
    NSString * uidStr = [ud objectForKey:@"cacheUid"];
    if (![uidStr isEqualToString:uid]) {
        [ud setObject:uid forKey:@"cacheUid"];
        NSArray * array = [ud objectForKey:@"cacheNetworkId"];
        for (NSString * str in array) {
            [ud setObject:nil forKey:str];
        }
    }
    [ud synchronize];
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
    self.window.backgroundColor = [UIColor blackColor];
    CGRect rect = self.window.frame;
    UITabBarController * tabCon = (UITabBarController *)self.window.rootViewController;
    UITabBar * tabbar = tabCon.tabBar;
    UIButton * plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(rect.size.width / 2 - 20, 5, 40, 40);
    [tabbar addSubview:plusButton];
    [plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [plusButton setImage:[UIImage imageNamed:@"plushight.png"] forState:UIControlStateNormal];
    [self.window makeKeyAndVisible];
    [plusButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)upload:(UIButton *)sender{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    UIWindow * window = delegate.window;
    UIViewController * con = window.rootViewController;
    [window bringSubviewToFront:delegate.uploadView];
    delegate.uploadView.hidden = NO;
    UIView * view = [delegate.uploadView viewWithTag:100];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = view.frame;
        rect.origin.y = 0;
        view.frame = rect;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.9, 0.9);
        con.view.transform = scaleTransform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[SQLCommand shareSQLCommand] closeDB];
    [CommonHelper removeShowFolder];
//    exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[SQLCommand shareSQLCommand] openDB];
    [CommonHelper createShowFolder];
//    [CommonHelper createShowFolder];
//    [UploadNetwork shareUploadNetwork];
//    [[UploadNetwork shareUploadNetwork] startUpload];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[SQLCommand shareSQLCommand] openDB];
    [CommonHelper createShowFolder];
//    [[FilesDownloadManager sharedFilesDownManage] getSqlData];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SQLCommand shareSQLCommand] closeDB];
    [CommonHelper removeShowFolder];
}

@end
