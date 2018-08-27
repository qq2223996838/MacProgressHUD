//
//  MacClickView.h
//  MacProgressHUD
//
//  Created by mooer on 2018/8/27.
//  Copyright © 2018年 mooer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacClickView.h"

@class MacClickView;

@protocol MacClickViewDelegate <NSObject>

@optional

- (void)stopDisappear;

@end

@interface MacClickView : NSView

@property (nonatomic, weak) id<MacClickViewDelegate> delegate;

@end
