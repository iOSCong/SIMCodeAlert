//
//  MZSIMCodeView.h
//  MobileBank
//
//  Created by 中科金财 on 17/9/4.
//  Copyright © 2017年 中科金财电子商务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MZSIMCodeViewDelegate <NSObject>

@required
//发送验证码
- (void)sendSIMCodeHandle;

@end

@interface MZSIMCodeView : UIView

@property (nonatomic, retain) id<MZSIMCodeViewDelegate> delegate;

@property (nonatomic, copy) NSString *payInfor, *recInfor, *moneyInfor;

@property (nonatomic,copy) void (^completeHandle)(NSString *simCode);
@property (nonatomic,copy) void (^simCodeHandle)(void);

- (void)show;

@end
