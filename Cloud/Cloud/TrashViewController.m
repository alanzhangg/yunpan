//
//  TrashViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/23.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "TrashViewController.h"
#import "PullingRefreshTableView.h"
#import "Global.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "ListTableViewCell.h"
#import "FileData.h"
#import "UIImageView+WebCache.h"
#import "TrashData.h"
#import "TrachFunctionTableViewCell.h"
#import "AppDelegate.h"
#import "SelectedTableViewCell.h"
#import "SearchResultTableViewCell.h"

@interface TrashViewController ()<PullingRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, ListTableViewCellDelegate, TrachFunctionTableViewCellDelegate>

@end

@implementation TrashViewController{
    PullingRefreshTableView * listTableView;
    UISearchBar * searchBar;
    UISearchDisplayController * searchController;
    NSMutableArray * listArray;
    NSMutableArray * heightArray;
    UIView * tabView;
    NSMutableArray * filterData;
    NSMutableArray * filterHeightArray;
    BOOL isDuoXuan;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"回收站";
    self.automaticallyAdjustsScrollViewInsets = NO;
    listArray = [NSMutableArray new];
    heightArray = [NSMutableArray new];
    filterHeightArray = [NSMutableArray new];
    filterData = [NSMutableArray new];
    isDuoXuan = NO;
    [self initSubViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getNetworkData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [tabView removeFromSuperview];
}

- (void)getNetworkData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={}"];
        NSDictionary * dic = @{@"param":param, @"aslp":QUERY_RECYCLE_BINFILE};
        
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
                    if (array.count > 0) {
                        [listArray removeAllObjects];
                        for (NSDictionary * dic in array) {
                            TrashData * data = [[TrashData alloc] init];
                            data.dict = dic;
                            [listArray addObject:data];
                        }
                        [self getCellHeight:listArray];
                        [listTableView reloadData];
                    }
                }else{
                    [Alert showHUDWihtTitle:dic[@"msg"]];
                }
                
            }
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
    [listTableView tableViewDidFinishedLoading];
}

- (void)initSubViews{
    
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 64 : 0;
    if (!IS_IOS7) {
        rect.size.height -= 44;
    }
    
    listTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight - 44) pullingDelegate:self];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.headerOnly = YES;
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width - 80, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    listTableView.tableHeaderView = searchBar;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, rect.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [searchBar addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 1)];
    lineView.backgroundColor = RGB(224, 224, 224);
    [searchBar addSubview:lineView];
    
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    searchController.delegate = self;
    searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:listTableView];
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 44);
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:RGB(94, 164, 254) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(duoxuan:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (NSArray *)getHeight:(NSArray *)array{
    NSMutableArray * heiArray = [NSMutableArray new];
    for (TrashData * data in array) {
        CGSize size = [[data.dict objectForKey:@"fileName"] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - 140, 1000) lineBreakMode:NSLineBreakByWordWrapping];
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

- (void)duoxuan:(UIButton *)sender{
    //增加tab选择
    
    CGRect rect = self.view.frame;
    
    for (TrashData * data in listArray) {
        data.function = NO;
    }
    
    if (!tabView) {
        tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, 49)];
        
        tabView.backgroundColor = RGB(53, 53, 53);
        UIButton * returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        returnBtn.frame = CGRectMake(10, 10, rect.size.width/2 - 15, 29);
        returnBtn.backgroundColor = RGB(78, 78, 78);
        returnBtn.layer.masksToBounds = YES;
        returnBtn.layer.cornerRadius = 2;
        [returnBtn setTitle:@"还原" forState:UIControlStateNormal];
        returnBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [returnBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
        returnBtn.tag = 100;
        [tabView addSubview:returnBtn];
        
        UIButton * deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(rect.size.width/2 + 5, 10, rect.size.width/2 - 15, 29);
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.backgroundColor = RGB(132, 53, 47);
        deleteBtn.layer.cornerRadius = 2;
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [deleteBtn setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteOrReturn:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 200;
        [tabView addSubview:deleteBtn];
    }
    
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UITabBarController * tabCon = (UITabBarController *)dele.window.rootViewController;
    if (tabView.frame.origin.y >= 49) {
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
        isDuoXuan = YES;
    }else{
        isDuoXuan = NO;
        self.navigationItem.title = @"回收站";
        self.navigationItem.leftBarButtonItem = nil;
        [sender setTitle:@"多选" forState:UIControlStateNormal];
        CGRect rect = tabView.frame;
        rect.origin.y = 49;
        tabView.frame = rect;
        [tabView removeFromSuperview];
    }
    [listTableView reloadData];
}

- (void)deleteOrReturn:(UIButton *)sender{
    NSString * str;
    if (sender.tag == 100) {
        str = @"确定要还原该文件或文件夹吗?";
    }else if (sender.tag == 200){
        str = @"文件或文件夹删除后将无法恢复，您确认要彻底删除吗?";
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    alert.tag = sender.tag;
}

- (void)quanxuan:(UIButton *)sender{
    
    if ([sender.currentTitle isEqualToString:@"全选"]) {
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
        for (TrashData * data in listArray) {
            data.isSelected = YES;
        }
    }else if([sender.currentTitle isEqualToString:@"全不选"]) {
        for (TrashData * data in listArray) {
            data.isSelected = NO;
        }
        [sender setTitle:@"全选" forState:UIControlStateNormal];
    }
    [listTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == listTableView) {
        return listArray.count;
    }else{
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == listTableView) {
        FileData * data = listArray[section];
        if (data.function) {
            return 2;
        }else
            return 1;
    }else{
        
        return filterData.count;
    }
    
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
        if (!isDuoXuan) {
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
                cell.timeLabel.text = [data.dict objectForKey:@"createTime"];
                if (![[data.dict objectForKey:@"fileFormat"] isEqualToString:@"f"]) {
                    cell.sizeLabel.text = [cell setLength:[data.dict[@"fileSize"] floatValue]];
                }else{
                    cell.sizeLabel.text = nil;
                }
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
                }else
                    cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
                
                [cell layoutSubview:heightArray[indexPath.section]];
                //    FileData * data = listArray[indexPath.section];
                //    cell.textLabel.text = data.fileName;
                return cell;
            }else{
                TrachFunctionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"trashcell"];
                if (!cell) {
                    cell = [[TrachFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trashcell"];
                    cell.backgroundColor = RGB(224, 224, 224);
                }
                cell.indexPath = indexPath;
                cell.actionDelegate = self;
                return cell;
            }
        }else{
            SelectedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
            if (!cell) {
                cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCell" withViewFrame:tableView.frame];
            }
            cell.indexPath = indexPath;
            TrashData * data = listArray[indexPath.section];
            cell.titleLabel.text = [data.dict objectForKey:@"fileName"];
            cell.timeLabel.text = [data.dict objectForKey:@"createTime"];
            if (![[data.dict objectForKey:@"fileFormat"] isEqualToString:@"f"]) {
                cell.sizeLabel.text = [cell setLength:[data.dict[@"fileSize"] floatValue]];
            }else{
                cell.sizeLabel.text = nil;
            }
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
            }else
                cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
            
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
        TrashData * data = filterData[indexPath.section];
        cell.titleLabel.text = [data.dict objectForKey:@"fileName"];
        cell.timeLabel.text = [data.dict objectForKey:@"createTime"];
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
        }else
            cell.headPhoto.image = [UIImage imageNamed:@"folder.png"];
        
        [cell layoutSubview:heightArray[indexPath.section]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isDuoXuan) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        TrashData * data = listArray[indexPath.section];
        data.isSelected = !data.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 20 : 0;
    if (!IS_IOS7) {
        rect.size.height -= 44;
    }
    listTableView.frame = CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight);
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self getSearchTableViewLabel:@"点击［搜索］按钮开始搜索"];
    [filterData removeAllObjects];
    [self getFilterHeight:filterData];
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
    [filterData removeAllObjects];
    for (int i = 0; i < listArray.count; i++) {
        TrashData * data = listArray[i];
        NSString * searchString = [searchBars.text lowercaseString];
        NSLog(@"%@", data.dict[@"fileName"]);
        NSRange range = [data.dict[@"fileName"] rangeOfString:searchString];
        if (range.length > 0) {
            [filterData addObject:data];
        }
    }
    if (filterData.count == 0) {
        [self getSearchTableViewLabel:@"暂无数据"];
    }
    [self getFilterHeight:filterData];
    [searchController.searchResultsTableView reloadData];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self changeFrame];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
    [self changeFrame];
}

- (void)changeFrame{
    CGRect rect = self.view.frame;
    CGFloat statusBarHeight = IS_IOS7 ? 64 : 0;
    if (!IS_IOS7) {
        rect.size.height -= 44;
    }
    listTableView.frame = CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height - statusBarHeight);
    
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

#pragma mark - TrachFunctionTableViewCellDelegate

- (void)functionAction:(NSIndexPath *)indexPath withTag:(NSInteger)tag{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    TrashData * data = listArray[indexPath.section];
    if (status == 1 || status == 2) {
//        NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", data.dict[@"id"]];
        [self actionFunction:@[data.dict[@"id"]] with:tag];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
    
}

- (void)actionFunction:(NSArray *)params with:(NSInteger)tag{
    NSDictionary * dic;
    NSMutableString * param = [NSMutableString new];
    for (NSString * str in params) {
        [param appendFormat:@"%@,", str];
    }
    [param deleteCharactersInRange:NSMakeRange(param.length - 1, 1)];
    param = (NSMutableString *)[NSString stringWithFormat:@"params={\"fileId\":\"%@\"}", param];
    if (tag == 100) {
        dic = @{@"param":param, @"aslp":RESTORE_FILE};
    }else if (tag == 200){
        dic = @{@"param":param, @"aslp":DELETE_THROUGH_FILE};
    }
    NSLog(@"%@", param);
    
    [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
        if (error) {
            NSLog(@"%@", error.description);
            [Alert showHUDWihtTitle:error.localizedDescription];
        }else{
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", dic);
            if ([dic[@"result"] isEqualToString:@"error"]) {
                [Alert showHUDWihtTitle:dic[@"msg"]];
                NSLog(@"%@", dic[@"msg"]);
            }else{
                if (tag == 100) {
                    [Alert showHUDWihtTitle:@"还原成功"];
                }else if (tag == 200){
                    [Alert showHUDWihtTitle:@"删除成功"];
                }
                NSMutableIndexSet * set = [NSMutableIndexSet indexSet];
//                NSMutableArray * array = [NSMutableArray new];
                for (NSString * str in params) {
                    for (int i = 0; i < listArray.count; i++) {
                        TrashData * data = listArray[i];
                        if ([data.dict[@"id"] isEqualToString:str]) {
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
            }
        }
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSMutableArray * array = [NSMutableArray new];
        for (TrashData * data in listArray) {
            if (data.isSelected) {
                [array addObject:data.dict[@"id"]];
            }
        }
        if (array.count == 0) {
            [Alert showHUDWihtTitle:@"请选择"];
        }else
            [self actionFunction:array with:alertView.tag];
    }
}

@end
