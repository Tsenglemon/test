//
//  CourseTimeCell.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/5.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseTimeCell : UITableViewCell

@property (nonatomic,weak) UIButton *weeksnum;
@property (nonatomic,weak) UIButton *weekday;
@property (nonatomic,weak) UIButton *coursenum;
@property (nonatomic,weak) UIButton *delete_btn;
@property (nonatomic,weak) UITextField *classroom;


-(instancetype)initWithreuseIdentifier:(NSString *)ID;

@end
