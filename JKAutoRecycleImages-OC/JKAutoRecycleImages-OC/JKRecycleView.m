//
//  JKRecycleView.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//  自动无限轮播

#import "JKRecycleView.h"

@interface JKRecycleView () <UIScrollViewDelegate>
{
    UIView *_contentView;
    UIPageControl *_pageControl;
}

/** scrollView */
@property (nonatomic, strong) UIScrollView *scrollView;

/** 中间的label */
@property (nonatomic, weak) UILabel *middleLabel;

/** 提示的label */
@property (nonatomic, weak) UILabel *tipLabel;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

/** 当前的数据 */
@property (nonatomic, strong) NSArray *imageUrls;

/** 其它数据 */
@property (nonatomic, strong) NSMutableArray *otherDataDicts;

/** 图片容器view数组 */
@property (nonatomic, strong) NSMutableArray *imageContainerViews;

/** 要循环的imageView */
@property (nonatomic, strong) NSMutableArray *recycleImageViews;

/** 所有的imageView */
@property (nonatomic, strong) NSMutableArray *allImageViews;

/** 所有的label */
@property (nonatomic, strong) NSMutableArray *allTitleLabels;

/** 当前的索引 */
@property (nonatomic, assign) int currentIndex;

/** 当前的图片 */
@property (nonatomic, weak) UIImageView *currentImageView;

/** 只有2张图片时，额外的图片 */
@property (nonatomic, strong) UIImageView *thirdImageView;

/** 图片页数 */
@property (nonatomic, assign) int pagesCount;

/** 数据是否已经添加 */
@property (nonatomic, assign) BOOL isDataAdded;
@end

@implementation JKRecycleView

+ (instancetype)recycleViewWithFrame:(CGRect)frame{
    
    JKRecycleView *rv = [[JKRecycleView alloc] initWithFrame:frame];
    
    return rv;
}

#pragma mark - 懒加载
- (UIView *)contentView{
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self insertSubview:contentView atIndex:0];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        scrollView.scrollsToTop = NO;
        scrollView.scrollEnabled = NO;
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(3 * self.frame.size.width, 0);
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView insertSubview:scrollView atIndex:0];
        
        for (UIView *vv in scrollView.subviews) {
            [vv removeFromSuperview];
        }
        
        //        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        //        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.right.top.bottom.mas_equalTo(0);
        //        }];
        
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
        pageControl.userInteractionEnabled = NO;
//        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
//        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
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

- (NSMutableArray *)otherDataDicts{
    if (!_otherDataDicts) {
        _otherDataDicts = [NSMutableArray array];
    }
    return _otherDataDicts;
}

- (UIImageView *)thirdImageView{
    if (!_thirdImageView) {
        _thirdImageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    }
    return _thirdImageView;
}

- (NSMutableArray *)imageContainerViews{
    if (!_imageContainerViews) {
        _imageContainerViews = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            UIView *containerView = [[UIView alloc] init];
            [_imageContainerViews addObject:containerView];
        }
    }
    return _imageContainerViews;
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
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    // 初始化数据
    _autoRecycleInterval = 3;
    _autoRecycle = YES;
    
    // 初始化scrollView
    [self scrollView];
    
    // 初始化pageControl
    [self pageControl];
    
    // 添加手势
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMiddleImageView)]];
    
    //    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    //    tipLabel.text = @"此处应有图片";
    //    tipLabel.textColor = [UIColor whiteColor];
    //    tipLabel.textAlignment = NSTextAlignmentCenter;
    //    [self insertSubview:tipLabel belowSubview:self.scrollView];
    //    self.tipLabel = tipLabel;
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//- (void)willResignActive{
//    [self removeTimer];
//}
//
//- (void)didBecomeActive{
//    [self addTimer];
//}

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
- (void)updateRecycleImageViews {
    
    if (self.allImageViews.count <= 0) {
        return;
    }
    
    // 先清空数组
    [self.recycleImageViews removeAllObjects];
    
    // 计算好上一张和下一张图片的索引
    int previousIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex - 1];
    int nextIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex + 1];
    
    // 按顺序添加要循环的三张图片
    if (_pagesCount == 2) {
        
        [self.recycleImageViews addObject:self.thirdImageView];
        
        // TODO: ---只有两张图片时这里也要设置图片
        self.thirdImageView.image = [UIImage imageNamed:self.imageUrls[previousIndex]];
//        [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrls[previousIndex]]];
        
    }else{
        
        [self.recycleImageViews addObject:self.allImageViews[previousIndex]];
    }
    
    [self.recycleImageViews addObject:self.allImageViews[self.currentIndex]];
    [self.recycleImageViews addObject:self.allImageViews[nextIndex]];
    
    if (self.allTitleLabels.count >= self.currentIndex + 1) {
        
        // 中间label赋值
        self.middleLabel = self.allTitleLabels[self.currentIndex];
    }
}

#pragma mark - 重载recycleImageViews
- (void)reloadRecycleImageViews {
    
    // 先让scrollView移除所有控件
    for (UIImageView *imgv in self.recycleImageViews) {
        
        [imgv removeFromSuperview];
    }
    
    // 更新要循环的三张图片
    [self updateRecycleImageViews];
    
    // 将这三张图片添加到scrollView
    for (NSInteger i = 0; i < 3; i++) {
        
        UIView *containerView = self.imageContainerViews[i];
        
        UIImageView *imageView = self.recycleImageViews[i];
        imageView.transform = CGAffineTransformIdentity;
        
        CGRect rect = imageView.frame;
        
        containerView.frame = CGRectMake(_scrollView.bounds.size.width * i, rect.origin.y, rect.size.width, rect.size.height);
        
        imageView.frame = containerView.bounds;
        
        [containerView addSubview:imageView];
        
        if (self.scaleAnimated) {
            imageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            imageView.center = CGPointMake(containerView.frame.size.width * 0.5, containerView.frame.size.height * 0.5);
        }
        
        [_scrollView addSubview:containerView];
    }
    
    // 如果只有一张图片及以下，就没必要滚动了吧
    _scrollView.scrollEnabled = YES;
    
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
    
    if (!_autoRecycle ||
        _pagesCount <= 1 ||
        self.timer != nil ||
        _autoRecycleInterval <= 1) return;
    
    __weak typeof(self) weakSelf = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_autoRecycleInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [weakSelf startAutoRecycle];
        
    }];
}

#pragma mark - 移除定时器
- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 循环滚动的方法
- (void)startAutoRecycle {
    
    if (!self.timer) {
        return;
    }
    
    CGPoint newOffset = CGPointMake(_scrollView.bounds.size.width * 2, 0);
    [_scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - ScrollView Delegate
// 根据滚动的偏移量设置当前的索引，并更新要进行循环的三张图片
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX >= (2 * _scrollView.bounds.size.width)) {
        
        self.currentIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex + 1];
        self.currentImageView = self.allImageViews[self.currentIndex];
        [self reloadRecycleImageViews];
    }
    
    if (offsetX <= 0) {
        
        self.currentIndex = [self getVaildNextPageIndexWithIndex:self.currentIndex - 1];
        self.currentImageView = self.allImageViews[self.currentIndex];
        [self reloadRecycleImageViews];
    }
}

// 减速完毕 重新设置scrollView的x偏移
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0) animated:YES];
    
    if (!self.scaleAnimated) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.currentImageView.transform = CGAffineTransformIdentity;
    }];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (!self.scaleAnimated) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.currentImageView.transform = CGAffineTransformIdentity;
    }];
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
/** 设置数据 */
- (void)setImageUrls:(NSArray *)imageUrls titles:(NSArray *)titles otherDataDicts:(NSArray <NSDictionary *> *)otherDataDicts{
    
    if (imageUrls.count <= 0 || imageUrls == nil) {
        
        [self removeTimer];
        
        _pagesCount = 0;
        _scrollView.scrollEnabled = NO;
        _pageControl.hidden = YES;
        self.tipLabel.hidden = NO;
        
        for (UIImageView *imgv in _allImageViews) {
            [imgv removeFromSuperview];
        }
        
        [_allImageViews removeAllObjects];
        [_recycleImageViews removeAllObjects];
        [_allTitleLabels removeAllObjects];
        [_otherDataDicts removeAllObjects];
        
        return;
    }
    
    self.tipLabel.hidden = YES;
    
    self.isDataAdded = NO;
    
    // 防止重复赋值
    if (imageUrls.count == self.imageUrls.count) {
        
        self.isDataAdded = YES;
        
        for (int i = 0; i < imageUrls.count; i++) {
            
            NSString *str1 = imageUrls[i];
            NSString *str2 = self.imageUrls[i];
            if ([str1 isEqualToString:str2]) continue;
            self.isDataAdded = NO;
            
            break;
        }
    }
    
    // 如果数据已经添加，直接返回
    if (self.isDataAdded) {
        return;
    }
    
    [self removeTimer];
    _pagesCount = 0;
    self.currentIndex = 0;
    _scrollView.scrollEnabled = NO;
    
    // 赋值
    self.imageUrls = nil;
    self.imageUrls = [imageUrls copy];
    [self.otherDataDicts removeAllObjects];
    [self.otherDataDicts addObjectsFromArray:otherDataDicts];;
    
    // pageControl的页数就是图片的个数
    _pagesCount = (int)imageUrls.count;
    self.pageControl.numberOfPages = _pagesCount;
    
    // 先清空数组
    [self.allImageViews removeAllObjects];
    [self.allTitleLabels removeAllObjects];
    
    // 循环创建imageView等控件，添加到数组中
    for (int i = 0; i < _pagesCount; i++) {
        
        // 创建imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        
// TODO: --- 在这里设置图片
        imageView.image = [UIImage imageNamed:imageUrls[i]];
//        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrls[i]]];
        
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        // 将控件添加到数组
        [self.allImageViews addObject:imageView];
        
        if (titles == nil || titles.count < imageUrls.count) continue;
        
        // 创建titleLabel
        UILabel *titleLabel = [[UILabel alloc] init];
        //        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(0, imageView.bounds.size.height-50, imageView.bounds.size.width, 30);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(1, 0);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        titleLabel.text = titles[i];
        
        CGSize labelSize = [titleLabel sizeThatFits:CGSizeMake(imageView.bounds.size.width-30, MAXFLOAT)];
        titleLabel.frame = CGRectMake(15, self.pageControl.frame.origin.y - labelSize.height, imageView.bounds.size.width-30, labelSize.height);
        
        [imageView addSubview:titleLabel];
        
        [self.allTitleLabels addObject:titleLabel];
    }
    
    _scrollView.scrollEnabled = YES;
    
    // 更新要进行循环的三张图片
    [self reloadRecycleImageViews];
    
    // 开始自动循环
    [self addTimer];
    
    if (imageUrls.count <= 1) {
        
        _pageControl.hidden = YES;
    }
    
    self.currentImageView = self.allImageViews.firstObject;
    
    if (!self.scaleAnimated) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.currentImageView.transform = CGAffineTransformIdentity;
    }];
}

- (void)setAutoRecycle:(BOOL)autoRecycle{
    _autoRecycle = autoRecycle;
    
    [self removeTimer];
    [self addTimer];
}

- (void)setAutoRecycleInterval:(NSTimeInterval)autoRecycleInterval{
    
    if (autoRecycleInterval < 1) return;
    
    _autoRecycleInterval = autoRecycleInterval;
    
    [self removeTimer];
    [self addTimer];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimer];
    NSLog(@"%d, %s",__LINE__, __func__);
}

#pragma mark - 点击了中间的ImageView即当前显示的ImageView
- (void)clickMiddleImageView {
    
    if (_pagesCount <= 0) {
        return;
    }
    
    !self.imageClickBlock ? : self.imageClickBlock(self.currentIndex, (self.otherDataDicts.count == self.imageUrls.count) ? [self.otherDataDicts objectAtIndex:self.currentIndex] : @{@"error" : @"图片和其它数据不一致"});
    
    if ([self.delegate respondsToSelector:@selector(recycleView:didClickImageWithIndex:otherDataDict:)]) {
        [self.delegate recycleView:self didClickImageWithIndex:self.currentIndex otherDataDict:(self.otherDataDicts.count == self.imageUrls.count) ? [self.otherDataDicts objectAtIndex:self.currentIndex] : @{@"error" : @"图片和其它数据不一致"}];
    }
}
@end
