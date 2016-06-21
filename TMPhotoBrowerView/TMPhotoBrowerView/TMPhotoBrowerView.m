//
//  TMPhotoBrowerView.m
//  
//
//  Created by tangshimi on 6/20/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import "TMPhotoBrowerView.h"
#import "TMPhotoCollectionViewCell.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

#define GetScreenWidth      [[UIScreen mainScreen] bounds].size.width
#define GetScreenHeight     [[UIScreen mainScreen] bounds].size.height

static NSString *kCollectionViewCellReuseID = @"MedPhotoCollectionViewCell";
static CGFloat const kAnimationDuration = 0.3;
static CGFloat const kTipDuration = 1.0;

@interface TMPhotoBrowerView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIImageView *rotationTemporaryImageView;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, assign) BOOL haveTransition;

@end

@implementation TMPhotoBrowerView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(self.originalImageURLArray, @"self.originalImageURLArray can't be nil");
    
    if (self.imageURLArray.count == 0) {
        self.imageURLArray = [self.originalImageURLArray copy];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.rotationTemporaryImageView];
    [self.view addSubview:self.indexLabel];
    [self.view addSubview:self.saveButton];
    self.rotationTemporaryImageView.hidden = YES;
    
    NSDictionary *views = @{ @"collectionView" : self.collectionView,
                             @"indexLabel" : self.indexLabel,
                             @"saveButton" : self.saveButton };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[indexLabel]"
                                                                      options:NSLayoutFormatAlignAllTop
                                                                      metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[saveButton(40)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[saveButton]-20-|" options:0 metrics:nil views:views]];
    
    self.indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(self.currentIndex + 1), @(self.imageURLArray.count)];
    
    self.collectionView.hidden = YES;
    self.indexLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showPhoto];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return self.canAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.hidden = YES;
    
    TMPhotoCollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
    
    CGRect frame = [cell convertRect:cell.imageView.frame toView:self.view];
    self.rotationTemporaryImageView.frame = frame;
    self.rotationTemporaryImageView.image = cell.imageView.image;
    
    self.rotationTemporaryImageView.hidden = NO;
    
    CGFloat scale = CGRectGetWidth(self.rotationTemporaryImageView.frame) / cell.imageView.image.size.width;
    self.rotationTemporaryImageView.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.collectionView.hidden = NO;
    self.rotationTemporaryImageView.hidden = YES;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TMPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseID forIndexPath:indexPath];
    __weak __typeof(self) weakSelf = self;
    cell.tapBlock = ^(NSInteger index) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf hidePhoto];
    };
    
    cell.defaultImage = self.defaultImage;
    [cell setImage:self.originalImageURLArray[indexPath.row] imageURL:self.imageURLArray[indexPath.row] indexPath:indexPath];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    self.indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(index + 1), @(self.imageURLArray.count)];
    
    self.currentIndex = index;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(GetScreenWidth, GetScreenHeight);
}

#pragma mark -
#pragma mark - response event -

- (void)saveButtonAction:(UIButton *)button
{
    TMPhotoCollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
    
    if (cell) {
        UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    } else {
        self.tipLabel.text = @"图片保存失败";
        [self showTipView];
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error) {
        message = @"图片已保存";
    } else {
        message = [error description];
    }
    
    self.tipLabel.text = message;
    
    [self showTipView];
}

#pragma mark -
#pragma mark - public -

- (void)show
{
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self
                                                                                 animated:NO
                                                                               completion:nil];
}

#pragma mark -
#pragma mark - private -

- (void)showPhoto
{    
    if (!self.haveTransition) {
        self.collectionView.contentOffset = CGPointMake(GetScreenWidth * self.currentIndex, 0);
        self.collectionView.hidden = NO;
        self.indexLabel.hidden = self.imageURLArray.count == 1 ? : NO;

        return;
    }
    
    UIImageView *temporaryImageView = [UIImageView new];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *originalKey = [manager cacheKeyForURL:[NSURL URLWithString:self.originalImageURLArray[self.currentIndex]]];
    NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:self.imageURLArray[self.currentIndex]]];
    
    if ([manager cachedImageExistsForURL:[NSURL URLWithString:self.imageURLArray[self.currentIndex]]]) {
        temporaryImageView.image = [manager.imageCache imageFromDiskCacheForKey:key];
    } else {
        temporaryImageView.image = [manager.imageCache imageFromMemoryCacheForKey:originalKey];
    }
    temporaryImageView.image = temporaryImageView.image ? : [UIImage imageNamed:self.defaultImage];
    
    [self.view addSubview:temporaryImageView];
    temporaryImageView.frame = [self.imageFrameArray[self.currentIndex] CGRectValue];
    
    CGRect temporaryImageViewFrame;
    
    if (temporaryImageView.image) {
        CGFloat showHeight = temporaryImageView.image.size.height / (temporaryImageView.image.size.width / GetScreenWidth);
        
        temporaryImageViewFrame = CGRectMake(0, 0, GetScreenWidth, showHeight);
        
        if (showHeight < GetScreenHeight) {
            temporaryImageViewFrame = CGRectMake(0, (GetScreenHeight - showHeight) / 2.0 , GetScreenWidth, showHeight);
        }
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        temporaryImageView.frame = temporaryImageViewFrame;
    } completion:^(BOOL finished) {
        [temporaryImageView removeFromSuperview];
        self.collectionView.contentOffset = CGPointMake(GetScreenWidth * self.currentIndex, 0);
        self.collectionView.hidden = NO;
        self.indexLabel.hidden = self.imageURLArray.count == 1 ? : NO;
    }];
}

- (void)hidePhoto
{
    if (!self.haveTransition) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.imageFrameArray.count - 1 < self.currentIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ( CGRectIsEmpty([self.imageFrameArray[self.currentIndex] CGRectValue])) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    TMPhotoCollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
    
    UIImageView *temporaryImageView = [UIImageView new];
    temporaryImageView.contentMode = UIViewContentModeScaleAspectFill;
    temporaryImageView.clipsToBounds = YES;
    temporaryImageView.frame = [cell.imageView.superview convertRect:cell.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:temporaryImageView];
    
    self.collectionView.hidden = YES;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *originalKey = [manager cacheKeyForURL:[NSURL URLWithString:self.originalImageURLArray[self.currentIndex]]];
    temporaryImageView.image = [manager.imageCache imageFromDiskCacheForKey:originalKey] ? : [UIImage imageNamed:self.defaultImage];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            temporaryImageView.frame = [self.imageFrameArray[self.currentIndex] CGRectValue];
        } completion:^(BOOL finished) {
            [temporaryImageView removeFromSuperview];
        }];
    }];
}

- (void)showTipView
{
    [self.view addSubview:self.tipView];
    
    NSDictionary *views = @{ @"tipView" : self.tipView };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[tipView(100)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tipView(100)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTipDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tipView removeFromSuperview];
    });
}

#pragma mark -
#pragma mark - setter and getter -

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView =  ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.minimumInteritemSpacing = 0.0f;
            flowLayout.minimumLineSpacing = 0.0f;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                                  collectionViewLayout:flowLayout];
            collectionView.translatesAutoresizingMaskIntoConstraints = NO;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.pagingEnabled = YES;
            [collectionView registerClass:[TMPhotoCollectionViewCell class]
               forCellWithReuseIdentifier:kCollectionViewCellReuseID];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView;
        });
    }
    return _collectionView;
}

- (UILabel *)indexLabel
{
    if (!_indexLabel) {
        _indexLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:18];
            label;
        });
    }
    return _indexLabel;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setTitle:@"保存" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            button.layer.cornerRadius = 3.0;
            button.layer.masksToBounds = YES;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor grayColor].CGColor;
            [button addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _saveButton;
}

- (UIImageView *)rotationTemporaryImageView
{
    if (!_rotationTemporaryImageView) {
        _rotationTemporaryImageView =  ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.autoresizingMask = 0xff;
            imageView.contentMode = UIViewContentModeCenter;
            imageView;
        });
    }
    return _rotationTemporaryImageView;
}

- (UIView *)tipView
{
    if (!_tipView) {
        _tipView = ({
            UIView *view = [[UIView alloc] init];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            view.layer.cornerRadius = 10;
            [view addSubview:self.tipLabel];
            
            NSDictionary *views = @{ @"tipLabel" : self.tipLabel };
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tipLabel]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tipLabel]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
            view;
        });
    }
    return _tipView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _tipLabel;
}

- (void)setImageViewArray:(NSArray<UIImageView *> *)imageViewArray
{
    _imageViewArray = [imageViewArray copy];
    
    NSMutableArray *frameArray = [NSMutableArray new];
    [imageViewArray enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect convertFrame = [obj.superview convertRect:obj.frame toView:[UIApplication sharedApplication].keyWindow];
        
        [frameArray addObject:[NSValue valueWithCGRect:convertFrame]];
    }];
    
    self.imageFrameArray = [frameArray copy];
}

- (BOOL)haveTransition
{
    return self.imageFrameArray.count > 0;
}

@end
