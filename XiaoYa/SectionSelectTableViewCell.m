//
//  SectionSelectTableViewCell.m
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "SectionSelectTableViewCell.h"
#import "Masonry.h"
#import "Utils.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface SectionSelectTableViewCell()
@property (nonatomic , weak)UILabel *time;
@property (nonatomic , weak)UILabel *number;
@property (nonatomic , weak)UILabel *event;
//@property (nonatomic , weak)UIButton *mutipleChoice;

@end

@implementation SectionSelectTableViewCell
- (void)setModel:(NSArray *)model{
    self.time.text = model[0];
    self.number.text = model[1];
}


+(instancetype)SectionCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"SectionSelectCell";
    SectionSelectTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[SectionSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    //底部分割线
    UIView *bottomSeparate = [[UIView alloc]init];
    bottomSeparate.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];//系统分割线颜色
    [self.contentView addSubview:bottomSeparate];
    __weak typeof(self)weakself = self;
    [bottomSeparate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.width.mas_equalTo(586 / 750.0 * kScreenWidth);
        make.left.bottom.equalTo(weakself.contentView);
    }];
    //竖分割线
    UIView *horSeparate = [[UIView alloc]init];
    horSeparate.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];//系统分割线颜色
    [self.contentView addSubview:horSeparate];
    [horSeparate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(39);//和单元格行高相同
        make.left.equalTo(weakself.contentView).offset(40);
        make.top.equalTo(weakself);
    }];
    //时间和节数。参照timeViewCell.m
    UILabel *time = [[UILabel alloc]init];
    _time = time;
    _time.font = [UIFont systemFontOfSize:10];
    _time.textColor = [Utils colorWithHexString:@"#999999"];
    
    UILabel *number = [[UILabel alloc]init];
    _number = number;
    _number.font = [UIFont systemFontOfSize:10];
    _number.textColor = [Utils colorWithHexString:@"#4c4c4c"];
    [self.contentView addSubview:_time];
    [self.contentView addSubview:_number];
    
    [_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_left).offset(20);
        make.bottom.equalTo(weakself.contentView.mas_centerY).offset(-3);
    }];
    [_number mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_left).offset(20);
        make.top.equalTo(weakself.contentView.mas_centerY).offset(3);
    }];
    //事件描述
    UILabel *event = [[UILabel alloc]init];
    _event = event;
    _event.font = [UIFont systemFontOfSize:14];
    _event.text = @"事件描述";
    _event.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_event];
    [_event mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_centerX);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
    }];
    //复选按钮
    UIButton * mutipleChoice = [[UIButton alloc]init];
    _mutipleChoice = mutipleChoice;
    [_mutipleChoice setImage:[UIImage imageNamed:@"未选择节"] forState:UIControlStateNormal];
    [_mutipleChoice setImage:[UIImage imageNamed:@"选择节"] forState:UIControlStateSelected];
    [self.contentView addSubview:_mutipleChoice];
    [_mutipleChoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
        make.right.equalTo(weakself.contentView.mas_right).offset(-5);
    }];
    [_mutipleChoice addTarget:self action:@selector(mutipleClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)mutipleClicked:(UIButton *)sender{
    //cell 里的 button，它的 superview 是 UITableViewCellContentView，而它的 superview 就是我们自定义的 cell，cell 的 superview 是 UITableViewWrapperView，而它的 superview 就是 UITableView
    UIView *view1 = [sender superview];
    UIView *view2 = [view1 superview];
    NSIndexPath *indexPath = [(UITableView *)[[view2 superview] superview] indexPathForCell:(UITableViewCell*)view2];
 
    if (sender.isSelected) {//已经选中了
        sender.selected = NO;//置为未选中
        [self.delegate SectionSelectTableViewCell:self deSelectIndex:indexPath];
    }else{
        sender.selected = YES;
        [self.delegate SectionSelectTableViewCell:self selectIndex:indexPath];
    }
}

@end
