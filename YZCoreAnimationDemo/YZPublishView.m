//
//  YZPublishView.m
//  YZCoreAnimationDemo
//
//  Created by Lester 's Mac on 2021/9/8.
//

#import "YZPublishView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface YZPublishView()<CAAnimationDelegate>

@property (nonatomic, weak) UIVisualEffectView *blurView;

@property (nonatomic, weak) UIButton *addBtn;

@property (nonatomic, strong) NSMutableArray *btnArray;

@property (nonatomic, strong) NSMutableArray *frameArray;

@property (nonatomic, assign) BOOL isShow;

@end

@implementation YZPublishView

- (NSMutableArray *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (NSMutableArray *)frameArray {
    if (!_frameArray) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}

+ (instancetype)publishView {
    YZPublishView *pView = [[YZPublishView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    return pView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    blurView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    blurView.alpha = 0.9;
    [self addSubview:blurView];
    self.blurView = blurView;
    [blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePublishView)]];


    NSArray *imageArray = @[@"tabbar_compose_photo", @"tabbar_compose_music", @"tabbar_compose_review"];
    for (NSUInteger i = 0; i < imageArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 50)*0.5, [UIScreen mainScreen].bounds.size.height - 50 - 50, 50, 50);
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [self.btnArray addObject:btn];
        [self addSubview:btn];
    }
    

    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 56)*0.5, [UIScreen mainScreen].bounds.size.height - 56 - 50, 56, 56);
    [addBtn setImage:[UIImage imageNamed:@"post_animate_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(closePublishView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addBtn];
    self.addBtn = addBtn;
}

- (void)show {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc.view addSubview:self];
    
    [self showCurrentView];
}

/*
 * mass:
 质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
 * stiffness:
 刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
 * damping:
 阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
 * initialVelocity:
 初始速率，动画视图的初始速度大小
 速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
 */

#pragma mark - 显示动画
- (void)showCurrentView {
    self.isShow = YES;
    CGFloat margin = 40;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - margin*4)/3;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.addBtn.transform = CGAffineTransformMakeRotation(-M_PI_4);
    }];
    
    
    for (NSUInteger i = 0; i < self.btnArray.count; i++) {
        
        CGRect toValue = CGRectMake(margin*(i+1)+width*i+width*0.5, [UIScreen mainScreen].bounds.size.height*0.6+width*0.5, width, width);
        [self.frameArray addObject:[NSValue valueWithCGRect:toValue]];
        
        UIButton *btn = self.btnArray[i];
        
        CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim1.toValue = @1.5;
        
        
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim2.fromValue = @0;
        anim2.toValue = @1;
        
        CASpringAnimation *anim3 = [CASpringAnimation animationWithKeyPath:@"position"];
        anim3.damping = 8;
        anim3.stiffness = 120;
        anim3.mass = 0.6;
        anim3.initialVelocity = 0;
        anim3.fromValue = [NSValue valueWithCGPoint:self.addBtn.center];
        anim3.toValue = [NSValue valueWithCGPoint:toValue.origin];
        
        CABasicAnimation *anim4 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anim4.fromValue = @(DEGREES_TO_RADIANS(90/(self.btnArray.count - i)));
        anim4.toValue = @0;
        
        CAAnimationGroup *groupAnim = [CAAnimationGroup animation];
        groupAnim.animations = @[anim1, anim2, anim3, anim4];
        groupAnim.duration = 0.75;
        groupAnim.removedOnCompletion = NO;
        groupAnim.fillMode = kCAFillModeForwards;
        groupAnim.delegate = self;
        groupAnim.beginTime = CACurrentMediaTime()+i*(0.4/self.btnArray.count);
        [btn.layer addAnimation:groupAnim forKey:[NSString stringWithFormat:@"animation%ld", i]];
    }
}

#pragma mark - 关闭动画
- (void)closePublishView {
    
    self.isShow = NO;
    
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakself.addBtn.transform = CGAffineTransformIdentity;
    }];
    
    for (NSInteger i = self.btnArray.count - 1; i >= 0; i--) {
        
        UIButton *btn = self.btnArray[i];
        
        CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim1.fromValue = @1;
        anim1.toValue = @0.5;
        
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim2.toValue = @0.7;
        
        CABasicAnimation *anim3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anim3.toValue = @(DEGREES_TO_RADIANS(90/(self.btnArray.count - i)));
        
        CABasicAnimation *anim4 = [CABasicAnimation animationWithKeyPath:@"position"];
        anim4.toValue = [NSValue valueWithCGPoint:self.addBtn.center];
        
        CAAnimationGroup *groupAnim = [CAAnimationGroup animation];
        groupAnim.animations = @[anim1, anim2, anim3, anim4];
        groupAnim.duration = 0.35;
        groupAnim.removedOnCompletion = NO;
        groupAnim.fillMode = kCAFillModeForwards;
        groupAnim.beginTime = CACurrentMediaTime()+(self.btnArray.count-1-i)*(0.4/self.btnArray.count);
        if (i == 0) {
            groupAnim.delegate = self;
        }
        [btn.layer addAnimation:groupAnim forKey:@"closeAnimation"];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.isShow) {
        for (int i = 0; i < self.btnArray.count; i++) {
            UIButton *button = self.btnArray[i];
            button.center = [self.frameArray[i] CGRectValue].origin;
        }
    } else {
        [self.btnArray removeAllObjects];
        [self.frameArray removeAllObjects];
        [self removeFromSuperview];
    }
}


@end
