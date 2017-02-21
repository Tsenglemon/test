//
//  BusinessViewController.m
//  XiaoYa
//
//  Created by commet on 16/11/25.
//  Copyright © 2016年 commet. All rights reserved.
//事务管理

#import "BusinessViewController.h"
#import "businessviewcell.h"
#import "Utils.h"
#import "Masonry.h"
#import "DatePicker.h"
#import "MonthPicker.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "AppDelegate.h"
#import "SectionSelect.h"
#import "RemindSelect.h"
#import "RepeatSetting.h"
#import "UIView+Extend.h"
#import <objc/runtime.h>
#import "CommentViewController.h"
#import "UIAlertController+Appearance.h"
#import "UILabel+AlertActionFont.h"
#import "DbManager.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define scaleToHeight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaleToWidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontScale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

@interface BusinessViewController ()<DatePickerDelegate,MonthPickerDelegate,SectionSelectDelegate,RemindSelectDelegate,RepeatSettingDelegate,CommentVCDelegate,UITextFieldDelegate>

//事务的子view
@property (nonatomic,weak) UIView *businessField_view;//第一行的描述父view
//@property (nonatomic,weak) UITextField *busDescription;//事件描述textfield，描述+时间均有内容才允许保存事件，因此用属性声明
@property (nonatomic,weak) UIView *commentsField_view;//最后一行备注
@property (nonatomic,weak) businessviewcell *businessTime_view;//时间选择板块
@property (nonatomic,weak) businessviewcell *clock_view;//提醒重复设置板块
@property (nonatomic,weak) UIView *comments_view;
@property (nonatomic,weak) UIButton *delete_btn;//删除按钮
@property (nonatomic,weak) UIButton *remind_btn;//提醒按钮
@property (nonatomic,weak) UITextField *commentfield;//备注栏
@property (nonatomic,weak) UIView *coverLayer;//日历弹出时背后的半透明遮罩

@property (nonatomic , weak) DatePicker *datePicker;//自定义的日期选择器
//@property (nonatomic , strong) NSDate *currentDate;//当前日期
@property (nonatomic , strong) NSDate *lastSelectedDate;//上一次选择的日期
@property (nonatomic , weak) SectionSelect *selectSection;//自定义时间段（节）选择器
@property (nonatomic , weak) RemindSelect *settingRemind;//提醒
@property (nonatomic , weak) RepeatSetting *settingRepeat;//重复
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , strong) BusinessModel *busModel;
//@property (nonatomic , copy) NSString *commentInfo;//备注的内容
@property (nonatomic , strong) NSArray *repeatItem;//“重复”项的内容
//@property (nonatomic , assign) NSInteger repeatIndex;//“重复”中的哪一项

@end

@implementation BusinessViewController{
    CGFloat rowHeight;//每一行的高度80像素
    CGFloat separateHeight;//分割行高度 30像素
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
    CGFloat datePickerWidth;//日期选择器宽度
}

- (instancetype)initWithfirstDateOfTerm:(NSDate *)firstDateOfTerm businessModel:(BusinessModel *)busModel{
    if(self = [super init]){
        self.firstDateOfTerm = firstDateOfTerm;
        self.busModel = busModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionArray = [NSMutableArray array];
    self.sections = [NSMutableArray array];
    self.commentInfo = [NSString string];
    self.repeatItem = @[@"每天",@"每两天",@"每周",@"每月",@"每年",@"工作日",@"不重复"];
    rowHeight = 80;
    separateHeight = 30;
    
    if (self.busModel) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        self.currentDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self.busModel.date]];
        self.sectionArray = self.busModel.timeArray;
        self.repeatIndex = self.busModel.repeat.integerValue;
        
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};//设置标题文字样式
        self.navigationItem.title = @"事务";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    }else{
        self.currentDate = [NSDate date];//当前时间
        self.repeatIndex = 6;//如果是从“+”进来的，默认是最后一项，“不重复”
    }
    
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self addBusinessField_view];
    [self addBusinessTime_view];
    [self addRemind_btn];
    [self settingClockView];
    [self settingCommentView];
    [self settingDeleteBtn];
    _clock_view.hidden = YES;
    _commentsField_view.hidden = YES;
    _delete_btn.hidden = YES;
    
    if (self.busModel) {//如果模型有值，表明是从点击课程格子进来的
        _remind_btn.hidden = YES;
        _clock_view.hidden = NO;
        _commentsField_view.hidden = NO;
        _delete_btn.hidden = NO;
    }
}

//事务界面自己的确认和取消按钮方法。从主界面点击格子跳转进事务界面的情况下，方法才会有效；如果是从“+”进来的就没用
- (void)confirm{//这里需要完善->能否点击的条件
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel{
    //如果全部没输入就直接返回，但日期是一定会有的（所以不存在直接返回的情况）
//    if ([_busDescription.text isEqualToString:@""] && self.sectionArray.count == 0) {
//        [self.navigationController popViewControllerAnimated:YES];//返回主界面
//    }else{
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            [self.navigationController popViewControllerAnimated:YES];
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_busDescription];
}

//描述
- (void)addBusinessField_view{
    UIView *businessfield_view = [[UIView alloc] init];
    _businessField_view = businessfield_view;
    _businessField_view.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
    [self.view addSubview:_businessField_view];
    __weak typeof(self) weakself = self;
    [_businessField_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(rowHeight * scaleToHeight );
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(weakself.view);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    //文本框
    UITextField *busDescription = [[UITextField alloc] init];
    //边框
    _busDescription = busDescription;
    _busDescription.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _busDescription.layer.borderWidth = 0.5f;
    _busDescription.layer.cornerRadius = 2.0f;
    //placeholder颜色、大小
    //自定义textfield
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请描述你的事务" attributes:dict];
    [_busDescription setAttributedPlaceholder:attribute];
    //文本颜色、大小
    _busDescription.textColor = [Utils colorWithHexString:@"#333333"];
    _busDescription.font = [UIFont systemFontOfSize:12.0];
    //文本框内的文字距离左边框的距离
    _busDescription.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _busDescription.leftViewMode = UITextFieldViewModeAlways;
    _busDescription.text = self.busModel.desc;
    [_businessField_view addSubview:_busDescription];
    [_busDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_businessField_view.mas_centerX);
        make.centerY.equalTo(_businessField_view.mas_centerY);
        make.width.mas_equalTo(500 * scaleToWidth);
        make.height.mas_equalTo(54 * scaleToHeight);
    }];
    
    [_busDescription addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIImageView *pen = [[UIImageView alloc] init];
    pen.image = [UIImage imageNamed:@"pencil"];
    [_businessField_view addSubview:pen];
    [pen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_busDescription.mas_centerY);
        make.right.equalTo(_busDescription.mas_left).offset(-24 * scaleToWidth);
    }];
    //监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(descChange:) name:UITextFieldTextDidChangeNotification object:_busDescription];
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_businessField_view addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_businessField_view.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_businessField_view addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_businessField_view.mas_bottom);
    }];
}

//留个坑，导航栏右按钮要在描述和时间都有才能点击
-(void)descChange:(NSNotification *)notification
{
    UIViewController *vc = self.view.superview.viewController;
    if (_busDescription.text.length > 0) {
        vc.navigationItem.rightBarButtonItem.enabled = YES;//设置导航栏右按钮可以点击
    }else
    {
        vc.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}

- (void)textFiledDidChange:(UITextField *)textField
{
    if ([self indexOfCharacter:textField.text] != -1) {
        textField.text = [textField.text substringToIndex:[self indexOfCharacter:textField.text]];//输入字数超过了就截断
    }
}

- (int)indexOfCharacter:(NSString *)strtemp//限制文本框输入最长20个字符
{
    int strlength = 0;
    for (int i=0; i< [strtemp length]; i++) {
        int a = [strtemp characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fa5) { //判断是否为中文
            strlength += 2;
        }else{
            strlength += 1;
        }
        if (strlength > 20) {
            return i;
        }
    }
    return -1;
}

//时间选择板块
- (void)addBusinessTime_view{
    NSArray *iconarray = @[@"日历"];
    businessviewcell *businesstime_view = [[businessviewcell alloc]initWithFrame:CGRectZero andNSArray:iconarray];
    _businessTime_view = businesstime_view;
    [self.view addSubview:businesstime_view];
    
    __weak typeof(self) weakself = self;
    [businesstime_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(rowHeight * 3 * scaleToHeight);
        make.top.equalTo(_businessField_view.mas_bottom).offset(separateHeight * scaleToHeight);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    [_businessTime_view.button1 addTarget:self action:@selector(dateSelected) forControlEvents:UIControlEventTouchUpInside];
    [businesstime_view.button2 addTarget:self action:@selector(sectionSelected) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.busModel) {
        [self bsTVBtnSetting:self.currentDate];
        
        NSMutableArray * tempArr = [self.sectionArray mutableCopy];
        for (int i = 0; i < tempArr.count ; i ++) {
            if ([tempArr[i] intValue] == 0) {
                tempArr[i] = @"早间";
            }else if ([tempArr[i] intValue] == 5){
                tempArr[i] = @"午间";
            }else if([tempArr[i] intValue] > 5 && [tempArr[i] intValue] < 14){
                tempArr[i] = [NSString stringWithFormat:@"%d",[tempArr[i] intValue] - 1];
            }else if ([tempArr[i] intValue] == 14){
                tempArr[i] = @"晚间";
            }
        }
        NSMutableString *subTimeStr = [NSMutableString stringWithFormat:@"%@",tempArr[0]];
        if (self.sectionArray.count != 1) {
            for (int i = 1; i < self.sectionArray.count; i++) {
                [subTimeStr appendFormat:@"、%@",tempArr[i]];
            }
        }
//        NSString *subTimeStr = [self.busModel.time substringToIndex:self.busModel.time.length - 1];
        [self.businessTime_view.button2 setTitle:[NSString stringWithFormat:@"第%@节",subTimeStr] forState:UIControlStateNormal];
    }
}

//日期选择
- (void)dateSelected{
    //生成遮罩层
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    _coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    UIWindow *theWindow = app.window;//全屏遮罩要加到window上
    [theWindow addSubview:_coverLayer];
    
    //生成自定义日期选择器
    weekWidth = 120.0 / 750.0 * kScreenWidth;
    cellWidth = 76.0 / 750.0 * kScreenWidth;

    datePickerWidth = weekWidth +cellWidth *7;
    int weekRow = [DateUtils rowNumber:self.currentDate];//日历该有多少行
    CGFloat datePickerHeight = cellWidth * (weekRow + 1 ) + (130 + 178) / 1334.0 * kScreenHeight;//+1:显示周几的一行，130：两个btn高度，178：顶部年月高度
    DatePicker * picker = [[DatePicker alloc]initWithFrame:CGRectMake(0, 64, datePickerWidth, datePickerHeight) date:self.currentDate firstDateOfTerm:self.firstDateOfTerm];
    CGPoint center =  picker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    picker.center = center;
    _datePicker = picker;
    [_coverLayer addSubview:_datePicker];
    _datePicker.delegate = self;
    
    self.lastSelectedDate = self.currentDate;
}

//时间段（节）选择
- (void)sectionSelected{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    _coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    UIWindow *theWindow = app.window;//全屏遮罩要加到window上
    [theWindow addSubview:_coverLayer];
    
    CGFloat width = 650 / 750.0 * kScreenWidth;
    CGFloat height = (178 + 130 ) / 1334.0 * kScreenHeight + 39 * 5;
    
    SectionSelect *selectSection = [[SectionSelect alloc]initWithFrame:CGRectMake(0, 0, width, height) sectionArr:self.sectionArray selectedDate:self.currentDate];
    CGPoint center =  selectSection.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    selectSection.center = center;
    _selectSection = selectSection;
    [_coverLayer addSubview:_selectSection];
    _selectSection.delegate = self;
}

//提醒重复设置板块
- (void)addRemind_btn{
    UIButton *remind_btn = [[UIButton alloc] init];
    _remind_btn = remind_btn;
    [_remind_btn setTitle:@"提醒、重复、备注" forState:UIControlStateNormal];
    [_remind_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    _remind_btn.titleLabel.font = [UIFont systemFontOfSize:16 * fontScale];
    _remind_btn.backgroundColor = [UIColor whiteColor];
    [_remind_btn setImage:[UIImage imageNamed:@"pulldown"] forState:UIControlStateNormal];
    [_remind_btn addTarget:self action:@selector(remind_btn_click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_remind_btn];
    __weak typeof(self) weakself = self;
    [_remind_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(rowHeight * scaleToWidth);
        make.top.equalTo(_businessTime_view.mas_bottom).offset(separateHeight * scaleToHeight);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    //设置文字和图片的位置
    _remind_btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    CGFloat btnImgWidth = _remind_btn.imageView.bounds.size.width;
    CGFloat btnWidth = _remind_btn.bounds.size.width;
    CGFloat btnTextWidth = _remind_btn.titleLabel.bounds.size.width;
    _remind_btn.titleEdgeInsets = UIEdgeInsetsMake(0, (btnWidth - 3 * btnImgWidth - btnTextWidth)/2, 0, 0);
    _remind_btn.imageEdgeInsets = UIEdgeInsetsMake(0, (btnWidth - btnImgWidth + btnTextWidth)/2 + 5, 0, 0);
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_remind_btn addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_remind_btn.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_remind_btn addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_remind_btn.mas_bottom);
    }];
}

- (void)remind_btn_click{
    _remind_btn.hidden = YES;
    _clock_view.hidden = NO;
    _commentsField_view.hidden = NO;
}

- (void)settingClockView{
    //提醒重复设置板块
    NSArray *iconview = @[@"钟",@"refresh-3"];
    businessviewcell *clock_view = [[businessviewcell alloc]initWithFrame:CGRectZero andNSArray:iconview];
    _clock_view = clock_view;
    [_clock_view.button1 setTitle:@"不提醒" forState:UIControlStateNormal];
    [_clock_view.button2 setTitle:self.repeatItem[self.repeatIndex] forState:UIControlStateNormal];
    [self.view addSubview:_clock_view];
    __weak typeof(self) weakself = self;
    [_clock_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(rowHeight * 3 * scaleToHeight);
        make.top.equalTo(_businessTime_view.mas_bottom).offset(separateHeight * scaleToHeight);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    [_clock_view.button1 addTarget:self action:@selector(remindSetting) forControlEvents:UIControlEventTouchUpInside];
    [_clock_view.button2 addTarget:self action:@selector(repeatSetting) forControlEvents:UIControlEventTouchUpInside];
}

- (void)remindSetting{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    _coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    UIWindow *theWindow = app.window;//全屏遮罩要加到window上
    [theWindow addSubview:_coverLayer];
    
    CGFloat width = 530 / 750.0 * kScreenWidth;
    CGFloat height = 318;
    RemindSelect *settingRemind = [[RemindSelect alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    CGPoint center =  settingRemind.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    settingRemind.center = center;
    _settingRemind = settingRemind;
    [_coverLayer addSubview:_settingRemind];
    settingRemind.delegate = self;
}

- (void)repeatSetting{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    _coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    UIWindow *theWindow = app.window;//全屏遮罩要加到window上
    [theWindow addSubview:_coverLayer];
    
    CGFloat width = 530 / 750.0 * kScreenWidth;
    CGFloat height = 318;
    RepeatSetting *setting = [[RepeatSetting alloc]initWithFrame:CGRectMake(0, 0, width, height) selectedIndex:self.repeatIndex];
    CGPoint center =  setting.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    setting.center = center;
    _settingRepeat = setting;
    [_coverLayer addSubview:_settingRepeat];
    setting.delegate = self;
}

- (void)settingCommentView{
    //备注栏
    UIView *commentsfield_view = [[UIView alloc] init];
    _commentsField_view = commentsfield_view;
    _commentsField_view.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
    [self.view  addSubview:_commentsField_view];
    [_commentsField_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(rowHeight * scaleToHeight );
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_clock_view.mas_bottom).offset(separateHeight * scaleToHeight);
        make.centerX.equalTo(_clock_view.mas_centerX);
    }];
    //备注文本框
    UITextField *commentfield = [[UITextField alloc] init];
    _commentfield = commentfield;
    //边框
    _commentfield.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _commentfield.layer.borderWidth = 0.5f;
    _commentfield.layer.cornerRadius = 2.0f;
    //placeholder颜色、大小
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"有什么要补充的写在这里吧！" attributes:dict];
    [_commentfield setAttributedPlaceholder:attribute];
    //文本颜色、大小
    _commentfield.textColor = [Utils colorWithHexString:@"#333333"];
    _commentfield.font = [UIFont systemFontOfSize:12.0];
    //文本框内的文字距离左边框的距离
    _commentfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _commentfield.leftViewMode = UITextFieldViewModeAlways;
    _commentfield.text = self.busModel.comment;
    [_commentsField_view addSubview:_commentfield];
    [_commentfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_commentsField_view.mas_centerX);
        make.centerY.equalTo(_commentsField_view.mas_centerY);
        make.width.mas_equalTo(500 * scaleToWidth);
        make.height.mas_equalTo(54 * scaleToHeight);
    }];
    _commentfield.delegate = self;
    
    UIImageView *comment = [[UIImageView alloc] init];
    comment.image = [UIImage imageNamed:@"edit"];
    [_commentsField_view addSubview:comment];
    [comment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_commentfield.mas_centerY);
        make.right.equalTo(_commentfield.mas_left).offset(-24 * scaleToWidth);
    }];
    __weak typeof(self) weakself = self;
    //备注顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_commentsField_view addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_commentsField_view.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_commentsField_view addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_commentsField_view.mas_bottom);
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CommentViewController *commentVC = [[CommentViewController alloc]initWithTextStr:self.commentInfo];
    commentVC.delegate = self;
    [self.navigationController pushViewController:commentVC animated:YES];
    return NO;
}

- (void)settingDeleteBtn{
    UIButton *delete_btn = [[UIButton alloc] init];
    _delete_btn = delete_btn;
    [_delete_btn setTitle:@"删除" forState:UIControlStateNormal];
    [_delete_btn setTitleColor:[Utils colorWithHexString:@"#FF0000"] forState:UIControlStateNormal];
    _delete_btn.titleLabel.font = [UIFont systemFontOfSize:14 * fontScale];
    _delete_btn.backgroundColor = [UIColor whiteColor];
    [_delete_btn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakself = self;
    [self.view addSubview:_delete_btn];
    [_delete_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(rowHeight * scaleToWidth);
        make.top.equalTo(_commentsField_view.mas_bottom).offset(100.0 * scaleToHeight);
        make.centerX.equalTo(_commentsField_view.mas_centerX);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_delete_btn addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_delete_btn.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_delete_btn addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_delete_btn.mas_bottom);
    }];
}

- (void)deleteAction{
    DbManager *dbManger = [DbManager shareInstance];
    if (_busModel.repeat.intValue == 6) {//不重复
        NSArray *otherTitles = @[@"确认"];
        void (^confirmBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            NSString *sql = [NSString stringWithFormat:@"DELETE from t_201601 where description = '%@' and comment = '%@' and date = '%@' and time = '%@' and repeat = %@ and overlap = %@;",_busModel.desc,_busModel.comment,_busModel.date,_busModel.time,_busModel.repeat,_busModel.overlap];
            [dbManger executeNonQuery:sql];
            [self.navigationController popViewControllerAnimated:YES];
            
        };
        NSArray *otherBlocks = @[confirmBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除本次事务？" message:@"本次删除不可逆" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:otherTitles otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSArray *otherTitles = @[@"仅删除本次事件",@"删除将来所有事件"];
        void (^confirmBlock1)(UIAlertAction *action) = ^(UIAlertAction *action){
            NSString *sql = [NSString stringWithFormat:@"DELETE from t_201601 where description = '%@' and comment = '%@' and date = '%@' and time = '%@' and repeat = %@ and overlap = %@;",_busModel.desc,_busModel.comment,_busModel.date,_busModel.time,_busModel.repeat,_busModel.overlap];
            [dbManger executeNonQuery:sql];
            [self.navigationController popViewControllerAnimated:YES];
        };
        void (^confirmBlock2)(UIAlertAction *action) = ^(UIAlertAction *action){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [dbManger beginTransaction];
                NSString *sql = [NSString stringWithFormat:@"DELETE from t_201601 where description = '%@' and comment = '%@'  and time = '%@' and repeat = %@ and overlap = %@;",_busModel.desc,_busModel.comment,_busModel.time,_busModel.repeat,_busModel.overlap];
                [dbManger executeNonQuery:sql];
                [dbManger commitTransaction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        };
        NSArray *otherBlocks = @[confirmBlock1,confirmBlock2];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"此为重复事件" message:@"请选择您需要删除的类型" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:otherTitles otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark DatePickerDelegate
- (void)datePicker:(DatePicker *)datePicker createMonthPickerWithDate:(NSDate *)currentDate{
    MonthPicker *monthPicker = [[MonthPicker alloc]initWithFrame:CGRectMake(0, 0, 265, 322) date:currentDate];
    [_coverLayer addSubview:monthPicker];
    CGPoint center =  monthPicker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    monthPicker.center = center;
    monthPicker.delegate = self;
    self.datePicker.hidden = YES;//先隐藏，如果monthpicker里面选了“取消”就让它再显示出来
}

//日历日期选择点击了确认
- (void)datePicker:(DatePicker *)datePicker selectedDate:(NSDate *)selectedDate{
    [_coverLayer removeFromSuperview];//移除遮罩
    self.currentDate = selectedDate;//下次就会默认选中上次的日期
    [self bsTVBtnSetting:selectedDate];
}

//_businessTime_view.button1按钮文本设置
- (void)bsTVBtnSetting:(NSDate *) selectedDate{
    //确定这一天是周几
    NSString * dayStr = [selectedDate dayOfCHNWeek];
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:selectedDate];
    NSInteger month = curDateComp.month;
    NSInteger day = curDateComp.day;
    NSInteger dateDistance = [DateUtils dateDistanceFromDate:selectedDate toDate:self.firstDateOfTerm];
    NSInteger week = dateDistance / 7 + 1;
    if (week < 1 || week > 24){
        [_businessTime_view.button1 setTitle:[NSString stringWithFormat:@"第 周 周%@ %ld月%ld日",dayStr,month,day] forState:UIControlStateNormal];
    }else{
        [_businessTime_view.button1 setTitle:[NSString stringWithFormat:@"第%ld周 周%@ %ld月%ld日",week,dayStr,month,day] forState:UIControlStateNormal];
    }
}

- (void)datePickerCancelAction:(DatePicker *)datePicker{
    [_coverLayer removeFromSuperview];//移除遮罩
}

#pragma mark MonthPickerDelegate
- (void)monthPickerCancelAction:(MonthPicker *)monthPicker{
    self.datePicker.hidden = NO;
}

- (void)monthPickerConfirmAction:(MonthPicker *)monthPicker date:(NSDate *)currentDate{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *Comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
    NSDateComponents *Comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.lastSelectedDate];
    if (Comp1.year == Comp2.year && Comp1.month == Comp2.month) {
        self.datePicker.hidden = NO;
        return;
    }
    
    self.lastSelectedDate = currentDate;
    
    [self.datePicker removeFromSuperview];
    int weekRow = [DateUtils rowNumber:currentDate];//日历该有多少行
    CGFloat datePickerHeight = cellWidth * (weekRow + 1 ) + (130 + 178) / 1334.0 * kScreenHeight;//130：两个btn高度，178：顶部年月高度
    DatePicker * picker = [[DatePicker alloc]initWithFrame:CGRectMake(0, 64, datePickerWidth, datePickerHeight) date:currentDate firstDateOfTerm:self.firstDateOfTerm];
    CGPoint center =  picker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    picker.center = center;
    _datePicker = picker;
    [_coverLayer addSubview:_datePicker];
    _datePicker.delegate = self;
}

#pragma mark SectionSelectDelegate
//取消操作
- (void)SectionSelectCancelAction:(SectionSelect *)sectionSelector{
    [_coverLayer removeFromSuperview];//移除遮罩
}

//确认操作
- (void)SectionSelectComfirmAction:(SectionSelect *)sectionSelector sectionArr:(NSMutableArray *)sectionArray{
    [_coverLayer removeFromSuperview];
    NSInteger count = sectionArray.count;
    if (count != 0) {
        [sectionArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2)
        {
            //此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
            if ([obj1 integerValue] < [obj2 integerValue])
            {
                return NSOrderedAscending;//将第一个元素放在第二个元素之前
            }else
            {
                return NSOrderedDescending;//将第一个元素放在第二个元素之后
            }
        }];
        
        NSMutableArray *tempArray = [sectionArray mutableCopy];
        for (int i = 0; i < tempArray.count ; i ++) {
            if ([tempArray[i] intValue] == 0) {
                tempArray[i] = @"早间";
            }else if ([tempArray[i] intValue] == 5){
                tempArray[i] = @"午间";
            }else if([tempArray[i] intValue] > 5 && [tempArray[i] intValue] < 14){
                tempArray[i] = [NSString stringWithFormat:@"%d",[tempArray[i] intValue] - 1];
            }
            else if ([tempArray[i] intValue] == 14){
                tempArray[i] = @"晚间";
            }
        }
        NSMutableString *str = [NSMutableString stringWithFormat:@"%@",tempArray[0]];
        if (count != 1) {
            for (int i = 1; i < count; i++) {
                [str appendFormat:@"、%@",tempArray[i]];
            }
        }
        [self.businessTime_view.button2 setTitle:[NSString stringWithFormat:@"第%@节",str] forState:UIControlStateNormal];
        self.sectionArray = sectionArray;
        
        [self.sections removeAllObjects];
        int sectionCount = 1;
        if (count != 1){
            int i = 1;
            for (; i < count; i++) {
                NSString *num1 = (NSString*)sectionArray[i-1];
                NSString *num2 = (NSString*)sectionArray[i];
                if ([num1 intValue] != [num2 intValue] - 1) {
                    sectionCount ++;
                }
            }
        }
        if (sectionCount == 1) {
            [self.sections addObject:sectionArray];
        }else{
            int i = 0;
            for (int k = 0; k < sectionCount; k ++) {
                NSMutableArray *temp = [NSMutableArray array];
                for (; i < count-1; i++) {
                    NSString *num1 = (NSString*)sectionArray[i];
                    NSString *num2 = (NSString*)sectionArray[i+1];
                    if ([num1 intValue] == [num2 intValue] - 1) {
                        [temp addObject:num1];
                    }
                    else{
                        [temp addObject:num1];
                        [self.sections addObject:temp];
                        i++;
                        break;
                    }
                }
                if (k == sectionCount - 1) {
                    [temp addObject:sectionArray[count-1]];
                    [self.sections addObject:temp];
                }
            }
        }
    }
}

#pragma mark RemindSelectDelegate
- (void)RemindSelectComfirmAction:(RemindSelect *)sectionSelector indexArr:(NSMutableArray *)indexArray{
    [_coverLayer removeFromSuperview];
}

- (void)RemindSelectCancelAction:(RemindSelect *)sectionSelector{
    [_coverLayer removeFromSuperview];//移除遮罩
}

#pragma mark RepeatSettingDelegate
- (void)RepeatSettingComfirmAction:(RepeatSetting *)sectionSelector selectedIndex:(NSInteger)index{
    self.repeatIndex = index;
    [_clock_view.button2 setTitle:self.repeatItem[index] forState:UIControlStateNormal];
    [_coverLayer removeFromSuperview];
}

- (void)RepeatSettingCancelAction:(RepeatSetting *)sectionSelector{
    [_coverLayer removeFromSuperview];
}

#pragma maek CommentVCDelegate
- (void)commentVC:(CommentViewController *)vc infomation:(NSString *)info{
    self.commentInfo = info;
    NSString *tempStr;
    if (info.length > 20) {
        tempStr = [[info substringToIndex:20] stringByAppendingString:@"..."];
    }else{
        tempStr = info;
    }
    _commentfield.text = tempStr;
}
@end
