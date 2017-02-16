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
@property (nonatomic,weak) UILabel *comment;
@property (nonatomic,weak) UIButton *select;


-(instancetype)initWithreuseIdentifier:(NSString *)reuseIdentifier;

@end
