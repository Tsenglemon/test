//
//  BusinessViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/25.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessModel.h"
@class BusinessViewController;
@protocol BusinessViewControllerDelegate <NSObject>
//传回添加的那一周，刷新主界面
- (void)BusinessViewController:(BusinessViewController*)viewController week:(NSInteger )selectedWeek;
//刷新主界面
- (void)deleteBusiness:(BusinessViewController *)viewController;
@end

@interface BusinessViewController : UIViewController
@property (nonatomic , weak) id <BusinessViewControllerDelegate> delegate;

- (instancetype)initWithfirstDateOfTerm:(NSDate *)firstDateOfTerm businessModel:(BusinessModel *)busModel;
- (void)dataStore;
@end
