//
//  JKRecycleView.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//

#import "JKRecycleView.h"

@interface JKRecycleView () <UIScrollViewDelegate>
/** scrollView */
@property (nonatomic, strong) UIScrollView *scrollView;

/** pageControl */
@property (nonatomic, strong) UIPageControl *pageControl;

/** 中间的label */
@property (nonatomic, weak) UILabel *middleLabel;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

/** 当前的数据 */
@property (nonatomic, strong) NSArray *imageNames;

/** 要循环的imageView */
@property (nonatomic, strong) NSMutableArray *recycleImageViews;

/** 所有的imageView */
@property (nonatomic, strong) NSMutableArray *allImageViews;

/** 所有的label */
@property (nonatomic, strong) NSMutableArray *allTitleLabels;

/** 当前的索引 */
@property (nonatomic, assign) int currentIndex;

/** 图片页数 */
@property (nonatomic, assign) int pagesCount;

/** 数据是否应添加 */
@property (nonatomic, assign) BOOL isDataAdded;
@end

@implementation JKRecycleView

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(3 * self.bounds.size.width, 0);
        [self insertSubview:scrollView atIndex:0];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 37);
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (NSMutableArray *)recycleImageViews {
    if (!_recycleImageViews) {
        _recycleImageViews = [NSMutableArray array];
    }
    return _recycleImageViews;
}

- (NSMutableArray *)allImageViews {
    if (!_allImageViews) {
        _allImageViews = [NSMutableArray array];
    }
    return _allImageViews;
}

- (NSMutableArray *)allTitleLabels {
    if (!_allTitleLabels) {
        _allTitleLabels = [NSMutableArray array];
    }
    return _allTitleLabels;
}

#pragma mark - 初始化
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    // 初始化数据
    _autoRecycleInterval = 3;
    _isAutoRecycle = YES;
    
    // 初始化scrollView
    [self scrollView];
    
    // 初始化pageControl
    [self pageControl];
    
    // 添加手势
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMiddleImageView)]];
}

#pragma mark - 传入一个index来获取下一个正确的index
- (int)getVaildNextPageIndexWithIndex:(int)index {
    if (index == -1) {
        return _pagesCount - 1;
    } else if (index == _pagesCount) {
        return 0;
    }
    return index;
}

#pragma mark - 更新recycleImageViews
- (void)updaterecycleImageViews {
    // 先清空数组
    [self.recycleImageViews removeAllObjects];
    
    // 计算好上一张和下一张图片的索引
    int previousIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex - 1];
    int nextIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex + 1];
    
    // 按顺序添加要循环的三张图片
    [self.recycleImageViews addObject:self.allImageViews[previousIndex]];
    [self.recycleImageViews addObject:self.allImageViews[self.currentIndex]];
    [self.recycleImageViews addObject:self.allImageViews[nextIndex]];
    
    // 中间label赋值
    if (self.allTitleLabels.count < self.currentIndex + 1) return;
    self.middleLabel = self.allTitleLabels[self.currentIndex];
}

#pragma mark - 重载recycleImageViews
- (void)reloadRecycleImageViews {
    // 先让scrollView移除所有控件
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 更新要循环的三张图片
    [self updaterecycleImageViews];
    
    // 将这三张图片添加到scrollView
    for (NSInteger i = 0; i < self.recycleImageViews.count; i++) {
        UIImageView *imageView = self.recycleImageViews[i];
        
        CGRect rect = imageView.frame;
        imageView.frame = CGRectMake(self.scrollView.bounds.size.width * i, rect.origin.y, rect.size.width, rect.size.height);
        [_scrollView addSubview:self.recycleImageViews[i]];
    }
    
    // 如果只有一张图片及以下，就没必要滚动了吧
    if (_pagesCount <= 1) {
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width * 2, 0);
        _scrollView.scrollEnabled = NO;
        _pageControl.hidden = YES;
        return;
    }
    
    // 设置scollView偏移
    _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    
    // 设置pageControl的当前页
    _pageControl.currentPage = self.currentIndex;
}

#pragma mark - 添加定时器
- (void)addTimer {
    if (!self.isAutoRecycle) return;
    if (_pagesCount == 1) return;
    if (self.timer) return;
    self.timer = [NSTimer timerWithTimeInterval:_autoRecycleInterval target:self selector:@selector(startAutoRecycle) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 移除定时器
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 循环滚动的方法
- (void)startAutoRecycle {
    CGPoint newOffset = CGPointMake(_scrollView.bounds.size.width * 2, 0);
    [_scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - ScrollView Delegate
// 根据滚动的偏移量设置当前的索引，并更新要进行循环的三张图片
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    if(offsetX >= (2 * _scrollView.bounds.size.width)) {
        self.currentIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex + 1];
        [self reloadRecycleImageViews];
    }
    if(offsetX <= 0) {
        self.currentIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex - 1];
        [self reloadRecycleImageViews];
    }
}

// 减速完毕 重新设置scrollView的x偏移
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0) animated:YES];
}

// 手指拖动 移除定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

// 手指松开 添加定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

#pragma mark - setter方法
- (void)setImageNames:(NSArray *)imageNames titles:(NSArray *)titles {
    // 防止重复赋值
    if (imageNames.count == self.imageNames.count) {
        self.isDataAdded = YES;
        for (int i = 0; i < imageNames.count; i++) {
            NSString *str1 = imageNames[i];
            NSString *str2 = self.imageNames[i];
            if ([str1 isEqualToString:str2]) continue;
            self.isDataAdded = NO;
            break;
        }
    }
    // 如果数据已经添加，直接返回
    if (self.isDataAdded) return;
    
    // 赋值
    self.imageNames = imageNames;
    
    // pageControl的页数就是图片的个数
    _pagesCount = (int)imageNames.count;
    self.pageControl.numberOfPages = _pagesCount;
    
    // 先清空数组
    [self.allImageViews removeAllObjects];
    [self.allTitleLabels removeAllObjects];
    
    // 循环创建imageView等控件，添加到数组中
    for (int i = 0; i < _pagesCount; i++) {
        // 创建imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNames[i] ofType:@"jpg"]];
        imageView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
        // 将控件添加到数组
        [self.allImageViews addObject:imageView];
        
        if (titles == nil || titles.count < imageNames.count) continue;
        
        // 创建titleLabel
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(0, imageView.bounds.size.height-50, imageView.bounds.size.width, 30);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(1, 0);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        titleLabel.text = titles[i];
        [imageView addSubview:titleLabel];
        [self.allTitleLabels addObject:titleLabel];
    }
    
    // 更新要进行循环的三张图片
    [self reloadRecycleImageViews];
    
    // 不自动循环
    if (!self.isAutoRecycle) return;
    
    // 开始自动循环
    [self addTimer];
}

- (void)setAutoRecycleInterval:(NSTimeInterval)autoRecycleInterval{
    _autoRecycleInterval = autoRecycleInterval;
    
    [self removeTimer];
    
    [self addTimer];
}

- (void)setIsAutoRecycle:(BOOL)isAutoRecycle{
    _isAutoRecycle = isAutoRecycle;
    
    [self removeTimer];
    
    [self addTimer];
}

- (void)dealloc{
    [self removeTimer];
}

#pragma mark - 点击了中间的ImageView即当前显示的ImageView
- (void)clickMiddleImageView {
    if ([self.delegate respondsToSelector:@selector(recycleView:didClickCurrentImageViewWithIndex:)]) {
        [self.delegate recycleView:self didClickCurrentImageViewWithIndex:self.currentIndex];
    }
}
@end
