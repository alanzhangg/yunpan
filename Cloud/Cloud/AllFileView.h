//
//  AllFileView.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/3/30.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "PullingRefreshTableView.h"

@protocol AllFileViewDelegate <NSObject>

- (void)openFolder:(id)data;

@end

@interface AllFileView : PullingRefreshTableView

@property (nonatomic, assign) id<AllFileViewDelegate> allDelegate;
@property (nonatomic, assign) int categoryType;
@property (nonatomic, assign) BOOL isDuoXuan;
@property (nonatomic, strong) UISearchDisplayController * searchController;
@property (nonatomic, strong) UISearchBar * searchBar;


- (void)setHeadViews:(CGRect)frame;
- (void)reloadDatas;

- (void)downloadFiles;
- (void)removeDuoXuanFiles;
- (void)shanchuWenjian:(NSIndexPath *)indexPath;
- (void)yongYuQuanXuan:(BOOL)isSelect;


@end
