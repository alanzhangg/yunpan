//
//  DownAndLoadViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DownAndLoadViewController.h"
#import "XHScrollMenu.h"
#import "XHMenu.h"
#import "Global.h"
#import "DownloadListView.h"
#import "AppDelegate.h"
#import "UploadListView.h"
#import "UploadNetwork.h"
#import "FilesDownloadManager.h"

@interface DownAndLoadViewController ()<XHScrollMenuDelegate, UIScrollViewDelegate>

@end

@implementation DownAndLoadViewController{
    XHScrollMenu * scrollMenu;
    UIScrollView * menuScrollView;
    int currentPage;
    UIView * tabView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"传输列表";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initSubViews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[FilesDownloadManager sharedFilesDownManage] startRequest:nil];
    DownloadListView * leftView = (DownloadListView *)[menuScrollView viewWithTag:200];
    [leftView reloadDatas];
    
    UploadListView * rightView = (UploadListView *)[menuScrollView viewWithTag:300];
    [rightView reloadDatas];
    
    [UploadNetwork shareUploadNetwork];
    [[UploadNetwork shareUploadNetwork] startUpload];
    [[FilesDownloadManager sharedFilesDownManage] getSqlData];
}

- (void)initSubViews{
//    [self initMenuBar];
    
    CGRect viewRect = self.view.frame;
    float statusBar = 0;
    if (IS_IOS7) {
        statusBar = 64;
    }
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 44);
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(duoxuan:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIView * tabberView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBar, viewRect.size.width, 50)];
    tabberView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tabberView];
    
    UISegmentedControl * segCon = [[UISegmentedControl alloc] initWithItems:@[@"下载列表", @"上传列表"]];
    segCon.tintColor = [UIColor grayColor];
    segCon.selectedSegmentIndex = 0;
    [segCon addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segCon.frame = CGRectMake(viewRect.size.width / 2 - 100, 10, 200, 30);
    [tabberView addSubview:segCon];
    
    menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, statusBar + 50, viewRect.size.width, viewRect.size.height - statusBar - 50 - 49)];
    menuScrollView.backgroundColor = [UIColor clearColor];
    menuScrollView.bounces = NO;
    menuScrollView.scrollEnabled = NO;
    [self.view addSubview:menuScrollView];
    menuScrollView.contentSize = CGSizeMake(viewRect.size.width * 2, menuScrollView.frame.size.height);
    menuScrollView.delegate = self;
    menuScrollView.pagingEnabled = YES;
    
    DownloadListView * leftview = [[DownloadListView alloc] initWithFrame:CGRectMake(0, 0, viewRect.size.width, menuScrollView.frame.size.height)];
    leftview.categoryName = @"下载";
    leftview.backgroundColor = [UIColor greenColor];
    [menuScrollView addSubview: leftview];
    leftview.parentVC = self;
    leftview.tag = 200;
    
    UploadListView * rightView = [[UploadListView alloc] initWithFrame:CGRectMake(viewRect.size.width, 0, viewRect.size.width, menuScrollView.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    [menuScrollView addSubview: rightView];
    rightView.parentVc = self;
    [rightView reloadDatas];
    rightView.tag = 300;
    
}

- (void)segmentAction:(UISegmentedControl *)seg{
    [menuScrollView setContentOffset:CGPointMake(seg.selectedSegmentIndex * menuScrollView.frame.size.width, 0) animated:YES];
}

- (void)initMenuBar{
    CGRect viewRect = self.view.frame;
    float statusBar = 0;
    if (IS_IOS7) {
        statusBar = 64;
    }
    
    scrollMenu = [[XHScrollMenu alloc] initWithFrame:CGRectMake(0, statusBar, viewRect.size.width, 35)];
    scrollMenu.backgroundColor = [UIColor whiteColor];
    scrollMenu.delegate = self;
    scrollMenu.selectedIndex = 0;
    
    [self.view addSubview:scrollMenu];
    
    NSMutableArray * menuArray = [NSMutableArray new];
    NSArray * titleArray = @[@"下载列表", @"上传列表"];
    for (int i = 0 ; i < 2; i++) {
        XHMenu *menu = [[XHMenu alloc] init];
        menu.title = titleArray[i];
        menu.titleNormalColor = RGB(80, 80, 80);
        menu.titleSelectedColor = RGB(42, 132, 255);
        menu.titleFont = [UIFont boldSystemFontOfSize:16];
        [menuArray addObject:menu];
    }
    scrollMenu.menus = menuArray;
    [scrollMenu reloadData];
}

- (void)duoxuan:(UIButton *)sender{
    //增加tab选择
    CGRect rect = self.view.frame;
    if (!tabView) {
        tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, 49)];
        
        tabView.backgroundColor = [UIColor darkGrayColor];
        
        UIButton * deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(10, 5,rect.size.width - 20, 39);
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 2;
        deleteBtn.backgroundColor = RGB(132, 53, 47);
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [deleteBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 200;
        [tabView addSubview:deleteBtn];
    }else{
        
    }
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UITabBarController * tabCon = (UITabBarController *)dele.window.rootViewController;
    
    if (tabView.frame.origin.y >= 49) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = scrollMenu.frame;
            rect.origin.y -= 35;
            scrollMenu.frame = rect;
            
            rect = menuScrollView.frame;
            rect.size.height += 50;
            rect.origin.y -= 50;
            menuScrollView.frame = rect;
            menuScrollView.scrollEnabled = NO;
            
            DownloadListView * view = (DownloadListView *)[menuScrollView viewWithTag:200];
            view.frame = CGRectMake(0, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = YES;
            [view layoutIfNeeded];
            
            UploadListView * upview = (UploadListView *)[menuScrollView viewWithTag:300];
            upview.frame = CGRectMake(menuScrollView.frame.size.width, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            upview.isDuoxuan = YES;
            [upview layoutIfNeeded];
            
            
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
    }else{
        
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = scrollMenu.frame;
            rect.origin.y += 35;
            scrollMenu.frame = rect;
            
            rect = menuScrollView.frame;
            rect.size.height -= 50;
            rect.origin.y += 50;
            menuScrollView.frame = rect;
            menuScrollView.scrollEnabled = NO;
            
            DownloadListView * view = (DownloadListView *)[menuScrollView viewWithTag:200];
            view.frame = CGRectMake(0, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = NO;
            [view duoxuan:NO];
            [view layoutIfNeeded];
            
            UploadListView * upview = (UploadListView *)[menuScrollView viewWithTag:300];
            upview.frame = CGRectMake(menuScrollView.frame.size.width, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            upview.isDuoxuan = NO;
            [upview duoxuan:NO];
            [upview layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }]; 
        self.navigationItem.title = @"传输列表";
        self.navigationItem.leftBarButtonItem = nil;
        [sender setTitle:@"多选" forState:UIControlStateNormal];
        CGRect rect = tabView.frame;
        rect.origin.y = 49;
        tabView.frame = rect;
        [tabView removeFromSuperview];
    }
}

- (void)deleteOrReturn:(UIButton *)sender{
    if (menuScrollView.contentOffset.x > 100) {
        NSLog(@"++++++");
        UploadListView * view = (UploadListView *)[menuScrollView viewWithTag:300];
        [view duoxuanShanchu];
    }else{
        NSLog(@"------");
        DownloadListView * view = (DownloadListView *)[menuScrollView viewWithTag:200];
        [view duoxuanShanchu];
    }
}

- (void)quanxuan:(UIButton *)sender{
    NSLog(@"%d", currentPage);
    DownloadListView * view;
    if (menuScrollView.contentOffset.x < 100) {
        view = (DownloadListView *)[menuScrollView viewWithTag:200];
    }else{
        view = (UploadListView *)[menuScrollView viewWithTag:300];
        
    }
    if ([sender.currentTitle isEqualToString:@"全选"]) {
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
        [view duoxuan:YES];
    }else if([sender.currentTitle isEqualToString:@"全不选"]){
        [view duoxuan:NO];
        [sender setTitle:@"全选" forState:UIControlStateNormal];
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
