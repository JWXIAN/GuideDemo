//
//  ViewController.m
//  GuideDemo
//
//  Created by GJW on 16/8/1.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "ViewController.h"
#import "JWFunctionGuide.h"
#import "UIView+FunctionGuideView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    JWFunctionGuide *guide = [[JWFunctionGuide alloc] initWithFocusRect:CGRectMake(50, 50, 40, 40) focusCornerRadius:0 focusInsets:UIEdgeInsetsZero];
    //    EAFeatureItem *item8 = [[EAFeatureItem alloc] initWithFocusView:self.leftView focusCornerRadius:0 focusInsets:UIEdgeInsetsZero];
    guide.introduce = @"该项目参考Github上学习开发";
    guide.btnActionBlock = ^(id sender){
        
    };
    [self.view showWithFunctionGuides:@[guide] saveKeyName:@"" theVersion:nil];
}
@end
