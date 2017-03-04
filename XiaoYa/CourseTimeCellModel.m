//
//  CourseTimeCellData.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/2/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "CourseTimeCellModel.h"
#import "CourseModel.h"

@implementation CourseTimeCellModel

-(id)initWithDefaultValue
{
    if (self = [super init])
    {
        self.weeks = [NSString stringWithFormat: @"1-16周"];
        self.weekDay = [NSString stringWithFormat:@"星期一"];
        self.weekDayNum = [NSString stringWithFormat:@"1"];
        self.courseTime = [NSString stringWithFormat:@"1-2节"];
        self.place = [NSString stringWithFormat:@"请输入上课教室"];
        self.courseName = [NSString stringWithFormat:@"请输入课程名称"];
        
        NSMutableArray * weeksArray = [[NSMutableArray alloc] init];
        _weeksArray  = weeksArray;
        for(int i= 1;i<=16;i++)
        {
            [_weeksArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        
        NSMutableArray * courseTimeArray = [[NSMutableArray alloc] init];
        _courseTimeArray = courseTimeArray;
        [_courseTimeArray addObjectsFromArray:[NSArray arrayWithObjects:@"1",@"2", nil]];
        
    }
    return self;
}


-(void)weeksArraytoWeeksString
{
    //显示格式处理,从选择的结果拼接出要显示的数据。如1-4,6,8-10 或 1-16（双周）
    //先清空_weeks内容
    _weeks = @"";
    
    if(_weeksArray.count == 0) //如果没有选
        return;
    
    int start = [[NSString stringWithString:_weeksArray[0]] intValue];
    int end=0;
    int step=1;
    int singleordouble=1;
    
    //NSLog(@"selectresult:%@",_selectResult);
    for(int i = 1;i<_weeksArray.count;i++)
    {
        NSString *weekstring = _weeksArray[i];
        if(weekstring.intValue == start + step)
        {
            end = weekstring.intValue;
            step++;
        }
        else
        {
            if(end > start){
                _weeks = [_weeks stringByAppendingFormat:@"%d-%d,",start,end];}
            else{
                _weeks = [_weeks stringByAppendingFormat:@"%d,",start];}
            start = [[NSString stringWithString:_weeksArray[i]] intValue];
            step = 1;
            
        }
    }
    if(end > start){
        _weeks = [_weeks stringByAppendingFormat:@"%d-%d",start,end];}
    else{
        _weeks = [_weeks stringByAppendingFormat:@"%d",start];}
    _weeks = [_weeks stringByAppendingFormat:@"周"];
    
    //当选择结果可以用单双周表示时
    if(_weeksArray.count>1)
    {
        start = [[NSString stringWithString:_weeksArray[0]] intValue];
        end=0;
        step=1;
        singleordouble=1;
        for(int i = 1;i<_weeksArray.count;i++)
        {
            NSString *weekstring = _weeksArray[i];
            if(weekstring.intValue == start + step*2)
            {
                end = weekstring.intValue;
                step++;
                singleordouble++;
            }
            else break;
        }
        if(singleordouble * 2 == [[NSString stringWithString:[_weeksArray lastObject]]intValue])
            _weeks = [NSString stringWithFormat:@"%d-%d周(双周)",start,end];
        else if(singleordouble * 2 - 1 == [[NSString stringWithString:[_weeksArray lastObject]]intValue])
            _weeks = [NSString stringWithFormat:@"%d-%d周(单周)",start,end];
    }

}


-(void)courseTimeArraytoCourseTimeString
{
    //先清空_courseTime的内容
    _courseTime = @"";
    
    NSArray *timeData = @[@"早间",@"1节",@"2节",@"3节",@"4节",@"午间",@"5节",@"6节",@"7节",@"8节",@"9节",@"10节",@"11节",@"12节",@"晚间"];
    
    for(NSString *everyone in _courseTimeArray)
    {
        _courseTime = [_courseTime stringByAppendingString:timeData[everyone.intValue]];
        _courseTime = [_courseTime stringByAppendingString:@","];
    }
    
    if(_courseTime.length >1)//添加判断条件是为了避免什么也没选的时候出错
        _courseTime = [_courseTime substringWithRange:NSMakeRange(0, [_courseTime length] - 1)];//去掉最后添加的,符号
    //NSLog(@"_courseTime:%@",_courseTime);
    
}

-(void)weekDayNumtoWeekDay
{
    NSArray * itemData = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
    _weekDay = itemData[_weekDayNum.intValue - 1];
    
}

//把coursetimecellmodel转变coursemodel，装在参数NSMutableArray。方便存储和使用
-(BOOL)CourseCellModeltoCourseModelinArray:(NSMutableArray *)courseModelArray
{
    
    if(![self checkifComplete]) return NO;//数据不完整
    
    NSArray *courseTimeDictArray = [[self consecutivejude:_courseTimeArray] copy];
    NSArray *weeksArray = _weeksArray;
    
    for(int j = 0;j<courseTimeDictArray.count;j++)
    {
        NSArray *course_startlast = courseTimeDictArray[j];
        for(int k=0;k<weeksArray.count;k++)
        {
            CourseModel *datamodel = [[CourseModel alloc] init];
            datamodel.place = _place;
            datamodel.courseName = _courseName;
            datamodel.weekday = _weekDayNum;
            datamodel.weeks = weeksArray[k];
            NSNumber *start = course_startlast[0];
            NSNumber *last = course_startlast[1];
            datamodel.courseStart = start.description;
            datamodel.numberOfCourse = last.description;
            NSLog(@"model:%@,%@,%@,%@,%@,%@",datamodel.place,datamodel.courseName,datamodel.weekday,datamodel.weeks,datamodel.courseStart,datamodel.numberOfCourse);
            [courseModelArray addObject:datamodel];
        }
    }
    
    return YES;
}

//检查当前数据是否完整
-(BOOL)checkifComplete
{
    //NSLog(@"%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld",_weeks.length , _weekDay.length , _courseTime.length , _place.length , _weeksArray.count , _courseTimeArray.count , _weekDay.length , _courseName.length);
    return (_weeks.length && _weekDay.length && _courseTime.length && _place.length && _weeksArray.count && _courseTimeArray.count && _weekDay.length && _courseName.length);    
}

//从时段array得出开始时间和持续时间（如1,2,4识别出第一组开始第一节，持续两节，第二组开始第四节，持续一节...）
-(NSMutableArray *)consecutivejude:(NSMutableArray *)array
{
    
    NSMutableArray *returnmodelarray = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:0]];//添加0尾方便处理
    int start = [array[0] intValue];
    int last = 1;
    int step = 1;
    for(int i=1;i<array.count;i++)
    {
        int next = [array[i] intValue];
        if(next == (start+step)){
            last+=1;
            step++;
        }
        else{
            NSArray *group = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:start],[NSNumber numberWithInt:last],nil];
            [returnmodelarray addObject:group];
            start = next;
            last = 1;
            step = 1;
        }
    }
    
    //NSLog(@"returnmodel:%@",returnmodelarray);
    return returnmodelarray;
}

//懒加载
-(NSMutableArray *)weeksArray
{
    if(!_weeksArray)
    {
        _weeksArray = [[NSMutableArray alloc] init];
    }
    return _weeksArray;
}

-(NSMutableArray *)courseTimeArray
{
    if(!_courseTimeArray)
    {
        _courseTimeArray = [[NSMutableArray alloc] init];
    }
    return _courseTimeArray;
}

-(BOOL)checkIfConflictComparetoAnotherCellModel:(CourseTimeCellModel *)courseCellModel
{
    if(![_weekDayNum isEqualToString: courseCellModel.weekDayNum]) return NO;
    
    NSMutableSet *weeksSet = [[NSMutableSet alloc] init];
    [weeksSet addObjectsFromArray:_weeksArray];
    [weeksSet addObjectsFromArray:courseCellModel.weeksArray];
    if(weeksSet.count == (_weeksArray.count + courseCellModel.weeksArray.count)) return NO;
    
    NSMutableSet *courseTimeSet = [[NSMutableSet alloc] init];
    [courseTimeSet addObjectsFromArray:_courseTimeArray];
    [courseTimeSet addObjectsFromArray:courseCellModel.courseTimeArray];
    if(courseTimeSet.count == (_courseTimeArray.count + courseCellModel.courseTimeArray.count)) return NO;
    
    return YES;
}

@end
