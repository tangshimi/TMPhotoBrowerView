//
//  TMPhotoCollectionViewCell.h
//  
//
//  Created by tangshimi on 6/20/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TMPhotoCollectionViewCellTapBlock)(NSInteger);

@interface TMPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, copy) NSString *defaultImage;
@property (nonatomic, copy) TMPhotoCollectionViewCellTapBlock tapBlock;

- (void)setImage:(NSString *)originalImageURL imageURL:(NSString *)imageURL indexPath:(NSIndexPath *)indexPath;

@end
