//
//  UIAlertController+Appearance.h
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Appearance)
//提示框按钮样式设置
- (void)addActionTarget:(UIAlertAction*)action hexColor:(NSString *)color;

//提示框title样式设置
- (void)alertTitleAppearance_title:(NSString *)title hexColor:(NSString *)color;
//提示框Message样式设置
- (void)alertMessageAppearance_message:(NSString *)message hexColor:(NSString *)color;
@end
