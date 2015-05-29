//
//  MoveFolderViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/8.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "MoveFolderViewController.h"
#import "SQLCommand.h"
#import "FolderTableViewCell.h"
#import "FileData.h"
#import "RenameViewController.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "ShangchuanViewController.h"

@interface MoveFolderViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *moveButton;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation MoveFolderViewController{
    NSArray * listArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self reloadDataList];
    if (_navTitle) {
        self.navigationItem.title = _navTitle;
    }
    if (_shangchuan) {
        self.navigationItem.prompt = @"选择路径";
//        [_moveButton setTitle:@"选定" forState:UIControlStateNormal];
    }
}

- (IBAction)createFolder:(UIButton *)sender {
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RenameViewController * renameCon = (RenameViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"renameCon"];
    renameCon.isXinjian = YES;
    FileData * fileData = [[FileData alloc] init];
    fileData.fileID = _folderId;
    fileData.fileName = _navTitle;
    renameCon.fileData = fileData;
    NormalNavigationController * nav = [[NormalNavigationController alloc] initWithRootViewController:renameCon];
    __weak MoveFolderViewController * weakSelf = self;
    renameCon.block = ^(){
        __strong MoveFolderViewController * strSeld = weakSelf;
        [strSeld getNetworkingData];
        
    };
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)reloadDataList{
    listArray = [[SQLCommand shareSQLCommand] getFolder:_folderId withMoveData:_moveFileDataArray];
    [_listTableView reloadData];
}

- (void)getNetworkingData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"allfile\",\"dirId\":\"%@\",\"searchValue\":\"\"}", _folderId];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_BY_SEARCH};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", dic);
                NSLog(@"%@", [dic objectForKey:@"msg"]);
                dic = [dic objectForKey:@"data"];
                NSArray * array = [dic objectForKey:@"fileList"];
                if (array) {
                    [SQLCommand updatedata:array withlistArray:listArray];
                    [self reloadDataList];
                }
            }
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

- (IBAction)moveFolder:(UIButton *)sender {
    
    if (_shangchuan) {
        if (_uploadBlock) {
            _uploadBlock(_fileData);
        }
    }else{
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSMutableString * sourceId = [[NSMutableString alloc] initWithString:@""];
            for (FileData * data in _moveFileDataArray) {
                [sourceId appendFormat:@"%@,", data.fileID];
            }
            if (sourceId.length > 2) {
                [sourceId deleteCharactersInRange:NSMakeRange(sourceId.length - 1, 1)];
            }
            NSString * param = [NSString stringWithFormat:@"params={\"sourceId\":\"%@\",\"targetId\":\"%@\"}", sourceId, _folderId];
            NSDictionary * dic = @{@"param":param, @"aslp":MOVE_FOLDER};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //                dic = [dic objectForKey:@"data"];
                    if ([dic[@"result"] isEqualToString:@"ok"]) {
                        [[SQLCommand shareSQLCommand] moveFile:_moveFileDataArray toTargetFolder:_folderId];
                        [Alert showHUDWihtTitle:@"移动成功"];
                        if (_block) {
                            _block();
                        }
                        [self cancel:nil];
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
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FolderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"folderCell"];
    FileData * data = listArray[indexPath.row];
    cell.folderName.text = data.fileName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoveFolderViewController * folderVC = (MoveFolderViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"moveFolder"];
    FileData * data = listArray[indexPath.row];
    folderVC.folderId = data.fileID;
    folderVC.navTitle = data.fileName;
    folderVC.moveFileDataArray = _moveFileDataArray;
    folderVC.block = _block;
    if (_shangchuan) {
        ShangchuanViewController * svc = (ShangchuanViewController *)self.navigationController;
        svc.fileData = data;
    }
    [self.navigationController pushViewController:folderVC animated:YES];
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
