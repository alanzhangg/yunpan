//
//  CategoryView.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "CategoryView.h"
#import "ListTableViewCell.h"
#import "FileData.h"
#import "UIImageView+WebCache.h"
#import "ListFunctionTableViewCell.h"
#import "RenameViewController.h"
#import "MoveFolderViewController.h"
#import "ALAlertView.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "SQLCommand.h"
#import "SearchResultTableViewCell.h"
#import "CategoryData.h"
#import "PictureBigShowViewController.h"
#import "SelectedTableViewCell.h"
#import "ShareToNetworkViewController.h"
#import "DocumentsViewController.h"
#import "FilesDownloadManager.h"
#import "VideoShowViewController.h"
#import "VideoNavigationController.h"
#import "VideoData.h"
#import "FileCategory.h"

@interface CategoryView ()<PullingRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, ListTableViewCellDelegate, ListFunctionTableViewCellDelegate>

@end

@implementation CategoryView{
    CGRect rectFrame;
    NSMutableArray * heightArray;
    NSMutableArray * filterData;
    NSMutableArray * filterHeightArray;
}

- (id)initWithFrame:(CGRect)frame pullingDelegate:(id<PullingRefreshTableViewDelegate>)aPullingDelegate{
    if (self = [super initWithFrame:frame pullingDelegate:aPullingDelegate]) {
        rectFrame = frame;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.delegate = self;
        self.dataSource = self;
        self.headerOnly = YES;
        self.pullingDelegate = self;
        heightArray = [NSMutableArray new];
        filterData = [NSMutableArray new];
        filterHeightArray = [NSMutableArray new];
//        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, 44)];
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, rectFrame.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [_searchBar addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectFrame.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [_searchBar addSubview:lineView];
    
    UIViewController * con = (UIViewController *)_allDelegate;
    _displayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:con];
    _displayController.delegate = self;
    _displayController.searchResultsDelegate = self;
    _displayController.searchResultsDataSource = self;
    _displayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableHeaderView = _searchBar;
    
    
    //    searchController.displaysSearchBarInNavigationBar = NO;
    //    searchBar.frame = CGRectMake(70, 0, frame.size.width - 80, 44);
    
}

- (void)reloadDatas{
    [heightArray removeAllObjects];
    [self getCellHeight:_listArray];
    [self reloadData];
}

- (NSArray *)getHeight:(NSArray *)array{
    NSMutableArray * heiArray = [NSMutableArray new];
    for (FileData * data in array) {
        CGSize size = [data.fileName sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        size.height += 10;
        CGFloat cellHeight = size.height + 40;
        if (cellHeight < 60) {
            cellHeight = 60;
        }
        NSDictionary * dic = @{@"cellheight":@(cellHeight), @"titleheight": @(size.height)};
        [heiArray addObject:dic];
    }
    return heiArray;
}

- (void)getFilterHeight:(NSArray *)array{
    [filterHeightArray removeAllObjects];
    [filterHeightArray addObjectsFromArray:[self getHeight:array]];
}

- (void)getCellHeight:(NSArray *)array{
    [heightArray removeAllObjects];
    [heightArray addObjectsFromArray:[self getHeight:array]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self getSearchTableViewLabel:@"点击［搜索］按钮开始搜索"];
    [filterData removeAllObjects];
    [_displayController.searchResultsTableView reloadData];
}

- (void)getSearchTableViewLabel:(NSString *)str{
    NSArray * array = [_displayController.searchResultsTableView subviews];
    NSLog(@"%s. %@", __func__, array);
    if (array.count > 1) {
        for (int i = 0; i < array.count; i++) {
            if ([array[i] isKindOfClass:[UILabel class]]) {
                UILabel * label = array[i];
                label.text = str;
                label.textColor = [UIColor blackColor];
            }
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBars{
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self];
    [hud setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [_displayController.searchResultsTableView addSubview:hud];
    [hud show:YES];
    
    [filterData removeAllObjects];
    [_displayController.searchResultsTableView reloadData];
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"%@\",\"dirId\":\"\",\"searchValue\":\"%@\"}", self.categoryName, searchBars.text];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_BY_SEARCH};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
                [Alert showHUDWihtTitle:error.localizedDescription];
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", dic);
                NSLog(@"%@", [dic objectForKey:@"msg"]);
                if ([dic[@"result"] isEqualToString:@"ok"]) {
                    dic = [dic objectForKey:@"data"];
                    NSArray * array = [dic objectForKey:@"fileList"];
                    if (array) {
                        
                        for (NSDictionary * dict in array) {
                            FileData * data = [[FileData alloc] init];
                            [data transformDictionary:dict];
                            [filterData addObject:data];
                        }
                    }
                    [self getFilterHeight:filterData];
                    if (filterData.count == 0) {
                        [self getSearchTableViewLabel:@"暂无数据"];
                    }
                    [_displayController.searchResultsTableView reloadData];
                }else{
                    [Alert showHUDWihtTitle:dic[@"msg"]];
                }
                
                // NSArray * array = [dic objectForKey:@"fileList"];
                
            }
            [hud hide:YES];
            [hud removeFromSuperview];
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    self.frame = CGRectMake(0, 20, rectFrame.size.width, rectFrame.size.height + 44);
    return YES;
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self changeFrame];
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
//    [self changeFrame];
//}

- (void)changeFrame{
    self.frame = CGRectMake(0, 64, rectFrame.size.width, rectFrame.size.height);
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self) {
        return _listArray.count;
    }else{
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self) {
        FileData * data = _listArray[section];
        if (data.function) {
            return 2;
        }else
            return 1;
    }else
        return filterData.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSDictionary * dic = heightArray[indexPath.section];
        return [[dic objectForKey:@"cellheight"] floatValue];
    }else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self) {
        if (!_isDuoXuan) {
            if (indexPath.row == 0) {
                ListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
                if (!cell) {
                    cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" withViewFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.funcDelegate = self;
                }
                cell.indexPath = indexPath;
                FileData * data = _listArray[indexPath.section];
                cell.titleLabel.text = data.fileName;
                cell.timeLabel.text = data.updateTime;
                if (![data.fileFormat isEqualToString:@"f"]) {
                    cell.sizeLabel.text = [cell setLength:[data.fileSize floatValue]];
                }else{
                    cell.sizeLabel.text = nil;
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
                
                [cell layoutSubview:heightArray[indexPath.section]];
                //    FileData * data = listArray[indexPath.section];
                //    cell.textLabel.text = data.fileName;
                return cell;
            }else{
                ListFunctionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"funcCell"];
                if (!cell) {
                    cell = [[ListFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"funcCell" withFrame:tableView.frame];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.allDelegate = self;
                }
                cell.indexPath = indexPath;
                
                return cell;
            }
        }else{
            SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
            if (!cell) {
                cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
            }
            cell.indexPath = indexPath;
            FileData * data = _listArray[indexPath.section];
            cell.titleLabel.text = data.fileName;
            cell.timeLabel.text = data.updateTime;
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
            
            if (!data.isSelected) {
                cell.selectedImageView.image = [UIImage imageNamed:@"check-box-outline-blank.png"];
            }else{
                cell.selectedImageView.image = [UIImage imageNamed:@"check-box.png"];
            }
            
            [cell layoutSubview:heightArray[indexPath.section]];
            
            return cell;
        }
        
    }else{
        SearchResultTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"searchcaCell"];
        if (!cell) {
            cell = [[SearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchcaCell" withViewFrame:tableView.frame];
        }
        cell.indexPath = indexPath;
        FileData * data = filterData[indexPath.row];
        cell.titleLabel.text = data.fileName;
        cell.timeLabel.text = data.createTime;
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
        }else
            cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
        
        [cell layoutSubview:heightArray[indexPath.section]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData * data = _listArray[indexPath.section];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        FileData * data;
        NSArray * selctArray;
        if (tableView == self) {
            data = _listArray[indexPath.section];
            selctArray = _listArray;
        }else{
            selctArray = filterData;
            data = filterData[indexPath.row];
        }
        NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
        NSMutableString * categoryStr = [NSMutableString new];
//        if ([data.fileFormat isEqualToString:@"f"]) {
//            if (_allDelegate && [_allDelegate respondsToSelector:@selector(openFolder:)]) {
//                [_allDelegate openFolder:data];
//            }
//            return;
//        }
        
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
            for (FileData * data in selctArray) {
                NSRange picRange = [categoryStr rangeOfString:data.fileFormat];
                //            NSLog(@"%@  %@   %d", categoryStr, data.fileFormat, picRange.length);
                if (picRange.length != 0 && ![data.fileFormat isEqualToString:@"f"]) {
                    [picArray addObject:data];
                }
            }
            
            PictureBigShowViewController * picVC = [[PictureBigShowViewController alloc] init];
            picVC.pictureArray = picArray;
            picVC.fileData = data;
            UIViewController * con = (UIViewController *)_allDelegate;
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
            UIViewController * con = (UIViewController *)_allDelegate;
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
            UIViewController * con = (UIViewController *)_allDelegate;
            [con.navigationController presentViewController:vnav animated:NO completion:nil];
        }
    }
}


#pragma mark - ListTableViewCellDelegate

- (void)settingFunction:(NSIndexPath *)index{
    for (int i = 0; i < _listArray.count; i++) {
        FileData * data = _listArray[i];
        if (data.function && i != index.section) {
            data.function = NO;
            ListTableViewCell * cell = (ListTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
            [btn setImage:[UIImage imageNamed:@"chevron-with-circle-down.png"] forState:UIControlStateNormal];
            
            [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    FileData * data = _listArray[index.section];
    if (!data.function) {
        data.function = YES;
        [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:index.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        ListTableViewCell * cell = (ListTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index.section]];
        UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
        [btn setImage:[UIImage imageNamed:@"chevron-with-circle-up.png"] forState:UIControlStateNormal];
    }else{
        data.function = NO;
        [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:index.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        ListTableViewCell * cell = (ListTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index.section]];
        UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
        [btn setImage:[UIImage imageNamed:@"chevron-with-circle-down.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - ListFunctionTableViewCellDelegate

- (void)functionAction:(NSIndexPath *)indexPath withTag:(NSInteger)tag{
    
    NSLog(@"%ld", (long)tag);
    
    if (tag == 100) {
        FileData * data = _listArray[indexPath.section];
        
        if ([[SQLCommand shareSQLCommand] checkIsAddDownloadList:data.fileID]) {
            [Alert showHUDWihtTitle:@"已在下载队列"];
            return;
        }
        data.filePID = @"";
        data.isHasDownload = @(1);
        data.hasDownloadSize = @"0";
        data.downloadStatus = @(0);
        data.downloadFolder = @"0";
        data.downloadQuantity = @(0);
        NSMutableArray * downArray = [NSMutableArray new];
        [downArray addObject:data];
        if (![data.fileFormat isEqualToString:@"f"]) {
            [[SQLCommand shareSQLCommand] insertDownloadData:downArray];
        }else{
            NSArray * array = [[SQLCommand shareSQLCommand] getCloudTableFolderData:data.fileID];
            int quantity = 0;
            for (FileData * downdata in array) {
                if ([downdata.fileFormat isEqualToString:@"f"]) {
                    downdata.isHasDownload = @(2);
                }else
                    downdata.isHasDownload = @(1);
                
                downdata.hasDownloadSize = @"0";
                downdata.downloadStatus = @(0);
                downdata.downloadFolder = @"0";
                downdata.downloadQuantity = @(0);
                if (![downdata.fileFormat isEqualToString:@"f"]) {
                    quantity++;
                }
            }
            if (array.count <= 0) {
                data.isHasDownload = @(2);
            }
            data.downloadQuantity = @(quantity);
            [downArray addObjectsFromArray:array];
            [[SQLCommand shareSQLCommand] insertDownloadData:downArray];
        }
        
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            
            [[FilesDownloadManager sharedFilesDownManage] getSqlData];
            [Alert showHUDWihtTitle:@"已加入下载队列"];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"网络不通，请检查网路"
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles: nil];
            [alertView show];
        }
    }else if (tag == 200){
        FileData * data = _listArray[indexPath.section];
        [self removeFiles:@[data]];
        
    }else if (tag == 300){
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RenameViewController * renameCon = (RenameViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"renameCon"];
        renameCon.fileData = _listArray[indexPath.section];
        NormalNavigationController * nav = [[NormalNavigationController alloc] initWithRootViewController:renameCon];
        renameCon.block = ^(){
            [self reloadData];
        };
        UIViewController * con = (UIViewController *)_allDelegate;
        [con presentViewController:nav animated:YES completion:^{
            
        }];
        
    }else if (tag == 400){
        
        ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:@"删除后可以在回收站恢复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        alertView.indexPath = indexPath;
        alertView.tag = 400;
        
    }else if (tag == 500){
        FileData * data = _listArray[indexPath.section];
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareToNetworkViewController * shareNet = (ShareToNetworkViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"shareToNetwork"];
        shareNet.fileData = data;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:shareNet];
        UIViewController * con = (UIViewController *)_allDelegate;
        [con presentViewController:nav animated:YES completion:^{
            
        }];
    }else{
        
    }
}

- (void)removeFiles:(NSArray *)removeFileData{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoveFolderViewController * folderVC = (MoveFolderViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"moveFolder"];
    folderVC.folderId = @"";
    folderVC.moveFileDataArray = removeFileData;
    __weak CategoryView * weakSelf = self;
    folderVC.block = ^(){
        [weakSelf reloadDatas];
    };
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:folderVC];
    UIViewController * con = (UIViewController *)_allDelegate;
    [con presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(ALAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 400 && alertView.cancelButtonIndex != buttonIndex) {
        FileData * fileData = _listArray[alertView.indexPath.section];
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", fileData.fileID];
            NSDictionary * dic = @{@"param":param, @"aslp":DELETE_FILE};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                    [Alert showHUDWihtTitle:error.localizedDescription];
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //                    dic = [dic objectForKey:@"data"];
                    if ([dic[@"result"] isEqualToString:@"ok"]) {
                        NSMutableArray * array = [[NSMutableArray alloc] initWithArray:_listArray];
                        [array removeObject:fileData];
                        _listArray = array;
                        [self deleteSections:[NSIndexSet indexSetWithIndex:alertView.indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [[SQLCommand shareSQLCommand] deleteFileData:@[fileData]];
                    }else{
                        [Alert showHUDWihtTitle:[dic objectForKey:@"msg"]];
                    }
                }
                [self tableViewDidFinishedLoading];
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
        
    }
}

#pragma mark - forDuoXuan

- (void)downloadFiles{
    NSMutableArray * array = [NSMutableArray new];
    for (FileData * data in _listArray) {
        if (data.isSelected) {
            [array addObject:data];
        }
    }
    if (array.count == 0) {
        [Alert showHUDWihtTitle:@"没有选中的文件"];
        return;
    }
    
    for (FileData * data in array) {
        if ([[SQLCommand shareSQLCommand] checkIsAddDownloadList:data.fileID]) {
            [Alert showHUDWihtTitle:@"已在下载队列"];
            return;
        }
        data.filePID = @"";
        data.isHasDownload = @(1);
        data.hasDownloadSize = @"0";
        data.downloadStatus = @(0);
        data.downloadFolder = @"0";
        data.downloadQuantity = @(0);
        NSMutableArray * downArray = [NSMutableArray new];
        [downArray addObject:data];
        if (![data.fileFormat isEqualToString:@"f"]) {
            [[SQLCommand shareSQLCommand] insertDownloadData:downArray];
        }else{
            NSArray * array = [[SQLCommand shareSQLCommand] getCloudTableFolderData:data.fileID];
            int quantity = 0;
            for (FileData * downdata in array) {
                if ([downdata.fileFormat isEqualToString:@"f"]) {
                    downdata.isHasDownload = @(2);
                }else
                    downdata.isHasDownload = @(1);
                
                downdata.hasDownloadSize = @"0";
                downdata.downloadStatus = @(0);
                downdata.downloadFolder = @"0";
                downdata.downloadQuantity = @(0);
                if (![downdata.fileFormat isEqualToString:@"f"]) {
                    quantity++;
                }
            }
            if (array.count <= 0) {
                data.isHasDownload = @(2);
            }
            data.downloadQuantity = @(quantity);
            [downArray addObjectsFromArray:array];
            [[SQLCommand shareSQLCommand] insertDownloadData:downArray];
        }
    }
    if (array.count > 0) {
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            
            [[FilesDownloadManager sharedFilesDownManage] startRequest:nil];
            [Alert showHUDWihtTitle:@"已加入下载队列"];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"网络不通，请检查网路"
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles: nil];
            [alertView show];
        }
    }
}

- (void)yongYuQuanXuan:(BOOL)isSelect{
    for (FileData * data in _listArray) {
        data.isSelected = isSelect;
    }
    [self reloadData];
}

- (void)shanchuWenjian:(NSIndexPath *)indexPath{
    ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:@"删除后可以在回收站恢复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView.indexPath = indexPath;
    alertView.tag = 400;
}

- (void)removeDuoXuanFiles{
    NSMutableArray * array = [NSMutableArray new];
    for (FileData * data in _listArray) {
        if (data.isSelected) {
            [array addObject:data];
        }
    }
    if (array.count == 0) {
        [Alert showHUDWihtTitle:@"没有选中的文件"];
        return;
    }
    [self removeFiles:array];
}

@end
