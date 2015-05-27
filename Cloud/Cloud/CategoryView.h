//
//  CategoryView.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/2.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "Global.h"
#import "PullingRefreshTableView.h"

@protocol CategoryViewDelegate <NSObject>

- (void)openFolder:(id)data;

@end

@interface CategoryView : PullingRefreshTableView

@property (nonatomic, assign) id<CategoryViewDelegate> allDelegate;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UISearchDisplayController * displayController;
@property (nonatomic, strong) NSArray * listArray;
@property (nonatomic, copy) NSString * categoryName;
@property (nonatomic, assign) BOOL isDuoXuan;

- (void)initSubViews;
- (void)reloadDatas;

- (void)downloadFiles;
- (void)removeDuoXuanFiles;
- (void)shanchuWenjian:(NSIndexPath *)indexPath;
- (void)yongYuQuanXuan:(BOOL)isSelect;

@end
