//
//  CourseModel.m
//  XiaoYa
//
//  Created by commet on 16/10/31.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "CourseModel.h"

@implementation CourseModel
- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic != nil) {
            self.weeks = [dic objectForKey:@"weeks"];
            self.weekday = [dic objectForKey:@"weekDay"];
            self.courseStart = [dic objectForKey:@"courseStart"];
            self.numberOfCourse = [dic objectForKey:@"numberOfCourse"];
            self.courseName = [dic objectForKey:@"courseName"];
            self.place = [dic objectForKey:@"place"];
            self.couresPeriod = [dic objectForKey:@"couresPeriod"];
        }
    }
    return self;
}
@end
