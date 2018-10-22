//
//  BSTOperation.m
//  base
//
//  Created by chen liangxiu on 2018/2/4.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXOperation.h"
#import <pthread/pthread.h>

typedef NS_ENUM(NSUInteger, BSTOperationStatus)
{
    BSTOperationInitailed = 0,
    BSTOperationExecuting,
    BSTOperationFinished,
};

@interface CLXOperation()

@property (nonatomic, assign) BSTOperationStatus bst_status;
@property (nonatomic, strong) BSTOperationTask task;

@end

@implementation CLXOperation {
    pthread_rwlock_t _locker;
}
@synthesize bst_status = _bst_status;

- (void)dealloc {
    pthread_rwlock_destroy(&_locker);
}

- (instancetype)initWithTask:(BSTOperationTask)task
{

    self = [super init];
    if (self) {
        _task = [task copy];
        _bst_status = BSTOperationInitailed;
        {
            pthread_rwlockattr_t attr;
            pthread_rwlockattr_init(&attr);
            pthread_rwlockattr_setpshared(&attr, PTHREAD_MUTEX_RECURSIVE);
            pthread_rwlock_init(&_locker, &attr);
            pthread_rwlockattr_destroy(&attr);
        }
        
    }
    return self;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSArray<NSString *>*keys = @[ @"isReady", @"isExecuting", @"isFinished"];
    if ([keys containsObject:key]) {
        return [[NSSet alloc] initWithObjects:@"bst_status", nil];
    } else {
        return [NSSet new];
    }
}

- (BOOL)isReady {
    switch (self.bst_status) {
        case BSTOperationInitailed:
            return [self isCancelled] || [super isReady];
            break;
        default:
            return NO;
            break;
    }
}

- (BOOL)isFinished
{
    return self.bst_status == BSTOperationFinished;
}

- (BOOL)isExecuting {
    return self.bst_status == BSTOperationExecuting;
}

- (void)start {
    [super start];
    if ([super isCancelled]) {
        [self finish];
    }
}

- (void)main {
    if ([super isCancelled]) {
        [self finish];
    } else {
        if (self.task != nil && [self canTransitionTo:BSTOperationExecuting]) {
            self.bst_status = BSTOperationExecuting;
            self.task(self);
        } else {
            [self finish];
        }
    }
}

- (void)finish
{
    dispatch_block_t removeAllDependencies = ^{
        for (NSOperation *op in self.dependencies) {
            [self removeDependency:op];
        }
    };
    if ([self canTransitionTo:BSTOperationFinished]) {
        self.bst_status = BSTOperationFinished;
        removeAllDependencies();
    }
}

#pragma mark - accessor methods
- (BSTOperationStatus)bst_status
{
    BSTOperationStatus status = BSTOperationInitailed;
    pthread_rwlock_rdlock(&_locker);
    status = _bst_status;
    pthread_rwlock_unlock(&_locker);
    return status;
}

- (void)setBst_status:(BSTOperationStatus)bst_status
{
    if ([self canTransitionTo:bst_status]) {
        [self willChangeValueForKey:@"bst_status"];
        pthread_rwlock_wrlock(&_locker);
        _bst_status = bst_status;
        pthread_rwlock_unlock(&_locker);
        [self didChangeValueForKey:@"bst_status"];
    }
}

#pragma mark - private methods
- (BOOL)canTransitionTo:(BSTOperationStatus)target {
    switch (target) {
        case BSTOperationInitailed: {
            if (self.bst_status == BSTOperationInitailed) {
                return YES;
            }
            return NO;
        } break;
        case BSTOperationExecuting: {
            if ([super isReady]) {
                return YES;
            }
            return NO;
        } break;
        case BSTOperationFinished:
            return YES;
            break;
    }
}

@end
