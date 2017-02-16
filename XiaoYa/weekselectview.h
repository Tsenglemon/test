//
//  weekselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/14.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface weekselectview : UIView

@property (nonatomic,strong) NSMutableArray *weekselected_array;
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;

-(instancetype)initWithFrame:(CGRect)frame;

@end
