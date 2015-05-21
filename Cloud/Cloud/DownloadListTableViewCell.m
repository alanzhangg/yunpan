//
//  DownloadListTableViewCell.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/16.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "DownloadListTableViewCell.h"
#import "Global.h"
#import "DownloadListView.h"
#import "CommonHelper.h"
#import "FilesDownloadManager.h"

@interface DownloadListTableViewCell ()<CircularProgressButtonDelegate, ASIProgressDelegate, ASIHTTPRequestDelegate, DownloadDelegate>

@property (nonatomic, copy) NSString *strLength;
@property (nonatomic ) float curLength;

@end

@implementation DownloadListTableViewCell{
    UIView * lineview;
    CGRect rectFrame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews:frame];
        rectFrame = frame;
        
    }
    return self;
}

- (void)initSubViews:(CGRect)frame{
    _headPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
    [self.contentView addSubview:_headPhoto];
    _headPhoto.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    _sizeLabel = [[UILabel alloc] init];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_sizeLabel];
    _sizeLabel.font = [UIFont systemFontOfSize:14];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    
    _functionButton = [[CircularProgressButton alloc]initWithFrame:CGRectMake(200, 5, 40, 40)
                                                         backColor:[UIColor lightGrayColor]
                                                     progressColor:[UIColor greenColor]
                                                         lineWidth:8];
    
    [_functionButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    _functionButton.delegate = self;
    _functionButton.selected = YES;
    [self.contentView addSubview:_functionButton];
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
    lineview.backgroundColor = RGB(224, 224, 224);
    [self.contentView addSubview:lineview];
}

- (void)layoutSubview:(NSDictionary *)dic{
    CGRect rect = lineview.frame;
    rect.origin.y = [[dic objectForKey:@"cellheight"] floatValue] - 1;
    lineview.frame = rect;
    _titleLabel.frame = CGRectMake(70, 10, rectFrame.size.width - 130, [[dic objectForKey:@"titleheight"] floatValue]);
    _timeLabel.frame = CGRectMake(70, 10 + _titleLabel.frame.size.height, rectFrame.size.width - 200, 20);
    _sizeLabel.frame = CGRectMake(_timeLabel.frame.size.width + _timeLabel.frame.origin.x + 10, _timeLabel.frame.origin.y, 70, 20);
    _functionButton.frame = CGRectMake(rect.size.width - 50, [[dic objectForKey:@"cellheight"] floatValue]/2 - 20, 30, 30);
    [_functionButton setProgress:0.0];
}

- (void)showSetting:(UIButton *)sender{
    if (_functionButton.selected) {//将文件状态由暂停改为下载
        _functionButton.selected = NO;
        [self stopDownloadFile];
        _timeLabel.text = @"";
    }else{//将文件状态由下载改为暂停
        _functionButton.selected = YES;
        [self downloadFile];
        _timeLabel.text = @"暂停";
    }
}

- (void)stopDownloadFile
{
    if(_fileInfo==nil)return;
    _timeLabel.text = @"暂停";
    [[FilesDownloadManager sharedFilesDownManage] stopRequest:_fileInfo];
//    [(DownloadListView*)self.parentVC removeASIRequst:_request];
    //  [self.parentVC reloadData];
}

/**
 *  cell中操作下载
 */
- (void)downloadFile
{
    if(_fileInfo==nil)return;
    [[FilesDownloadManager sharedFilesDownManage] startRequest:_fileInfo];
//    FIleDownLoadManager *filedownmanage=[FIleDownLoadManager sharedFilesDownManage];
//    
//    [filedownmanage keepOnNewASINetworkQueueWithGuid:_fileInfo];
    
    [self.parentVC reloadData];
}

//- (void)setRequest:(ASIHTTPRequest *)request
//{
//    if (request == nil) {
//        _request = nil;
//        _functionButton.selected = YES;
//        _functionButton.progress = 0;
//        return;
//    }else{
//        _request = nil;
//        _functionButton.progress = 0;
//        _request = request;
//        _functionButton.selected = NO;
//    }
//}
//暂停或者继续
-(void) PlayOrPausestate:(BOOL)check
{
    if(check)
    {
        _functionButton.selected = YES;
    }
    else{
        _functionButton.selected = NO;
    }
}


//- (void)setLengthss:(NSString *)length
//{
//    
//    _lengthss=length;
//    NSString *len = [CommonHelper getFileSizeString:length];
//    NSString *curlen = [CommonHelper getFileSizeString:_cursize];
//    self.detailTextLabel.text =[ NSString stringWithFormat: @"%@/%@",curlen ,len ];;
//    
//}
//-(void)setCursize:(NSString *)cursize
//{
//    _cursize=cursize;
//    NSString *len = [CommonHelper getFileSizeString:_lengthss];
//    NSString *curlen = [CommonHelper getFileSizeString:_cursize];
//    self.detailTextLabel.text =[ NSString stringWithFormat: @"%@/%@",curlen ,len ];;
//    
//}
//- (void)updateProgressViewWithProgress:(float)progress
//{
//    float cur= [_lengthss floatValue]*progress;
//    NSString *curlen = [CommonHelper getFileSizeString: [NSString stringWithFormat:@"%f",cur ]];
//    NSString *len = [CommonHelper getFileSizeString:_lengthss];
//    
//    // FileModel *fModel=[_request.userInfo objectForKey:@"File"];
//    // NSString *curlen=fModel.
//    
//    self.detailTextLabel.text =[ NSString stringWithFormat: @"%@/%@",curlen ,len ];;
//}
//-(void)setPercent:(float)per
//{
//    [_functionButton setProgress:per];
//    
//}

//- (NSString *)setLength:(float)length
//{
//    NSString *strLength;
//    float len = length;
//    if (len > 1024) {
//        len = len /1024;
//        if (len > 1024) {
//            len = len /1024;
//            if (len > 1024) {
//                len = len /1024;
//                if (len > 1024) {
//                    len = len /1024;
//                }else{
//                    strLength = [NSString stringWithFormat:@"%.2fG",len];
//                }
//            }else{
//                strLength = [NSString stringWithFormat:@"%.2fM",len];
//            }
//        }else{
//            strLength = [NSString stringWithFormat:@"%.2fK",len];
//        }
//    }else{
//        strLength = [NSString stringWithFormat:@"%.2fB",len];
//    }
//    return strLength;
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
