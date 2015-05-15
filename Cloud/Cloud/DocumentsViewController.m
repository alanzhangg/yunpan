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
    // Do any additional setup after loading the view.
    if (_isDownload) {
        _downloadFunction.hidden = NO;
        _networkFunction.hidden = YES;
    }else{
        _downloadFunction.hidden = YES;
        _networkFunction.hidden = NO;
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
    
}

- (IBAction)delete:(id)sender {

}

- (IBAction)shanChuBendi:(id)sender {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [hud hide:YES];
    [hud removeFromSuperview];
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
