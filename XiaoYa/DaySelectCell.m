//
//  DaySelectCell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/2/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "DaySelectCell.h"
#import "Masonry.h"
#import "Utils.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@implementation DaySelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    //    //底部分割线
    UIView *bottomSeparate = [[UIView alloc]init];
    bottomSeparate.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];//系统分割线颜色
    [self.contentView addSubview:bottomSeparate];
    __weak typeof(self)weakself = self;
    [bottomSeparate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.width.mas_equalTo(586 / 750.0 * kScreenWidth);
        make.left.bottom.equalTo(weakself.contentView);
    }];
    
    //事件描述
    UILabel *item = [[UILabel alloc]init];
    _item = item;
    _item.font = [UIFont systemFontOfSize:12];
    _item.text = @"事件描述";
    _item.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_item];
    [_item mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView.mas_left).offset(22);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
    }];
    //按钮
    UIButton * choiceBtn = [[UIButton alloc]init];
    _choiceBtn = choiceBtn;
    [_choiceBtn setImage:[UIImage imageNamed:@"未选择星期"] forState:UIControlStateNormal];
    [_choiceBtn setImage:[UIImage imageNamed:@"选择星期"] forState:UIControlStateSelected];
    [self.contentView addSubview:_choiceBtn];
    [_choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
        make.right.equalTo(weakself.contentView.mas_right).offset(-16);
    }];
}



@end
