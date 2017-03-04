//
//  dayselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaySelectCell.h"

@protocol dayselsctViewDelegate <NSObject>

-(void)setDayString:(NSString *)dayString inSection:(NSInteger )section;
-(void)removeCover;

@end


@interface dayselectview : UIView
@property (nonatomic,strong) NSString *weekDayString;//选择的星期几结果
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,copy) NSString * whichSection;


@property (nonatomic,weak) id delegate;


-(instancetype)initWithFrame:(CGRect)frame andDayString:(NSString *)dayString;


@end
