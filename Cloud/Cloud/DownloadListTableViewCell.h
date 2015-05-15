//
//  DownloadListTableViewCell.h
//  Cloud
//
//  Created by Team E Alanzhangg on 15/4/16.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileData.h"
#import "ASIHTTPRequest.h"
#import "CircularProgressButton.h"

@interface DownloadListTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * headPhoto;
@property (nonatomic, weak) ASIHTTPRequest * request;
@property (nonatomic, strong) FileData * fileInfo;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * sizeLabel;
@property (nonatomic, strong) CircularProgressButton * functionButton;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, weak) id parentVC;
@property (nonatomic, copy) NSString *lengthss;
@property (nonatomic, copy) NSString *cursize;

-(void) PlayOrPausestate:(BOOL)check;
-(void)setPercent:(float)per;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewFrame:(CGRect)frame;

- (void)layoutSubview:(NSDictionary *)dic;
- (NSString *)setLength:(float)length;

@end
