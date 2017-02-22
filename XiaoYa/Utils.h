//
//  Utils.h
//  XiaoYa
//
//  Created by commet on 16/10/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Utils : NSObject
+ (UIColor *)colorWithHexString: (NSString *)color;

//事务节数分割连续段
+ (NSMutableArray*)subSectionArraysFromArray:(NSMutableArray *)sectionArray;
@end
