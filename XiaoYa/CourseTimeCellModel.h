//
//  CourseTimeCellData.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/2/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseTimeCellModel : NSObject

//cell里显示的标签值（和CourseModel的意义不一样）
@property (nonatomic,copy) NSString * weeks;
@property (nonatomic,copy) NSString * weekDay;
@property (nonatomic,copy) NSString * courseTime;
@property (nonatomic,copy) NSString * place;
@property (nonatomic,copy) NSString * courseName;

//由于显示格式和实际数据差别较大，不作解析直接用数组分开存储
@property (nonatomic,strong) NSMutableArray * weeksArray; //周数 装值1~24 NString 如[1，2，3，10]
@property (nonatomic,strong) NSMutableArray * courseTimeArray; //节数 装值0~14 NString 如[0，3，4，10]
@property (nonatomic,copy) NSString * weekDayNum; //星期几 1~7


//默认值1-16周 星期一 1-2节 请输入上课教室
-(id)initWithDefaultValue;

//显示格式处理(根据数组结果，拼接出要求格式的显示的字符串)
-(void)weeksArraytoWeeksString;
-(void)courseTimeArraytoCourseTimeString;
-(void)weekDayNumtoWeekDay;

//把coursetimecellmodel转变coursemodel，装在nsarray返回。方便存储和使用
-(BOOL)CourseCellModeltoCourseModelinArray:(NSMutableArray *)courseModelArray;

//对比查看是否有时间冲突,有冲突返回YES ，没有冲突返回NO
-(BOOL)checkIfConflictComparetoAnotherCellModel:(CourseTimeCellModel *)courseCellModel;

@end
