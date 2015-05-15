//
//  DownloadFolderViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/13.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DownloadFolderViewController.h"
#import "Global.h"
#import "UploadFinishTableViewCell.h"
#import "SQLCommand.h"
#import "UIImageView+WebCache.h"
#import "CommonHelper.h"
#import "SelectedTableViewCell.h"
#import "CategoryData.h"
#import "PictureBigShowViewController.h"
#import "DocumentsViewController.h"
#import "VideoShowViewController.h"
#import "VideoNavigationController.h"

@interface DownloadFolderViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation DownloadFolderViewController{
    CGRect rectFrame;
    UITableView * listTableView;
    NSMutableArray * listArray;
    NSMutableArray * heiArray;
    BOOL isDuoXuan;
    UIView * tabView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    listArray = [NSMutableArray new];
    heiArray = [NSMutableArray new];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _fileData.fileName;
    rectFrame = self.view.frame;
    [self initSubViews];
    [self getdata];
}

- (void)getdata{
    [listArray removeAllObjects];
    [listArray addObjectsFromArray:[[SQLCommand shareSQLCommand] getSubfolders:_fileData.fileID]];
    [self getCellHeight:listArray];
    [listTableView reloadData];
}

- (void)getCellHeight:(NSArray *)array{
    [heiArray removeAllObjects];
    for (FileData * data in array) {
        CGSize size = [data.fileName sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        size.height += 10;
        CGFloat cellHeight = size.height + 40;
        if (cellHeight < 60) {
            cellHeight = 60;
        }
        NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
        [heiArray addObject:dic];
    }
}

- (void)initSubViews{
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 44);
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(duoxuan:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height) style:UITableViewStylePlain];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.tableFooterView = [UIView new];
    [self.view addSubview:listTableView];
    if ([listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [listTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [listTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)duoxuan:(UIButton *)item{
    CGRect rect = self.view.frame;
    if (!tabView) {
        tabView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, self.view.frame.size.width, 49)];
        
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
        [self.view addSubview:tabView];
    }else{
        
    }
    if (tabView.frame.origin.y >= rect.size.height) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = tabView.frame;
            rect.origin.y -= 49;
            tabView.frame = rect;
            
            rect = listTableView.frame;
            rect.size.height -= 49;
            listTableView.frame = rect;
        } completion:^(BOOL finished) {
            
        }];
        [item setTitle:@"取消" forState:UIControlStateNormal];
        isDuoXuan = YES;
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
            CGRect rect = tabView.frame;
            rect.origin.y += 49;
            tabView.frame = rect;
            
            rect = listTableView.frame;
            rect.size.height += 49;
            listTableView.frame = rect;
        } completion:^(BOOL finished) {
            
        }];
        isDuoXuan = NO;
        self.navigationItem.title = _fileData.fileName;
        self.navigationItem.leftBarButtonItem = nil;
        [item setTitle:@"多选" forState:UIControlStateNormal];
    }
    [listTableView reloadData];
//    CGRect rect = tabView.frame;
//    rect.origin.y = 0;
//    tabView.frame = rect;
//    [tabCon.tabBar addSubview:tabView];
    
    
}

- (void)quanxuan:(UIButton *)sender{
    
}

- (void)deleteOrReturn:(UIButton *)sender{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = heiArray[indexPath.section];
    return [[dic objectForKey:@"cellheight"] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!isDuoXuan) {
        FileData * data = listArray[indexPath.row];
        UploadFinishTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"finishCell"];
        if (!cell) {
            cell = [[UploadFinishTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"finishCell" withViewFrame:tableView.frame];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString * lenstr = data.thumDownloadUrl;
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
        NSRange range = [typeStr rangeOfString:data.fileFormat];
        cell.headPhoto.image = nil;
        if (lenstr.length > 3 && range.location != NSNotFound) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            [cell.headPhoto sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed];
        }else
            cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
        
        //        cell.headPhoto.image = [UIImage imageWithContentsOfFile:path];
        cell.titleLabel.text = data.fileName;
        cell.indexPath = indexPath;
        cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.updateTime];
        if (![data.fileFormat isEqualToString:@"f"]) {
            cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
        }else
            cell.sizeLabel.text = @"";
        NSDictionary * dic = heiArray[indexPath.row];
        [cell layoutSubview:dic];
        return cell;
    }else{
        SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        if (!cell) {
            cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
        }
        FileData * data = listArray[indexPath.row];
        NSString * lenstr = data.thumDownloadUrl;
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
        NSRange range = [typeStr rangeOfString:data.fileFormat];
        cell.headPhoto.image = nil;
        if (lenstr.length > 3 && range.location != NSNotFound) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            [cell.headPhoto sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed];
        }else
            cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
        
        cell.indexPath = indexPath;
        cell.titleLabel.text = data.fileName;
        cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.updateTime];
        cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
        if (!data.isSelected) {
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box-outline-blank.png"];
        }else{
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box.png"];
        }
        NSDictionary * dic = heiArray[indexPath.row];
        [cell layoutSubview:dic];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData *data = listArray[indexPath.row];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData * data = listArray[indexPath.row];
        NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
        NSMutableString * categoryStr = [NSMutableString new];
        if ([data.fileFormat isEqualToString:@"f"]) {
            DownloadFolderViewController * downloadFolderVC = [[DownloadFolderViewController alloc] init];
            downloadFolderVC.fileData = data;
            downloadFolderVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:downloadFolderVC animated:YES];
            return;
        }
        [categoryStr deleteCharactersInRange:NSMakeRange(0, categoryStr.length)];
        for (NSDictionary * dic in array) {
            if ([dic[@"categoryName"] isEqualToString:@"图片"]) {
                for (NSString * str in dic[@"categoryList"]) {
                    [categoryStr appendFormat:@"%@,", str];
                }
            }
        }
        NSRange range = [categoryStr rangeOfString:data.fileFormat];
        NSLog(@"%lu", (unsigned long)range.length);
        if (range.length != 0){
            NSMutableArray * picArray = [NSMutableArray new];
            for (FileData * data in listArray) {
                NSRange picRange = [categoryStr rangeOfString:data.fileFormat];
                //            NSLog(@"%@  %@   %d", categoryStr, data.fileFormat, picRange.length);
                if (picRange.length != 0 && ![data.fileFormat isEqualToString:@"f"]) {
                    [picArray addObject:data];
                }
            }
            
            PictureBigShowViewController * picVC = [[PictureBigShowViewController alloc] init];
            picVC.pictureArray = picArray;
            picVC.fileData = data;
            picVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:picVC animated:YES];
            return;
        }
        
        
        [categoryStr deleteCharactersInRange:NSMakeRange(0, categoryStr.length)];
        for (NSDictionary * dic in array) {
            if ([dic[@"categoryName"] isEqualToString:@"文档"]) {
                for (NSString * str in dic[@"categoryList"]) {
                    [categoryStr appendFormat:@"%@,", str];
                }
            }
        }
        
        range = [categoryStr rangeOfString:data.fileFormat];
        NSLog(@"%lu", (unsigned long)range.length);
        if (range.length != 0){
            UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DocumentsViewController * dvc = [storyBoard instantiateViewControllerWithIdentifier:@"documents"];
            dvc.fileData = data;
            dvc.isDownload = NO;
            dvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:dvc animated:YES];
        }
        
        [categoryStr deleteCharactersInRange:NSMakeRange(0, categoryStr.length)];
        for (NSDictionary * dic in array) {
            if ([dic[@"categoryName"] isEqualToString:@"视频"]) {
                for (NSString * str in dic[@"categoryList"]) {
                    [categoryStr appendFormat:@"%@,", str];
                }
            }
        }
        
        range = [categoryStr rangeOfString:data.fileFormat];
        NSLog(@"%lu", (unsigned long)range.length);
        if (range.length != 0){
            VideoShowViewController * dvc = [[VideoShowViewController alloc] init];
            VideoNavigationController * vnav = [[VideoNavigationController alloc] initWithRootViewController:dvc];
            VideoData * vData = [[VideoData alloc] init];
            vData.resouceName = data.fileName;
            vData.resourceURL = data.downloadUrl;
            dvc.videoData = vData;
            dvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController presentViewController:vnav animated:NO completion:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
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
