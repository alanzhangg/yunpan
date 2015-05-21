//
//  RenameViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/3.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "RenameViewController.h"
#import "Global.h"
#import "UIImageView+WebCache.h"
#import "NetWorkingRequest.h"
#import "Alert.h"
#import "SQLCommand.h"

@interface RenameViewController ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

@end

@implementation RenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if (_isXinjian) {
        self.navigationItem.title = @"新建文件夹";
    }else{
        self.navigationItem.title = @"重命名文件夹";
        _textField.text = _fileData.fileName;
    }
    _backView.layer.masksToBounds = YES;
    _backView.backgroundColor = [UIColor clearColor];
    _backView.layer.cornerRadius = 5;
    _backView.layer.borderColor = RGB(224, 224, 224).CGColor;
    _backView.layer.borderWidth = 1;
    
    [self addImage];
    
}

- (void)addImage{
    if (_isXinjian) {
         _fileImage.image = [UIImage imageNamed:@"folder.png"];
    }else{
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * lenstr = _fileData.thumDownloadUrl;
        NSString * typeStr = @"png,gif,jpg,jpeg,psd,bmp,pcx,pic";
        NSRange range = [typeStr rangeOfString:_fileData.fileFormat];
        if (lenstr.length > 3 && range.location != NSNotFound) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            [_fileImage sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:nil options:SDWebImageRetryFailed];
        }else{
            _fileImage.image = [UIImage imageNamed:@"folder.png"];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_textField resignFirstResponder];
}

- (IBAction)wanCheng:(UIBarButtonItem *)sender {
    if (_isXinjian) {
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param = [NSString stringWithFormat:@"params={\"dirName\":\"%@\",\"dirId\":\"%@\"}", _textField.text, _fileData ? _fileData.fileID : @""];
            NSDictionary * dic = @{@"param":param, @"aslp":SAVE_FOLDER};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //                NSArray * array = [dic objectForKey:@"fileList"];
                    if ([[dic objectForKey:@"result"] isEqualToString:@"ok"]) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            if (_block) {
                                _block();
                            }
                        }];
                    }else{
                        [Alert showAlertWithTitle:[dic objectForKey:@"msg"] MSG:nil];
                    }
                    
                }
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
    }else{
        int status = [AFHTTPAPIClient checkNetworkStatus];
        if (status == 1 || status == 2) {
            NSString * param = [NSString stringWithFormat:@"params={\"fileId\":\"%@\",\"fileName\":\"%@\"}", _fileData.fileID, _textField.text];
            NSDictionary * dic = @{@"param":param, @"aslp":RENAME_FILE};
            
            [NetWorkingRequest synthronizationWithString:dic andBlock:^(id data, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                }else{
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", dic);
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //                NSArray * array = [dic objectForKey:@"fileList"];
                    if ([[dic objectForKey:@"result"] isEqualToString:@"ok"]) {
                        _fileData.fileName = _textField.text;
                        [[SQLCommand shareSQLCommand] updateFileName:_fileData];
                        [self dismissViewControllerAnimated:YES completion:^{
                            if (_block) {
                                _block();
                            }
                        }];
                    }else{
                        [Alert showAlertWithTitle:[dic objectForKey:@"msg"] MSG:nil];
                    }
                    
                }
            }];
        }else{
            [Alert showHUDWihtTitle:@"无网络"];
        }
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
