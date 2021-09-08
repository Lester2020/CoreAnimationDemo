//
//  ViewController.m
//  YZCoreAnimationDemo
//
//  Created by Lester 's Mac on 2021/9/8.
//

#import "ViewController.h"
#import "YZPublishView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)publishBtnClick {
    YZPublishView *publishView = [YZPublishView publishView];
    [publishView show];
}

@end
