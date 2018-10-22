//
//  BSTOperation.h
//  base
//
//  Created by chen liangxiu on 2018/2/4.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLXOperation;
typedef void(^BSTOperationTask) (CLXOperation *operation);

@interface CLXOperation : NSOperation

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTask:(BSTOperationTask)task NS_DESIGNATED_INITIALIZER;

- (void)finish;

@end
