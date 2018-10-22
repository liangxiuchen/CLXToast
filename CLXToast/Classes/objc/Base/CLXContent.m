//
//  BSTContent.m
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXContent.h"
@import UIKit.UIView;
@interface CLXContent()

@property(nonatomic, assign) ToastStyle style;

@end

@implementation CLXContent

- (instancetype)init {
    return [self initWith:ToastHud];
}

- (instancetype)initWith:(ToastStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
    }
    return self;
}
//abstract methods
- (void)addSubviews:(UIView *)contentView {}
//abstract methods
- (void)layoutSubviews:(UIView *)contentView {}

@end
