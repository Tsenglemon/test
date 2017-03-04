//
//  weekselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/14.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol weekselectViewDelegate <NSObject>

-(void)setWeekSelectResult:(NSMutableArray *)weekselected inSection:(NSInteger)section;
-(void)removeCover;

@end

@interface weekselectview : UIView

@property (nonatomic,strong) NSMutableArray *weekselected_array;
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;

//两个给代理传输的数据
@property (nonatomic,strong) NSMutableArray* selectResult;
//@property (nonatomic,copy) NSString *showstring;
@property (nonatomic,copy) NSString * whichSection;

@property (nonatomic,weak) id delegate;

-(instancetype)initWithFrame:(CGRect)frame andWeekSelect:(NSArray *)showweek;

@end
