//
//  timeselecteview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface timeselecteview : UIView

@property (nonatomic,strong) NSMutableArray *dayselected_array;
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,weak) UILabel *today;
@property (nonatomic,strong) NSMutableArray *selectresult;

-(instancetype)initWithFrame:(CGRect)frame;


@end
