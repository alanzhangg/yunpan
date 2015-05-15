//
//  ListHiddenTableView.m
//  WorkNetwork
//
//  Created by Team E Alanzhangg on 14/11/28.
//  Copyright (c) 2014年 Team E Alanzhangg. All rights reserved.
//

#import "ListHiddenTableView.h"
#import "Global.h"

@interface ListHiddenTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ListHiddenTableView{
    UITableView * listTabelView;
    UIView * backgroundView;
}
@synthesize block;

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self initSubViews:frame];
    }
    return self;
}

- (void)initSubViews:(CGRect)frame{
    
    //    _buttonArray = @[@"创建群组", @"加入群组"];
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    backgroundView.backgroundColor = RGBA(0, 0, 0, 0.4);
    [self addSubview:backgroundView];
    backgroundView.userInteractionEnabled = YES;
    
    listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0) style:UITableViewStylePlain];
    listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTabelView.backgroundColor = [UIColor whiteColor];
    listTabelView.delegate = self;
    listTabelView.dataSource = self;
    [self addSubview:listTabelView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenView:)];
    [backgroundView addGestureRecognizer:tap];
    
}

- (void)hiddenView:(UIGestureRecognizer *)ges{
    if (block) {
        block(-1);
    }
    [self showOperationView];
}

- (void)reloadData{
//    _buttonArray = [HomePageData shareHomePageData].homeArray;
    [listTabelView reloadData];
}

- (void)showOperationView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowWorkNetWorkList" object:nil];
    [self reloadData];
    if (!self.hidden) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = listTabelView.frame;
            rect.size.height = 0;
            listTabelView.frame = rect;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = !self.hidden;
        }];
    }else{
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
        
        int statusBar = IS_IOS7 ? 64 : 0;
        
        CGRect rect = listTabelView.frame;
        rect.size.height = 50 * [_buttonArray count] - (backgroundView.frame.size.height - statusBar - 44) >= 0 ? backgroundView.frame.size.height - statusBar - 44 : 50 * [_buttonArray count];
        listTabelView.frame = rect;
        
        self.alpha = 1;
        self.hidden = !self.hidden;
        
        [UIView commitAnimations];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _buttonArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 50 - 1, tableView.frame.size.width, 1)];
        [cell.contentView addSubview:lineView];
        lineView.backgroundColor = RGB(180, 180, 180);
        
    }
    NSDictionary * dic = _buttonArray[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"categoryName"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self showOperationView];
//    NSDictionary * dic = _buttonArray[indexPath.row];
//    [HomePageData shareHomePageData].selectId = [dic objectForKey:@"id"];
//    [HomePageData shareHomePageData].selectName = [dic objectForKey:@"networkName"];
    if (block) {
        block(indexPath.row);
    }
    
}

@end
