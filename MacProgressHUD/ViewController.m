//
//  ViewController.m
//  MacProgressHUD
//
//  Created by mooer on 2018/8/27.
//  Copyright © 2018年 mooer. All rights reserved.
//

#import "ViewController.h"
#import "MacProgressHUD.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (IBAction)text:(id)sender {
    [MacProgressHUD showWaitingWithTitle:@"我是提示文字" time:5];
}

- (IBAction)icon:(id)sender {
    [MacProgressHUD showWaitingWithImgAnimationsSpeed:3 ImgURL:@"round" time:10];
}

- (IBAction)circle:(id)sender {
    [MacProgressHUD showWaitingWithRoundColor:[NSColor whiteColor] speed:3 time:10];
}

- (IBAction)point:(id)sender {
    [MacProgressHUD showWaitingWithPointColor:[NSColor whiteColor] speed:3 time:10];
}

- (IBAction)schedule:(id)sender {
    [MacProgressHUD showWaitingWithProgressColor:[NSColor whiteColor] speed:2 time:10];
}

- (IBAction)square:(id)sender {
    [MacProgressHUD showWaitingWithsQuareColor:[NSColor whiteColor] number:5 amplitude:5 speed:1 time:10];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
