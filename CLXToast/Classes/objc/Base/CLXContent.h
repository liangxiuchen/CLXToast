//
//  BSTContent.h
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
typedef NS_ENUM(NSUInteger, ToastStyle)
{
    ToastHud = 0,//弱提示，可是设置持续时间，时间到后，自动消失
    ToastWaiting,//类模态化即屏蔽了用户交互,使用场景，等待网络请求。 需要自己dismiss
    ToastCustomHud,//hud模式下, 自定义子view和布局
    ToastCustomWaiting,//waiting 模式下, 自定义子view和布局
};

@interface CLXContent : NSObject

@property(nonatomic, assign, readonly) ToastStyle style;

- (instancetype)init;
- (instancetype)initWith:(ToastStyle)style NS_DESIGNATED_INITIALIZER;

#pragma subclass hook methods
- (void)addSubviewsTo:(UIView *)contentView;
- (void)layoutSubviewsAt:(UIView *)contentView;

@end
