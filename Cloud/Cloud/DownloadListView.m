//
//  DownloadListView.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/13.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DownloadListView.h"
#import "Global.h"
#import "PullingRefreshTableView.h"
#import "SQLCommand.h"
#import "DownloadListTableViewCell.h"
#import "FileData.h"
#import "ListTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SelectedTableViewCell.h"
#import "FilesDownloadManager.h"
#import "UploadFailTableViewCell.h"
#import "UploadFinishTableViewCell.h"
#import "CommonHelper.h"
#import "DownloadListTableViewCell.h"
#import "CategoryData.h"
#import "PictureBigShowViewController.h"
#import "DocumentsViewController.h"
#import "VideoNavigationController.h"
#import "VideoShowViewController.h"
#import "DownloadFolderViewController.h"
#import "DownloadingListViewController.h"
#import "FileCategory.h"

@interface DownloadListView ()<PullingRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate, DownloadDelegate, UploadFailTableViewCellDelegate>

@end

@implementation DownloadListView{
    CGRect rectFrame;
    PullingRefreshTableView * listTableView;
    NSMutableArray * listArray;
    NSMutableArray * heightArray;
    NSMutableArray * headerArray;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        rectFrame = frame;
        _isDuoXuan = NO;
        heightArray = [NSMutableArray new];
        listArray = [NSMutableArray new];
        headerArray = [NSMutableArray new];
        [self initSubViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDatas) name:DownloadDataChange object:nil];
    }
    return self;
}

- (void)reloadDatas{
    [listArray removeAllObjects];
    [headerArray removeAllObjects];
    [FilesDownloadManager sharedFilesDownManage].downloadDelegate = self;
    NSMutableArray * lisarray = [NSMutableArray new];
    [lisarray addObjectsFromArray:[FilesDownloadManager sharedFilesDownManage].downloadListArray];
    for (NSMutableArray * array in lisarray) {
        for (int i = 0; i < array.count; i++) {
            FileData * fileData = array[i];
            if (![fileData.filePID isEqualToString:@""]) {
                [array removeObject:fileData];
                i = -1;
            }
        }
    }
    NSArray * nameArray = @[@"下载失败", @"正在下载", @"下载成功"];
    for (int i = 0; i < lisarray.count; i++) {
        NSArray * array = lisarray[i];
        if (array.count > 0) {
            [headerArray addObject:nameArray[i]];
            if ([nameArray[i] isEqualToString:@"正在上传"]) {
//                uploadingSec = headerArray.count - 1;
            }
            [listArray addObject:array];
        }
    }
    [self getCellHeight:listArray];
    [listTableView reloadData];
    
}

- (BOOL)duoxuan:(BOOL)isYes{
    return YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubViews{
    listArray = [NSMutableArray new];
    heightArray = [NSMutableArray new];
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height) pullingDelegate:self];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.hiddenAll = YES;
//    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:listTableView];
    if ([listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [listTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [listTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    listTableView.tableFooterView = [UIView new];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    rectFrame = self.frame;
    listTableView.frame = CGRectMake(0, 0, rectFrame.size.width, rectFrame.size.height);
    [listTableView reloadData];
}

//- (void)launchView{
//    [listArray removeAllObjects];
//    [listArray addObjectsFromArray:[[SQLCommand shareSQLCommand] getDownloadListData]];
//    [self getCellHeight:listArray];
//    [listTableView reloadData];
//}

- (void)getCellHeight:(NSArray *)array{
    [heightArray removeAllObjects];
    for (NSArray * sectionArray in array) {
        NSMutableArray * secHeightArray = [NSMutableArray new];
        for (FileData * data in sectionArray) {
            CGSize size = [data.fileName sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            size.height += 10;
            CGFloat cellHeight = size.height + 40;
            if (cellHeight < 60) {
                cellHeight = 60;
            }
            NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
            [secHeightArray addObject:dic];
        }
        [heightArray addObject:secHeightArray];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * array = listArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray * sectionArray = heightArray[indexPath.section];
    NSDictionary * dic = sectionArray[indexPath.row];
    return [[dic objectForKey:@"cellheight"] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return headerArray[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isDuoXuan) {
        NSString * secString = headerArray[indexPath.section];
        NSArray * array = listArray[indexPath.section];
        FileData * data = array[indexPath.row];
        //    NSString * path = NSHomeDirectory();
        //    NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumDownloadUrl];
        //    path = [path stringByAppendingPathComponent:pathstr];
        NSArray * hei = heightArray[indexPath.section];
        NSDictionary * dic = hei[indexPath.row];
        
        if ([secString isEqualToString:@"下载失败"]) {
            UploadFailTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FailCell"];
            if (!cell) {
                cell = [[UploadFailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FailCell" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.delegate = self;
            [cell.functionButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            switch ([FileCategory fileInformation:data.fileFormat]) {
                case FileCategoryPicture:{
                    NSString * lenstr = data.thumDownloadUrl;
                    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                    NSRange range = [typeStr rangeOfString:data.fileFormat];
                    
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
            cell.titleLabel.text = data.fileName;
            cell.detailLabel.text = @"下载失败";
            cell.indexPath = indexPath;
            [cell layoutSubview:dic];
            return cell;
        }else if ([secString isEqualToString:@"正在下载"]){
            
            
            DownloadListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
            if (!cell) {
                cell = [[DownloadListTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Identifier" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.fileInfo = data;
            switch ([FileCategory fileInformation:data.fileFormat]) {
                case FileCategoryPicture:{
                    NSString * lenstr = data.thumDownloadUrl;
                    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                    NSRange range = [typeStr rangeOfString:data.fileFormat];
                    
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
            
            //        cell.headPhoto.image = [UIImage imageWithContentsOfFile:path];
            cell.titleLabel.text = data.fileName;
            if ([data.downloadStatus intValue] == 1) {
                cell.functionButton.selected = NO;
                cell.timeLabel.text = @"暂停";
                cell.sizeLabel.text = @"0.0b/s";
            }else if ([data.downloadStatus intValue] == 0){
                cell.timeLabel.text = @"等待中......";
                cell.functionButton.selected == YES;
            }
            
            cell.indexPath = indexPath;
            //        cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.updateTime];
            //        cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
            [cell layoutSubview:dic];
            
            //    cell.textLabel.text = [NSString stringWithFormat:@"%@", fileData.isHasDownload];
            
            return cell;
        }else{
            UploadFinishTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"finishCell"];
            if (!cell) {
                cell = [[UploadFinishTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"finishCell" withViewFrame:tableView.frame];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch ([FileCategory fileInformation:data.fileFormat]) {
                case FileCategoryPicture:{
                    NSString * lenstr = data.thumDownloadUrl;
                    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                    NSRange range = [typeStr rangeOfString:data.fileFormat];
                    
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
            
            //        cell.headPhoto.image = [UIImage imageWithContentsOfFile:path];
            cell.titleLabel.text = data.fileName;
            cell.indexPath = indexPath;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.updateTime];
            if (![data.fileFormat isEqualToString:@"f"]) {
                cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
            }else
                cell.sizeLabel.text = @"";
            
            [cell layoutSubview:dic];
            return cell;
        }
    }else{
//        NSString * secString = headerArray[indexPath.section];
        NSArray * array = listArray[indexPath.section];
        FileData * data = array[indexPath.row];
        //    NSString * path = NSHomeDirectory();
        //    NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", data.thumDownloadUrl];
        //    path = [path stringByAppendingPathComponent:pathstr];
        NSArray * hei = heightArray[indexPath.section];
        NSDictionary * dic = hei[indexPath.row];
        
        SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        if (!cell) {
            cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
        }
        
        switch ([FileCategory fileInformation:data.fileFormat]) {
            case FileCategoryPicture:{
                NSString * lenstr = data.thumDownloadUrl;
                NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
                NSRange range = [typeStr rangeOfString:data.fileFormat];
                
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
        
        cell.indexPath = indexPath;
        cell.titleLabel.text = data.fileName;
        cell.timeLabel.text = [NSString stringWithFormat:@"%@", data.updateTime];
        cell.sizeLabel.text = [CommonHelper setLength:[data.fileSize floatValue]];
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
    if (_isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSArray * array = listArray[indexPath.section];
        FileData * data = array[indexPath.row];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        NSString * secString = headerArray[indexPath.section];
        if ([secString isEqualToString:@"下载成功"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSArray * lsarray = listArray[indexPath.section];
            FileData * data = lsarray[indexPath.row];
            NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
            NSMutableString * categoryStr = [NSMutableString new];
            if ([data.fileFormat isEqualToString:@"f"]) {
                NSString * secString = headerArray[indexPath.section];
                if ([secString isEqualToString:@"正在下载"]){
                    DownloadingListViewController * downloadingVC = [[DownloadingListViewController alloc] init];
                    UIViewController * con = (UIViewController *)_parentVC;
                    downloadingVC.fileData = data;
                    downloadingVC.hidesBottomBarWhenPushed = YES;
                    [con.navigationController pushViewController:downloadingVC animated:YES];
                }else{
                    DownloadFolderViewController * downloadFolderVC = [[DownloadFolderViewController alloc] init];
                    UIViewController * con = (UIViewController *)_parentVC;
                    downloadFolderVC.fileData = data;
                    downloadFolderVC.hidesBottomBarWhenPushed = YES;
                    [con.navigationController pushViewController:downloadFolderVC animated:YES];
                }
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
                for (FileData * data in lsarray) {
                    NSRange picRange = [categoryStr rangeOfString:data.fileFormat];
                    if (picRange.length != 0 && ![data.fileFormat isEqualToString:@"f"]) {
                        [picArray addObject:data];
                    }
                }
                
                PictureBigShowViewController * picVC = [[PictureBigShowViewController alloc] init];
                picVC.isDownload = YES;
//                picVC.isUpload = YES;
                picVC.pictureArray = picArray;
                picVC.fileData = data;
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
                dvc.isDownload = YES;
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
                vData.fileSize = data.fileSize;
                vData.fileFormat = data.fileFormat;
                dvc.videoData = vData;
                dvc.hidesBottomBarWhenPushed = YES;
                UIViewController * con = (UIViewController *)_parentVC;
                [con.navigationController presentViewController:vnav animated:NO completion:nil];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isDuoXuan) {
        return YES;
    }else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // NSLog(@"row=%d",row);
        NSMutableArray * secArray = listArray[indexPath.section];
        NSMutableArray * secHeiArray = [NSMutableArray arrayWithArray:heightArray[indexPath.section]];
        FileData * fileData = secArray[indexPath.row];
        NSMutableArray * delArray = [NSMutableArray new];
        if ([fileData.fileFormat isEqualToString:@"f"]) {
            [delArray addObject:fileData];
            [delArray addObjectsFromArray:[[SQLCommand shareSQLCommand] getDeleteDownloadData:fileData.fileID]];
        }else{
            [delArray addObject:fileData];
        }
        [secArray removeObjectAtIndex:indexPath.row];
        [secHeiArray removeObjectAtIndex:indexPath.row];
        //        [listArray insertObject:@{@"name":dic[@"name"], @"list":secArray} atIndex:indexPath.section];
        //        [heightArray removeObjectAtIndex:indexPath.section];
        //        [heightArray insertObject:secHeiArray atIndex:indexPath.section];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationMiddle];
        [self shanchudata:delArray];
        
//        FilesDownloadManager *filedownmanage=[FilesDownloadManager sharedFilesDownManage];
//        [filedownmanage deleteRequest:fileData];
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        NSString * path= [CommonHelper getTargetPathWithBasepath:filedownmanage.basePath subpath:filedownmanage.targetSubPath];
//        path = [path stringByAppendingPathComponent:fileData.fileName];
//        if ([fileManager fileExistsAtPath:path]) {
//            
//        }
//        [[SQLCommand shareSQLCommand] deleteDownloadData:@[fileData]];
        
    }
}

- (void)shanchudata:(NSMutableArray *)array{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[SQLCommand shareSQLCommand] deleteDownloadData:array];
        FilesDownloadManager *filedownmanage=[FilesDownloadManager sharedFilesDownManage];
        for (int i = 0; i < array.count; i++) {
            FileData * data = array[i];
            [filedownmanage deleteRequest:data];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSString * path= [CommonHelper getTargetPathWithBasepath:filedownmanage.basePath subpath:filedownmanage.targetSubPath];
            path = [path stringByAppendingPathComponent:data.fileName];
            if ([fileManager fileExistsAtPath:path]) {
                [fileManager removeItemAtPath:path error:nil];
            }
            path = [CommonHelper getTempFolderPathWithBasepath:filedownmanage.basePath];
            path = [path stringByAppendingPathComponent: data.fileName];
            if ([fileManager fileExistsAtPath:path]) {
                [fileManager removeItemAtPath:path error:nil];
            }
        }
//        [[SQLCommand shareSQLCommand] deleteDownloadData:@[array[0]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [listTableView reloadData];
        });
        
    });
    
}

- (void)duoxuanShanchu{
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"确定删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

-(void)removeASIRequst:(ASIHTTPRequest*)req{
    
}

#pragma mark - ListTableViewCellDelegate

- (void)settingFunction:(NSIndexPath *)index{
    NSDictionary * secdic = listArray[index.section];
    NSMutableArray * heiArray = [NSMutableArray arrayWithArray:heightArray[index.section]];
    if ([secdic[@"name"] isEqualToString:@"下载成功"]) {
        NSArray * array = secdic[@"list"];
        for (int i = 0; i < array.count; i++) {
            FileData * data = array[i];
            if (i != index.row && data.function) {
                data.function = NO;
//                NSDictionary * dict = heiArray[index.row];
            }
        }
        FileData * data = array[index.row];
        if (data.function) {
            data.function = NO;
            
        }else{
            data.function = YES;
            
        }
    }
}

#pragma mark - DownloadDelegate

- (void)updateCellProgress:(ASIHTTPRequest *)request{
    FileData * fileData = [request.userInfo objectForKey:@"File"];
    FileData * downloadData = [request.userInfo objectForKey:@"File"];
    if (fileData.filePID.length > 0) {
        fileData = [[SQLCommand shareSQLCommand] getShangchengFolder:fileData];
    }
    for (int i = 0; i < headerArray.count; i++) {
        NSString * secstr = headerArray[i];
        NSMutableArray * array = listArray[i];
        NSMutableArray * heiArray = heightArray[i];
        if ([secstr isEqualToString:@"正在下载"]) {
            for (int j = 0; j < array.count; j++) {
                FileData * data = array[j];
                if ([fileData.fileID isEqualToString:data.fileID]) {
                    DownloadListTableViewCell * cell = (DownloadListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    if (j != 0) {
                        [heiArray exchangeObjectAtIndex:j withObjectAtIndex:0];
                        [array exchangeObjectAtIndex:j withObjectAtIndex:0];
                        [listTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    }
                    if (cell) {
                        cell.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [CommonHelper setLength:[downloadData.hasDownloadSize longLongValue]], [CommonHelper setLength:[downloadData.fileSize longLongValue]]];
                        cell.sizeLabel.text = [NSString stringWithFormat:@"%@/s", [CommonHelper setLength:downloadData.uploadSpeed]];
                        [cell.functionButton setProgress:(float)[downloadData.hasDownloadSize longLongValue]/(float)[downloadData.fileSize longLongValue]];
                    }
                }
            }
            
        }
    }
}

- (void)shangchuan:(NSIndexPath *)indexPath{
    NSArray * array = listArray[indexPath.section];
    FileData * data = array[indexPath.row];
    data.isHasDownload = @(1);
    [[SQLCommand shareSQLCommand] updateDownloadData:@[data]];
    [[FilesDownloadManager sharedFilesDownManage] startRequest:data];
//    [upNetwork getUploadData];
//    [upNetwork startUpload];
//    [self reloadDatas];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSMutableArray * selectArray = [NSMutableArray new];
        for (NSMutableArray * array in listArray) {
            for (int i = 0; i < array.count; i++) {
                FileData * data = array[i];
                if (data.isSelected) {
                    [selectArray addObject:data];
                    [array removeObject:data];
                    i = -1;
                }
            }
        }
        NSMutableArray * dicengArray = [NSMutableArray new];
        for (int i = 0; i < selectArray.count; i++) {
            FileData * data = selectArray[i];
            if ([data.fileFormat isEqualToString:@"f"]) {
                [dicengArray addObjectsFromArray:[[SQLCommand shareSQLCommand] getDeleteDownloadData:data.fileID]];
            }
        }
        [selectArray addObjectsFromArray:dicengArray];
        [self shanchudata:selectArray];
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
