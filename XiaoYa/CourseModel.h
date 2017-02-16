//
//  CourseModel.h
//  XiaoYa
//
//  Created by commet on 16/10/31.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseModel : NSObject

@property (nonatomic, copy) NSString    *weeks;             //当前周
@property (nonatomic, copy) NSString    *weekday;           //周几,1/2/3/4/5/6/7,代表周一、周二、周三..
@property (nonatomic, copy) NSString    *courseStart;       //课程从第几节开始
@property (nonatomic, copy) NSString    *numberOfCourse;    //课程有几节课
@property (nonatomic, copy) NSString    *courseName;        //课程名称
@property (nonatomic, copy) NSString    *place;             //上课地点
@property (nonatomic, copy) NSString    *couresPeriod;      //周期，比如3-14周，则数据为3-14
@property (nonatomic, copy) NSString    *capter;
@property (nonatomic, assign) BOOL      haveLesson;

- (id)initWithDict:(NSDictionary *)dic;
@end
