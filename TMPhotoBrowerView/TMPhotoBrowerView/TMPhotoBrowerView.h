//
//  TMPhotoBrowerView.h
//  
//
//  Created by tangshimi on 6/20/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMPhotoBrowerView : UIViewController

/**
 *  TMPhotoBrowerView Can display different definition of the picture
 */
@property (nonatomic, copy) NSArray *originalImageURLArray;
@property (nonatomic, copy) NSArray *imageURLArray;

/**
 *  If you need a transition effect, set the following parameters
 */
@property (nonatomic, copy) NSArray<NSValue *> *imageFrameArray;
@property (nonatomic, copy) NSArray<UIView *> *imageViewArray;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL canAutorotate;

@property (nonatomic, copy) NSString *defaultImage;

/**
 *  show TMPhotoBrowerView
 */
- (void)show;

@end
