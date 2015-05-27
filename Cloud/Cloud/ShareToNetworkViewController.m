//
//  ShareToNetworkViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/22.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ShareToNetworkViewController.h"
#import "Global.h"
#import "PullingRefreshTableView.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "FileData.h"
#import "MBProgressHUD.h"
#import "NetworkLiatData.h"
#import "BOTableViewHeaderFooterView.h"
#import "BOShiXiangTableViewCell.h"

@interface ShareToNetworkViewController ()<UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate, BOTableViewHeaderFooterViewDelegate>

@property (nonatomic, strong) NSIndexPath * indexPath;

@end

@implementation ShareToNetworkViewController{
    NSMutableArray * listArray;
    PullingRefreshTableView * listTableView;
    NSArray * selArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    listArray = [NSMutableArray new];
    if (IS_IOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self initSubViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [listTableView launchRefreshing];
}

- (void)initSubViews{
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 64 : 0;
    
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight) pullingDelegate:self];
    [self.view addSubview:listTableView];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.headerOnly = YES;
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (IBAction)cancle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:hud];
    [hud show:YES];
    if (selArray.count > 0) {
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param;
            if ([selArray[1] isEqualToString:@"network"]) {
                param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\", \"teamId\":\"\", \"networkId\":\"%@\"}", _fileData.fileID, selArray[0]];
            }else{
                param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\", \"teamId\":\"%@\", \"networkId\":\"\"}", _fileData.fileID, selArray[0]];
            }
            NSDictionary * dic = @{@"param":param, @"aslp":SHARE_TO_NETWORK};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                [hud hide:YES];
                [hud removeFromSuperview];
                if (error) {
                    NSLog(@"%@", error.description);
                    [Alert showHUDWihtTitle:error.localizedDescription];
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    if ([dic[@"result"] isEqualToString:@"ok"]) {
                        [Alert showHUDWihtTitle:@"分享成功"];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [Alert showHUDWihtTitle:dic[@"msg"]];
                    }
                }
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
    }else{
        [hud hide:YES];
        [Alert showHUDWihtTitle:@"请选择工作网络"];
    }
}

#pragma mark - UITabeleViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [listTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [listTableView tableViewDidEndDragging:scrollView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 55;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BOTableViewHeaderFooterView * headerView = [BOTableViewHeaderFooterView headViewWithTableView:tableView];
    headerView.delegate = self;
    headerView.tag = 900 + section;
    NetworkLiatData * data = [listArray objectAtIndex:section];

    //    if (section == 0) {
    //        headerView.detailButton.hidden = YES;
    //    }
    if (selArray.count > 0) {
        if ([selArray[0] isEqualToString:data.netWorkDic[@"id"]]) {
            [headerView.bgButton setImage:[UIImage imageNamed:@"lef02.png"] forState:UIControlStateNormal];
        }
        else{
            [headerView.bgButton setImage:[UIImage imageNamed:@"sectionHeader.png"] forState:UIControlStateNormal];
        }
    }else{
        [headerView.bgButton setImage:[UIImage imageNamed:@"sectionHeader.png"] forState:UIControlStateNormal];
    }
    headerView.friendData = data;
    headerView.titleLabel.text = [data.netWorkDic objectForKey:@"networkName"];
    return headerView;
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NetworkLiatData * data = listArray[section];
    if (data.isOpen) {
        return [data.groupArray count];
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOShiXiangTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell ==  nil) {
        cell = [[BOShiXiangTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" withFrame:tableView.frame];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
        cell.rightButton.hidden = YES;
    }
    //    cell.rightButton.indexPath = indexPath;
    NetworkLiatData * data = [listArray objectAtIndex:indexPath.section];
    NSDictionary * dic = [data.groupArray objectAtIndex:indexPath.row];
//    NSString * str = @"%@(%d)";
//    str = [NSString stringWithFormat: str, [dic objectForKey:@"navname"], [[dic objectForKey:@"count"] intValue]];
//    NSRange range = [str rangeOfString:@"("];
//    NSMutableAttributedString * string  = [[NSMutableAttributedString alloc] initWithString:str];
//    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location ,str.length - range.location)];
    if (selArray.count > 0) {
        if ([selArray[0] isEqualToString:dic[@"id"]]) {
            UIImageView * bgImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 53)];
            //    bgImagView.backgroundColor = [UIColor redColor];
            bgImagView.image = [UIImage imageNamed:@"lef02.png"];
            cell.backgroundView = bgImagView;
        }
        else{
            UIImageView * selectedBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 53)];
            selectedBgView.image = [UIImage imageNamed:@"sectionHeader.png"];
            cell.backgroundView = selectedBgView;
        }
    }else{
        UIImageView * selectedBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 53)];
        selectedBgView.image = [UIImage imageNamed:@"sectionHeader.png"];
        cell.backgroundView = selectedBgView;
    }
    cell.titleLabel.text = [dic objectForKey:@"teamName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NetworkLiatData * data = listArray[indexPath.section];
    NSDictionary * dic = data.groupArray[indexPath.row];
    selArray = @[dic[@"id"], @"group"];
    [listTableView reloadData];
}

- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    [self getNetworkData];
}

- (void)finishTableRefresh{
    [listTableView tableViewDidFinishedLoading];
    [listTableView reloadData];
}

- (void)getNetworkData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={}"];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_NETWORKS};
        __block int i = 0;
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
                [Alert showHUDWihtTitle:error.localizedDescription];
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", dic);
                NSLog(@"%@", [dic objectForKey:@"msg"]);
                if ([dic[@"result"] isEqualToString:@"ok"]) {
                    NSDictionary * netDic = dic[@"data"];
                    NSArray * array = netDic[@"networks"];
                    [listArray removeAllObjects];
                    for (NSDictionary * dict in array) {
                        NetworkLiatData * netData = [[NetworkLiatData alloc] init];
                        netData.isOpen = NO;
                        netData.netWorkDic = dict;
                        [listArray addObject:netData];
                        NSString * param = [NSString stringWithFormat:@"params={\"networkId\":\"%@\", \"join\":\"true\"}", netData.netWorkDic[@"id"]];
                        NSDictionary * groupDic = @{@"param":param, @"aslp":QUERY_TEAMS};
                        [NetWorkingRequest synthronizationWithString:groupDic andBlock:^(id data, NSError *error) {
                            i++;
                            if (i == array.count) {
                                [self finishTableRefresh];
                            }
                            if (error) {
                                NSLog(@"%@", error.description);
                                [Alert showHUDWihtTitle:error.localizedDescription];
                            }else{
                                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                NSLog(@"%@", dic);
                                NSLog(@"%@", [dic objectForKey:@"msg"]);
                                if ([dic[@"result"] isEqualToString:@"ok"]) {
                                    NSDictionary * groupDic = dic[@"data"];
                                    netData.groupArray = groupDic[@"teams"];
                                    
                                }else{
                                    [Alert showHUDWihtTitle:dic[@"msg"]];
                                }
                                
                                // NSArray * array = [dic objectForKey:@"fileList"];
                                
                            }
                        }];
                        
                    }
                }else{
                    [Alert showHUDWihtTitle:dic[@"msg"]];
                }
                
                // NSArray * array = [dic objectForKey:@"fileList"];
                
            }
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
    
    
}

#pragma mark - BOTableViewHeaderFooterViewDelegate

- (void)clickHeaderView:(NetworkLiatData *)data with:(BOTableViewHeaderFooterView *)view{
    //    h_stages = (int)view.tag - 900;
    [listTableView reloadData];
    self.indexPath = [NSIndexPath indexPathForRow:-1 inSection:(int)view.tag - 900];
    NSDictionary * dic = data.netWorkDic;
//    selArray = @[[dic objectForKey:@"navcode"]];
    selArray = @[dic[@"id"], @"network"];
    [listTableView reloadData];
    //    if (_block) {
    //        _block(array);
    //    }
    //
    //    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)clickDetailButton{
    [listTableView reloadData];
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
