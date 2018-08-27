//
//  MacClickView.m
//  MacProgressHUD
//
//  Created by mooer on 2018/8/27.
//  Copyright © 2018年 mooer. All rights reserved.
//

#import "MacClickView.h"

@implementation MacClickView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)mouseDown:(NSEvent *)theEvent
{
    [self.delegate stopDisappear];
}

@end
