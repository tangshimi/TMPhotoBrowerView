//
//  TMPhotoCollectionViewCell.m
//  
//
//  Created by tangshimi on 6/20/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import "TMPhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "TMPhotoProgressView.h"

@interface TMPhotoCollectionViewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) UIButton *reDownloadButton;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) TMPhotoProgressView *progressView;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *originalImageURL;

@end

@implementation TMPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.reDownloadButton];
        
        self.scrollView.frame = self.bounds;
        self.imageView.frame = self.bounds;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.reDownloadButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.reDownloadButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self.scrollView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.imageView.image) {
        return;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (screenHeight > screenWidth) {
        CGFloat showHeight = self.imageView.image.size.height / (self.imageView.image.size.width / screenWidth);
        
        if (showHeight > screenHeight) {
            self.imageView.frame = CGRectMake(0, 0, screenWidth, showHeight);
            self.scrollView.contentSize = CGSizeMake(screenWidth, showHeight);
        } else {
            self.imageView.frame = CGRectMake(0, (screenHeight - showHeight) / 2.0 , screenWidth, showHeight);
            self.scrollView.contentSize = [UIScreen mainScreen].bounds.size;
        }
    } else {
        CGFloat showWidth = self.imageView.image.size.width / (self.imageView.image.size.height / screenHeight);
        
        if (showWidth > screenWidth) {
            self.imageView.frame = CGRectMake(0, 0, showWidth, screenHeight);
            self.scrollView.contentSize = CGSizeMake(showWidth, screenHeight);
        } else {
            self.imageView.frame = CGRectMake((screenWidth - showWidth) / 2.0, 0, showWidth, screenHeight);
            self.scrollView.contentSize = [UIScreen mainScreen].bounds.size;
        }
    }
}

- (void)setImage:(NSString *)originalImageURL imageURL:(NSString *)imageURL indexPath:(NSIndexPath *)indexPath;
{
    self.indexPath = indexPath;
    self.imageURL = imageURL;
    self.originalImageURL = originalImageURL;
    [self.scrollView setZoomScale:1.0];
    self.progressView.hidden = NO;
    self.reDownloadButton.hidden = YES;
    
    [self downloadImage];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    if (self.tapBlock) {
        self.tapBlock(self.indexPath.row);
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (UIView *view in scrollView.subviews){
        return view;
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height)  / 2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width  / 2  + offsetX,
                                        scrollView.contentSize.height  / 2  + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView.zoomScale < 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
        scrollView.contentOffset = CGPointMake(0, 0);
    } else if (scrollView.zoomScale > 2.0) {
        [scrollView setZoomScale:2.0 animated:YES];
    }
}

#pragma mark -
#pragma mark - response event -

- (void)reDownloadButtonAction:(UIButton *)button
{
    button.hidden = YES;
    
    [self downloadImage];
}

#pragma mark -
#pragma mark - private -

- (void)downloadImage
{
    self.progressView.progress = 0.001;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *originalImage = [manager.imageCache imageFromMemoryCacheForKey:[manager cacheKeyForURL:[NSURL URLWithString:self.originalImageURL]]];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL]
                      placeholderImage:originalImage ? : [UIImage imageNamed:self.defaultImage]
                               options:SDWebImageRetryFailed | SDWebImageHighPriority
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  self.progressView.progress = (float)receivedSize / expectedSize;
                              } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if (image) {
                                      self.progressView.progress = 1.0;
                                      self.imageView.image = image;
                                      [self setNeedsLayout];
                                  } else {
                                      self.reDownloadButton.hidden = originalImage ? YES : NO;
                                  }
                                  
                                  self.progressView.hidden = YES;
                              }];
    
}

#pragma mark -
#pragma mark - setter and getter -

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            scrollView.maximumZoomScale = 2.0;
            scrollView.minimumZoomScale = 0.5;
            scrollView.delegate = self;
            scrollView.delaysContentTouches = NO;
            scrollView;
        });
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView =  ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView;
        });
    }
    return _imageView;
}

- (TMPhotoProgressView *)progressView
{
    if (!_progressView) {
        _progressView =  ({
            TMPhotoProgressView *progressView = [[TMPhotoProgressView alloc] init];
            progressView.translatesAutoresizingMaskIntoConstraints = NO;
            progressView;
        });
    }
    return _progressView;
}

- (UIButton *)reDownloadButton
{
    if (!_reDownloadButton) {
        _reDownloadButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setTitle:@"重新下载" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(reDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _reDownloadButton;
}

@end
