//
//  ShareView.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/1.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "ShareView.h"
#import "Global.h"
#import "PullingRefreshTableView.h"
#import "ListTableViewCell.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "TrashData.h"
#import "ShareFunctionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SelectedTableViewCell.h"
#import "ALAlertView.h"
#import "FileData.h"
#import "DocumentsViewController.h"
#import "CategoryData.h"
#import "FileCategory.h"
#import "FolderViewController.h"
#import "VideoShowViewController.h"
#import "VideoNavigationController.h"
#import "SQLCommand.h"
#import "FilesDownloadManager.h"
#import "PictureBigShowViewController.h"

@interface ShareView ()<PullingRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate, ListTableViewCellDelegate, ShareFunctionTableViewCellDelegate>

@end

@implementation ShareView{
    CGRect rectFrame;
    PullingRefreshTableView * listTableView;
    NSMutableArray * listArray;
    NSMutableArray * heightArray;
}


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        rectFrame = frame;
        _isDuoXuan = NO;
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    listTableView.frame = CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height);
    [listTableView reloadData];
}

- (void)initSubViews{
    listArray = [NSMutableArray new];
    heightArray = [NSMutableArray new];
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height) pullingDelegate:self];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.headerOnly = YES;
    //    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [listTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [listTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self addSubview:listTableView];
    //    listTableView.separatorInset =
    listTableView.tableFooterView = [UIView new];
}

- (void)launchView{
    [listTableView launchRefreshing];
}

#pragma mark - PullingTableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    TrashData * data = listArray[section];
    if (data.function) {
        return 2;
    }else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSDictionary * dic = heightArray[indexPath.section];
        return [[dic objectForKey:@"cellheight"] floatValue];
    }else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isDuoXuan) {
        if (indexPath.row == 0) {
            ListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" withViewFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.funcDelegate = self;
            }
            cell.indexPath = indexPath;
            TrashData * data = listArray[indexPath.section];
            cell.titleLabel.text = [data.dict objectForKey:@"fileName"];
            cell.timeLabel.text = [data.dict objectForKey:@"shareTime"];
            if (![[data.dict objectForKey:@"fileFormat"] isEqualToString:@"f"]) {
                cell.sizeLabel.text = [cell setLength:[data.dict[@"fileFormat"] floatValue]];
            }else{
                cell.sizeLabel.text = nil;
            }
            
            switch ([FileCategory fileInformation:[data.dict objectForKey:@"fileFormat"]]) {
                case FileCategoryPicture:{
                    NSString * lenstr = [data.dict objectForKey:@"thumDownloadUrl"];
                    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                    NSRange range = [typeStr rangeOfString:[data.dict objectForKey:@"fileFormat"]];
                    if (lenstr.length > 3 && range.location != NSNotFound) {
                        NSString * urlstr;
                        if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                            urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
                        }else{
                            urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
                        }
                        [cell.headPhoto sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed];
                    }
                }
                    break;
                case FileCategoryEXCEL:
                    cell.headPhoto.image = [UIImage imageNamed:@"excel.png"];
                    break;
                case FileCategoryFolder:
                    cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
                    break;
                case FileCategoryMovie:
                    cell.headPhoto.image = [UIImage imageNamed:@"video.png"];
                    break;
                case FileCategoryMusic:
                    cell.headPhoto.image = [UIImage imageNamed:@"audio.png"];
                    break;
                case FileCategoryPDF:
                    cell.headPhoto.image = [UIImage imageNamed:@"pdf.png"];
                    break;
                case FileCategoryPPT:
                    cell.headPhoto.image = [UIImage imageNamed:@"ppt.png"];
                    break;
                case FileCategoryTXT:
                    cell.headPhoto.image = [UIImage imageNamed:@"txt.png"];
                    break;
                case FileCategoryWord:
                    cell.headPhoto.image = [UIImage imageNamed:@"word.png"];
                    break;
                case FileCategoryZIP:
                    cell.headPhoto.image = [UIImage imageNamed:@"zip.png"];
                    break;
                default:
                    cell.headPhoto.image = nil;
                    break;
            }
            
            [cell layoutSubview:heightArray[indexPath.section]];
            //    FileData * data = listArray[indexPath.section];
            //    cell.textLabel.text = data.fileName;
            return cell;
        }else{
            ShareFunctionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"trashcell"];
            if (!cell) {
                cell = [[ShareFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trashcell" withFrame:tableView.frame];
                cell.backgroundColor = RGB(224, 224, 224);
                cell.shareDelegate = self;
            }
            cell.indexPath = indexPath;
            if ([_shareCategory isEqualToString:@"myshare"]) {
                [cell.deleteButton setTitle:@"取消分享" forState:UIControlStateNormal];
                
            }else{
                [cell.deleteButton setTitle:@"下载" forState:UIControlStateNormal];
                [cell.deleteButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            }
            return cell;
        }
    }else{
        SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        if (!cell) {
            cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.indexPath = indexPath;
        TrashData * data = listArray[indexPath.section];
        cell.titleLabel.text = [data.dict objectForKey:@"fileName"];
        cell.timeLabel.text = [data.dict objectForKey:@"shareTime"];
        switch ([FileCategory fileInformation:[data.dict objectForKey:@"fileFormat"]]) {
            case FileCategoryPicture:{
                NSString * lenstr = [data.dict objectForKey:@"thumDownloadUrl"];
                NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                NSRange range = [typeStr rangeOfString:[data.dict objectForKey:@"fileFormat"]];
                if (lenstr.length > 3 && range.location != NSNotFound) {
                    NSString * urlstr;
                    if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                        urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
                    }else{
                        urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
                    }
                    [cell.headPhoto sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed];
                }
            }
                break;
            case FileCategoryEXCEL:
                cell.headPhoto.image = [UIImage imageNamed:@"excel.png"];
                break;
            case FileCategoryFolder:
                cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
                break;
            case FileCategoryMovie:
                cell.headPhoto.image = [UIImage imageNamed:@"video.png"];
                break;
            case FileCategoryMusic:
                cell.headPhoto.image = [UIImage imageNamed:@"audio.png"];
                break;
            case FileCategoryPDF:
                cell.headPhoto.image = [UIImage imageNamed:@"pdf.png"];
                break;
            case FileCategoryPPT:
                cell.headPhoto.image = [UIImage imageNamed:@"ppt.png"];
                break;
            case FileCategoryTXT:
                cell.headPhoto.image = [UIImage imageNamed:@"txt.png"];
                break;
            case FileCategoryWord:
                cell.headPhoto.image = [UIImage imageNamed:@"word.png"];
                break;
            case FileCategoryZIP:
                cell.headPhoto.image = [UIImage imageNamed:@"zip.png"];
                break;
            default:
                cell.headPhoto.image = nil;
                break;
        }
        
        if (!data.isSelected) {
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box-outline-blank.png"];
        }else{
            cell.selectedImageView.image = [UIImage imageNamed:@"check-box.png"];
        }
        
        [cell layoutSubview:heightArray[indexPath.section]];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        TrashData * data = listArray[indexPath.section];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        if ([_shareCategory isEqualToString:@"shareme"]) {
            FileData * data = [FileData new];
            TrashData * trashData = listArray[indexPath.section];
            [data transformDictionary:trashData.dict];
            NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
            NSMutableString * categoryStr = [NSMutableString new];
            
            if ([data.fileFormat isEqualToString:@"f"]) {
                FolderViewController * folderVC = [[FolderViewController alloc] init];
                folderVC.fileDta = (FileData *)data;
                UIViewController * con = (UIViewController *)_parentVC;
                [con.navigationController pushViewController:folderVC animated:YES];
                return;
            }
            
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
                for (TrashData * data in listArray) {
                    FileData * fileData = [FileData new];
                    [fileData transformDictionary:data.dict];
                    NSRange picRange = [categoryStr rangeOfString:fileData.fileFormat];
                    //            NSLog(@"%@  %@   %d", categoryStr, data.fileFormat, picRange.length);
                    if (picRange.length != 0 && ![fileData.fileFormat isEqualToString:@"f"]) {
                        [picArray addObject:fileData];
                    }
                }
                
                PictureBigShowViewController * picVC = [[PictureBigShowViewController alloc] init];
                picVC.pictureArray = picArray;
                picVC.fileData = data;
                picVC.isUpload = NO;
                UIViewController * con = (UIViewController *)_parentVC;
                picVC.hidesBottomBarWhenPushed = YES;
                [con.navigationController pushViewController:picVC animated:YES];
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
                UIViewController * con = (UIViewController *)_parentVC;
                [con.navigationController pushViewController:dvc animated:YES];
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
                UIViewController * con = (UIViewController *)_parentVC;
                [con.navigationController presentViewController:vnav animated:NO completion:nil];
            }
        }
    }
    
}

- (BOOL)duoxuan:(BOOL)isYes{
    if (listArray.count > 0) {
        for (TrashData * data in listArray) {
            data.isSelected = isYes;
        }
        TrashData * data = listArray[0];
        [listTableView reloadData];
        return data.isSelected;
    }else
        return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [listTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [listTableView tableViewDidEndDragging:scrollView];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    return [NSDate date];
}

- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    [self getNetworkData];
}

- (void)getNetworkData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"%@\",\"dirId\":\"\",\"searchValue\":\"\"}", _shareCategory];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_BY_SEARCH};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            [listTableView tableViewDidFinishedLoading];
            if (error) {
                NSLog(@"%@", error.description);
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", dic);
                NSLog(@"%@", [dic objectForKey:@"msg"]);
                dic = [dic objectForKey:@"data"];
                NSArray * array = [dic objectForKey:@"fileList"];
                [listArray removeAllObjects];
                for (NSDictionary * dic in array) {
                    TrashData * data = [[TrashData alloc] init];
                    data.dict = dic;
                    [listArray addObject:data];
                }
                [self getCellHeight:listArray];
                [listTableView reloadData];
            }
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
    
}

- (void)getCellHeight:(NSArray *)array{
    [heightArray removeAllObjects];
    for (TrashData * data in array) {
        CGSize size = [[data.dict objectForKey:@"fileName"] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        size.height += 10;
        CGFloat cellHeight = size.height + 40;
        if (cellHeight < 60) {
            cellHeight = 60;
        }
        NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
        [heightArray addObject:dic];
    }
}

#pragma mark - ListTableViewCellDelegate

- (void)settingFunction:(NSIndexPath *)index{
    
    for (int i = 0; i < listArray.count; i++) {
        TrashData * data = listArray[i];
        if (data.function && i != index.section) {
            data.function = NO;
            ListTableViewCell * cell = (ListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
            [btn setImage:[UIImage imageNamed:@"chevron-with-circle-down.png"] forState:UIControlStateNormal];
            
            [listTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    TrashData * data = listArray[index.section];
    if (!data.function) {
        data.function = YES;
        [listTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:index.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        ListTableViewCell * cell = (ListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index.section]];
        UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
        [btn setImage:[UIImage imageNamed:@"chevron-with-circle-up.png"] forState:UIControlStateNormal];
    }else{
        data.function = NO;
        [listTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:index.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        ListTableViewCell * cell = (ListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index.section]];
        UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
        [btn setImage:[UIImage imageNamed:@"chevron-with-circle-down.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - ShareFunctionTableViewCellDelegate

- (void)quxiaoGongXuan{
    NSMutableArray * array = [NSMutableArray new];
    for (TrashData * data in listArray) {
        if (data.isSelected) {
            [array addObject:data];
        }
    }
    if (array.count == 0) {
        [Alert showHUDWihtTitle:@"没有选择内容"];
    }else{
        ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:nil message:@"取消共享后，该条共享记录将被删除，确定要取消共享吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        alertView.tag = 100;
    }
}

- (void)shareFunctions:(NSIndexPath *)indexPath{
    if ([_shareCategory isEqualToString:@"myshare"]) {
        if (_isDuoXuan) {
            [self quxiaoGongXuan];
        }else{
            ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:nil message:@"取消共享后，该条共享记录将被删除，确定要取消共享吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
            alertView.tag = 100;
            alertView.indexPath = indexPath;
        }
    }else{
        
        
    }
}

- (void)alertView:(ALAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.cancelButtonIndex != buttonIndex) {
        if ([_shareCategory isEqualToString:@"myshare"]) {
            NSMutableArray * array = [NSMutableArray new];
            if (_isDuoXuan) {
                for (TrashData * data in listArray) {
                    if (data.isSelected) {
                        [array addObject:data];
                    }
                }
            }else{
                TrashData * data = listArray[alertView.indexPath.section];
                [array addObject:data];
            }
            NSMutableString * str = [NSMutableString new];
            for (TrashData * data in array) {
                [str appendFormat:@"%@,", data.dict[@"fileId"]];
            }
            [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
            int status = [AFHTTPAPIClient checkNetworkStatus];
            if (status == 1 || status == 2) {
                NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", str];
                NSDictionary * dic = @{@"param":param, @"aslp":CANCEL_SHARE_FILE};
                
                [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                    [listTableView tableViewDidFinishedLoading];
                    if (error) {
                        NSLog(@"%@", error.description);
                    }else{
                        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        //                        NSLog(@"%@", dic);
                        NSLog(@"%@", [dic objectForKey:@"msg"]);
                        if ([dic[@"result"] isEqualToString:@"ok"]) {
                            [Alert showHUDWihtTitle:@"取消成功"];
                            NSMutableIndexSet * set = [NSMutableIndexSet indexSet];
                            for (TrashData * tdata in array) {
                                for (int i = 0; i < listArray.count; i++) {
                                    TrashData * data = listArray[i];
                                    if ([data.dict[@"fileId"] isEqualToString:tdata.dict[@"fileId"]]) {
                                        //                            [array addObject:data];
                                        [set addIndex:i];
                                        break;
                                    }
                                }
                            }
                            [listArray removeObjectsAtIndexes:set];
                            [self getCellHeight:listArray];
                            [listTableView beginUpdates];
                            [listTableView deleteSections:set withRowAnimation:UITableViewRowAnimationRight];
                            //                [listTableView reloadData];
                            [listTableView endUpdates];
                        }else{
                            [Alert showHUDWihtTitle:dic[@"msg"]];
                        }
                    }
                }];
            }else{
                [Alert showHUDWihtTitle:@"无网络"];
            }
        }
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
