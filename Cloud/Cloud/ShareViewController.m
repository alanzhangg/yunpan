//
//  ShareViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ShareViewController.h"
#import "XHScrollMenu.h"
#import "XHMenu.h"
#import "Global.h"
#import "ShareView.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "AppDelegate.h"

@interface ShareViewController ()<XHScrollMenuDelegate, UIScrollViewDelegate>

@end

@implementation ShareViewController{
    XHScrollMenu * scrollMenu;
    UIScrollView * menuScrollView;
    int currentPage;
    UIView * tabView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"共享";
    
    [self initSubViews];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [tabView removeFromSuperview];
}

- (void)initSubViews{
    [self initMenuBar];
    
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
    
    menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, statusBar + 35, viewRect.size.width, viewRect.size.height - statusBar - 35)];
    menuScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:menuScrollView];
    menuScrollView.contentSize = CGSizeMake(viewRect.size.width * 2, menuScrollView.frame.size.height);
    menuScrollView.delegate = self;
    menuScrollView.pagingEnabled = YES;
    
    ShareView * leftview = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, viewRect.size.width, menuScrollView.frame.size.height)];
    leftview.shareCategory = @"myshare";
    leftview.parentVC = self;
    leftview.backgroundColor = [UIColor greenColor];
    [menuScrollView addSubview: leftview];
    leftview.tag = 200;
    
    ShareView * rightView = [[ShareView alloc] initWithFrame:CGRectMake(viewRect.size.width, 0, viewRect.size.width, menuScrollView.frame.size.height)];
    rightView.shareCategory = @"shareme";
    rightView.parentVC = self;
    rightView.backgroundColor = [UIColor redColor];
    [menuScrollView addSubview: rightView];
    rightView.tag = 300;
    
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        [leftview launchView];
        [rightView launchView];
    }else{
        [Alert showHUDWihtTitle:@"真的没有网络"];
    }
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
    NSArray * titleArray = @[@"我的分享", @"别人的共享"];
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
        
        tabView.backgroundColor = RGB(53, 53, 53);
        UIButton * returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        returnBtn.frame = CGRectMake(10, 5, rect.size.width - 20, 39);
        [returnBtn setTitle:@"取消共享" forState:UIControlStateNormal];
        returnBtn.layer.masksToBounds = YES;
        returnBtn.layer.cornerRadius = 2;
        returnBtn.backgroundColor = RGB(78, 78, 78);
        [returnBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
        returnBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [returnBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
        returnBtn.tag = 100;
        [tabView addSubview:returnBtn];
        
    }else{
        
    }
    NSLog(@"%d", currentPage);
    if (currentPage == 0) {
        UIButton * btn = (UIButton *)[tabView viewWithTag:200];
        [btn setTitle:@"取消共享" forState:UIControlStateNormal];
        btn.tag = 100;
    }else{
        UIButton * btn = (UIButton *)[tabView viewWithTag:100];
        [btn setTitle:@"下载" forState:UIControlStateNormal];
        btn.tag = 200;
    }
    
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UITabBarController * tabCon = (UITabBarController *)dele.window.rootViewController;
    
    if (tabView.frame.origin.y >= 49) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = scrollMenu.frame;
            rect.origin.y -= 35;
            scrollMenu.frame = rect;
            
            rect = menuScrollView.frame;
            rect.size.height += 35;
            rect.origin.y -= 35;
            menuScrollView.frame = rect;
            menuScrollView.scrollEnabled = NO;
            
            ShareView * view = (ShareView *)[menuScrollView viewWithTag:200];
            view.frame = CGRectMake(0, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = YES;
            [view layoutIfNeeded];
            
            view = (ShareView *)[menuScrollView viewWithTag:300];
            view.frame = CGRectMake(menuScrollView.frame.size.width, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = YES;
            [view layoutIfNeeded];
            
            
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
            rect.size.height -= 35;
            rect.origin.y += 35;
            menuScrollView.frame = rect;
            menuScrollView.scrollEnabled = YES;
            
            ShareView * view = (ShareView *)[menuScrollView viewWithTag:200];
            view.frame = CGRectMake(0, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = NO;
            [view layoutIfNeeded];
            
            view = (ShareView *)[menuScrollView viewWithTag:300];
            view.frame = CGRectMake(menuScrollView.frame.size.width, 0, menuScrollView.frame.size.width, menuScrollView.frame.size.height);
            view.isDuoXuan = NO;
            [view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }];
        self.navigationItem.title = @"共享";
        self.navigationItem.leftBarButtonItem = nil;
        [sender setTitle:@"多选" forState:UIControlStateNormal];
        CGRect rect = tabView.frame;
        rect.origin.y = 49;
        tabView.frame = rect;
        [tabView removeFromSuperview];
    }
}

- (void)deleteOrReturn:(UIButton *)sender{
    if (sender.tag == 100) {
        ShareView * view = (ShareView *)[menuScrollView viewWithTag:200];
        [view quxiaoGongXuan];
    }
}

- (void)quanxuan:(UIButton *)sender{
    NSLog(@"%d", currentPage);
    ShareView * view;
    if (currentPage == 0) {
        view = (ShareView *)[menuScrollView viewWithTag:200];
    }else{
        view = (ShareView *)[menuScrollView viewWithTag:300];
    }
    if ([sender.currentTitle isEqualToString:@"全选"]) {
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
        [view duoxuan:YES];
    }else if([sender.currentTitle isEqualToString:@"全不选"]){
        [view duoxuan:NO];
        [sender setTitle:@"全选" forState:UIControlStateNormal];
    }
    
}

#pragma mark - XHScrollMenuDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    
    [scrollMenu setSelectedIndex:currentPage animated:YES calledDelegate:YES];
    
    
}

- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex {
    
    [self menuSelectedIndex:selectIndex];
}

- (void)scrollMenuDidManagerSelected:(XHScrollMenu *)scrollMenu {
}

- (void)menuSelectedIndex:(NSUInteger)index {
    CGRect visibleRect = CGRectMake(index * CGRectGetWidth(menuScrollView.bounds), 0, CGRectGetWidth(menuScrollView.bounds), CGRectGetHeight(menuScrollView.bounds));
    //    _menuBar.selectedItemIndex = scrollView.contentOffset.x/320;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [menuScrollView scrollRectToVisible:visibleRect animated:NO];
    } completion:^(BOOL finished) {
        //        shouldObserving = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
