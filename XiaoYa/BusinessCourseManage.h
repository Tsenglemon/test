//
//  BusinessCourseManage.h
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessCourseManage : UIViewController
/**
 *  指定初始化方法
 *  @param controllersArray         子控制器数组
 */
- (instancetype)initWithControllersArray:(NSArray *)controllersArray firstDateOfTerm:(NSDate *)firstDateOfTerm;
@end
