//
//  FolderViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/7.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "FolderViewController.h"
#import "Global.h"
#import "PullingRefreshTableView.h"
#import "SQLCommand.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "ListFunctionTableViewCell.h"
#import "ListTableViewCell.h"
#import "FileData.h"
#import "RenameViewController.h"
#import "UIImageView+WebCache.h"
#import "SearchResultTableViewCell.h"
#import "AppDelegate.h"
#import "SelectedTableViewCell.h"
#import "CategoryData.h"
#import "PictureBigShowViewController.h"
#import "DocumentsViewController.h"
#import "MoveFolderViewController.h"
#import "ALAlertView.h"
#import "ShareToNetworkViewController.h"
#import "FileCategory.h"
#import "FilesDownloadManager.h"

@interface FolderViewController ()<PullingRefreshTableViewDelegate , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, ListFunctionTableViewCellDelegate, ListTableViewCellDelegate>

@end

@implementation FolderViewController{
    CGRect rectFrame;
    NSMutableArray * listArray;
    NSMutableArray * heightArray;
    PullingRefreshTableView * listTableView;
    UISearchBar * searchBar;
    UISearchDisplayController * searchController;
    NSMutableArray * filterData;
    NSMutableArray * filterHeightArray;
    UIView * tabView;
    BOOL isDuoxuan;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _fileDta.fileName;
    self.automaticallyAdjustsScrollViewInsets = NO;
    listArray = [NSMutableArray new];
    heightArray = [NSMutableArray new];
    filterData = [NSMutableArray new];
    filterHeightArray = [NSMutableArray new];
    rectFrame = self.view.frame;
    [self initSubViews];
    [self reloadDataList];
    [self getNetworkingData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadDataList];
}

- (void)getData{
    [listArray removeAllObjects];
    [listArray addObjectsFromArray:[[SQLCommand shareSQLCommand] getFolderData:_fileDta.fileID]];
}

- (void)reloadDataList{
    [self getData];
    [self getCellHeight:listArray];
    [listTableView reloadData];
}

- (NSArray *)getHeight:(NSArray *)array{
    NSMutableArray * heiArray = [NSMutableArray new];
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

- (void)setHeadViews:(CGRect)frame{
    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    headView.backgroundColor = [UIColor clearColor];
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, frame.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [headView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [headView addSubview:lineView];
    
    UIView * verLineView = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 1, 43)];
    verLineView.backgroundColor = RGB(224, 224, 224);
    [headView addSubview:verLineView];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(70, 0, frame.size.width - 80, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [headView addSubview:searchBar];
    
    UIButton * addFolderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFolderButton.frame = CGRectMake(10, 0, 44, 44);
    [addFolderButton setImage:[UIImage imageNamed:@"folder-add.png"] forState:UIControlStateNormal];
    [headView addSubview:addFolderButton];
    [addFolderButton addTarget:self action:@selector(addNewFolder:) forControlEvents:UIControlEventTouchUpInside];
    
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    searchController.displaysSearchBarInNavigationBar = NO;
    //    searchBar.frame = CGRectMake(70, 0, frame.size.width - 80, 44);
    [headView addSubview:searchBar];
    listTableView.tableHeaderView = headView;
    
}

- (void)addNewFolder:(UIButton *)sender{
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RenameViewController * renameCon = (RenameViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"renameCon"];
    renameCon.isXinjian = YES;
    renameCon.fileData = _fileDta;
    NormalNavigationController * nav = [[NormalNavigationController alloc] initWithRootViewController:renameCon];
    __weak FolderViewController * weakSelf = self;
    renameCon.block = ^(){
        __strong FolderViewController * strSeld = weakSelf;
        [strSeld getNetworkingData];
        
    };
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)getNetworkingData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"allfile\",\"dirId\":\"%@\",\"searchValue\":\"\"}", _fileDta.fileID];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_BY_SEARCH};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
                [Alert showHUDWihtTitle:error.localizedDescription];
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", dic);
//                NSLog(@"%@", [dic objectForKey:@"msg"]);
                if ([dic[@"result"] isEqualToString:@"ok"]) {
                    dic = [dic objectForKey:@"data"];
                    NSArray * array = [dic objectForKey:@"fileList"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if (array) {
                            [SQLCommand updatedata:array withlistArray:listArray];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self reloadDataList];
                        });
                    });
                    
                }else{
                    [Alert showHUDWihtTitle:dic[@"msg"]];
                }
            }
            [listTableView tableViewDidFinishedLoading];
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

- (void)initSubViews{
    
    float statusBar = 0;
    if (IS_IOS7) {
        statusBar = 64;
    }
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 44);
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(duoxuan:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, statusBar, rectFrame.size.width, rectFrame.size.height - statusBar - 49) pullingDelegate:self];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    [self.view addSubview:listTableView];
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTableView.headerOnly = YES;
    [self setHeadViews:rectFrame];
}

- (void)duoxuan:(UIButton *)sender{
    
    CGRect rect = self.view.frame;
    if (!tabView) {
        tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, 49)];
        tabView.backgroundColor = RGB(53, 53, 53);
        
        NSArray * array = @[@"下载", @"移动", @"删除"];
        for (int i = 0; i < 3; i++) {
            UIButton * returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            returnBtn.frame = CGRectMake(5 + 5 * (i + 1) + (rect.size.width - 35)/3 * i , 10, (rect.size.width - 35)/3, 29);
            returnBtn.backgroundColor = RGB(78, 78, 78);
            returnBtn.layer.masksToBounds = YES;
            returnBtn.layer.cornerRadius = 2;
            [returnBtn setTitle:array[i] forState:UIControlStateNormal];
            returnBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [returnBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
            [returnBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 2) {
                returnBtn.backgroundColor = RGB(132, 53, 47);
            }
            returnBtn.tag = 100 + i;
            [tabView addSubview:returnBtn];
        }
        
    }else{
        
    }
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UITabBarController * tabCon = (UITabBarController *)dele.window.rootViewController;
    
    if (tabView.frame.origin.y >= 49) {
        [UIView animateWithDuration:0.1 animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
        CGRect rect = tabView.frame;
        rect.origin.y = 0;
        tabView.frame = rect;
        [tabCon.tabBar addSubview:tabView];
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        
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
        
        [self quxiaoDuoXuan:(sender)];
    }
    isDuoxuan = !isDuoxuan;
    [listTableView reloadData];
}

- (void)deleteOrReturn:(UIButton *)sender{
    if (sender.tag == 100) {
        [self downloadFiles];
    }else if (sender.tag == 101) {
        [self removeDuoXuanFiles];
    }else if (sender.tag == 102){
        [self shanchuWenjian:nil];
    }

}

- (void)quanxuan:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"全选"]) {
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
        for (FileData * data in listArray) {
            data.isSelected = YES;
        }
    }else if([sender.currentTitle isEqualToString:@"全不选"]) {
        for (FileData * data in listArray) {
            data.isSelected = NO;
        }
        [sender setTitle:@"全选" forState:UIControlStateNormal];
    }
    [listTableView reloadData];
}

- (void)quxiaoDuoXuan:(UIButton *)sender{
    [UIView animateWithDuration:0.1 animations:^{
        
        
    } completion:^(BOOL finished) {
        
    }];
    self.navigationItem.title = @"共享";
    self.navigationItem.leftBarButtonItem = nil;
    [sender setTitle:@"多选" forState:UIControlStateNormal];
    CGRect rect = tabView.frame;
    self.navigationItem.title = _fileDta.fileName;
    rect.origin.y = 49;
    tabView.frame = rect;
    [tabView removeFromSuperview];
    
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != searchController.searchResultsTableView) {
        [listTableView tableViewDidScroll:scrollView];
        if (scrollView.contentOffset.y <= 43 && scrollView.contentOffset.y >= 0) {
            [self setHeadViews:rectFrame];
        }
    }
    
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
    
    [self getNetworkingData];
    
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == listTableView) {
        return listArray.count;
    }else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == listTableView) {
        FileData * data = listArray[section];
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
    if (tableView == listTableView) {
        if (!isDuoxuan) {
            if (indexPath.row == 0) {
                ListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
                if (!cell) {
                    cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" withViewFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.funcDelegate = self;
                }
                cell.indexPath = indexPath;
                FileData * data = listArray[indexPath.section];
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
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.indexPath = indexPath;
            FileData * data = listArray[indexPath.section];
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
        SearchResultTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        if (!cell) {
            cell = [[SearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell" withViewFrame:tableView.frame];
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
    if (isDuoxuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FileData * data = listArray[indexPath.section];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        FileData * data;
        NSArray * selctArray;
        if (tableView == listTableView) {
            data = listArray[indexPath.section];
            selctArray = listArray;
        }else{
            selctArray = filterData;
            data = filterData[indexPath.row];
        }
        NSMutableArray * array = [[CategoryData shareCategoryData] categoryArray];
        NSMutableString * categoryStr = [NSMutableString new];
        if ([data.fileFormat isEqualToString:@"f"]) {
            FolderViewController * folderVC = [[FolderViewController alloc] init];
            folderVC.fileDta = (FileData *)data;
            [self.navigationController pushViewController:folderVC animated:YES];
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
    }
    
    
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self getSearchTableViewLabel:@"点击［搜索］按钮开始搜索"];
    [filterData removeAllObjects];
    [searchController.searchResultsTableView reloadData];
}

- (void)getSearchTableViewLabel:(NSString *)str{
    NSArray * array = [searchController.searchResultsTableView subviews];
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
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:searchController.searchResultsTableView];
    [hud setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [searchController.searchResultsTableView addSubview:hud];
    [hud show:YES];
    
    [filterData removeAllObjects];
    [searchController.searchResultsTableView reloadData];
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"allfile\",\"dirId\":\"%@\",\"searchValue\":\"%@\"}", _fileDta.fileID, searchBars.text];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_FILE_BY_SEARCH};
        
        [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"%@", error.description);
                [Alert showHUDWihtTitle:error.localizedDescription];
            }else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", dic);
//                NSLog(@"%@", [dic objectForKey:@"msg"]);
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
                    [searchController.searchResultsTableView reloadData];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBars{
    
    CGRect rect = self.view.frame;
    searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    listTableView.frame = CGRectMake(0, 20, rect.size.width, rect.size.height + 44);
    return YES;
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self changeFrame];
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
//    [self changeFrame];
//}

- (void)changeFrame{
        
    searchBar.frame = CGRectMake(70, 0, self.view.frame.size.width - 80, 44);
    listTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 44);
    
}

#pragma mark - ListTableViewCellDelegate

- (void)settingFunction:(NSIndexPath *)index{
    for (int i = 0; i < listArray.count; i++) {
        FileData * data = listArray[i];
        if (data.function && i != index.section) {
            data.function = NO;
            ListTableViewCell * cell = (ListTableViewCell *)[listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            UIButton * btn = (UIButton *)[cell.contentView viewWithTag:200];
            [btn setImage:[UIImage imageNamed:@"chevron-with-circle-down.png"] forState:UIControlStateNormal];
            
            [listTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    FileData * data = listArray[index.section];
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

#pragma mark - ListFunctionTableViewCellDelegate

- (void)functionAction:(NSIndexPath *)indexPath withTag:(NSInteger)tag{
    
    NSLog(@"%ld", (long)tag);
    
    if (tag == 100) {
        
    }else if (tag == 200){
        
        FileData * data = listArray[indexPath.section];
        [self removeFiles:@[data]];
        
    }else if (tag == 300){
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RenameViewController * renameCon = (RenameViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"renameCon"];
        renameCon.fileData = listArray[indexPath.section];
        NormalNavigationController * nav = [[NormalNavigationController alloc] initWithRootViewController:renameCon];
        renameCon.block = ^(){
            [listTableView reloadData];
        };
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        
    }else if (tag == 400){
        [self shanchuWenjian:indexPath];
    }else if (tag == 500){
        FileData * data = listArray[indexPath.section];
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareToNetworkViewController * shareNet = (ShareToNetworkViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"shareToNetwork"];
        shareNet.fileData = data;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:shareNet];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }else{
        
    }
}

- (void)removeFiles:(NSArray *)removeFileData{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoveFolderViewController * folderVC = (MoveFolderViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"moveFolder"];
    folderVC.folderId = @"";
    folderVC.moveFileDataArray = removeFileData;
    __weak FolderViewController * weakSelf = self;
    folderVC.block = ^(){
        [weakSelf getNetworkingData];
    };
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:folderVC];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(ALAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 400 && alertView.cancelButtonIndex != buttonIndex) {
        NSMutableArray * array = [NSMutableArray new];
        NSMutableArray * indexArray = [NSMutableArray new];
        if (isDuoxuan) {
            for (int i = 0; i < listArray.count; i++) {
                FileData * data = listArray[i];
                if (data.isSelected) {
                    [array addObject:data];
                    [indexArray addObject:@(i)];
                }
            }
        }else{
            [array addObject:listArray[alertView.indexPath.section]];
            [indexArray addObject:@(alertView.indexPath.section)];
        }
        if (array.count == 0) {
            [Alert showHUDWihtTitle:@"没有选中的文件"];
            return;
        }
        
        NSMutableString * idstr = [NSMutableString new];
        for (FileData * data in array) {
            [idstr appendFormat:@"%@,", data.fileID];
        }
        [idstr deleteCharactersInRange:NSMakeRange(idstr.length - 1, 1)];
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", idstr];
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
                        for (NSNumber * num in indexArray) {
                            NSUInteger numb = [num integerValue];
                            [listArray removeObjectAtIndex:numb];
                            [heightArray removeObjectAtIndex:numb];
                        }
                        
                        NSMutableIndexSet * indexSets = [NSMutableIndexSet indexSet];
                        for (FileData * data in array) {
                            for (int i = 0; i < listArray.count; i++) {
                                FileData * selectData = listArray[i];
                                if ([selectData.fileID isEqualToString:data.fileID]) {
                                    NSIndexSet * selectSet = [NSIndexSet indexSetWithIndex:i];
                                    [indexSets addIndexes:selectSet];
                                }
                            }
                        }
                        [[SQLCommand shareSQLCommand] deleteFileData:array];
                        if (isDuoxuan) {
                            [listTableView beginUpdates];
                            [listTableView deleteSections:indexSets withRowAnimation:UITableViewRowAnimationAutomatic];
                            [listTableView endUpdates];
                            
                        }else
                            [self reloadDataList];
                    }else{
                        [Alert showHUDWihtTitle:[dic objectForKey:@"msg"]];
                    }
                    //                    NSArray * array = [dic objectForKey:@"fileList"];
                    //                    if (array) {
                    //                        [SQLCommand updatedata:array withlistArray:listArray];
                    //
                    //                        [self reloadDatas];
                    //                    }
                }
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
        
    }
}

#pragma mark - forDuoXuan

- (void)downloadFiles{
    NSMutableArray * array = [NSMutableArray new];
    for (FileData * data in listArray) {
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
            }if (array.count <= 0) {
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
    for (FileData * data in listArray) {
        data.isSelected = isSelect;
    }
    [listTableView reloadData];
}

- (void)shanchuWenjian:(NSIndexPath *)indexPath{
    ALAlertView * alertView = [[ALAlertView alloc] initWithTitle:@"删除后可以在回收站恢复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView.indexPath = indexPath;
    alertView.tag = 400;
}

- (void)removeDuoXuanFiles{
    NSMutableArray * array = [NSMutableArray new];
    for (FileData * data in listArray) {
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
