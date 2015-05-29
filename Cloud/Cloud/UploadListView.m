//
//  UploadListView.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/29.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "UploadListView.h"
#import "UploadNetwork.h"
#import "PullingRefreshTableView.h"
#import "UploadData.h"
#import "UploadFailTableViewCell.h"
#import "SQLCommand.h"
#import "UploadFinishTableViewCell.h"
#import "UploadingTableViewCell.h"
#import "CommonHelper.h"
#import "VideoShowViewController.h"
#import "VideoNavigationController.h"
#import "CategoryData.h"
#import "PictureBigShowViewController.h"
#import "SelectedTableViewCell.h"

@interface UploadListView ()<UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate, UploadFailTableViewCellDelegate, UploadNetworkDelegate>

@end

@implementation UploadListView{
    CGRect rectFrame;
    NSMutableArray * heightArray;
    PullingRefreshTableView * listTableView;
    UploadNetwork * upNetwork;
    NSMutableArray * headerArray;
    NSMutableArray * listArray;
    int uploadingSec;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    rectFrame = self.frame;
    listTableView.frame = CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height);
    [listTableView reloadData];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        rectFrame = frame;
        heightArray = [NSMutableArray new];
        headerArray = [NSMutableArray new];
        listArray = [NSMutableArray new];
        upNetwork = [UploadNetwork shareUploadNetwork];
        [self initSubViews];
        [UploadNetwork shareUploadNetwork].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDatas) name:@"listChange" object:nil];
        uploadingSec = -1;
    }
    return self;
}

- (BOOL)duoxuan:(BOOL)isYes{

    for (int i = 0; i < listArray.count; i++) {
        NSArray * array = listArray[i];
        NSString * secstr = headerArray[i];
        if (![secstr isEqualToString:@"正在上传"]) {
            for (UploadData * data in array) {
                data.isSelected = isYes;
            }
        }
    }
    [listTableView reloadData];
    
    return YES;
}

- (void)reloadDatas{
    [headerArray removeAllObjects];
    [listArray removeAllObjects];
    NSArray * nameArray = @[@"上传失败", @"正在上传", @"上传完成"];
    for (int i = 0; i < 3; i++) {
        NSArray * array = upNetwork.listArray[i];
        if (array.count > 0) {
            [headerArray addObject:nameArray[i]];
            if ([nameArray[i] isEqualToString:@"正在上传"]) {
                uploadingSec = headerArray.count - 1;
            }
            [listArray addObject:array];
        }
    }
    [self getHeight];
    [listTableView reloadData];
}

- (NSArray *)getHeight{
    [heightArray removeAllObjects];
    for (NSArray * array in listArray) {
        NSMutableArray * heiArray = [NSMutableArray new];
        for (UploadData * data in array) {
            CGSize size = [data.fileName sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            size.height += 10;
            CGFloat cellHeight = size.height + 40;
            if (cellHeight < 60) {
                cellHeight = 60;
            }
            NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
            [heiArray addObject:dic];
        }
        [heightArray addObject:heiArray];
    }
    return heightArray;
}

- (void)initSubViews{
    heightArray = [NSMutableArray new];
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height) pullingDelegate:self];
    listTableView.delegate = self;
    listTableView.dataSource = self;
//    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTableView.hiddenAll = YES;
    listTableView.tableFooterView = [UIView new];
    [self addSubview:listTableView];
    if ([listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [listTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [listTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return headerArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * array = heightArray[indexPath.section];
    NSDictionary * dic = array[indexPath.row];
    return [[dic objectForKey:@"cellheight"] floatValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return headerArray[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [listArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isDuoxuan) {
        NSString * secString = headerArray[indexPath.section];
        NSArray * array = listArray[indexPath.section];
        UploadData * data = array[indexPath.row];
        NSString * path = NSHomeDirectory();
        NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumbNail];
        path = [path stringByAppendingPathComponent:pathstr];
        NSArray * hei = heightArray[indexPath.section];
        NSDictionary * dic = hei[indexPath.row];
        
        if ([secString isEqualToString:@"上传失败"]) {
            UploadFailTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FailCell"];
            if (!cell) {
                cell = [[UploadFailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FailCell" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.delegate = self;
            cell.headPhoto.image = [UIImage imageWithContentsOfFile:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            cell.titleLabel.text = data.fileName;
            cell.indexPath = indexPath;
            [cell layoutSubview:dic];
            return cell;
        }else if ([secString isEqualToString:@"正在上传"]){
            UploadingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"uploadingCell"];
            if (!cell) {
                cell = [[UploadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"uploadingCell" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.loadData = data;
            cell.headPhoto.backgroundColor = [UIColor redColor];
            cell.headPhoto.image = [UIImage imageWithContentsOfFile:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            cell.titleLabel.text = data.fileName;
            cell.timeLabel.text = @"等待中......";
            cell.indexPath = indexPath;
            [cell layoutSubview:dic];
            return cell;
        }else{
            UploadFinishTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"finishCell"];
            if (!cell) {
                cell = [[UploadFinishTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"finishCell" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.headPhoto.backgroundColor = [UIColor redColor];
            cell.headPhoto.image = [UIImage imageWithContentsOfFile:path];
            cell.titleLabel.text = data.fileName;
            cell.indexPath = indexPath;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.UPLOADtIME];
            cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
            [cell layoutSubview:dic];
            return cell;
        }
    }else{
        NSArray * array = listArray[indexPath.section];
        UploadData * data = array[indexPath.row];
        NSString * path = NSHomeDirectory();
        NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumbNail];
        path = [path stringByAppendingPathComponent:pathstr];
        NSArray * hei = heightArray[indexPath.section];
        NSDictionary * dic = hei[indexPath.row];
        
        SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        if (!cell) {
            cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
        }
        cell.indexPath = indexPath;
        NSLog(@"%@   %@", data.fileName, data.UPLOADtIME);
        cell.titleLabel.text = data.fileName;
        if (![data.UPLOADtIME isEqual:[NSNull null]]) {
            cell.timeLabel.text = data.UPLOADtIME;
        }
        cell.headPhoto.image = [UIImage imageWithContentsOfFile:path];
        if (!data.isSelected) {
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box-outline-blank.png"];
        }else{
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box.png"];
        }
        
        [cell layoutSubview:dic];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isDuoxuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSArray * array = listArray[indexPath.section];
        UploadData * data = array[indexPath.row];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }else{
        NSMutableString * categoryStr = [NSMutableString new];
        NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
        NSString * secString = headerArray[indexPath.section];
        NSArray * dataArray = listArray[indexPath.section];
        UploadData * data = dataArray[indexPath.row];
        NSRange range;
        if (![secString isEqualToString:@"正在上传"]){
            for (NSDictionary * dic in array) {
                if ([dic[@"categoryName"] isEqualToString:@"图片"]) {
                    for (NSString * str in dic[@"categoryList"]) {
                        [categoryStr appendFormat:@"%@,", str];
                    }
                }
            }
            range = [categoryStr rangeOfString:[[data.fileName pathExtension] lowercaseString]];
            NSLog(@"%lu", (unsigned long)range.length);
            if (range.length != 0){
                NSMutableArray * picArray = [NSMutableArray new];
                for (UploadData * data in dataArray) {
                    NSRange picRange = [categoryStr rangeOfString:[[data.fileName pathExtension] lowercaseString]];
                    //            NSLog(@"%@  %@   %d", categoryStr, data.fileFormat, picRange.length);
                    if (picRange.length != 0) {
                        [picArray addObject:data];
                    }
                }
                
                PictureBigShowViewController * picVC = [[PictureBigShowViewController alloc] init];
                picVC.uploadArray = picArray;
                picVC.uploadData = data;
                picVC.isUpload = YES;
                picVC.isDownload = YES;
                UIViewController * con = (UIViewController *)_parentVc;
                picVC.hidesBottomBarWhenPushed = YES;
                [con.navigationController pushViewController:picVC animated:YES];
                return;
            }
            
            [categoryStr deleteCharactersInRange:NSMakeRange(0, categoryStr.length)];
            for (NSDictionary * dic in array) {
                if ([dic[@"categoryName"] isEqualToString:@"视频"]) {
                    for (NSString * str in dic[@"categoryList"]) {
                        [categoryStr appendFormat:@"%@,", str];
                    }
                }
            }
            
            range = [categoryStr rangeOfString:[[data.fileName pathExtension] lowercaseString]];
            NSLog(@"%@", [data.fileName pathExtension]);
            NSLog(@"%lu", (unsigned long)range.length);
            if (range.length != 0){
                VideoShowViewController * dvc = [[VideoShowViewController alloc] init];
                VideoNavigationController * vnav = [[VideoNavigationController alloc] initWithRootViewController:dvc];
                VideoData * vData = [[VideoData alloc] init];
                vData.resouceName = data.fileName;
                vData.resourceURL = @"";
                vData.fileFormat = @"";
                dvc.videoData = vData;
                dvc.hidesBottomBarWhenPushed = YES;
                UIViewController * con = (UIViewController *)_parentVc;
                [con.navigationController presentViewController:vnav animated:NO completion:nil];
            }
        }
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isDuoxuan) {
        return YES;
    }else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * array = listArray[indexPath.section];
    UploadData * data = array[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        NSString * headStr = headerArray[indexPath.section];
        if ([UploadNetwork shareUploadNetwork].uploadData) {
            UploadData * upData = [UploadNetwork shareUploadNetwork].uploadData;
            if ([upData.fileID isEqualToString:data.fileID]) {
                [[UploadNetwork shareUploadNetwork] cancleUpload];
            }
        }
        if ([[SQLCommand shareSQLCommand] checkFileOnly:data]) {
            [self shanchuData:data];
        }
        [[SQLCommand shareSQLCommand] deleteUploadData:@[data]];
        [array removeObject:data];
        if (array.count > 0) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [tableView reloadData];
        }
    }
}

- (void)shanchuData:(UploadData *)data{
    NSFileManager * fileManeger = [NSFileManager defaultManager];
    NSString * path = NSHomeDirectory();
    NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumbNail];
    NSString * filePath = [path stringByAppendingPathComponent:pathstr];
    [fileManeger removeItemAtPath:filePath error:nil];
    
    pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumbNail];
    filePath = [path stringByAppendingPathComponent:pathstr];
    [fileManeger removeItemAtPath:filePath error:nil];
}

- (void)duoxuanShanchu{
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"确定删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
    
}

#pragma mark - UploadFailTableViewCellDelegate

- (void)shangchuan:(NSIndexPath *)indexPath{
    NSArray * array = listArray[indexPath.section];
    UploadData * data = array[indexPath.row];
    data.status = @(1);
    [[SQLCommand shareSQLCommand] updateUploadData:data];
    [upNetwork getUploadData];
    [upNetwork startUpload];
    [self reloadDatas];
    
}

#pragma mark - UploadNetworkDelegate

- (void)updatingCellData:(UploadData *)data{
    
    for (int i = 0; i < headerArray.count; i++) {
        NSString * secString = headerArray[i];
        if ([secString isEqualToString:@"正在上传"]) {
            for (int j = 0; j < [listArray[i] count]; j++) {
                UploadData * updata = listArray[i][j];
                if ([data.fileID isEqualToString:updata.fileID]) {
                    UploadingTableViewCell * cell = (UploadingTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    
                    if (cell) {
                        cell.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [CommonHelper setLength:data.uploadSize], [CommonHelper setLength:[data.fileSize longLongValue]]];
                        cell.sizeLabel.text = [NSString stringWithFormat:@"%@/s", [CommonHelper setLength:data.uploadSpeed]];
                        NSLog(@"%f", (float)data.uploadSize/(float)[data.fileSize longLongValue]);
                        [cell.functionButton setProgress:(float)data.uploadSize/(float)[data.fileSize longLongValue]];
                    }
                }
            }
        }
    }
    
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex != buttonIndex) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray * selectArray = [NSMutableArray new];
            for (NSMutableArray * array in listArray) {
                for (int i = 0; i < array.count; i++) {
                    UploadData * data = array[i];
                    if (data.isSelected) {
                        [selectArray addObject:data];
                        if ([[SQLCommand shareSQLCommand] checkFileOnly:data]) {
                            [self shanchuData:data];
                        }
                        [array removeObject:data];
                        i = -1;
                    }
                }
            }
            [[SQLCommand shareSQLCommand] deleteUploadData:selectArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [listTableView reloadData];
            });
        });
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
