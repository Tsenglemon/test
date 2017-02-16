//
//  CourseButton.m
//  XiaoYa
//
//  Created by commet on 16/11/1.
//  Copyright © 2016年 commet. All rights reserved.
//
//课程格子按钮 模板类
#import "CourseButton.h"
#import "Masonry.h"

@implementation CourseButton
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.isOverlap = 0;
        
        UILabel *event = [[UILabel alloc]init];
        _event = event;
        _event.textColor = [UIColor whiteColor];
        _event.font = [UIFont systemFontOfSize:11];//默认11，但选中的放大列字号13
        
        UILabel *place = [[UILabel alloc]init];
        _place = place;
        _place.textColor = [UIColor whiteColor];
        _place.font = [UIFont systemFontOfSize:11];
        
        [self addSubview:_event];
        [self addSubview:_place];
        
        __weak typeof(self) weakself = self;
        [_event mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.bottom.equalTo(weakself.mas_centerY).offset(-5);
        }];
        [_place mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.top.equalTo(weakself.mas_centerY).offset(5);
        }];
    }
    return self;
}

//- (void)setCourseModel:(CourseModel *)courseModel
//{
//    _event.text = courseModel.courseName;
//    _place.text = courseModel.place;
//}

@end
