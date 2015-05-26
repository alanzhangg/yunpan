//
//  DocumentsViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DocumentsViewController.h"
#import "FileData.h"
#import "CommonHelper.h"
#import "Alert.h"
#import "MBProgressHUD.h"
#import "ALAlertView.h"
#import "NetWorkingRequest.h"
#import "SQLCommand.h"
#import "FilesDownloadManager.h"

@interface DocumentsViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *downloadFunction;
@property (weak, nonatomic) IBOutlet UIView *networkFunction;

@end

@implementation DocumentsViewController{
    MBProgressHUD * hud;
    UIColor * backcolor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    if (_isDownload) {
        _downloadFunction.hidden = YES;
        _networkFunction.hidden = NO;

    }else{
        _downloadFunction.hidden = NO;
        _networkFunction.hidden = YES;
    }
    
    
    _webView.delegate = self;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [hud show:YES];
    
    self.navigationItem.title = _fileData.fileName;
    NSString * path = [self getFilesPath];
    NSLog(@"%@ %d", path, [CommonHelper isExistFile:path]);
    if ([CommonHelper isExistFile:path]) {
        NSFileManager * fileManage = [NSFileManager defaultManager];
        NSString * showPath = [self copyFolderPath];
        showPath = [showPath stringByAppendingPathComponent:_fileData.fileName];
        if (![fileManage fileExistsAtPath:showPath]) {
            NSError * error;
            [fileManage copyItemAtPath:path toPath:showPath error: &error];
            if (error) {
                NSLog(@"%s %@", __func__, error);
                [Alert showHUDWihtTitle:@"加载失败"];
            }
        }
        NSURL * url = [[NSURL alloc] initFileURLWithPath:showPath];
        NSLog(@"url = %@", url);
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }else{
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * lenstr = _fileData.downloadUrl;
        if (lenstr.length > 3) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
            [_webView loadRequest:request];
        }
    }
}

- (NSString *)copyFolderPath{
    NSString * path = [CommonHelper getDocumentPath];
    NSString * str = [NSString stringWithFormat:@"Download/show"];
    path = [path stringByAppendingPathComponent:str];
    return path;
}

- (NSString *)getFilesPath{
    NSString * path = [CommonHelper getDocumentPath];
    NSString * str = [NSString stringWithFormat:@"Download/folder/%@", _fileData.fileName];
    path = [path stringByAppendingPathComponent:str];
    return path;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.tintColor = backcolor;
    
}

- (IBAction)share:(id)sender {
    
}

- (IBAction)download:(id)sender {
    NSLog(@"download");
    FileData * data = _fileData;
    
    if ([[SQLCommand shareSQLCommand] checkIsAddDownloadList:data.fileID]) {
        [Alert showHUDWihtTitle:@"已在下载队列"];
        return;
    }
    data.filePID = @"";
    data.isHasDownload = @(1);
    data.hasDownloadSize = @"0";
    data.downloadStatus = @(0);
    data.downloadFolder = @"0";
    data.downloadQuantity = @(0);
    NSMutableArray * downArray = [NSMutableArray new];
    [downArray addObject:data];
    [[SQLCommand shareSQLCommand] insertDownloadData:downArray];
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        [[FilesDownloadManager sharedFilesDownManage] startRequest:nil];
        [Alert showHUDWihtTitle:@"已加入下载队列"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"网络不通，请检查网路"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles: nil];
        [alertView show];
    }
}

- (IBAction)delete:(id)sender {
    FileData * fileData = _fileData;
    NSMutableArray * delArray = [NSMutableArray new];
    [delArray addObject:fileData];
    [self shanchudata:delArray];
}

- (void)shanchudata:(NSMutableArray *)array{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[SQLCommand shareSQLCommand] deleteDownloadData:array];
        FilesDownloadManager *filedownmanage=[FilesDownloadManager sharedFilesDownManage];
        for (int i = 0; i < array.count; i++) {
            FileData * data = array[i];
            [filedownmanage deleteRequest:data];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSString * path= [CommonHelper getTargetPathWithBasepath:filedownmanage.basePath subpath:filedownmanage.targetSubPath];
            path = [path stringByAppendingPathComponent:data.fileName];
            if ([fileManager fileExistsAtPath:path]) {
                [fileManager removeItemAtPath:path error:nil];
            }
            path = [CommonHelper getTempFolderPathWithBasepath:filedownmanage.basePath];
            path = [path stringByAppendingPathComponent: data.fileName];
            if ([fileManager fileExistsAtPath:path]) {
                [fileManager removeItemAtPath:path error:nil];
            }
        }
        //        [[SQLCommand shareSQLCommand] deleteDownloadData:@[array[0]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    });
    
}

- (IBAction)shanChuBendi:(id)sender {
    NSLog(@"shanchu");
    ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:@"删除后可以在回收站恢复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView.tag = 400;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [hud hide:YES];
    [hud removeFromSuperview];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(ALAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 400 && alertView.cancelButtonIndex != buttonIndex) {
        NSMutableString * idstr = [NSMutableString new];
        [idstr appendFormat:@"%@,", _fileData.fileID];
        [idstr deleteCharactersInRange:NSMakeRange(idstr.length - 1, 1)];
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", idstr];
            NSDictionary * dic = @{@"param":param, @"aslp":DELETE_FILE};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                    [Alert showHUDWihtTitle:error.localizedDescription];
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //                    dic = [dic objectForKey:@"data"];
                    if ([dic[@"result"] isEqualToString:@"ok"]) {
                        
                        [[SQLCommand shareSQLCommand] deleteFileData:@[_fileData]];
                        if (_block) {
                            _block();
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        [Alert showHUDWihtTitle:[dic objectForKey:@"msg"]];
                    }
                }
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
