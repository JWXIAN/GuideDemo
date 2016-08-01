//
//  JWFunctionGuide.h
//  GuideDemo
//
//  Created by GJW on 16/8/1.
//  Copyright © 2016年 JW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//单布局元素在界面上垂直居中时，是将介绍文案布局顶部，还是底部
typedef NS_ENUM(NSUInteger, GuideViewAlignmentPriority) {
    GuideViewAlignmentBottomFirst = 0, //底部优先
    GuideViewAlignmentTopFirst     //顶部优先
};


//@protocol JWFunctionGuideDelegate<NSObject>
//- (void)didBtnGuideClick:(id)sender;
//@end

@interface JWFunctionGuide : NSObject

//@property (weak, nonatomic) id<JWFunctionGuideDelegate> delegate;

//需要高亮的UI元素，与focusRect二者直选其一，如果设置了focusView，focusRect无效
@property (nonatomic, strong ,readonly) UIView *focusView;

//需要高亮的区域
@property (nonatomic, assign ,readonly) CGRect focusRect;

//如果高亮元素需要添加圆角效果，需要设置相应的圆角半径
@property (nonatomic, assign) CGFloat focusCornerRadius;

//高亮区域相对于focusView的frame的偏移
@property (nonatomic, assign) UIEdgeInsets focusInsets;

//按钮
@property (nonatomic, copy) void(^btnActionBlock)(id sender);
//按钮的标题
@property (nonatomic, copy) NSString *btnActionTitle;

//单布局元素在界面上垂直居中时，是将介绍文案布局顶部，还是底部
@property (nonatomic ,assign) GuideViewAlignmentPriority guideViewAlignmentPriority;

//一段对该区域的文字介绍，也可以是一张本地图的名称，必须是png或者jpg图片
@property (nonatomic, strong) NSString *introduce;
//描述的字体
@property (nonatomic, strong) UIFont *describeFont;
//描述文字的颜色
@property (nonatomic, strong) UIColor *describeTextColor;

//指示符号的图片名称
@property (nonatomic, copy) NSString *indicatorImageName;

//生成的按钮的背景图片名称
@property (nonatomic, copy) NSString *btnGuideBackgroundImageName;

- (instancetype)initWithFocusView:(UIView *)focusView focusCornerRadius:(CGFloat) focusCornerRadius  focusInsets:(UIEdgeInsets) focusInsets;

- (instancetype)initWithFocusRect:(CGRect)rect focusCornerRadius:(CGFloat) focusCornerRadius  focusInsets:(UIEdgeInsets) focusInsets;
@end
