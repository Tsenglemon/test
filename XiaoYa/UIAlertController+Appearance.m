//
//  UIAlertController+Appearance.m
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "UIAlertController+Appearance.h"
#import "Utils.h"
@implementation UIAlertController (Appearance)

//提示框按钮样式设置
- (void)addActionTarget:(UIAlertAction*)action hexColor:(NSString *)color{
    [action setValue:[Utils colorWithHexString:color] forKey:@"titleTextColor"];
    [self addAction:action];
}

//提示框title样式设置
- (void)alertTitleAppearance_title:(NSString *)title hexColor:(NSString *)color{
    NSInteger length = [title length];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
    [self setValue:alertControllerStr forKey:@"attributedTitle"];
}
//提示框Message样式设置
- (void)alertMessageAppearance_message:(NSString *)message hexColor:(NSString *)color{
    NSInteger length = [message length];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
    [self setValue:alertControllerStr forKey:@"attributedMessage"];
}
@end
