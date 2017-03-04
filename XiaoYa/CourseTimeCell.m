//
//  CourseTimeCell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/5.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "CourseTimeCell.h"
#import "Utils.h"
#import "Masonry.h"


#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0


//用在添加课程的页面

@implementation CourseTimeCell

-(instancetype)initWithreuseIdentifier:(NSString *)ID
{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID])
    {

        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [[Utils colorWithHexString:@"#D9D9D9"] CGColor];
        self.layer.borderWidth = 0.5;
        //添加竖线
        for(int i =0;i<2;i++)
        {
            UIView *verticalline = [[UIView alloc] init];
            verticalline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
            [self addSubview:verticalline];
            __weak typeof(self) weakself = self;
            [verticalline mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(320.0 / 1334.0 * kScreenHeight);
                make.width.mas_equalTo(0.5);
                make.left.equalTo(weakself.mas_left).offset((60  + 65 * i)/ 750.0 * kScreenWidth);
                make.centerY.equalTo(weakself.mas_centerY);
            }];
        }
        
        //添加横线和箭头
        for (int i =0; i<3; i++) {
            UIView *horizonline = [[UIView alloc] init];
            horizonline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
            [self addSubview:horizonline];
            __weak typeof(self) weakself = self;
            [horizonline mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.5);
                make.width.mas_equalTo(500.0 / 750.0 * kScreenWidth);
                make.left.equalTo(weakself.mas_left).offset(125.0 / 750.0 * kScreenWidth);
                make.top.equalTo(weakself.mas_top).offset(80.0 / 1334.0 * kScreenHeight * (i+1));
            }];
            
            UIImageView *arrow = [[UIImageView alloc] init];
            arrow.image = [UIImage imageNamed:@"arrow"];
            [self addSubview:arrow];
            [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(horizonline.mas_right);
                make.bottom.equalTo(horizonline.mas_bottom);
            }];
            
        }
        
        __weak typeof(self) weakself = self;
        
        UIButton *deletebtn = [[UIButton alloc] init];
        _delete_btn = deletebtn;
        [_delete_btn setBackgroundImage:[UIImage imageNamed:@"删除圆"] forState:UIControlStateNormal];
        _delete_btn.backgroundColor = [UIColor whiteColor];
        [self addSubview:_delete_btn];
        [_delete_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.height.equalTo(weakself.mas_height);
            make.centerY.equalTo(weakself.mas_centerY);
            make.centerX.equalTo(weakself.mas_left).offset(30.0*scaletowidth);
        }];
        
        
        UILabel *coursetime = [[UILabel alloc] init];
        coursetime.text = @"上\n课\n时\n间";
        coursetime.numberOfLines = [coursetime.text length];
        coursetime.font = [UIFont systemFontOfSize:14*fontscale];
        coursetime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:coursetime];
        
        [coursetime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(weakself.mas_height);
            make.width.mas_equalTo(65.0 / 750.0 * kScreenWidth);
            make.left.mas_equalTo(60.0 / 750.0 *kScreenWidth);
            make.centerY.equalTo(weakself.mas_centerY);
        }];
        
        //设置三个显示的button和一个field
        UIButton *weeks = [[UIButton alloc] init];
        _weeks = weeks;
        [self addSubview:_weeks];
        UIButton *weekDay = [[UIButton alloc] init];
        _weekDay = weekDay;
        [self addSubview:_weekDay];
        UIButton *courseTime = [[UIButton alloc] init];
        _courseTime = courseTime;
        [self addSubview:_courseTime];
        UITextField *place = [[UITextField alloc] init];
        _place = place;
        [self addSubview:_place];
        
        [_weeks setTitle:@"1-16周" forState:UIControlStateNormal];
        [_weeks setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _weeks.titleLabel.font = [UIFont systemFontOfSize:14*fontscale];
        
        [_weekDay setTitle:@"周一" forState:UIControlStateNormal];
        [_weekDay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _weekDay.titleLabel.font = [UIFont systemFontOfSize:14*fontscale];
        
        [_courseTime setTitle:@"1-2节" forState:UIControlStateNormal];
        [_courseTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _courseTime.titleLabel.font = [UIFont systemFontOfSize:14*fontscale];
        
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
        dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
        NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入上课教室" attributes:dict];
        [_place setAttributedPlaceholder:attribute];
        _place.font = [UIFont systemFontOfSize:12.0*fontscale];

        //_place.placeholder = @"请输入上课教室";
        [_place setTextAlignment:NSTextAlignmentCenter];
        
        [_weeks mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.width.mas_equalTo(500.0 / 750.0 *kScreenWidth);
            make.height.mas_equalTo(80.0 / 1334.0 *kScreenHeight);
            make.top.equalTo(weakself.mas_top);
        }];
        
        [_weekDay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.width.mas_equalTo(500.0 / 750.0 *kScreenWidth);
            make.height.mas_equalTo(80.0 / 1334.0 *kScreenHeight);
            make.top.equalTo(_weeks.mas_bottom);
        }];

        [courseTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.width.mas_equalTo(500.0 / 750.0 *kScreenWidth);
            make.height.mas_equalTo(80.0 / 1334.0 *kScreenHeight);
            make.top.equalTo(_weekDay.mas_bottom);
        }];

        [_place mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.width.mas_equalTo(500.0 / 750.0 *kScreenWidth);
            make.height.mas_equalTo(80.0 / 1334.0 *kScreenHeight);
            make.top.equalTo(courseTime.mas_bottom);
        }];

        
        
    }
    
    return self;
}

@end
