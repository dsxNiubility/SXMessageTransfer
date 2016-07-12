//
//  SXMessageInteraction.m
//  Pods
//
//  Created by dongshangxian on 16/3/29.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "SXMessageInteraction.h"

@implementation SXMessageInteraction

+ (instancetype)interaction
{
    return [[SXMessageInteraction alloc]init];
}

+ (instancetype)interactionWithObserver:(id)observer
{
    return [self interactionWithObserver:observer priority:@(500)];
}

+ (instancetype)interactionWithObserver:(id)observer priority:(NSNumber *)priority{
    SXMessageInteraction *instance = [[SXMessageInteraction alloc]init];
    if (observer) {
        [instance setObserverInstanceName:NSStringFromClass([observer class])];
    }
    [instance setPriority:priority];
    [instance setObserverID:[observer hash]];
    return instance;
}

- (void)setPriority:(NSNumber *)priority
{
    if ([priority integerValue] < 1) {
        _priority = @(1);
    }else if ([priority integerValue] > 1000){
        _priority = @(1000);
    }else{
        _priority = priority;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observerInstanceName = nil;
    }
    return self;
}


@end