//
//  BusinessModel.h
//  XiaoYa
//
//  Created by commet on 17/2/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessModel : NSObject
@property (nonatomic, copy)   NSString *dataid;
@property (nonatomic, copy)   NSString *desc;                 //描述
@property (nonatomic, copy)   NSString *comment;              //备注
@property (nonatomic, copy)   NSString *week;                 //当前周 0-n
@property (nonatomic, copy)   NSString *weekday;              //周几 0-6，周一为0
@property (nonatomic, copy)   NSString *date;                 //日期yyyymmdd
@property (nonatomic ,copy)   NSString *time;                 //时间，第几节
@property (nonatomic ,copy)   NSString *repeat;               //是否重复
@property (nonatomic ,copy)   NSString *overlap;              //是否和课程有重合，0每天，1每两天…6不重复
@property (nonatomic ,strong) NSMutableArray *timeArray;      //把time string转化成array

- (id)initWithDict:(NSDictionary *)dic;
@end
