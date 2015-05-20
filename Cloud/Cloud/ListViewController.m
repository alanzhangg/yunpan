//
//  ListViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ListViewController.h"
#import "Global.h"
#import "SQLCommand.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "FileData.h"
#import "BackButton.h"
#import "ListHiddenTableView.h"
#import "AllFileView.h"
#import "DocumentsView.h"
#import "CategoryData.h"
#import "FolderViewController.h"
#import "AppDelegate.h"
#import "FilesDownloadManager.h"
#import "CommonHelper.h"
#import "UploadNetwork.h"

@interface ListViewController ()<AllFileViewDelegate>

@end

@implementation ListViewController{
    NSMutableArray * listArray;
    NSInteger cellSelected;
    SQLCommand * command;
    NSMutableArray * categoryArray;
    ListHiddenTableView * listType;
    AllFileView * allFileView;
    DocumentsView * documentsView;
    UIView * tabView;
    UIButton * rightBtn;
    int currentPage;
    NSString * titleString;
    BOOL isDownloadAllData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 1;
    command = [SQLCommand shareSQLCommand];
    [command createDB];
    [command openDB];
    
//    [FIleDownLoadManager sharedFilesDownManageWithBasepath:@"Download" TargetPathArr:[NSArray arrayWithObject:@"Download/Folder"]];
    
    categoryArray = [[NSMutableArray alloc] init];
    cellSelected = -1;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"网盘";
    listArray = [NSMutableArray new];
    [listArray addObjectsFromArray:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
    if (IS_IOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self initSubViews];
    [self addCategory];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [allFileView reloadDatas];
    [documentsView reloadDatas];
    
}

- (void)addCategory{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    
    if (status == 1 || status == 2) {
        [self downloadAllData];
        NSString * param = [NSString stringWithFormat:@"params={}"];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_CATEGORY};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
            }else{
                //            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", dic);
//                NSLog(@"%@", [dic objectForKey:@"msg"]);
                dic = [dic objectForKey:@"data"];
                NSArray * array = [dic objectForKey:@"categoryList"];
                [categoryArray addObject:@{@"categoryName":@"全部"}];
                [categoryArray addObjectsFromArray:array];
                [categoryArray addObject:@{@"categoryName":@"其他"}];
                [CategoryData shareCategoryData].categoryArray = categoryArray;
                [self addTitleViews];
            }
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

- (void)addTitleViews{
    CGRect viewRect = self.view.frame;
    float statusBarHeight = IS_IOS7 ? 64 : 0;
    
    listType = [[ListHiddenTableView alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 64 : 0, viewRect.size.width, viewRect.size.height - statusBarHeight)];
    __weak ListViewController * weakSelf = self;
    listType.buttonArray = categoryArray;
    listType.block = ^(NSInteger index){
        __strong ListViewController * strongSelf = weakSelf;
        [strongSelf changeType:index];
    };
    [self.view addSubview:listType];
    listType.hidden = YES;
    [listType reloadData];
    titleString = @"个人网盘";
    self.navigationItem.titleView = [self createTitleBtn:titleString];
}

- (void)changeType:(NSInteger)index{
    
    if (index >= 0) {
        titleString = [categoryArray[index] objectForKey:@"categoryName"];
        if ([titleString isEqualToString:@"全部"]) {
            titleString = @"个人网盘";
            [self.view bringSubviewToFront:allFileView];
            currentPage = 1;
        }else if ([titleString isEqualToString:@"文档"] || [titleString isEqualToString:@"视频"] || [titleString isEqualToString:@"音频"] || [titleString isEqualToString:@"其他"] || [titleString isEqualToString:@"图片"]){
            [self addDocumentsView:titleString];
            currentPage = 2;
        }
        [self quxiaoDuoXuan:rightBtn];
        self.navigationItem.titleView = [self createTitleBtn:titleString];
    }else{
        UIView * view = self.navigationItem.titleView;
        view = [view viewWithTag:1111];
        view.transform =  CGAffineTransformMakeRotation(0);
    }
    [self addBackButton];
    
}

- (UIView *)createTitleBtn:(NSString *)str{
    NSString * lenStr = str;
    CGSize size = [lenStr sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(1000, 40)];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width + 30, 40)];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 40)];
    titleLabel.text = str;
    titleLabel.tag = 3333;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = RGB(0, 0, 0);
    [view addSubview:titleLabel];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width, 5, 30, 30)];
    imageView.tag = 1111;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed:@"arrow-down.png"];
    [view addSubview:imageView];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [btn addTarget:self action:@selector(showWOrkNetList:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    return view;
}

- (void)showWOrkNetList:(UIButton *)sender{
    UIView * view = self.navigationItem.titleView;
    view = [view viewWithTag:1111];
    if (listType.hidden) {
        view.transform =  CGAffineTransformMakeRotation(M_PI);
    }else{
        view.transform =  CGAffineTransformMakeRotation(0);
    }
    
    [self.view bringSubviewToFront:listType];
    [listType showOperationView];
}

- (void)downloadAllData{
    
    int status = [AFHTTPAPIClient checkNetworkStatus];
    
    if (status == 1 || status == 2) {
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        BOOL appFirst = [ud boolForKey:@"appfirst"];
        if (!appFirst) {
            isDownloadAllData = YES;
            NSString * param = [NSString stringWithFormat:@"params={}"];
            NSDictionary * dic = @{@"param":param, @"aslp":QUERY_ALL_FILE};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                }else{
                    //            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    dic = [dic objectForKey:@"data"];
                    NSArray * array = [dic objectForKey:@"fileList"];
                    if (array) {
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSMutableArray * dataArray = [NSMutableArray new];
                            for (NSDictionary * dict in array) {
                                FileData * data = [[FileData alloc] init];
                                [data transformDictionary:dict];
                                [dataArray addObject:data];
                            }
                            [command insertData:dataArray];
                            [ud setBool:YES forKey:@"appfirst"];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [allFileView reloadDatas];
                            });
                        });
                    }
                }
            }];
        }
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

- (void)addBackButton{
    BackButton * backBtn = [BackButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"arrowww.png"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, 0, 40, 40);
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    [backBtn addTarget:self action:@selector(backToPortal) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initSubViews{
    
    [self addBackButton];
    
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 64 : 0;
    if (!IS_IOS7) {
        rect.size.height -= 44;
    }
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
//    rightBtn.backgroundColor = [UIColor redColor];
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(duoxuan:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadBtn.frame = CGRectMake(10, 0, 44, 44);
//    uploadBtn.backgroundColor = [UIColor blueColor];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [uploadBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(shangchuan:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem * uploadItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    self.navigationItem.rightBarButtonItems = @[rightItem, uploadItem];
    
    allFileView = [[AllFileView alloc] initWithFrame:CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight - 44) pullingDelegate:nil];
    allFileView.allDelegate = self;
    allFileView.categoryType = 1;
    allFileView.tableFooterView = [UIView new];
    [allFileView setHeadViews:allFileView.frame];
    [self.view addSubview:allFileView];
    
}

- (void)shangchuan:(UIButton *)sender{
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

- (void)duoxuan:(UIButton *)sender{
    
    CGRect rect = self.view.frame;
    if (!tabView) {
        tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, 49)];
        tabView.backgroundColor = RGB(53, 53, 53);
        
        NSArray * array = @[@"下载", @"分享", @"移动", @"删除"];
        for (int i = 0; i < 4; i++) {
            UIButton * returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            returnBtn.frame = CGRectMake(5 + 5 * (i + 1) + (rect.size.width - 35)/4 * i , 10, (rect.size.width - 35)/4, 29);
            returnBtn.backgroundColor = RGB(78, 78, 78);
            returnBtn.layer.masksToBounds = YES;
            returnBtn.layer.cornerRadius = 2;
            [returnBtn setTitle:array[i] forState:UIControlStateNormal];
            returnBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [returnBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
            [returnBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 3) {
                returnBtn.backgroundColor = RGB(132, 53, 47);
            }
            returnBtn.tag = 100 + i;
            [tabView addSubview:returnBtn];
        }
        
    }else{
        
    }
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UITabBarController * tabCon = (UITabBarController *)dele.window.rootViewController;
    
    if (tabView.frame.origin.y >= 49) {
        [UIView animateWithDuration:0.1 animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
        CGRect rect = tabView.frame;
        rect.origin.y = 0;
        tabView.frame = rect;
        [tabCon.tabBar addSubview:tabView];
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 50, 44);
        [leftBtn setTitle:@"全选" forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(quanxuan:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.title = @"选择文件";
        self.navigationItem.titleView = nil;
        allFileView.isDuoXuan = YES;
        [allFileView reloadDatas];
        documentsView.isDuoXuan = YES;
        [documentsView reloadDatas];
        
    }else{
        
        [self quxiaoDuoXuan:(sender)];
        [self addBackButton];
    }
}

- (void)quxiaoDuoXuan:(UIButton *)sender{
    [UIView animateWithDuration:0.1 animations:^{
        
        
    } completion:^(BOOL finished) {
        
    }];
    self.navigationItem.title = @"共享";
    self.navigationItem.leftBarButtonItem = nil;
    [sender setTitle:@"多选" forState:UIControlStateNormal];
    CGRect rect = tabView.frame;
    self.navigationItem.title = titleString;
    self.navigationItem.titleView = [self createTitleBtn:titleString];
    rect.origin.y = 49;
    tabView.frame = rect;
    [tabView removeFromSuperview];
    allFileView.isDuoXuan = NO;
    [allFileView reloadDatas];
    documentsView.isDuoXuan = NO;
    [documentsView reloadDatas];
}

- (void)quanxuan:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"全选"]) {
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
        if (currentPage == 1) {
            [allFileView yongYuQuanXuan:YES];
        }else{
            [documentsView yongYuQuanXuan:YES];
        }
    }else if([sender.currentTitle isEqualToString:@"全不选"]) {
        if (currentPage == 1) {
            [allFileView yongYuQuanXuan:NO];
        }else{
            [documentsView yongYuQuanXuan:NO];
        }
        [sender setTitle:@"全选" forState:UIControlStateNormal];
    }
//    [listTableView reloadData];
}

- (void)deleteOrReturn:(UIButton *)sender{
    if (sender.tag == 102) {
        if (currentPage == 1) {
            [allFileView removeDuoXuanFiles];
        }else{
            [documentsView removeDuoXuanFiles];
        }
        
    }else if (sender.tag == 103){
        if (currentPage == 1) {
            [allFileView shanchuWenjian:nil];
        }else{
            [documentsView shanchuWenjian:nil];
        }
    }
}

- (void)addDocumentsView:(NSString *)titleString{
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 64 : 0;
    if (!IS_IOS7) {
        rect.size.height -= 44;
    }
    if (!documentsView) {
        documentsView = [[DocumentsView alloc] initWithFrame:CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight) pullingDelegate:nil];
        documentsView.allDelegate = self;
        [documentsView initSubViews];
        [self.view addSubview:documentsView];
    }
    documentsView.categoryName = titleString;
    [documentsView initialiseData];
    [self.view bringSubviewToFront:documentsView];
}

-(void)backToPortal{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * str = [NSString stringWithFormat:@"%@://", [ud objectForKey:@"appid"]];
    if ([ud objectForKey:@"appid"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"byod.portal://"]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

#pragma mark - AllFileViewDelegate

- (void)openFolder:(id)data{
    
    FolderViewController * folderVC = [[FolderViewController alloc] init];
    folderVC.fileDta = (FileData *)data;
    [self.navigationController pushViewController:folderVC animated:YES];
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
