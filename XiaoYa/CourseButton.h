//
//  CourseButton.h
//  XiaoYa
//
//  Created by commet on 16/11/1.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
#import "BusinessModel.h"
@interface CourseButton : UIButton
@property (nonatomic , weak)UILabel *event;//事件
@property (nonatomic , weak)UILabel *place;//地点
@property (nonatomic , assign)BOOL isOverlap;//课程、事务是否重合的标记，决定背景图片是啥
@property (nonatomic ,strong) NSMutableArray *courseArray;
@property (nonatomic ,strong) NSMutableArray *businessArray;

//@property (nonatomic , strong)CourseModel *courseModel;
//@property (nonatomic , strong)BusinessModel *businessModel;
@end
