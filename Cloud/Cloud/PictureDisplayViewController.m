//
//  PictureDisplayViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/27.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "PictureDisplayViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Global.h"
#import "PhotoData.h"
#import "DetailPictureDisplayViewController.h"
#import "NRCollectImageData.h"

@interface PictureDisplayViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation PictureDisplayViewController{
    NSMutableArray * listArray;
    NSString * proparty;
    ALAssetsLibrary * library;
    UITableView * listTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"选择相册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_isVideo) {
        proparty = ALAssetTypeVideo;
    }else{
        proparty = ALAssetTypePhoto;
    }
    listArray = [NSMutableArray new];
    library = [[ALAssetsLibrary alloc] init];
    [self getData];
    [self initSubView];
    
}

- (void)initSubView{
    UIButton * uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadBtn.frame = CGRectMake(10, 0, 44, 44);
    //    uploadBtn.backgroundColor = [UIColor blueColor];
    [uploadBtn setTitle:@"返回" forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [uploadBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    CGRect rect = self.view.frame;
    
    listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStylePlain];
    [self.view addSubview:listTableView];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    PhotoData * data = listArray[indexPath.row];
    cell.imageView.image = data.image;
    cell.textLabel.text = data.groupName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)data.numbers];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotoData * data = listArray[indexPath.row];
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailPictureDisplayViewController * dvc = [storyBoard instantiateViewControllerWithIdentifier:@"detailPicture"];
    dvc.groupListArray = data.groupArray;
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (void)back:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error){
                if ([[error localizedDescription] rangeOfString:@"Global denied access"].location == NSNotFound) {
                    NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态 .");
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问相册.请在'设置->定位服务'设置为打开状态 ." message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }else{
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"相册访问失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            };
            
            
            ALAssetsLibraryGroupsEnumerationResultsBlock groupBlock = ^(ALAssetsGroup *group, BOOL *stop){
                if (group != nil) {
                    NSMutableArray * array = [NSMutableArray new];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        NSLog(@"%d, %s", index, stop);
                        if (result != NULL) {
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:proparty]) {
                                NRCollectImageData * data = [[NRCollectImageData alloc] init];
                                data.result = result;
                                [array addObject:data];
                            }
                        }
                        if (index == group.numberOfAssets - 1) {
                            if (array.count > 0) {
                                PhotoData * data = [[PhotoData alloc] init];
                                data.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                                data.numbers = array.count;
                                data.image = [UIImage imageWithCGImage:group.posterImage];
                                data.groupArray = array;
                                [listArray addObject:data];
                            }
                        }
                    }];
                }
                if (stop) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@", listArray);
                        [listTableView reloadData];
                    });
                }
            };
            
            [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:groupBlock failureBlock:failureBlock];
            
        }
    });
    
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
