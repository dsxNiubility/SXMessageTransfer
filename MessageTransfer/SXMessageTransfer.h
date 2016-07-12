//
//  SXMessageTransfer.h
//  Pods
//
//  Created by dongshangxian on 16/3/25.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SXMessageInteraction.h"

#define MsgTransfer [SXMessageTransfer transfer]
typedef void(^MsgPosterVoidAction)(id msgObject);
typedef id (^MsgPosterReturnAction)(id msgObject);

typedef NS_ENUM(NSUInteger, SXMessageExcuteType) {
    SXMessageExcuteTypeSync = 1,
    SXMessageExcuteTypeAsync = 2,
};

@interface SXMessageTransfer : NSObject


+ (instancetype)transfer;


#pragma mark -
#pragma mark 第二版的接口

/**
 *  simple way to add a block ,when msg received
 *
 *  @param msg   origin msg
 *  @param observer input self needn't to think about
 *  @param block doing onReceived
 */
- (void)listenMsg:(NSString *)msg observer:(id)observer onReceive:(MsgPosterVoidAction)block;

/**
 *  do some processing when msg received,return the results
 *
 *  @param msg   origin msg
 *  @param observer input self needn't to think about
 *  @param block doing onReceived,and return the processing results
 */
- (void)listenMsg:(NSString *)msg observer:(id)observer onReceiveAndProcessing:(MsgPosterReturnAction)block;

/**
 *  add a block also add observer with priority,when msg received,
 *
 *  @param msg         origin msg
 *  @param interaction include observer and priority
 *  @param block       doing onReceived
 */
- (void)listenMsg:(NSString *)msg withInteraction:(SXMessageInteraction *)interaction onReceive:(MsgPosterVoidAction)block;

/**
 *  add a block also add observer with priority,when msg received, and do some processing when msg received,return the results
 *
 *  @param msg         origin msg
 *  @param interaction include observer and priority
 *  @param block       doing onReceived,and return the processing results
 */
- (void)listenMsg:(NSString *)msg withInteraction:(SXMessageInteraction *)interaction onReceiveAndProcessing:(MsgPosterReturnAction)block;

/**
 *  simple way to send a msg ,and do the block when msg on reached
 *
 *  @param msg   origin msg
 *  @param block doing on reached
 */
- (void)sendMsg:(NSString *)msg onReached:(MsgPosterVoidAction)block;

/**
 *  send a msg with a object ,and do the block when msg on reached
 *
 *  @param msg    origin msg
 *  @param object msg carry object
 *  @param block  doing on reached
 */
- (void)sendMsg:(NSString *)msg withObject:(id)object onReached:(MsgPosterVoidAction)block;

/**
 *  send a msg with a object and set this msg's excute type ,and do the block when msg on reached,
 *
 *  @param msg    origin msg
 *  @param object msg carry object
 *  @param type   (async or sync default is sync)
 *  @param block  doing on reached
 */
- (void)sendMsg:(NSString *)msg withObject:(id)object type:(SXMessageExcuteType)type onReached:(MsgPosterVoidAction)block;

@end

@interface SXMessageObserver : NSObject

@property(nonatomic,copy)NSString *msgName;
@property(nonatomic,strong)NSNumber *priority;
@property(nonatomic,assign)NSUInteger objectID;

@end
