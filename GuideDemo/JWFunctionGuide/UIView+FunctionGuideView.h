//
//  UIView+FunctionGuideView.h
//  GuideDemo
//
//  Created by GJW on 16/8/1.
//  Copyright © 2016年 JW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWFunctionGuide.h"

@interface UIView (FunctionGuideView)
/**
 *  展示引导页面
 *
 *  @param functionGuides 展示的引导功能
 *  @param keyName        版本Key
 *  @param version        版本
 */
- (void)showWithFunctionGuides:(NSArray<JWFunctionGuide *> *)functionGuides saveKeyName:(NSString *)keyName theVersion:(NSString *)version;

/**
 *  是否已经引导
 *
 *  @param keyName 版本Key
 *  @param version 版本号
 *
 *  @return BOOL
 */
+ (BOOL)boolShowGuidesWithVersion:(NSString *)keyName theVersion:(NSString *)version;

/**
 *  关闭引导
 */
- (void)dismissFunctionGuideView;
@end
