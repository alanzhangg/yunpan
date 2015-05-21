
#import "CircularProgressButton.h"

@interface CircularProgressButton ()

//@property (nonatomic) NSTimer *timer;
//@property (nonatomic) AVAudioPlayer *player;//an AVAudioPlayer instance

@property (assign, nonatomic) CGFloat angle;//angle between two lines

@end

@implementation CircularProgressButton

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
//        UIImage *imgPause = [[UIImage alloc]initWithContentsOfFile:[[NSBundle alloc]pathForResource:@"file_pause_normal" ofType:@"png"]];
      //  UIImage *imgPause =[[UIImage alloc]initWithContentsOfFile:[[NSBundle alloc]pathForResource:@"file_pause_normal" ofType:@"png"]];
        
      //  [UIImage imageNamed:@"file_pause_normal.png"];
      //  UIImage *imgDown =
      //  [[UIImage alloc]initWithContentsOfFile:[[NSBundle alloc]pathForResource:@"file_download_normal" ofType:@"png"]];
         UIImage *imgPause = [UIImage imageNamed:@"outing.png"];
//         UIImage *imgDown =[UIImage imageNamed:@"file_download_normal.png"];
        [self setBackgroundImage:imgPause forState:UIControlStateNormal];
//        [self setBackgroundImage:imgDown  forState:UIControlStateSelected];
        _progressColor = progressColor;
        _lineWidth = lineWidth;
        _backColor = backColor;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateProgressViewWithProgress:)]) {
        [self.delegate updateProgressViewWithProgress:self.progress];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //draw background circle
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2)
                                                              radius:(CGRectGetWidth(self.bounds) - self.lineWidth ) / 2
                                                          startAngle:(CGFloat) - M_PI_2
                                                            endAngle:(CGFloat)(1.5 * M_PI)
                                                           clockwise:YES];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (self.progress) {
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                                      radius:(CGRectGetWidth(self.bounds) - self.lineWidth ) / 2
                                                                  startAngle:(CGFloat) - M_PI_2
                                                                    endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI)
                                                                   clockwise:YES];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
}

@end
