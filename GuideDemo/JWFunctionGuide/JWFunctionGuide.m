//
//  JWFunctionGuide.m
//  GuideDemo
//
//  Created by GJW on 16/8/1.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "JWFunctionGuide.h"

@implementation JWFunctionGuide

- (instancetype)initWithFocusRect:(CGRect)rect focusCornerRadius:(CGFloat) focusCornerRadius  focusInsets:(UIEdgeInsets) focusInsets
{
    self = [super init];
    if (self) {
        _focusRect = rect;
        self.focusCornerRadius = focusCornerRadius;
        self.focusInsets = focusInsets;
    }
    return self;
}
- (instancetype)initWithFocusView:(UIView *)focusView focusCornerRadius:(CGFloat) focusCornerRadius  focusInsets:(UIEdgeInsets) focusInsets
{
    self = [super init];
    if (self) {
        _focusView = focusView;
        self.focusCornerRadius = focusCornerRadius;
        self.focusInsets = focusInsets;
    }
    
    return self;
}
@end
