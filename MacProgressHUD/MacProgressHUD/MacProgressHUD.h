//
//  MacProgressHUD.h
//  MacProgressHUD
//
//  Created by mooer on 2018/8/27.
//  Copyright © 2018年 mooer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacClickView.h"

@interface MacProgressHUD : NSObject<MacClickViewDelegate>
{
    MacClickView *gloomyViewx;//深色背景
}

//纯文字(时间)
+ (void)showWaitingWithTitle:(NSString *)title time:(NSInteger)showTime;

//图标旋转（旋转速率、时间）
+ (void)showWaitingWithImgAnimationsSpeed:(NSInteger)speed ImgURL:(NSString *)imgURL time:(NSInteger)showTime;

//圆圈循环旋转（圆圈颜色、旋转速率、时间）
+ (void)showWaitingWithRoundColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime;

//点点（点颜色、点速率、时间）
+ (void)showWaitingWithPointColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime;

//进度条（进度条颜色、进度速率、时间）
+ (void)showWaitingWithProgressColor:(NSColor *)color speed:(NSInteger)speed time:(NSInteger)showTime;

//方块跳动（方块颜色、方块个数、上下幅度、跳动速率、时间）
+ (void)showWaitingWithsQuareColor:(NSColor *)color number:(NSInteger)number amplitude:(NSInteger)amplitude speed:(NSInteger)speed time:(NSInteger)showTime;

//GIF动画
+ (void)showWaitingWithGifTime:(NSInteger)showTime;

//停止一切动画
+ (void)stopDisappear;
@end

