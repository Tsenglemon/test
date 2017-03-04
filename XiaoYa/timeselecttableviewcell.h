//
//  timeselecttableviewcell.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface timeselecttableviewcell : UITableViewCell

@property (nonatomic,weak) UILabel *time;
@property (nonatomic,weak) UILabel *number;
@property (nonatomic,weak) UILabel *timenode;
@property (nonatomic,weak) UILabel *comment; //中间的注释
@property (nonatomic,weak) UIButton *selectBtn; //右边的选框
@property (nonatomic,weak) UIView *overlapAlertView; //提示“将会覆盖原有课程”的警示条


-(instancetype)initWithreuseIdentifier:(NSString *)reuseIdentifier;

@end
