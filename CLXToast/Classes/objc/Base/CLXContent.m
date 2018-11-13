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
- (void)addSubviewsTo:(UIView *)contentView {
    @throw [NSException exceptionWithName:@"abstract methods" reason:@"abstract methods calleds" userInfo:nil];
}
//abstract methods
- (void)layoutSubviewsAt:(UIView *)contentView {
    @throw [NSException exceptionWithName:@"abstract methods" reason:@"abstract methods calleds" userInfo:nil];
}

@end
