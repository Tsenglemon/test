//
//  BusinessModel.m
//  XiaoYa
//
//  Created by commet on 17/2/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "BusinessModel.h"

@implementation BusinessModel
- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic != nil) {
            self.dataid = [dic objectForKey:@"id"];
            self.desc = [dic objectForKey:@"description"];
            self.comment = [dic objectForKey:@"comment"];
            self.date = [dic objectForKey:@"date"];
            self.time = [dic objectForKey:@"time"];
            self.repeat = [dic objectForKey:@"repeat"];
//            self.overlap = [dic objectForKey:@"overlap"];
            
            self.intersects = NO;
            self.timeArray = [NSMutableArray array];
            if (self.time.length != 0) {
                NSString *subTimeStr = [self.time substringWithRange:NSMakeRange(1, self.time.length - 2)];//截去头尾“,”
                NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
                self.timeArray = [tempArray mutableCopy];
            }
        }
    }
    return self;
}
@end
