//
//  dayselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicTemplateCell.h"


@interface dayselectview : UIView
@property (nonatomic,strong) NSString *dayselected;//选择的日子
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;


-(instancetype)initWithFrame:(CGRect)frame;


@end
