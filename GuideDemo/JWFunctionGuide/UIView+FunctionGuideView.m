//
//  UIView+FunctionGuideView.m
//  GuideDemo
//
//  Created by GJW on 16/8/1.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "UIView+FunctionGuideView.h"
#import <objc/runtime.h>

static char versionKeyName;
static char theContainerView;
static char btnActionsDic;
//位置
typedef NS_ENUM(NSUInteger, GuideViewLocation) {
    GuideViewLocationDefault = 0,
    GuideViewLocationUp = 1 << 1,
    GuideViewLocationLeft = 1 << 2,
    GuideViewLocationDown = 1 << 3,
    GuideViewLocationRight = 1 << 4
};

@implementation UIView (FunctionGuideView)

#pragma mark - 展示引导
- (void)showWithFunctionGuides:(NSArray<JWFunctionGuide *> *)functionGuides saveKeyName:(NSString *)keyName theVersion:(NSString *)version{
    //如果该版本已经出现过引导 return
    if ([UIView boolShowGuidesWithVersion:keyName theVersion:version]) return;
    //关闭引导
    [self dismissFunctionGuideView];
    //视图布局
    [self layoutSubviewsWithGuides:functionGuides];
}

#pragma mark - 版本判断
+ (BOOL)boolShowGuidesWithVersion:(NSString *)keyName theVersion:(NSString *)version{
    if(!keyName) return NO;
    
    if(![version isEqualToString:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]] && version) return YES;
    
    id result = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",keyName,version]];
    
    if(result) return [result boolValue];
    
    return NO;
}

#pragma mark - 视图布局
- (void)layoutSubviewsWithGuides:(NSArray<JWFunctionGuide *> *)functionGuides{
    if(functionGuides.count==0) return;
    //创建父视图
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedEvent:)];
    [containerView addGestureRecognizer:tap];
    [self setContainerView:containerView];
    [self addSubview:containerView];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,self.bounds.size.width, self.bounds.size.height)cornerRadius:0];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;
    shapeLayer.opacity =0.8;
    [containerView.layer addSublayer:shapeLayer];
    
    NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
    [self setButtonActionsDictionary:actionDict];
    
    [functionGuides enumerateObjectsUsingBlock:^(JWFunctionGuide * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.btnActionBlock) actionDict[@(idx)] = [obj.btnActionBlock copy];
        [self layountWithGuides:obj];
    }];
}

- (void)layountWithGuides:(JWFunctionGuide *)guideView{
    UIView *containerView = [self getContainerView]; //创建父容器
    UIView *introduceView = nil;            //子视图
    UIImageView *indicatorImageView = nil;
    UIButton *btnDuide = nil;
    //绘制镂空的区域
    CGRect guidesViewFrame = guideView.focusView ? [guideView.focusView convertRect:guideView.focusView.bounds toView:[self getContainerView]] : guideView.focusRect;
    
    //绘制镂空区域
    CAShapeLayer *shapeLayer = (CAShapeLayer *)[containerView.layer.sublayers firstObject];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:shapeLayer.path];
    
    guidesViewFrame.origin.x += guideView.focusInsets.left;
    guidesViewFrame.origin.y += guideView.focusInsets.top;
    guidesViewFrame.size.width += guideView.focusInsets.right - guideView.focusInsets.left;
    guidesViewFrame.size.height += guideView.focusInsets.bottom - guideView.focusInsets.top;
    
    [bezierPath appendPath:[UIBezierPath bezierPathWithRoundedRect:guidesViewFrame cornerRadius:guideView.focusCornerRadius]];
    shapeLayer.path = bezierPath.CGPath;
    
    //添加箭头
    if(guideView.btnActionBlock || guideView.introduce)
    {
        NSString *imageName = guideView.indicatorImageName ?: @"defaultIndicate";
        
        UIImage *indicatorImage = [UIImage imageNamed:imageName];
        
        
        CGSize imageSize = CGSizeMake(indicatorImage.size.width, indicatorImage.size.height);
        
        indicatorImageView = [[UIImageView alloc] initWithImage:indicatorImage];
        indicatorImageView.clipsToBounds = YES;
        indicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
        indicatorImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        [containerView addSubview :indicatorImageView];
        
        
        //布局介绍文案
        if(guideView.introduce)
        {
            NSString *typeString = [[[guideView.introduce componentsSeparatedByString:@"."] lastObject] lowercaseString];
            
            if([typeString isEqualToString:@"png"] || [typeString isEqualToString:@"jpg"] || [typeString isEqualToString:@"jpeg"])
            {
                UIImage *introduceImage = [UIImage imageNamed:guideView.introduce];
                
                imageSize = CGSizeMake(introduceImage.size.width, introduceImage.size.height);
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:introduceImage];
                
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
                
                introduceView = imageView;
            }
            else
            {
                UILabel *introduceLabel = [[UILabel alloc] init];
                introduceLabel.backgroundColor = [UIColor clearColor];
                introduceLabel.numberOfLines = 0;
                introduceLabel.text = guideView.introduce;
                
                introduceLabel.font = guideView.describeFont ?: [UIFont systemFontOfSize:13];
                
                introduceLabel.textColor = guideView.describeTextColor ?: [UIColor whiteColor];
                
                introduceView = introduceLabel;
            }
            
            [containerView addSubview :introduceView];
        }
        
        //布局按钮
        if(guideView.btnActionBlock || guideView.btnActionTitle)
        {
            btnDuide = [[UIButton alloc] init];
            [btnDuide setBackgroundImage:[[UIImage imageNamed:guideView.btnGuideBackgroundImageName ?:  @"icon_ea_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
            btnDuide.titleLabel.font = [UIFont systemFontOfSize:15];
            
            if(guideView.btnActionTitle.length <= 0)
            {
                guideView.btnActionTitle = @"知道了";
            }
            
            [btnDuide setTitle:guideView.btnActionTitle forState:UIControlStateNormal];
            [btnDuide sizeToFit];
            [btnDuide addTarget:self action:@selector(btnDuideAction:) forControlEvents:UIControlEventTouchUpInside];
            
            CGRect frame = btnDuide.frame;
            frame.size.width += 20;
            frame.size.height += 10;
            btnDuide.frame = frame;
            [containerView addSubview:btnDuide];
        }
    }
    
    GuideViewLocation location = [self getLocationForFeatureItem:guideView];
    
    CGRect introduceFrame = introduceView.frame;
    const CGFloat verticalSpacing = 10;
    
    //箭头方向向上
    if(location & GuideViewLocationUp || location == GuideViewLocationDefault)
    {
        //将箭头的锚点移动到顶部中间
        indicatorImageView.layer.anchorPoint = CGPointMake(.5f, 0);
        
        indicatorImageView.center = CGPointMake(CGRectGetMinX(guidesViewFrame) + CGRectGetWidth(guidesViewFrame) / 2, CGRectGetMinY(guidesViewFrame) + CGRectGetHeight(guidesViewFrame) + verticalSpacing);
        
        //箭头方向左上
        if(location & GuideViewLocationLeft)
        {
            CGAffineTransform transform = indicatorImageView.transform;
            indicatorImageView.transform = CGAffineTransformRotate(transform, - M_PI / 4);
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceFrame.origin.x = indicatorImageView.frame.origin.x;
                introduceFrame.origin.y = CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing;
                introduceView.frame = introduceFrame;
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake(containerView.bounds.size.width - indicatorImageView.frame.origin.x * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                
                introduceView.frame = CGRectMake(indicatorImageView.frame.origin.x, CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing, rect.size.width, rect.size.height);
            }
            
            //如果文案的宽度小于箭头指示器的宽度,则将文案的中心设置成指示器的右端
            if(introduceView.frame.size.width < indicatorImageView.frame.size.width)
            {
                CGPoint center = introduceView.center;
                center.x = indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width;
                introduceView.center = center;
            }
            
        }
        //箭头方向右上
        else if(location & GuideViewLocationRight)
        {
            CGAffineTransform transform = indicatorImageView.transform;
            indicatorImageView.transform = CGAffineTransformRotate(transform,M_PI / 4);
            
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceFrame.origin.x = indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width - introduceFrame.size.width;
                
                introduceFrame.origin.y = CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing;
                
                introduceView.frame = introduceFrame;
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake( containerView.bounds.size.width - (containerView.bounds.size.width - indicatorImageView.frame.origin.x - indicatorImageView.frame.size.width) * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                
                introduceView.frame = CGRectMake(indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width - rect.size.width, CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing, rect.size.width, rect.size.height);
            }
            
            //如果文案的宽度小于箭头指示器的宽度,则将文案的中心设置成指示器的右端
            if(introduceView.frame.size.width < indicatorImageView.frame.size.width)
            {
                CGPoint center = introduceView.center;
                center.x = indicatorImageView.frame.origin.x;
                introduceView.center = center;
            }
        }
        else //垂直向上
        {
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceView.center = CGPointMake(indicatorImageView.center.x, CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing + introduceFrame.size.height / 2);
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)introduceView;
                label.textAlignment = NSTextAlignmentCenter;
                
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake(containerView.bounds.size.width * 3 / 4, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                introduceView.frame = CGRectMake((containerView.bounds.size.width - rect.size.width) / 2, CGRectGetMaxY(indicatorImageView.frame) + verticalSpacing, rect.size.width, rect.size.height);
            }
        }
    }
    //箭头方向下,布局方式是先布局介绍文案->布局按钮
    else if(location & GuideViewLocationDown)
    {
        //是否需要布局按钮
        CGFloat buttonVerticalOccupySpace = btnDuide ? CGRectGetHeight(btnDuide.frame) + verticalSpacing : 0;
        
        //箭头方向左下
        if(location & GuideViewLocationLeft)
        {
            //将箭头的锚点移动到低部中间
            indicatorImageView.layer.anchorPoint = CGPointMake(.5f, 1.f);
            //计算箭头的位置
            indicatorImageView.center = CGPointMake(CGRectGetMinX(guidesViewFrame) + CGRectGetWidth(guidesViewFrame) / 2, CGRectGetMinY(guidesViewFrame) - CGRectGetHeight(indicatorImageView.frame));
            
            CGAffineTransform transform = indicatorImageView.transform;
            transform = CGAffineTransformTranslate(transform, CGRectGetHeight(indicatorImageView.frame) * sinf(M_PI / 4), 0);
            
            indicatorImageView.transform = CGAffineTransformRotate(transform,  - M_PI * 3 / 4);
            
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceFrame.origin.x = indicatorImageView.frame.origin.x;
                introduceFrame.origin.y = CGRectGetMinY(indicatorImageView.frame) - verticalSpacing - buttonVerticalOccupySpace - CGRectGetHeight(introduceView.frame);
                introduceView.frame = introduceFrame;
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake(containerView.bounds.size.width - indicatorImageView.frame.origin.x * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                
                introduceView.frame = CGRectMake(indicatorImageView.frame.origin.x, CGRectGetMinY(indicatorImageView.frame) - verticalSpacing - buttonVerticalOccupySpace - rect.size.height, rect.size.width, rect.size.height);
            }
            
            //如果文案的宽度小于箭头指示器的宽度,则将文案的中心设置成指示器的右端
            if(introduceView.frame.size.width < indicatorImageView.frame.size.width)
            {
                CGPoint center = introduceView.center;
                center.x = indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width;
                introduceView.center = center;
            }
        }
        //箭头方向右下
        else if(location & GuideViewLocationRight)
        {
            //将箭头的锚点移动到低部中间
            indicatorImageView.layer.anchorPoint = CGPointMake(.5f, 1.f);
            //计算箭头的位置
            indicatorImageView.center = CGPointMake(CGRectGetMinX(guidesViewFrame) + CGRectGetWidth(guidesViewFrame) / 2, CGRectGetMinY(guidesViewFrame) - CGRectGetHeight(indicatorImageView.frame));
            
            CGAffineTransform transform = indicatorImageView.transform;
            transform = CGAffineTransformTranslate(transform, - CGRectGetHeight(indicatorImageView.frame) * sinf(M_PI / 4), 0);
            indicatorImageView.transform = CGAffineTransformRotate(transform, M_PI * 3 / 4);
            
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceFrame.origin.x = indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width - introduceFrame.size.width;
                
                introduceFrame.origin.y = CGRectGetMinY(indicatorImageView.frame) - verticalSpacing - buttonVerticalOccupySpace - CGRectGetHeight(introduceView.frame);
                
                introduceView.frame = introduceFrame;
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake(containerView.bounds.size.width - (containerView.bounds.size.width - indicatorImageView.frame.origin.x - indicatorImageView.frame.size.width) * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                
                introduceView.frame = CGRectMake(indicatorImageView.frame.origin.x + indicatorImageView.frame.size.width - rect.size.width, CGRectGetMinY(indicatorImageView.frame) - verticalSpacing - buttonVerticalOccupySpace - rect.size.height, rect.size.width, rect.size.height);
            }
            
            //如果文案的宽度小于箭头指示器的宽度,则将文案的中心设置成指示器的左端
            if(introduceView.frame.size.width < indicatorImageView.frame.size.width)
            {
                CGPoint center = introduceView.center;
                center.x = indicatorImageView.frame.origin.x;
                introduceView.center = center;
            }
            
        }
        else //垂直向下
        {
            //将箭头的锚点移动到顶部中间
            //            indicatorImageView.layer.anchorPoint = CGPointMake(.5f, 0.f);
            
            indicatorImageView.center = CGPointMake(CGRectGetMinX(guidesViewFrame) + CGRectGetWidth(guidesViewFrame) / 2, CGRectGetMinY(guidesViewFrame) - verticalSpacing - CGRectGetHeight(indicatorImageView.bounds) / 2);
            
            CGAffineTransform transform = indicatorImageView.transform;
            indicatorImageView.transform = CGAffineTransformRotate(transform, M_PI);
            
            //计算介绍的位置
            if([introduceView isKindOfClass:[UIImageView class]])
            {
                introduceView.center = CGPointMake(indicatorImageView.center.x, CGRectGetMinY(indicatorImageView.frame) - buttonVerticalOccupySpace - verticalSpacing - introduceFrame.size.height / 2);
            }
            else if([introduceView isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)introduceView;
                label.textAlignment = NSTextAlignmentCenter;
                
                CGRect rect = [guideView.introduce boundingRectWithSize:CGSizeMake(containerView.bounds.size.width * 3 / 4, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ((UILabel *)introduceView).font} context:nil];
                introduceView.frame = CGRectMake((containerView.bounds.size.width - rect.size.width) / 2, CGRectGetMinY(indicatorImageView.frame)  - buttonVerticalOccupySpace - verticalSpacing - rect.size.height, rect.size.width, rect.size.height);
            }
        }
    }
    btnDuide.center = CGPointMake(introduceView.center.x, CGRectGetMaxY(introduceView.frame) + verticalSpacing + btnDuide.frame.size.height / 2);
}
- (void)btnDuideAction:(UIButton *)sender{
    NSMutableDictionary *actionDict = [self getButtonActionsDictionary];
    void (^action)(id sendr)  = actionDict[@(sender.tag)];
    if(action) action(sender);
    [self dismissFunctionGuideView];
}

#pragma mark - 计算GuideView位置
- (GuideViewLocation)getLocationForFeatureItem:(JWFunctionGuide *)guideView{
    
    GuideViewLocation location = GuideViewLocationDefault;
    
    CGRect frame = guideView.focusRect;
    
    const NSInteger split = 16;
    
    //将展示区域分割成16*16的区域
    CGFloat squareWidth = self.bounds.size.width / split;
    CGFloat squareHeight = self.bounds.size.height / split;
    
    CGFloat leftSpace = frame.origin.x;
    CGFloat rightSpace = self.bounds.size.width - (frame.origin.x + frame.size.width);
    CGFloat topSpace = frame.origin.y;
    CGFloat bottomSpace = self.bounds.size.height - (frame.origin.y + frame.size.height);
    
    //如果focusView的x轴上的宽占据了绝大部分则认为是横向居中的
    if(frame.size.width <= squareWidth * (split - 1)){
        //左边
        if((leftSpace - rightSpace) >= squareWidth) location |= GuideViewLocationRight;
        //右边
        else if((rightSpace - leftSpace) >= squareWidth) location |= GuideViewLocationLeft;
    }
    //如果focusView的y轴上的宽占据了绝大部分则认为是横向居中的
    if(frame.size.height <= squareWidth * (split - 1))
    {
        //上边
        if((topSpace - bottomSpace) >= squareHeight) location |= GuideViewLocationDown;
        //下边
        else if((bottomSpace - topSpace) >= squareHeight) location |= GuideViewLocationUp;
        //如果上下距离接近相等
        else if(fabs(bottomSpace - topSpace) <= 1){
            if(guideView.guideViewAlignmentPriority == GuideViewAlignmentBottomFirst) location |= GuideViewLocationUp;
            else location |= GuideViewLocationDown;
        }
    }
    return location;
}

#pragma mark - 关闭引导
- (void)dismissFunctionGuideView{
    if(![self getContainerView]) return;   //视图是否存在
    [UIView boolShowWithVersionKey:[self getVersionKeyName] boolShow:YES];  //存版本
    [[self getContainerView] removeFromSuperview];
    [self setContainerView:nil];    //父容器置空
}
- (void)touchedEvent:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded) [self dismissFunctionGuideView];
}

#pragma mark - 存版本
+ (void)boolShowWithVersionKey:(NSString *)keyName boolShow:(BOOL)boolShow{
    if(!keyName) return;    //不存在则存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:boolShow forKey:keyName];
    [ud synchronize];
}
#pragma mark - 版本Key
- (void)setKeyName:(NSString *)keyName{
    objc_setAssociatedObject(self, &versionKeyName, keyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)getVersionKeyName{
    return objc_getAssociatedObject(self, &versionKeyName);
}
#pragma mark - 父容器
- (void)setContainerView:(UIView *)containerView{
    objc_setAssociatedObject(self, &theContainerView, containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)getContainerView{
    return objc_getAssociatedObject(self, &theContainerView);
}
#pragma mark - 按钮响应事件
- (void)setButtonActionsDictionary:(NSMutableDictionary *)actionsDictionary{
    objc_setAssociatedObject(self, &btnActionsDic, actionsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)getButtonActionsDictionary{
    return objc_getAssociatedObject(self, &btnActionsDic);
}

@end
