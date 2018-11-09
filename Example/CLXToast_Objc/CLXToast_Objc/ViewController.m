//
//  ViewController.m
//  CLXCLXToast_Objc
//
//  Created by carroll chen on 2018/11/9.
//  Copyright © 2018年 carroll chen. All rights reserved.
//

#import "ViewController.h"
#import <CLXToast/CLXToast.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CLXToast.hudBuilder.title(@"it is a title").show();
    CLXToast.hudBuilder.subtitle(@"it is a subtitle").show();
    CLXToast.hudBuilder.title(@"it is a title").subtitle(@"it is a subtitle").show();
    CLXToast.hudBuilder.title(@"it is a long long long long long long long title").subtitle(@"it is a long long long long long long long long long long long long subtitle").show();

    //adjust titles space demo
    CLXToast.hudBuilder.title(@"adjust space").subtitle(@"adjust space between title and subtitle").interTitlesSpacing(10).show();


    //completion callback demo
    CLXToast.hudBuilder.title(@"it is a completion callback test").showWith(0.f, YES, ^{
        NSLog(@"--------------------hud is finished--------------------");
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
