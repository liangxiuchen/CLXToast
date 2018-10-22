//
//  BSTToast+internal.h
//  BSTLayer
//
//  Created by chen liangxiu on 2018/2/9.
//  Copyright © 2018年 cn.liang.xiu.chen. All rights reserved.
//

#import "CLXToast.h"
#import "CLXOperation.h"

@interface CLXToast ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CLXContent *content;
@property (nonatomic, weak) CLXOperation *myTransaction;
@property (nonatomic, strong) CLXToast *retainCircle;
@property (nonatomic, strong) NSLayoutConstraint *toast_w;
@property (nonatomic, strong) NSLayoutConstraint *toast_h;
@property (nonatomic, strong) NSLayoutConstraint *contentView_w;
@property (nonatomic, strong) NSLayoutConstraint *contentView_h;

@end
