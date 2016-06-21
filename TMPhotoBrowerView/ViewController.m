//
//  ViewController.m
//  TMPhotoBrowerView
//
//  Created by tangshimi on 6/21/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+WebCache.h"
#import "TMPhotoBrowerView.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.]
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *imageView1 = [[UIButton alloc] init];
    [imageView1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    imageView1.frame = CGRectMake(50, 320, 150, 100);
    self.button1 = imageView1;
    
    [imageView1 sd_setImageWithURL:[NSURL URLWithString: @"http://attach.bbs.miui.com/forum/201206/06/2226336d6nxnnfxldyxhed.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    [self.view addSubview:imageView1];
    
    UIButton *imageView2 = [[UIButton alloc] init];
    imageView2.frame = CGRectMake(250, 320, 150, 100);
    self.button2 = imageView2;
    
    [imageView2 sd_setImageWithURL:[NSURL URLWithString: @"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    [self.view addSubview:imageView2];
}

- (void)buttonAction:(UIButton *)button
{
    TMPhotoBrowerView *photo = [[TMPhotoBrowerView alloc] init];
    photo.originalImageURLArray = @[ @"http://attach.bbs.miui.com/forum/201206/06/2226336d6nxnnfxldyxhed.jpg",  @"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg", @"http://cdn.duitang.com/uploads/item/201112/27/20111227143751_TtLkL.jpg" ];
    
   // photo.imageViewArray = @[ self.button1, [UIImageView new]];
    photo.imageFrameArray = @[ [NSValue valueWithCGRect:CGRectMake(50, 320, 150, 100)], [NSValue valueWithCGRect:CGRectMake(250, 320, 150, 100)] ];
    photo.currentIndex = 0;
    photo.canAutorotate = YES;
    [photo show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
