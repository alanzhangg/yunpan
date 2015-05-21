//
//  DetailPictureDisplayViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/27.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DetailPictureDisplayViewController.h"
#import "NRcollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NRCollectImageData.h"
#import "ShangchuanViewController.h"
#import "MoveFolderViewController.h"
#import "SQLCommand.h"
#import "UploadData.h"
#import "MBProgressHUD.h"
#import "Alert.h"
#import "UploadNetwork.h"

@interface DetailPictureDisplayViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *fileButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@end

@implementation DetailPictureDisplayViewController{
    FileData * selectData;
    MBProgressHUD * hud;
}

- (IBAction)quanXuan:(id)sender {
    UIBarButtonItem * item = sender;
    if ([item.title isEqual:@"全选"]) {
        item.title = @"全不选";
        for (NRCollectImageData * data in _groupListArray) {
            data.isSelected = YES;
        }
    }else{
        item.title = @"全选";
        for (NRCollectImageData * data in _groupListArray) {
            data.isSelected = NO;
        }
    }
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"已选择0个文件";
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[NRcollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView reloadData];
    
    _fileButton.layer.masksToBounds = YES;
    _fileButton.layer.cornerRadius = 5;
    _uploadButton.layer.masksToBounds = YES;
    _uploadButton.layer.cornerRadius = 5;
    
}
- (IBAction)selectFolder:(id)sender {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoveFolderViewController * folderVC = (MoveFolderViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"moveFolder"];
    folderVC.folderId = @"";
    folderVC.shangchuan = YES;
//    folderVC.moveFileDataArray = removeFileData;
//    __weak AllFileView * weakSelf = self;
//    folderVC.block = ^(){
//        [weakSelf reloadDatas];
//    };
    ShangchuanViewController * nav = [[ShangchuanViewController alloc] initWithRootViewController:folderVC];
    nav.fileData = nil;
    nav.block = ^(id fileData){
        selectData = (FileData *)fileData;
        if (selectData) {
            [sender setTitle:selectData.fileName forState:UIControlStateNormal];
        }else{
            [sender setTitle:@"我的网盘" forState:UIControlStateNormal];
        }
    };
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)uploadButton:(id)sender {
    NSMutableArray * array = [NSMutableArray new];
    for (NRCollectImageData * data in _groupListArray) {
        if (data.isSelected) {
            [array addObject:data];
        }
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * path = NSHomeDirectory();
    path = [path stringByAppendingPathComponent:@"Documents/upload"];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"%@", path);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * upDataArray = [NSMutableArray new];
        for (NRCollectImageData * data in array) {
            UploadData * upData = [[UploadData alloc] init];
            upData.fileID = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000000)];
            upData.fileName = [[data.result defaultRepresentation] filename];
            upData.fileSize = [NSNumber numberWithLongLong:[[data.result defaultRepresentation] size]];
            upData.status = @(1);
            upData.thumbNail = [NSString stringWithFormat:@"thum%@", upData.fileName];
            if (selectData) {
                upData.parentID = selectData.fileID;
            }else{
                upData.parentID = @"";
            }
            [upDataArray addObject:upData];
            NSLog(@"%@", upData.fileID);
            @autoreleasepool {
                NSString * thunpath = NSHomeDirectory();
                NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", upData.thumbNail];
                thunpath = [thunpath stringByAppendingPathComponent:pathstr];
                if (![fileManager fileExistsAtPath:thunpath]) {
                    UIImage * image = [UIImage imageWithCGImage:[data.result thumbnail]];
                    NSData * data = UIImageJPEGRepresentation(image, 1.0);
                    [data writeToFile:thunpath atomically:YES];
                }
            }
            @autoreleasepool {
                NSString * upPath = NSHomeDirectory();
                NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", upData.fileName];
                upPath = [upPath stringByAppendingPathComponent:pathstr];
                if (![fileManager fileExistsAtPath:upPath]) {
                    if ([[data.result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ALAssetRepresentation * rep = data.result.defaultRepresentation;
                        Byte * buffer = (Byte *)malloc((unsigned long)rep.size);
                        NSUInteger bufferd = [rep getBytes:buffer fromOffset:0.0 length:(unsigned long)rep.size error:nil];
                        NSData * data = [NSData dataWithBytesNoCopy:buffer length:bufferd freeWhenDone:YES];
                        [data writeToFile:upPath atomically:YES];
                    }else{
                        ALAssetRepresentation * rep = data.result.defaultRepresentation;
                        char const * cvideoPath = [upPath UTF8String];
                        FILE * file = fopen(cvideoPath, "a+");
                        if (file) {
                            const int bufferSize = 1024 * 1024;
                            Byte * buffer = (Byte *)malloc(bufferSize);
                            NSUInteger read = 0, offset = 0, writtrn = 0;
                            NSError * err = nil;
                            if (rep.size != 0) {
                                do {
                                    read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                                    writtrn = fwrite(buffer, sizeof(char), read, file);
                                    offset += read;
                                } while (read != 0 && !err);
                            }
                            free(buffer);
                            buffer = NULL;
                            fclose(file);
                            file = NULL;
                        }
                        
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SQLCommand shareSQLCommand] insertUploadData:upDataArray];
            [Alert showHUDWihtTitle:@"已加入上传列表"];
            [[UploadNetwork shareUploadNetwork] getUploadData];
            [[UploadNetwork shareUploadNetwork] startUpload];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        
    });
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _groupListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NRcollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        
    }
    cell.highlighted = YES;
    [cell settingFrame:CGSizeMake((self.view.frame.size.width - 20) / 4, (self.view.frame.size.width - 20) / 4)];
    NRCollectImageData * data = _groupListArray[indexPath.row];
    cell.bgImageView.image = [UIImage imageWithCGImage:data.result.thumbnail];
//    [cell.selectedBtn addTarget:self action:@selector(selectedImages:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectedBtn.tag = indexPath.row + 200;
    if (data.isSelected) {
        [cell.selectedBtn setImage:[UIImage imageNamed:@"check-box.png"] forState:UIControlStateNormal];
    }else{
        [cell.selectedBtn setImage:[UIImage imageNamed:@"untitled.png"] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)selectedImages:(UIButton *)sender{
    NRCollectImageData * data = _groupListArray[sender.tag - 200];
    data.isSelected = !data.isSelected;
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width - 20) / 4, (self.view.frame.size.width - 20) / 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.frame.size.width, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NRCollectImageData * data = _groupListArray[indexPath.row];
    data.isSelected = !data.isSelected;
    [_collectionView reloadData];
    //    [[NSUserDefaults standardUserDefaults] setObject:listArray[indexPath.row] forKey:@"backgroundImage"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
//    NRShowDetailImageViewController * detailVC = [[NRShowDetailImageViewController alloc] init];
//    [self.navigationController pushViewController:detailVC animated:YES];
//    NRCollectImageData * data = listArray[indexPath.row];
//    detailVC.detailImage = [UIImage imageWithCGImage:data.result.defaultRepresentation.fullScreenImage];
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
