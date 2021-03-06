//
//  BusinessViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/25.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessModel.h"
@class BusinessViewController;
@protocol BusinessViewControllerDelegate <NSObject>
//传回添加的那一周
- (void)BusinessViewController:(BusinessViewController*)viewController week:(NSInteger )selectedWeek;

@end

@interface BusinessViewController : UIViewController
@property (nonatomic,weak) UITextField *busDescription;//事件描述textfield，描述+时间均有内容才允许保存事件，因此用属性声明
@property (nonatomic , strong) NSDate *currentDate;//当前日期
@property (nonatomic , strong) NSMutableArray *sections;//二维数组，对不连续的节数分连续段储存
@property (nonatomic , assign) NSInteger repeatIndex;//“重复”中的哪一项
@property (nonatomic , copy) NSString *commentInfo;//备注的内容
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , weak) id <BusinessViewControllerDelegate> delegate;


- (instancetype)initWithfirstDateOfTerm:(NSDate *)firstDateOfTerm businessModel:(BusinessModel *)busModel;

@end
