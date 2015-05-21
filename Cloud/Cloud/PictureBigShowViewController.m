//
//  PictureBigShowViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/10.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "PictureBigShowViewController.h"
#import "Global.h"
#import "TabberButton.h"
#import "PictureCollectionViewCell.h"
#import "FileData.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UploadData.h"

@interface PictureBigShowViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation PictureBigShowViewController{
    UIColor * backcolor;
    UIView * tabbarView;
    UICollectionView * pictureCollectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    if (IS_IOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self initSubViews];
    NSLog(@"%@", _pictureArray);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tap];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self showNav];
}

- (void)tapView:(UIGestureRecognizer *)ges{
    if (self.navigationController.navigationBarHidden) {
        [self showNav];
    }else{
        [self hiddenNav];
    }
    
}

- (void)hiddenNav{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = tabbarView.frame;
        rect.origin.y = self.view.frame.size.height + 49;
        tabbarView.frame = rect;
    }];
}

- (void)showNav{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = tabbarView.frame;
        rect.origin.y = self.view.frame.size.height - 49;
        tabbarView.frame = rect;
    }];
}

- (void)initSubViews{
   
    CGRect rect = self.view.frame;
    
    UICollectionViewFlowLayout * flowout = [[UICollectionViewFlowLayout alloc] init];
    [flowout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    pictureCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) collectionViewLayout:flowout];
    pictureCollectView.backgroundColor = [UIColor clearColor];
    pictureCollectView.pagingEnabled = YES;
    pictureCollectView.delegate = self;
    pictureCollectView.dataSource = self;
    [pictureCollectView registerClass:[PictureCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:pictureCollectView];
    if (!_isUpload) {
        [self addTabbarView];
        NSUInteger index = [_pictureArray indexOfObject:_fileData];
        if (index < _pictureArray.count) {
            pictureCollectView.contentOffset = CGPointMake(index * rect.size.width, 0);
        }
        
    }else{
        NSUInteger index = [_uploadArray indexOfObject:_uploadData];
        pictureCollectView.contentOffset = CGPointMake(index * rect.size.width, 0);
    }
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    CGRect rects = tabbarView.frame;
    rects.origin.y = self.view.frame.size.height - 49;
    tabbarView.frame = rects;
}

- (void)addTabbarView{
    CGRect rect = self.view.frame;
    tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, rect.size.width, 49)];
    tabbarView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:tabbarView];
    NSArray * titleArray = @[@"下载", @"分享", @"删除"];
    for (int i = 0; i < 3; i++) {
        TabberButton * btn = [TabberButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((rect.size.width - 49 * 3) / 4 * (i + 1) + 49 * i, 0, 49, 49);
        [tabbarView addSubview:btn];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        btn.tag = 200 + i;
        [btn addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)functionAction:(TabberButton *)sender{
//    NSLog(@"%d", sender.tag);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (!_isUpload) {
        self.navigationItem.title = [NSString stringWithFormat:@"1/%lu", (unsigned long)_pictureArray.count];
        NSUInteger index = [_pictureArray indexOfObject:_fileData];
        NSString * str = [NSString stringWithFormat:@"%lu/%lu", index + 1, (unsigned long)_pictureArray.count];
        self.navigationItem.title = str;
    }else{
        self.navigationItem.title = [NSString stringWithFormat:@"1/%lu", (unsigned long)_uploadArray.count];
        NSUInteger index = [_uploadArray indexOfObject:_uploadData];
        NSString * str = [NSString stringWithFormat:@"%d/%lu", index + 1, (unsigned long)_uploadArray.count];
        self.navigationItem.title = str;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.tintColor = backcolor;

}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!_isUpload) {
        return _pictureArray.count;
    }else
        return _uploadArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PictureCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        
    }
//    indexP = indexPath;
    if (!_isUpload) {
        FileData * data = _pictureArray[indexPath.row];
        
        NSString * lenstr = data.downloadUrl;
        NSLog(@"%@", lenstr);
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        //    NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
        //    NSRange range = [typeStr rangeOfString:data.fileFormat];
        if (lenstr.length > 3) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            UIView * view = [cell.scrollView viewWithTag:333];
            [view removeFromSuperview];
            MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
            [hud setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height / 2)] ;
            hud.tag = 333;
            [cell.scrollView addSubview:hud];
            cell.scrollView.zoomScale = 1;
            [hud show:YES];
            NSLog(@"%@", urlstr);
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [cell settingFrame:CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height) withInter:0];
                [hud removeFromSuperview];
            }];
            
            [cell settingFrame:CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height) withInter:0];
        }
        [cell settingFrame:CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height) withInter:0];
    }else{
        UploadData * uploadData = _uploadArray[indexPath.row];
        NSString * path = NSHomeDirectory();
        NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", uploadData.fileName];
        path = [path stringByAppendingPathComponent:pathstr];
        cell.imageView.image = [UIImage imageWithContentsOfFile:path];
        
        [cell settingFrame:CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height) withInter:0];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(collectionView.frame.size.width - 10, collectionView.frame.size.height);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(5, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sscrollView{
    if (!_isUpload) {
        int scrollViewIndex = sscrollView.contentOffset.x/sscrollView.frame.size.width;
        NSString * str = [NSString stringWithFormat:@"%d/%lu", scrollViewIndex + 1, (unsigned long)_pictureArray.count];
        self.navigationItem.title = str;
    }else{
        int scrollViewIndex = sscrollView.contentOffset.x/sscrollView.frame.size.width;
        NSString * str = [NSString stringWithFormat:@"%d/%lu", scrollViewIndex + 1, (unsigned long)_uploadArray.count];
        self.navigationItem.title = str;
    }
    
    [self hiddenNav];
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
