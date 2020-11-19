//
//  JKCycleBannerView.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//  自动无限轮播

#import "JKCycleBannerView.h"

@class JKCycleBannerCell;

@protocol JKCycleBannerCellDelegate <NSObject>

@optional

/** 自定义加载图片 */
- (BOOL)bannerCell:(JKCycleBannerCell *)bannerCell loadImageWithImageView:(UIImageView *)imageView dict:(NSDictionary *)dict;
@end

#pragma mark
#pragma mark - -------------cell-------------

@interface JKCycleBannerCell : UICollectionViewCell

/** delegate */
@property (nonatomic, weak) id<JKCycleBannerCellDelegate> delegate;

- (void)bindDict:(NSDictionary *)dict
    contentInset:(UIEdgeInsets)contentInset
    cornerRadius:(CGFloat)cornerRadius;
@end

#pragma mark
#pragma mark - -------------JKCycleBannerView-------------

@interface JKCycleBannerView () <UICollectionViewDataSource, UICollectionViewDelegate, JKCycleBannerCellDelegate>
{
    UIView *_contentView;
    UIPageControl *_pageControl;
}

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** timer */
@property (nonatomic, strong) dispatch_source_t timer;

/** dataSourceArr */
@property (nonatomic, strong) NSMutableArray *dataSourceArr;

/** pagesCount */
@property (nonatomic, assign) NSInteger pagesCount;
@end

@implementation JKCycleBannerView

#pragma mark
#pragma mark - Public Methods

+ (instancetype)recycleViewWithFrame:(CGRect)frame {
    
    JKCycleBannerView *recycleView = [[JKCycleBannerView alloc] initWithFrame:frame];
    
    recycleView.flowlayout.itemSize = CGSizeMake(frame.size.width + 2, frame.size.height);
    
    return recycleView;
}

- (void)setAutoRecycle:(BOOL)autoRecycle {
    _autoRecycle = autoRecycle;
    
    [self removeTimer];
    [self addTimer];
}

- (void)setAutoRecycleInterval:(NSTimeInterval)autoRecycleInterval {
    
    if (autoRecycleInterval < 1) return;
    
    _autoRecycleInterval = autoRecycleInterval;
    
    [self removeTimer];
    [self addTimer];
}

/**
 * 设置数据
 * 数组中每个元素应是NSDictionary类型
 * NSDictionary必须有一个图片urlkey JKCycleBannerImageUrlKey
 * JKCycleBannerTitleKey和JKCycleBannerOtherDictKey可有可无
 */
- (void)setDataSource:(NSArray <NSDictionary *> *)dataSource {
    
    _pagesCount = dataSource.count;
    
    self.pageControl.numberOfPages = _pagesCount;
    
    [self.dataSourceArr removeAllObjects];
    
    for (NSDictionary *dict in dataSource) {
        
        if ([dict isKindOfClass:[NSDictionary class]]) {
            
            [self.dataSourceArr addObject:dict];
            
        } else {
            
            NSAssert(NO, @"dataSource中对象必须是NSDictionary类型!");
            
            [self.dataSourceArr removeAllObjects];
            
            return;
        }
    }
    
    if (_pagesCount <= 1) {
        
        self.collectionView.scrollEnabled = NO;
        
        [self.collectionView reloadData];
        
        return;
    }
    
    self.collectionView.scrollEnabled = YES;
    
    [self.dataSourceArr addObject:[dataSource.firstObject copy]];
    [self.dataSourceArr insertObject:[dataSource.lastObject copy] atIndex:0];
    
    [self.collectionView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    
        [self addTimer];
    });
}

- (void)addTimer {
    
    if (!_autoRecycle ||
        _pagesCount <= 1 ||
        self.timer != nil ||
        _autoRecycleInterval < 1 ||
        self.collectionView.isDragging) { return; }
    
    __weak typeof(self) weakSelf = self;
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    uint64_t interval = (uint64_t)(_autoRecycleInterval * NSEC_PER_SEC);
    
    dispatch_time_t delayTime = dispatch_walltime(NULL, (int64_t)(_autoRecycleInterval * NSEC_PER_SEC));
    
    dispatch_source_set_timer(self.timer, delayTime, interval, 0);
    
    dispatch_source_set_event_handler(self.timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf startAutoRecycle];
        });
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}

- (void)removeTimer {
    
    if (!self.timer) { return; }
    
    dispatch_source_cancel(self.timer);
    
    self.timer = nil;
}

#pragma mark
#pragma mark - Override

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeTimer];
    
    // TODO: - JKTODO delete
    NSLog(@"[ClassName: %@], %d, %s", NSStringFromClass([self class]), __LINE__, __func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) { return; }
    
    [self removeTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.collectionView.frame = CGRectMake(-1, 0, self.contentView.bounds.size.width + 2, self.contentView.bounds.size.height);
    
    self.flowlayout.itemSize = self.collectionView.bounds.size;
    
    if (_manualPageControlFrame) { return; }
    
    if (self.pageControlInBottomInset) {
        
        self.pageControl.frame = CGRectMake(0, self.bounds.size.height - self.contentInset.bottom + (self.contentInset.bottom - 20) * 0.5, self.bounds.size.width, 20);
        
    } else {
        
        self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 20 - self.contentInset.bottom, self.bounds.size.width, 20);
    }
}

#pragma mark
#pragma mark - Private Methods

- (void)startAutoRecycle {
    
    if (!self.timer || self.collectionView.isDragging) { return; }
    
    CGPoint newOffset = CGPointMake(_collectionView.contentOffset.x + _collectionView.bounds.size.width, 0);
    
    [_collectionView setContentOffset:newOffset animated:YES];
}

#pragma mark
#pragma mark - Private Selector



#pragma mark
#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataSourceArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JKCycleBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JKCycleBannerCell class]) forIndexPath:indexPath];
    
    [cell bindDict:self.dataSourceArr[indexPath.item] contentInset:self.contentInset cornerRadius:self.cornerRadius];
    
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    !self.imageClickBlock ? : self.imageClickBlock(self.dataSourceArr[indexPath.item]);
    
    if ([self.delegate respondsToSelector:@selector(cycleBannerView:didClickImageWithDict:)]) {
        
        [self.delegate cycleBannerView:self didClickImageWithDict:self.dataSourceArr[indexPath.item]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_scaleAnimated) {
        
        cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_scaleAnimated) { return; }
    
    NSIndexPath *index = [collectionView indexPathsForVisibleItems].lastObject;
    
    UICollectionViewCell *cell1 = [collectionView cellForItemAtIndexPath:index];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        cell1.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!scrollView.isDragging) { return; }
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    // 在最左侧
    if (contentOffset.x < scrollView.bounds.size.width) {
        
        contentOffset.x += (scrollView.bounds.size.width * (_pagesCount * 1.0));
        
        scrollView.contentOffset = contentOffset;
        
        return;
    }
    
    CGFloat delta = scrollView.contentOffset.x / scrollView.bounds.size.width - ((_pagesCount + 1) * 1.0);
    
    // 在最右侧
    if (delta > 0.0) {
        
        contentOffset.x = scrollView.bounds.size.width * (1.0 + delta);
        
        scrollView.contentOffset = contentOffset;
    }
}

// 减速完毕 重新设置scrollView的x偏移
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self adjustContentOffset:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self adjustContentOffset:scrollView];
}

- (void)adjustContentOffset:(UIScrollView *)scrollView {
    
    NSInteger page = (NSInteger)((scrollView.contentOffset.x) / scrollView.bounds.size.width);
    
    if (page == 0) { // 滚动到左边，自动调整到倒数第二
        
        //scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width * (_pagesCount), 0);
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSourceArr.count - 2 inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        
        self.pageControl.currentPage = _pagesCount;
        
        if (_scaleAnimated) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.pagesCount inSection:0]];
                
                [UIView animateWithDuration:0.25 animations:^{
                    
                    cell.transform = CGAffineTransformIdentity;
                }];
            });
        }
        
    } else if (page == _pagesCount + 1){ // 滚动到右边，自动调整到第二个
        
        //scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        
        self.pageControl.currentPage = 0;
        
        if (_scaleAnimated) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
                
                [UIView animateWithDuration:0.25 animations:^{
                    
                    cell.transform = CGAffineTransformIdentity;
                }];
            });
        }
        
    } else {
        
        self.pageControl.currentPage = page - 1;
    }
}

// 手指拖动 移除定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self removeTimer];
}

// 手指松开 添加定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self addTimer];
}

#pragma mark
#pragma mark - JKCycleBannerCellDelegate

/** 自定义加载图片 */
- (BOOL)bannerCell:(JKCycleBannerCell *)bannerCell loadImageWithImageView:(UIImageView *)imageView dict:(NSDictionary *)dict {
    
    return !!self.loadImageBlock || [self.delegate respondsToSelector:@selector(bannerCell:loadImageWithImageView:dict:)];
}

#pragma mark
#pragma mark - Initialization & Build UI

/** 初始化自身属性 交给子类重写 super自动调用该方法 */
- (void)initializeProperty {
    
    // 初始化数据
    _autoRecycleInterval = 3;
    _autoRecycle = YES;
}

/** 构造函数初始化时调用 注意调用super */
- (void)initialization {
    
    [self initializeProperty];
    [self createUI];
    [self layoutUI];
    [self initializeUIData];
}

/** 创建UI 交给子类重写 super自动调用该方法 */
- (void)createUI {
    
    // 初始化scrollView
    [self collectionView];
}

/** 布局UI 交给子类重写 super自动调用该方法 */
- (void)layoutUI {
    
}

/** 初始化UI数据 交给子类重写 super自动调用该方法 */
- (void)initializeUIData {
    
}

#pragma mark
#pragma mark - Private Property

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.clipsToBounds = YES;
        [self insertSubview:contentView atIndex:0];
        _contentView = contentView;
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _flowlayout = [[UICollectionViewFlowLayout alloc] init];
        _flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowlayout.minimumLineSpacing = 0;
        _flowlayout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowlayout];
        collectionView.backgroundColor = nil;
        collectionView.scrollsToTop = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self.contentView insertSubview:collectionView atIndex:0];
        [collectionView registerClass:[JKCycleBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([JKCycleBannerCell class])];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20 - self.contentInset.bottom, self.bounds.size.width, 20)];
        pageControl.hidesForSinglePage = YES;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        [self.contentView addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (NSMutableArray *)dataSourceArr {
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}
@end

#pragma mark - -------------cell-------------

@interface JKCycleBannerCell ()

/** dict */
@property (nonatomic, copy, readonly) NSDictionary *dict;

/** containerView */
@property (nonatomic, weak) UIView *containerView;

/** imageView */
@property (nonatomic, weak) UIImageView *imageView;

/** 图片内缩的大小 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

/** titleLabel */
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation JKCycleBannerCell

#pragma mark
#pragma mark - Public Methods

- (void)bindDict:(NSDictionary *)dict
    contentInset:(UIEdgeInsets)contentInset
    cornerRadius:(CGFloat)cornerRadius {
    
    _dict = [dict copy];
    
    [self updateUIWithContentInset:contentInset cornerRadius:cornerRadius];
    
    BOOL customizeLoadImageFlag = NO;
    
    if ([self.delegate respondsToSelector:@selector(bannerCell:loadImageWithImageView:dict:)]) {
        
        customizeLoadImageFlag = [self.delegate bannerCell:self loadImageWithImageView:self.imageView dict:dict];
    }
    
    if (!customizeLoadImageFlag) {
        
        self.imageView.image = [UIImage imageNamed:_dict[JKCycleBannerImageUrlKey]];
    }
    
    if (_dict[JKCycleBannerTitleKey] == nil) {
        
        _titleLabel.hidden = YES;
        
        return;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@", _dict[JKCycleBannerTitleKey]];
    
    self.titleLabel.hidden = NO;
}

#pragma mark
#pragma mark - Override

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutUI];
}

#pragma mark
#pragma mark - Private Methods

- (void)updateUIWithContentInset:(UIEdgeInsets)contentInset
                    cornerRadius:(CGFloat)cornerRadius {
    
    if (self.imageView.layer.cornerRadius != cornerRadius) {
        
        self.imageView.layer.cornerRadius = cornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(contentInset, self.contentInset)) {
        
        self.contentInset = contentInset;
        
        [self setNeedsLayout];
    }
}

#pragma mark
#pragma mark - Private Selector



#pragma mark
#pragma mark - Initialization & Build UI

/** 初始化自身属性 交给子类重写 super自动调用该方法 */
- (void)initializeProperty {
    
    self.contentInset = UIEdgeInsetsZero;
}

/** 构造函数初始化时调用 注意调用super */
- (void)initialization {
    
    [self initializeProperty];
    [self createUI];
    [self layoutUI];
    [self initializeUIData];
}

/** 创建UI 交给子类重写 super自动调用该方法 */
- (void)createUI {
    
    UIView *containerView = [[UIView alloc] init];
    [self.contentView insertSubview:containerView atIndex:0];
    _containerView = containerView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.containerView addSubview:imageView];
    _imageView = imageView;
}

/** 布局UI 交给子类重写 super自动调用该方法 */
- (void)layoutUI {
    
    self.containerView.frame = CGRectMake(1, 0, CGRectGetWidth(self.contentView.frame) - 2, CGRectGetHeight(self.contentView.frame));
    
    self.imageView.frame = CGRectMake(self.contentInset.left, self.contentInset.top, CGRectGetWidth(self.containerView.frame) - self.contentInset.left - self.contentInset.right, CGRectGetHeight(self.containerView.frame) - self.contentInset.top - self.contentInset.bottom);
    
    if (!_titleLabel) { return; }
    
    CGSize labelSize = [_titleLabel sizeThatFits:CGSizeMake(self.containerView.bounds.size.width - 30 - self.contentInset.left - self.contentInset.right, INFINITY)];
    
    _titleLabel.frame = CGRectMake((CGRectGetWidth(self.containerView.frame) - labelSize.width) * 0.5, self.containerView.bounds.size.height - 20 - labelSize.height - self.contentInset.bottom, labelSize.width, labelSize.height);
}

/** 初始化UI数据 交给子类重写 super自动调用该方法 */
- (void)initializeUIData {
    
}

#pragma mark
#pragma mark - Private Property

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(100, 20, 100, 30);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(1, 0);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.containerView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}
@end
