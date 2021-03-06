//
//  DownloadingListViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/13.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DownloadingListViewController.h"
#import "FilesDownloadManager.h"
#import "Global.h"
#import "DownloadListTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SelectedTableViewCell.h"
#import "CommonHelper.h"
#import "CategoryData.h"
#import "DownloadFolderViewController.h"
#import "PictureBigShowViewController.h"
#import "DocumentsViewController.h"
#import "VideoShowViewController.h"
#import "VideoNavigationController.h"
#import "SQLCommand.h"
#import "UploadFailTableViewCell.h"
#import "FilesDownloadManager.h"
#import "FileCategory.h"

@interface DownloadingListViewController ()<UITableViewDataSource, UITableViewDelegate, UploadFailTableViewCellDelegate, DownloadDelegate>

@end

@implementation DownloadingListViewController{
    UITableView * listTableView;
    NSMutableArray * listArray;
    NSMutableArray * heiArray;
    NSMutableArray * secTitleArray;
    BOOL isDuoXuan;
    CGRect rectFrame;
    UIView * tabView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    listArray = [NSMutableArray new];
    heiArray = [NSMutableArray new];
    secTitleArray = [NSMutableArray arrayWithObjects:@"下载失败", @"正在下载", nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _fileData.fileName;
    rectFrame = self.view.frame;
    [FilesDownloadManager sharedFilesDownManage].downloadDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:DownloadDataChange object:nil];
    [self initSubViews];
    [self getdata];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [FilesDownloadManager sharedFilesDownManage].downloadDelegate = nil;
}

- (void)refresh:(NSNotification *)not{
    [self getdata];
}

- (void)getdata{
    [listArray removeAllObjects];
    secTitleArray = [NSMutableArray arrayWithObjects:@"下载失败", @"正在下载", nil];
    NSMutableArray * array = [NSMutableArray new];
    [array addObjectsFromArray:[[SQLCommand shareSQLCommand] getSubFilesUndownload:_fileData]];
    NSMutableArray * errorArray = [NSMutableArray new];
    NSMutableArray * downloadingArray = [NSMutableArray new];
    for (FileData * data in array) {
        if (![data.fileFormat isEqualToString:@"f"]) {
            if ([data.isHasDownload intValue] == 0) {
                [errorArray addObject:data];
            }else if ([data.isHasDownload intValue] == 1){
                [downloadingArray addObject:data];
            }
        }
    }
    [listArray addObject:errorArray];
    [listArray addObject:downloadingArray];
    for (int i = 0; i < listArray.count; i++) {
        NSMutableArray * secarray = listArray[i];
        if (secarray.count == 0) {
            [listArray removeObjectAtIndex:i];
            [secTitleArray removeObjectAtIndex:i];
            i = -1;
        }
    }
    [self getCellHeight:listArray];
    [listTableView reloadData];
}

- (void)getCellHeight:(NSArray *)array{
    [heiArray removeAllObjects];
    for (NSArray * secArray in array) {
        NSMutableArray * heiSecArray = [NSMutableArray new];
        for (FileData * data in secArray) {
            CGSize size = [data.fileName sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            size.height += 10;
            CGFloat cellHeight = size.height + 40;
            if (cellHeight < 60) {
                cellHeight = 60;
            }
            NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
            [heiSecArray addObject:dic];
        }
        [heiArray addObject:heiSecArray];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return listArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return secTitleArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = [heiArray[indexPath.section] objectAtIndex:indexPath.row];
    return [[dic objectForKey:@"cellheight"] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!isDuoXuan) {
        FileData * data = [listArray[indexPath.section] objectAtIndex:indexPath.row];
        NSDictionary * dic = [heiArray[indexPath.section] objectAtIndex:indexPath.row];
        NSString * secString = secTitleArray[indexPath.section];
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
            cell.indexPath = indexPath;
            [cell layoutSubview:dic];
            return cell;
        }else{
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
            cell.indexPath = indexPath;
            [cell layoutSubview:dic];
            return cell;
        }
    }else{
        SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        if (!cell) {
            cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
        }
        FileData * data = [listArray[indexPath.section] objectAtIndex:indexPath.row];
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
        NSDictionary * dic = [heiArray[indexPath.section] objectAtIndex:indexPath.row];
        [cell layoutSubview:dic];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData *data = [listArray[indexPath.section] objectAtIndex:indexPath.row];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData * data = [listArray[indexPath.section] objectAtIndex:indexPath.row];
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
            for (FileData * data in listArray[indexPath.section]) {
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
            vData.fileSize = data.fileSize;
            vData.fileFormat = data.fileFormat;
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
        NSMutableArray * secArray = listArray[indexPath.section];
        NSMutableArray * secHeiArray = [NSMutableArray arrayWithArray:heiArray[indexPath.section]];
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
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self shanchudata:delArray];
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

- (void)updateCellProgress:(ASIHTTPRequest *)request{
    FileData * fileData = [request.userInfo objectForKey:@"File"];
    for (int i = 0; i < secTitleArray.count; i++) {
        NSString * secstr = secTitleArray[i];
        NSMutableArray * array = listArray[i];
        NSMutableArray * secHeiArray = heiArray[i];
        if ([secstr isEqualToString:@"正在下载"]) {
            for (int j = 0; j < array.count; j++) {
                FileData * data = array[j];
                if ([fileData.fileID isEqualToString:data.fileID]) {
                    DownloadListTableViewCell * cell = (DownloadListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    if (j != 0) {
                        [secHeiArray exchangeObjectAtIndex:j withObjectAtIndex:0];
                        [array exchangeObjectAtIndex:j withObjectAtIndex:0];
                        [listTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    }
                    if (cell) {
                        cell.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [CommonHelper setLength:[fileData.hasDownloadSize longLongValue]], [CommonHelper setLength:[data.fileSize longLongValue]]];
                        cell.sizeLabel.text = [NSString stringWithFormat:@"%@/s", [CommonHelper setLength:fileData.uploadSpeed]];
                        //                        NSLog(@"%f", (float)data.uploadSize/(float)[data.fileSize longLongValue]);
                        [cell.functionButton setProgress:(float)[fileData.hasDownloadSize longLongValue]/(float)[data.fileSize longLongValue]];
                    }
                    [listTableView reloadData];
                }
            }
            
        }
    }
}

#pragma mark - UploadFailTableViewCellDelegate

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
