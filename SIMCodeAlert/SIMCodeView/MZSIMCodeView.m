//
//  MZSIMCodeView.m
//  MobileBank
//
//  Created by 中科金财 on 17/9/4.
//  Copyright © 2017年 中科金财电子商务有限公司. All rights reserved.
//

#import "MZSIMCodeView.h"

#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH 290
#define PWD_COUNT 6
#define DOT_WIDTH 40
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 35  //100
#define ALERT_HEIGHT 290
#define LABEL_HEIGHT 30
#define LABEL_FONT 22

@interface MZSIMCodeView ()<UITextFieldDelegate>
{
    NSMutableArray *pwdIndicatorArr;
}
@property (nonatomic, strong) UIView *paymentAlert, *inputView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel, *line, *payAccountLabel, *recAccountLabel, *moneyLabel;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) NSString *totalString;
@property(nonatomic,retain)NSTimer *messageTimer;
@property(nonatomic,assign)int totalTime;

@end

@implementation MZSIMCodeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4f];
        [self drawView];
    }
    return self;
}

- (void)drawView {
    if (!_paymentAlert) {
        _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake((self.bounds.size.width-PAYMENT_WIDTH)/2, (self.bounds.size.height-KEYBOARD_HEIGHT)/2-ALERT_HEIGHT/2, PAYMENT_WIDTH, ALERT_HEIGHT)];
        _paymentAlert.layer.cornerRadius = 5.f;
        _paymentAlert.layer.masksToBounds = YES;
        _paymentAlert.backgroundColor = [UIColor colorWithWhite:1. alpha:.95];
        [self addSubview:_paymentAlert];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PAYMENT_WIDTH, TITLE_HEIGHT)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.text = @"请输入短信验证码";
        [_paymentAlert addSubview:_titleLabel];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setFrame:CGRectMake(_paymentAlert.frame.size.width-TITLE_HEIGHT, 0, TITLE_HEIGHT, TITLE_HEIGHT)];
        [_closeBtn setTitle:@"╳" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_paymentAlert addSubview:_closeBtn];
        
        _line = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT, PAYMENT_WIDTH, .5f)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line];
        
        //充值金额
        _moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+LABEL_HEIGHT, PAYMENT_WIDTH-30, LABEL_HEIGHT)];
        //        _moneyLabel.backgroundColor = [UIColor cyanColor];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.textColor = [UIColor darkGrayColor];
        _moneyLabel.font = [UIFont systemFontOfSize:LABEL_FONT];
        [_paymentAlert addSubview:_moneyLabel];
        
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(15, _paymentAlert.frame.size.height-(PAYMENT_WIDTH-30)/6-110, PAYMENT_WIDTH-30, (PAYMENT_WIDTH-30)/6)];
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.layer.cornerRadius = 3;
        _inputView.layer.borderWidth = 1.f;
        _inputView.layer.borderColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.].CGColor;
        [_paymentAlert addSubview:_inputView];
        
        pwdIndicatorArr = [[NSMutableArray alloc]init];
        _pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _pwdTextField.hidden = YES;
        _pwdTextField.delegate = self;
        _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_inputView addSubview:_pwdTextField];
        
        CGFloat width = _inputView.bounds.size.width/PWD_COUNT;
        for (int i = 0; i < PWD_COUNT; i ++) {
            UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake((width-DOT_WIDTH)/2.f + i*width, (_inputView.bounds.size.height-DOT_WIDTH)/2.f, DOT_WIDTH, DOT_WIDTH)];
            dot.textAlignment = NSTextAlignmentCenter;
            dot.font = [UIFont systemFontOfSize:38];
            dot.tag = 1000+i;
            dot.hidden = YES;
            [_inputView addSubview:dot];
            [pwdIndicatorArr addObject:dot];
            
            if (i == PWD_COUNT-1) {
                continue;
            }
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake((i+1)*width, 0, .5f, _inputView.bounds.size.height)];
            line.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.];
            [_inputView addSubview:line];
        }
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setFrame:CGRectMake(15, 235, _inputView.frame.size.width, 40)];
        [sureBtn setBackgroundColor:[UIColor orangeColor]];
        [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnHandle) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        sureBtn.layer.cornerRadius = 5;
        [_paymentAlert addSubview:sureBtn];
        
    }
}

//确认充值
- (void)sureBtnHandle
{
    [self dismiss];
    
    [self performSelector:@selector(hiddenBtn) withObject:nil afterDelay:.3f];
}

- (void)hiddenBtn
{
    if (_completeHandle) {
        _completeHandle(self.totalString);
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _paymentAlert.alpha = 0;
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_pwdTextField becomeFirstResponder];
        _paymentAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentAlert.alpha = 1.0;
    } completion:nil];
}

- (void)dismiss
{
    [_pwdTextField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        _paymentAlert.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length >= PWD_COUNT && string.length) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    NSString *totalString;
    if (string.length <= 0) {
        totalString = [textField.text substringToIndex:textField.text.length-1];
    }
    else {
        totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    [self setDotWithCount:totalString text:string];
    
    NSLog(@"_____total %@",totalString);
    self.totalString = totalString;
    return YES;
}

- (void)setDotWithCount:(NSString *)totalString text:(NSString *)text{
    for (UILabel *dot in pwdIndicatorArr) {
        dot.hidden = YES;
    }
    for (int i = 0; i< totalString.length; i++) {
        ((UILabel*)[pwdIndicatorArr objectAtIndex:i]).hidden = NO;
        ((UILabel*)[pwdIndicatorArr objectAtIndex:i]).text = [totalString substringWithRange:NSMakeRange(i, 1)];
    }
}

#pragma mark -

//充值金额
- (void)setMoneyInfor:(NSString *)moneyInfor {
    if (_moneyInfor != moneyInfor) {
        _moneyInfor = moneyInfor;
        _moneyLabel.text = [NSString stringWithFormat:@"%@",moneyInfor];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
