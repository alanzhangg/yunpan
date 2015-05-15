//
//  ShangchuanViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/27.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ShangchuanViewController.h"
#import "Global.h"
#import "MoveFolderViewController.h"

@interface ShangchuanViewController ()

@end

@implementation ShangchuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    NSArray * titleArray = @[@"新建文件夹", @"选定"];
    NSArray * colorArray = @[RGB(106, 106, 106), RGB(32, 121, 227)];
    for (int i = 0; i < 2; i++) {
        UIButton * tabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tabBtn.frame = CGRectMake(20 + ((self.view.frame.size.width - 50) / 2 + 10) * i, 5, (self.view.frame.size.width - 50) / 2, 39);
        tabBtn.layer.masksToBounds = YES;
        tabBtn.layer.cornerRadius = 2;
        [view addSubview:tabBtn];
        [tabBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        tabBtn.backgroundColor = colorArray[i];
        tabBtn.tag = 100 + 100 * i;
        [tabBtn addTarget:self action:@selector(shangchuan:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)shangchuan:(UIButton *)sender{
    if (sender.tag == 100) {
        MoveFolderViewController * folervc = (MoveFolderViewController *)self.topViewController;
        [folervc createFolder:nil];
    }else{
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (_block) {
                _block(_fileData);
            }
        }];
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
