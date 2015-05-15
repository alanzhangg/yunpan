//
//  DocumentsView.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DocumentsView.h"
#import "CategoryData.h"
#import "SQLCommand.h"
#import "NetWorkingRequest.h"
#import "Alert.h"

@implementation DocumentsView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)initialiseData{
    
    [self reloadDatas];
    [self getNetworkingData];
}

- (void)reloadDatas{
    
    
    if ([self.categoryName isEqualToString:@"其他" ]) {
        NSMutableArray * array = [NSMutableArray new];
        for (NSDictionary * dic in [CategoryData shareCategoryData].categoryArray) {
            [array addObjectsFromArray:dic[@"categoryList"]];
        }
        [array addObject:@"f"];
        self.listArray = [[SQLCommand shareSQLCommand] getOtherFolderData:array];
    }else{
        NSArray * categoryListArray;
        for (NSDictionary * dic in [CategoryData shareCategoryData].categoryArray) {
            if ([dic[@"categoryName"] isEqualToString:self.categoryName]) {
                categoryListArray = dic[@"categoryList"];
            }
        }
        self.listArray = [[SQLCommand shareSQLCommand] getCategoryData:categoryListArray];
    }
    
    [super reloadDatas];
}

- (void)getNetworkingData{
    int status = [AFHTTPAPIClient checkNetworkStatus];
    if (status == 1 || status == 2) {
        NSString * param = [NSString stringWithFormat:@"params={\"categoryName\":\"%@\",\"dirId\":\"\",\"searchValue\":\"\"}", self.categoryName];
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
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [SQLCommand updatedata:array withlistArray:self.listArray];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self reloadDatas];
                            });
                        });
                    }
                }else
                    [Alert showHUDWihtTitle:dic[@"msg"]];
            }
            [self tableViewDidFinishedLoading];
        }];
    }else{
        [Alert showHUDWihtTitle:@"无网络"];
    }
}

#pragma mark - PullingTableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self tableViewDidEndDragging:scrollView];
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

@end
