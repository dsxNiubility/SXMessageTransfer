//
//  SXMessageInteraction.h
//  Pods
//
//  Created by dongshangxian on 16/3/29.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SXMessageInteraction : NSObject

/**
 *  The instance name who observe this msg.
 */
@property (nonatomic, strong) NSString *observerInstanceName;

/**
 *  The instance name who observe this msg.
 */
@property(nonatomic,assign)NSUInteger observerID;

/**
 *  biger is more prior , set number between 1 and 1000 , default is 500
 */
@property(nonatomic,strong)NSNumber *priority;

/**
 *  Factory method for create the interaction.
 *
 *  @return Instance.
 */
+ (instancetype)interaction;

/**
 *  Factory method for create the interaction.
 *
 *
 *  @return Instance.
 */
+ (instancetype)interactionWithObserver:(id)observer;

/**
 *  add observer with priority
 */
+ (instancetype)interactionWithObserver:(id)observer priority:(NSNumber *)priority;



@end
