//
//  MacProgressHUD.m
//  MacProgressHUD
//
//  Created by mooer on 2018/8/27.
//  Copyright © 2018年 mooer. All rights reserved.
//

#import "MacProgressHUD.h"
#include <QuartzCore/CoreAnimation.h>

#define Screen_height  270
#define Screen_width   480
#define DefaultRect     CGRectMake(0, 0, Screen_width, Screen_height)

#define GloomyBlackColor  [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:.5]
#define GloomyClearCloler  [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0]

@interface MacProgressHUD()<CAAnimationDelegate>
@end

@implementation MacProgressHUD

MacClickView *gloomyView;//深色背景
NSTextField *titleTF;
NSImageView *loadingImgView;
CAShapeLayer *animLayer;
bool animState;
NSMutableArray *pointImgViewsMAry;
NSMutableArray *quareViewsMAry;
MacClickView *progressView;
NSInteger classSpeed;

#pragma mark -   类初始化
+ (void)initialize {
    if (self == [MacProgressHUD self]) {
        //该方法只会走一次
        [self customView];
    }
}
#pragma mark - 初始化gloomyView
+(void)customView {
    gloomyView = [[MacClickView alloc] initWithFrame:DefaultRect];
    gloomyView.wantsLayer =YES;
    gloomyView.delegate = (id)self;
    [gloomyView.layer setBackgroundColor:[GloomyBlackColor CGColor]];
    
    titleTF = [[NSTextField alloc]init];
    titleTF.editable = NO;
    titleTF.bordered = NO; //不显示边框
    titleTF.backgroundColor = [NSColor clearColor]; //控件背景色
    titleTF.textColor = [NSColor whiteColor];  //文字颜色
    titleTF.alignment = NSTextAlignmentCenter; //水平显示方式
    titleTF.font = [NSFont fontWithName:@"Arial" size:18];
    
    if (@available(macOS 10.11, *)) {
        titleTF.maximumNumberOfLines = 1;
    } else {
        // Fallback on earlier versions
    } //最多显示行数
    titleTF.frame = NSMakeRect(0, Screen_height/2-30, Screen_width, 60);
    
    
}

//纯文字+时间
+ (void)showWaitingWithTitle:(NSString *)title time:(NSInteger)showTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        titleTF.stringValue = title;  //现实的文字内容
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        [gloomyView addSubview:titleTF];
        
        
    });
    
    //自动消失
    double delayInSeconds = 3;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        [self stopDisappear];
    });
    
}

//图标旋转
+ (void)showWaitingWithImgAnimationsSpeed:(NSInteger)speed ImgURL:(NSString *)imgURL time:(NSInteger)showTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        
        loadingImgView = [[NSImageView alloc]init];
        loadingImgView.imageFrameStyle = NSImageFramePhoto; //图片边框的样式
        loadingImgView.layer.backgroundColor = [NSColor clearColor].CGColor;
        loadingImgView.image = [NSImage imageNamed:imgURL];
        loadingImgView.imageScaling = NSImageScaleProportionallyDown;//图片缩放/剪切
        [loadingImgView setAnimates:YES];
        loadingImgView.imageAlignment = NSImageAlignCenter; //图片内容对于控件的位置
        loadingImgView.wantsLayer = YES;
        loadingImgView.layer.cornerRadius = 30;
        
        float x  = gloomyView.frame.origin.x+gloomyView.frame.size.width/2;
        float y  = gloomyView.frame.origin.y+gloomyView.frame.size.height/2;
        
        loadingImgView.frame = NSMakeRect(x, y, 60, 60);
        [gloomyView addSubview:loadingImgView];
        
        CALayer *viewLayer = loadingImgView.layer;
        
        // 对Z轴进行旋转（指定Z轴的话，就和UIView的动画一样绕中心旋转）
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        // 设定旋转角度
        animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
        animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 终止角度
        // 设置时间
        [animation setDuration:speed];
        // 设置次数 or 重复
        [animation setRepeatCount:CGFLOAT_MAX];
        // 添加上动画
        [viewLayer addAnimation:animation forKey:nil];
        
        //自动消失
        double delayInSeconds = showTime;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //执行事件
            [self stopDisappear];
        });
        
    });
}


//圆圈循环旋转
+ (void)showWaitingWithRoundColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        animState = YES;
        classSpeed = speed;
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        //        [gloomyView addSubview:titleTF];
        
        CGFloat radiusX = gloomyView.bounds.size.width / 2;
        CGFloat radiusY = gloomyView.bounds.size.height / 2;
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:CGPointMake(radiusX, radiusY) radius:40 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        
        animLayer = [CAShapeLayer layer];
        animLayer.path = [self CGPathFromPath:path];
        animLayer.lineWidth = 8.f;
        animLayer.strokeColor = color.CGColor;
        animLayer.fillColor = [NSColor clearColor].CGColor;
        //        animLayer.strokeStart = 0;
        //        animLayer.strokeEnd = 1.;
        [gloomyView.layer addSublayer:animLayer];
        
        [self animationPositive];
        
        //自动消失
        double delayInSeconds = showTime;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //执行事件
            animState = NO;
            [animLayer removeAllAnimations];
            [self stopDisappear];
        });
        
    });
    
}

//点点
+ (void)showWaitingWithPointColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        animState = YES;
        classSpeed = speed;
        
        pointImgViewsMAry = [[NSMutableArray alloc]init];
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        
        CGFloat radiusX = gloomyView.bounds.size.width / 2;
        CGFloat radiusY = gloomyView.bounds.size.height / 2;
        
        
        for (int i = 0; i<6; i++) {
            
            MacClickView *pointImgViewx = [[MacClickView alloc] initWithFrame:NSMakeRect(radiusX-6/2*30, radiusY, 15, 15)];
            pointImgViewx.wantsLayer =YES;
            [pointImgViewx.layer setBackgroundColor:[color CGColor]];
            pointImgViewx.layer.cornerRadius = 8;
            [gloomyView addSubview:pointImgViewx];
            [pointImgViewsMAry addObject:pointImgViewx];
            
            
            // 位置移动
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.delegate = (id)self;
            // 持续时间
            animation.duration = 2;
            // 重复次数
            animation.repeatCount = 1;//CGFLOAT_MAX
            //是否还原
            animation.removedOnCompletion = NO;
            // 起始位置
            //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
            // 终止位置
            animation.toValue = [NSNumber numberWithFloat:i*30];
            
            animation.fillMode = kCAFillModeForwards;
            // 添加动画
            NSString *key = [NSString stringWithFormat:@"positionStart %i",i];
            [animation setValue:key forKey:@"animType"];
            [pointImgViewx.layer addAnimation:animation forKey:key];
            NSLog(@"key ===  %@",key);
            
        }
        
    });
    
    //自动消失
    double delayInSeconds = showTime;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        animState = NO;
        [self stopDisappear];
    });
}

//进度条
+ (void)showWaitingWithProgressColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        animState = YES;
        classSpeed = speed;
        
        CGFloat radiusX = gloomyView.bounds.size.width / 2;
        CGFloat radiusY = gloomyView.bounds.size.height / 2;
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        
        progressView = [[MacClickView alloc] initWithFrame:NSMakeRect(radiusX-150, radiusY, 30, 30)];
        progressView.wantsLayer =YES;
        [progressView.layer setBackgroundColor:[color CGColor]];
        progressView.layer.cornerRadius = 1;
        [gloomyView addSubview:progressView];
        
        [self animationProgressStart];
        
    });
    
    //自动消失
    double delayInSeconds = showTime;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        animState = NO;
        [self stopDisappear];
    });
}

//方块跳动
+ (void)showWaitingWithsQuareColor:(NSColor *)color number:(NSInteger)number amplitude:(NSInteger)amplitude speed:(NSInteger)speed time:(NSInteger)showTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        animState = YES;
        classSpeed = speed;
        
        quareViewsMAry = [[NSMutableArray alloc]init];
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        
        CGFloat radiusX = gloomyView.bounds.size.width / 2;
        CGFloat radiusY = gloomyView.bounds.size.height / 2;
        
        
        for (int i = 0; i<number; i++) {
            
            MacClickView *pointImgViewx = [[MacClickView alloc] initWithFrame:NSMakeRect(radiusX-number/2*55+i*55-25, radiusY, 50, 50)];
            pointImgViewx.wantsLayer =YES;
            [pointImgViewx.layer setBackgroundColor:[color CGColor]];
            [gloomyView addSubview:pointImgViewx];
            
            [self beatingAnimation:pointImgViewx currentNumber:i];
            [quareViewsMAry addObject:pointImgViewx];
        }
        
        
    });
    
    //自动消失
    double delayInSeconds = showTime;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        animState = NO;
        [self stopDisappear];
    });
}

//GIF动画
+ (void)showWaitingWithGifTime:(NSInteger)showTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSWindow *window = [NSApplication sharedApplication].keyWindow;
        [window.contentView addSubview:gloomyView];
        
        /*
         暂未实现
         */
        
        
    });
    
    //自动消失
    double delayInSeconds = showTime;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        [self stopDisappear];
    });
}

//停止/消失
+ (void)stopDisappear
{
    [gloomyView removeFromSuperview];
    
    gloomyView = [[MacClickView alloc] initWithFrame:DefaultRect];
    gloomyView.wantsLayer =YES;
    gloomyView.delegate = (id)self;
    [gloomyView.layer setBackgroundColor:[GloomyBlackColor CGColor]];
}

+ (CGMutablePathRef)CGPathFromPath:(NSBezierPath *)path
{
    CGMutablePathRef cgPath = CGPathCreateMutable();
    NSInteger n = [path elementCount];
    
    for (NSInteger i = 0; i < n; i++) {
        NSPoint ps[3];
        switch ([path elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement: {
                CGPathMoveToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSLineToBezierPathElement: {
                CGPathAddLineToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSCurveToBezierPathElement: {
                CGPathAddCurveToPoint(cgPath, NULL, ps[0].x, ps[0].y, ps[1].x, ps[1].y, ps[2].x, ps[2].y);
                break;
            }
            case NSClosePathBezierPathElement: {
                CGPathCloseSubpath(cgPath);
                break;
            }
            default: NSAssert(0, @"Invalid NSBezierPathElement");
        }
    }
    return cgPath;
}

/**
 * 动画开始时
 */
+ (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSLog(@"begin");
}

/**
 * 动画结束时
 */
+ (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    
    if (animState == NO) {
        return;
    }
    
    NSLog(@"Stop");
    
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"strokeEnd"]) {
        [animLayer removeAllAnimations];
        [self animationReverse];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"strokeStart"]) {
        [animLayer removeAllAnimations];
        [self animationPositive];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"positionStart 5"]) {
        [self animationPositionEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"positionEnd 5"]) {
        [self animationPositionStart];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"progressStart"]) {
        [self animationProgressEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"progressEnd"]) {
        [self animationProgressStart];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"quareStart 4"]) {
        [self animationQuareEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"quareEnd 4"]) {
        [self animationQuareStart];
    };
    
}

+ (void)animationQuareStart
{
    for (int i = 0; i<quareViewsMAry.count; i++) {
        
        MacClickView *pointImgViewx = quareViewsMAry[i];
        [self beatingAnimation:pointImgViewx currentNumber:i];
        
    }
}

+ (void)animationQuareEnd
{
    for (int i = 0; i<quareViewsMAry.count; i++) {
        
        MacClickView *pointImgViewx = quareViewsMAry[i];
        [self beatingAnimationx:pointImgViewx currentNumber:i];
        
    }
}

+ (void)animationProgressStart
{
    // 比例缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    // 起始scale
    animation.fromValue = @(1.0);
    // 终止scale
    animation.toValue = @(10);
    //是否还原
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = @"progressStart";
    [animation setValue:key forKey:@"animType"];
    [progressView.layer addAnimation:animation forKey:key];
}

+ (void)animationProgressEnd
{
    // 比例缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    // 起始scale
    animation.fromValue = @(10);
    // 终止scale
    animation.toValue = @(1.0);
    //是否还原
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = @"progressEnd";
    [animation setValue:key forKey:@"animType"];
    [progressView.layer addAnimation:animation forKey:key];
}

+ (void)animationPositionStart
{
    for (int i = 0; i<pointImgViewsMAry.count; i++) {
        
        MacClickView *pointImgViewx = pointImgViewsMAry[i];
        
        // 位置移动
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.delegate = (id)self;
        // 持续时间
        animation.duration = classSpeed;//2
        // 重复次数
        animation.repeatCount = 1;//CGFLOAT_MAX
        //是否还原
        animation.removedOnCompletion = NO;
        // 起始位置
        //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
        // 终止位置
        animation.toValue = [NSNumber numberWithFloat:i*30];
        
        animation.fillMode = kCAFillModeForwards;
        // 添加动画
        NSString *key = [NSString stringWithFormat:@"positionStart %i",i];
        [animation setValue:key forKey:@"animType"];
        [pointImgViewx.layer addAnimation:animation forKey:key];
        
    }
}

+ (void)animationPositionEnd
{
    for (int i = 0; i<pointImgViewsMAry.count; i++) {
        
        MacClickView *pointImgViewx = pointImgViewsMAry[i];
        
        // 位置移动
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.delegate = (id)self;
        // 持续时间
        animation.duration = classSpeed;//2
        // 重复次数
        animation.repeatCount = 1;//CGFLOAT_MAX
        //是否还原
        animation.removedOnCompletion = NO;
        // 起始位置
        //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
        // 终止位置
        int x;
        if (i == 0) {
            x = 5;
        }else if(i == 1){
            x = 4;
        }else if(i == 2){
            x = 3;
        }else if(i == 3){
            x = 2;
        }else if(i == 4){
            x = 1;
        }else{
            x = 0;
        }
        animation.toValue = [NSNumber numberWithFloat:x*30];
        
        animation.fillMode = kCAFillModeForwards;
        // 添加动画
        NSString *key = [NSString stringWithFormat:@"positionEnd %i",i];
        [animation setValue:key forKey:@"animType"];
        [pointImgViewx.layer addAnimation:animation forKey:key];
        
    }
}

+ (void)animationPositive
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = (id)self;
    animation.fromValue = @(0);
    animation.toValue = @(1.f);
    animation.duration = classSpeed;//2
    animation.removedOnCompletion = NO;//是否还原
    //        [animation setRepeatCount:CGFLOAT_MAX];
    animation.fillMode  = kCAFillModeForwards;
    [animation setValue:@"strokeEnd" forKey:@"animType"];
    [animLayer addAnimation:animation forKey:@"strokeEnd"];
}

+ (void)animationReverse
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation.delegate = (id)self;
    animation.fromValue = @(0);
    animation.toValue = @(1.f);
    animation.duration = classSpeed;//2
    animation.removedOnCompletion = NO;//是否还原
    //        [animation setRepeatCount:CGFLOAT_MAX];
    animation.fillMode  = kCAFillModeForwards;
    [animation setValue:@"strokeStart" forKey:@"animType"];
    [animLayer addAnimation:animation forKey:@"strokeStart"];
    
}

+ (void)beatingAnimation:(MacClickView *)view currentNumber:(NSInteger)currentNumber
{
    // 位置移动
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    //是否还原
    animation.removedOnCompletion = NO;
    // 起始位置
    //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
    // 终止位置
    if (currentNumber%2==0) {//如果是偶数
        animation.toValue = [NSNumber numberWithFloat:-30];
    }else{//如果是奇数
        animation.toValue = [NSNumber numberWithFloat:30];
    }
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = [NSString stringWithFormat:@"quareStart %li",(long)currentNumber];
    [animation setValue:key forKey:@"animType"];
    [view.layer addAnimation:animation forKey:key];
}

+ (void)beatingAnimationx:(MacClickView *)view currentNumber:(NSInteger)currentNumber
{
    // 位置移动
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    //是否还原
    animation.removedOnCompletion = NO;
    // 起始位置
    //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
    // 终止位置
    if (currentNumber%2!=0) {//如果不是偶数
        animation.toValue = [NSNumber numberWithFloat:-30];
    }else{//如果不是奇数
        animation.toValue = [NSNumber numberWithFloat:30];
    }
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = [NSString stringWithFormat:@"quareEnd %li",(long)currentNumber];
    [animation setValue:key forKey:@"animType"];
    [view.layer addAnimation:animation forKey:key];
}

@end
