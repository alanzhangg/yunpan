//
//  XHScrollMenu.m
//  XHScrollMenu
//
//  Created by 曾 宪华 on 14-3-8.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "XHScrollMenu.h"

#import "Global.h"
#import "UIScrollView+XHVisibleCenterScroll.h"
#import "MenuButton.h"

#define kXHMenuButtonBaseTag 100

@interface XHScrollMenu () <UIScrollViewDelegate> {
    
}

@property (nonatomic, strong) UIImageView *leftShadowView;
@property (nonatomic, strong) UIImageView *rightShadowView;

@property (nonatomic, strong) UIButton *managerMenusButton;

@property (nonatomic, strong) NSMutableArray *menuButtons;

@end

@implementation XHScrollMenu

#pragma mark - Propertys

- (NSMutableArray *)menuButtons {
    if (!_menuButtons) {
        _menuButtons = [[NSMutableArray alloc] initWithCapacity:self.menus.count];
    }
    return _menuButtons;
}

#pragma mark - Action

- (void)managerMenusButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(scrollMenuDidManagerSelected:)]) {
        [self.delegate scrollMenuDidManagerSelected:self];
    }
}

- (void)menuButtonSelected:(UIButton *)sender {
//    [self.menuButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if (obj == sender) {
//            sender.selected = YES;
//        } else {
//            UIButton *menuButton = obj;
//            menuButton.selected = NO;
//        }
//    }];
    
    if ([self.delegate respondsToSelector:@selector(butttonClick:)]) {
        [self.delegate butttonClick:sender];
    }
    
    [self setSelectedIndex:sender.tag - kXHMenuButtonBaseTag animated:YES calledDelegate:YES];
}

#pragma mark - Life cycle

- (UIImageView *)getShadowView:(BOOL)isLeft {
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, CGRectGetHeight(self.bounds))];
    shadowImageView.image = [UIImage imageNamed:(isLeft ? @"leftShadow" : @"rightShadow")];
    /** keep this code due with layer shadow
    shadowImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowImageView.layer.shadowOffset = CGSizeMake((isLeft ? 2.5 : -1.5), 0);
    shadowImageView.layer.shadowRadius = 3.2;
    shadowImageView.layer.shadowOpacity = 0.5;
    shadowImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowImageView.bounds].CGPath;
     */
    
    shadowImageView.hidden = isLeft;
    return shadowImageView;
}

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _selectedIndex = 0;
    
    _leftShadowView = [self getShadowView:YES];
    _leftShadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    _rightShadowView = [self getShadowView:NO];
    _rightShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    CGFloat width = CGRectGetHeight(self.bounds);
    _managerMenusButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - width, 0, width, width)];
    _managerMenusButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _managerMenusButton.backgroundColor = self.backgroundColor;
    [_managerMenusButton setImage:[UIImage imageNamed:@"managerMenuButton"] forState:UIControlStateNormal];
    [_managerMenusButton addTarget:self action:@selector(managerMenusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rightShadowViewFrame = _rightShadowView.frame;
    rightShadowViewFrame.origin = CGPointMake(CGRectGetMinX(_managerMenusButton.frame) - CGRectGetWidth(rightShadowViewFrame), 0);
    _rightShadowView.frame = rightShadowViewFrame;
//     - CGRectGetWidth(rightShadowViewFrame) * 2 - CGRectGetWidth(_managerMenusButton.frame)
    //原始
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftShadowView.frame), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    //修改
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    UIView * underlineView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height - 1, _scrollView.frame.size.width, 0.5)];
    [self addSubview:underlineView];
    underlineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    _indicatorView = [XHIndicatorView initIndicatorView];
    _indicatorView.alpha = 0.;
    [_scrollView addSubview:self.indicatorView];
    
    [self addSubview:self.scrollView];
//    [self addSubview:self.leftShadowView];
//    [self addSubview:self.rightShadowView];
//    [self addSubview:self.managerMenusButton];
}

- (void)setupIndicatorFrame:(CGRect)menuButtonFrame animated:(BOOL)animated callDelegate:(BOOL)called {
    [UIView animateWithDuration:(animated ? 0.15 : 0) delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _indicatorView.frame = CGRectMake(CGRectGetMinX(menuButtonFrame)-10, CGRectGetHeight(self.bounds) - kXHIndicatorViewHeight, CGRectGetWidth(menuButtonFrame), kXHIndicatorViewHeight);
    } completion:^(BOOL finished) {
        if (called) {
            if ([self.delegate respondsToSelector:@selector(scrollMenuDidSelected:menuIndex:)]) {
                [self.delegate scrollMenuDidSelected:self menuIndex:self.selectedIndex];
            }
        }
    }];
}

- (UIButton *)getButtonWithMenu:(XHMenu *)menu {
    CGSize buttonSize = [menu.title sizeWithFont:menu.titleFont constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds) - 10) lineBreakMode:NSLineBreakByCharWrapping];
    MenuButton *button = [[MenuButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    button.titleLabel.font = menu.titleFont;
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:menu.title forState:UIControlStateNormal];
    [button setTitle:menu.title forState:UIControlStateHighlighted];
    [button setTitle:menu.title forState:UIControlStateSelected];
    [button setTitleColor:menu.titleNormalColor forState:UIControlStateNormal];
    if (!menu.titleHighlightedColor) {
        menu.titleHighlightedColor = menu.titleNormalColor;
    }
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width / 2 + 5, 0, 30, button.frame.size.height)];
//    label.text = [NSString stringWithFormat:@"%d", menu.numbers];
//    if (menu.numbers > 99) {
//        label.text = @"99+";
//    }
//    label.layer.cornerRadius = label.frame.size.height/2;
//    label.font = [UIFont systemFontOfSize:14];
//    label.clipsToBounds = YES;
//    label.backgroundColor = RGB(0, 127, 255);
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    [button addSubview:label];
    [button setTitleColor:menu.titleHighlightedColor forState:UIControlStateHighlighted];
    if (!menu.titleSelectedColor) {
        menu.titleSelectedColor = menu.titleNormalColor;
    }
    [button setTitleColor:menu.titleSelectedColor forState:UIControlStateSelected];
    [button addTarget:self action:@selector(menuButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

#pragma mark - Public

- (CGRect)rectForSelectedItemAtIndex:(NSUInteger)index {
    CGRect rect = ((UIView *)self.menuButtons[index]).frame;
    return rect;
}

- (XHMenuButton *)menuButtonAtIndex:(NSUInteger)index {
    return self.menuButtons[index];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)aniamted calledDelegate:(BOOL)calledDelgate {
    _selectedIndex = selectedIndex;
    UIButton *selectedMenuButton = [self menuButtonAtIndex:_selectedIndex];
    CGRect selectedMenuRect = selectedMenuButton.frame;
    selectedMenuRect.size.width += 20;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView scrollRectToVisibleCenteredOn:selectedMenuButton.frame animated:NO];
    } completion:^(BOOL finished) {
        [self changeButtonTitleColor:selectedIndex];
        [self setupIndicatorFrame:selectedMenuRect animated:aniamted callDelegate:calledDelgate];

    }];
}

//改变选中字体颜色

- (void)changeButtonTitleColor:(NSUInteger)selectIndex{
    UIButton * selectButton = [self menuButtonAtIndex:selectIndex];
    [self.menuButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == selectButton) {
            selectButton.selected = YES;
        } else {
            UIButton *menuButton = obj;
            menuButton.selected = NO;
        }
    }];
//    for (int i = 0; i < self.menuButtons.count; i++) {
//        UIButton * selectButton = [self menuButtonAtIndex:i];
//        XHMenu * menu = self.menus[i];
//        if (i == selectIndex) {
//            [selectButton setTitleColor:menu.titleSelectedColor forState:UIControlStateNormal];
//        }else{
//            [selectButton setTitleColor:menu.titleNormalColor forState:UIControlStateNormal];
//        }
//    }
}

- (void)reloadData {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [((UIButton *)obj) removeFromSuperview];
        }
    }];
    if (self.menuButtons.count)
        [self.menuButtons removeAllObjects];
    
    // layout subViews
    CGFloat contentWidth = 10;
    for (XHMenu *menu in self.menus) {
        NSUInteger index = [self.menus indexOfObject:menu];
        UIButton *menuButton = [self getButtonWithMenu:menu];
        menuButton.tag = kXHMenuButtonBaseTag + index;
        CGRect menuButtonFrame = menuButton.frame;
        CGFloat buttonX = 0;
        if (index) {
            
            //原始
            //buttonX = kXHMenuButtonPaddingX + CGRectGetMaxX(((UIButton *)(self.menuButtons[index - 1])).frame);
            buttonX = [UIScreen mainScreen].bounds.size.width / 2 + ([UIScreen mainScreen].bounds.size.width / 2 - menuButtonFrame.size.width) / 2 ;
            
        } else {
            //修改
            buttonX = ([UIScreen mainScreen].bounds.size.width / 2 - menuButtonFrame.size.width) / 2 ;
            //原始 buttonX ＝ kXHMenuButtonStarX;
        }
        
        menuButtonFrame.origin = CGPointMake(buttonX, CGRectGetMidY(self.bounds) - (CGRectGetHeight(menuButtonFrame) / 2.0));
        menuButton.frame = menuButtonFrame;
        [self.scrollView addSubview:menuButton];
        [self.menuButtons addObject:menuButton];
        
        // scrollView content size width
        if (index == self.menus.count - 1) {
            contentWidth += CGRectGetMaxX (menuButtonFrame);
        }
        
        if (self.selectedIndex == index) {
            menuButton.selected = YES;
            // indicator
            _indicatorView.alpha = 1.;
            [self setupIndicatorFrame:menuButtonFrame animated:NO callDelegate:NO];
        }
    }
    //原始
//    [self.scrollView setContentSize:CGSizeMake(contentWidth + kXHMenuButtonStarX, CGRectGetHeight(self.scrollView.frame))];
//    [self rectScrollViewFrame];
    [self setSelectedIndex:self.selectedIndex animated:NO calledDelegate:YES];
}

- (void)rectScrollViewFrame{
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (self.scrollView.contentSize.width < rect.size.width) {
        self.scrollView.frame = CGRectMake(320/2 - self.scrollView.contentSize.width / 2, self.scrollView.frame.origin.y, self.scrollView.contentSize.width, self.scrollView.frame.size.height);
    }
}

#pragma mark - UIScrollView delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat contentOffsetX = scrollView.contentOffset.x;
//    CGFloat contentSizeWidth = (NSInteger)scrollView.contentSize.width;
//    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.bounds);
//    if (contentSizeWidth == scrollViewWidth) {
//        self.leftShadowView.hidden = YES;
//        self.rightShadowView.hidden = YES;
//    } else if (contentSizeWidth <= scrollViewWidth) {
//        self.leftShadowView.hidden = YES;
//        self.rightShadowView.hidden = YES;
//    } else {
//        if (contentOffsetX > 0) {
//            self.leftShadowView.hidden = NO;
//        } else {
//            self.leftShadowView.hidden = YES;
//        }
//        
//        if ((contentOffsetX + scrollViewWidth) >= contentSizeWidth) {
//            self.rightShadowView.hidden = YES;
//        } else {
//            self.rightShadowView.hidden = NO;
//        }
//    }
//}

@end
