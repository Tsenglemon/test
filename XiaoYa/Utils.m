//
//  Utils.m
//  XiaoYa
//
//  Created by commet on 16/10/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "Utils.h"

@implementation Utils
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//事务节数分割连续段，连续的分为一组
+ (NSMutableArray*)subSectionArraysFromArray:(NSMutableArray *)sectionArray{
    NSMutableArray *sections = [NSMutableArray array];
    NSInteger count = sectionArray.count;
    int sectionCount = 1;
    if (count != 1){
        int i = 1;
        for (; i < count; i++) {
            NSString *num1 = (NSString*)sectionArray[i-1];
            NSString *num2 = (NSString*)sectionArray[i];
            if ([num1 intValue] != [num2 intValue] - 1) {
                sectionCount ++;
            }
        }
    }
    if (sectionCount == 1) {
        [sections addObject:sectionArray];
    }else{
        int i = 0;
        for (int k = 0; k < sectionCount; k ++) {
            NSMutableArray *temp = [NSMutableArray array];
            for (; i < count-1; i++) {
                NSString *num1 = (NSString*)sectionArray[i];
                NSString *num2 = (NSString*)sectionArray[i+1];
                if ([num1 intValue] == [num2 intValue] - 1) {
                    [temp addObject:num1];
                }
                else{
                    [temp addObject:num1];
                    [sections addObject:temp];
                    i++;
                    break;
                }
            }
            if (k == sectionCount - 1) {
                [temp addObject:sectionArray[count-1]];
                [sections addObject:temp];
            }
        }
    }
    return sections;
}
@end
