//
//  VideoShowViewController.m
//  Cloud
//
//  Created by Team E Alanzhangg on 15/5/4.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "VideoShowViewController.h"
#import "CyberPlayerController.h"
#import "CommonHelper.h"
#import "Alert.h"

@interface VideoShowViewController ()

@end

@implementation VideoShowViewController{
    CyberPlayerController * cbPlayController;
    UIColor * backcolor;
    UIView * tabbarView;
    NSURL * fileURL;
    UISlider * slide;
    NSTimer *timer;
    UIButton * pauseBtn;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    
    NSString * msAK = @"rC37ZizhLbEkRtFwPGRYEiak";
    NSString * msSK = @"hWLoY742iB7acP2oE8D3POORaKZ3o1GU";
    self.navigationItem.title = _videoData.resouceName;
    
    
    [[CyberPlayerController class] setBAEAPIKey:msAK SecretKey:msSK];
    [self shengchengUrl];
//    fileURL = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear4/prog_index.m3u8"];
    
    //注册监听，当播放器完成视频播放位置调整后会发送CyberPlayerSeekingDidFinishNotification通知，
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tap];
}

- (void)seekComplete:(NSNotification *)notification{
//    slide.value = cbPlayController.currentPlaybackTime/cbPlayController.duration;
    //开始启动UI刷新
    [self startTimer];
}

- (void)finish:(NSNotification *)notification{
    [cbPlayController pause];
    pauseBtn.selected = YES;
    [self stopTimer];
    slide.value = 0.0;
}

- (void)startTimer{
    //为了保证UI刷新在主线程中完成。
    [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)stopTimer{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    timer = nil;
}

- (void)startTimeroOnMainThread{
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
    }
    
}

- (void)timerHandler:(NSTimer*)timer
{
    [self refreshProgress:cbPlayController.currentPlaybackTime totalDuration:cbPlayController.duration];
}
- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
    slide.value = (float)currentTime/(float)allSecond;
    NSLog(@"%d   %d", currentTime, allSecond);
}

- (void)shengchengUrl{
    
    NSString * path = [self getFilesPath];
    NSLog(@"%@ %d", path, [CommonHelper isExistFile:path]);
    if ([CommonHelper isExistFile:path]) {
        fileURL = [self diskUrl:path];
        return;
    }
    path = NSHomeDirectory();
    NSString * pathstr = [NSString stringWithFormat:@"Documents/upload/%@", _videoData.resouceName];
    path = [path stringByAppendingPathComponent:pathstr];
    if ([CommonHelper isExistFile:path]) {
        fileURL = [self diskUrl:path];
    }
    else{
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * lenstr = _videoData.resourceURL;
        if (lenstr.length > 3) {
            NSString * urlstr;
            if ([[lenstr substringToIndex:2] isEqualToString:@".."]) {
                urlstr = [NSString stringWithFormat:@"%@%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }else{
                urlstr = [NSString stringWithFormat:@"%@/r/%@", [ud objectForKey:@"server"], [lenstr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            }
            fileURL = [NSURL URLWithString:urlstr];
//            NSLog(@"%@", fileURL);
//            fileURL = [NSURL URLWithString:@"http://192.168.1.183/video/1.mp4"];
        }
    }
}

- (NSURL *)diskUrl:(NSString *)path{
    NSFileManager * fileManage = [NSFileManager defaultManager];
    NSString * showPath = [self copyFolderPath];
    showPath = [showPath stringByAppendingPathComponent:_videoData.resouceName];
    if (![fileManage fileExistsAtPath:showPath]) {
        NSError * error;
        [fileManage copyItemAtPath:path toPath:showPath error: &error];
        if (error) {
            NSLog(@"%s %@", __func__, error);
            [Alert showHUDWihtTitle:@"加载失败"];
        }
    }
    NSURL * url = [[NSURL alloc] initFileURLWithPath:showPath];
    return url;
}

- (NSString *)copyFolderPath{
    NSString * path = [CommonHelper getDocumentPath];
    NSString * str = [NSString stringWithFormat:@"Download/show"];
    path = [path stringByAppendingPathComponent:str];
    return path;
}

- (NSString *)getFilesPath{
    NSString * path = [CommonHelper getDocumentPath];
    NSString * str = [NSString stringWithFormat:@"Download/folder/%@", _videoData.resouceName];
    path = [path stringByAppendingPathComponent:str];
    return path;
}

- (void)initSubViews{
    
    CGRect rect = self.view.frame;
    
    UIBarButtonItem * leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    NSLog(@"%@", fileURL);
    if (fileURL) {
        cbPlayController = [[CyberPlayerController alloc] initWithContentURL:fileURL];
        [cbPlayController.view setFrame:rect];
        cbPlayController.scalingMode = CBPMovieScalingModeAspectFit;
        [self.view addSubview:cbPlayController.view];
        [cbPlayController play];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"加载失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onpreparedListener:)
                                                 name: CyberPlayerLoadDidPreparedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(seekComplete:)
                                                 name:CyberPlayerSeekingDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finish:)
                                                 name:CyberPlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [self addTabbarView];
    
}

- (void)addTabbarView{
    CGRect rect = self.view.frame;
    tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, rect.size.width, 49)];
    tabbarView.backgroundColor = [UIColor blackColor];
    tabbarView.alpha = 0.7;
    [self.view addSubview:tabbarView];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(10, 5, 40, 40);
    pauseBtn.layer.masksToBounds = YES;
    pauseBtn.layer.cornerRadius = 20;
    [pauseBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [pauseBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateSelected];
    [pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:pauseBtn];
    
    slide = [[UISlider alloc] initWithFrame:CGRectMake(60, 20, rect.size.width - 100, 10)];
    [tabbarView addSubview:slide];
    [slide addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventValueChanged];
}

- (void)onDragSlideDone:(id)sender {
    NSLog(@"++++++++");
    [cbPlayController seekTo:slide.value * cbPlayController.duration];
}

- (void) onpreparedListener: (NSNotification*)aNotification
{
    //视频文件完成初始化，开始播放视频并启动刷新timer。
    [self startTimer];
}

- (void)pause:(UIButton *)sender{
    if (sender.selected) {
        sender.selected = NO;
        [cbPlayController start];
        [self startTimer];
    }else{
        sender.selected = YES;
        [cbPlayController pause];
        [self stopTimer];
    }
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = tabbarView.frame;
        rect.origin.y = self.view.frame.size.height - 49;
        tabbarView.frame = rect;
    }];
}

- (void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self initSubViews];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [cbPlayController stop];
    [self stopTimer];
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
