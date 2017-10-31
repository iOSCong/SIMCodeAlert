//
//  ViewController.m
//  SIMCodeAlert
//
//  Created by MCEJ on 2017/10/31.
//  Copyright © 2017年 MCEJ. All rights reserved.
//

#import "ViewController.h"
#import "MZSIMCodeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *simLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 50)];
    simLabel.text = @"点击输入验证码";
    simLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:simLabel];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //弹出短信验证码界面
    MZSIMCodeView *payAlert = [[MZSIMCodeView alloc] init];
    payAlert.moneyInfor = [NSString stringWithFormat:@"充值金额: 100.03元"];
    [payAlert show];
    payAlert.completeHandle = ^(NSString *simCode) {
        NSLog(@"验证码是:%@",simCode);
        //确认充值
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
