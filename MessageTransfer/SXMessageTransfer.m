//
//  MTMMessageTransmitter.m
//  Pods
//
//  Created by dongshangxian on 16/3/25.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "SXMessageTransfer.h"

@interface SXMessageTransfer ()

/**
 *  save received block which has return arguments
 */
@property(nonatomic,strong)NSMutableDictionary *blockReceivedReturnStack;
/**
 *  save received block which not has return arguments
 */
@property(nonatomic,strong)NSMutableDictionary *blockReceivedVoidStack;
/**
 *  save the observer , key is origin msgname ,value is array inclued observer
 */
@property(nonatomic,strong)NSMutableDictionary *msgObserversStack;
/**
 *  save reached block
 */
@property(nonatomic,strong)NSMutableDictionary *blockReachedStack;
/**
 *  save the msg's excute type. key is origin msgName ,value is async or sync
 */
@property(nonatomic,strong)NSMutableDictionary *msgExcuteType;
/**
 *  queue to excute async operation
 */
@property(nonatomic,strong)NSOperationQueue *msgQueue;
/**
 *  save every msg, not add same observer again
 */
@property(nonatomic,strong)NSMutableArray *msgStack;
/**
 *  a index for observeHashID
 */
@property(nonatomic,strong)NSMutableArray *obsIndex;


@end

@implementation SXMessageTransfer

#pragma mark -
#pragma mark lifecycle
+ (instancetype)transfer
{
    static dispatch_once_t onceToken;
    static SXMessageTransfer *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[SXMessageTransfer alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeObserverInObserverStack:) name:@"MTBMsgRemoveObserver" object:nil];
        self.msgQueue = [[NSOperationQueue alloc]init];
        [self.msgQueue setMaxConcurrentOperationCount:8];
    }
    return self;
}

#pragma mark -
#pragma mark lazy
- (NSMutableDictionary *)blockReceivedVoidStack
{
    if (!_blockReceivedVoidStack) {
        _blockReceivedVoidStack = [NSMutableDictionary dictionary];
    }
    return _blockReceivedVoidStack;
}

- (NSMutableDictionary *)blockReceivedReturnStack
{
    if (!_blockReceivedReturnStack) {
        _blockReceivedReturnStack = [NSMutableDictionary dictionary];
    }
    return _blockReceivedReturnStack;
}

- (NSMutableDictionary *)blockReachedStack
{
    if (!_blockReachedStack) {
        _blockReachedStack = [NSMutableDictionary dictionary];
    }
    return _blockReachedStack;
}

- (NSMutableDictionary *)msgObserversStack
{
    if (!_msgObserversStack) {
        _msgObserversStack = [NSMutableDictionary dictionary];
    }
    return _msgObserversStack;
}

-(NSMutableArray *)msgStack
{
    if (!_msgStack) {
        _msgStack = [NSMutableArray array];
    }
    return _msgStack;
}

- (NSMutableArray *)obsIndex
{
    if (!_obsIndex) {
        _obsIndex = [NSMutableArray array];
    }
    return _obsIndex;
}

- (NSMutableDictionary *)msgExcuteType
{
    if (!_msgExcuteType) {
        _msgExcuteType = [NSMutableDictionary dictionary];
    }
    return _msgExcuteType;
}

- (void)send:(NSDictionary *)dict to:(NSString *)className
{
    NSString *messageName = [NSString stringWithFormat:@"%@ReceiveMsg",className];
    [[NSNotificationCenter defaultCenter]postNotificationName:messageName object:dict];
}


#pragma mark -
#pragma mark listen

- (void)listenMsg:(NSString *)msg observer:(id)observer onReceive:(MsgPosterVoidAction)block{
    
    SXMessageInteraction *interaction = [[SXMessageInteraction alloc]init];
    [interaction setObserverID:[observer hash]];
    [interaction setPriority:@(500)];
    [self listenMsg:msg withInteraction:interaction onReceive:block];
}

- (void)listenMsg:(NSString *)msg withInteraction:(SXMessageInteraction *)interaction onReceive:(MsgPosterVoidAction)block{
    NSString *key = [msg stringByAppendingString:[NSString stringWithFormat:@"%ld",interaction.observerID]];
    NSMutableArray *array = [([self.blockReceivedVoidStack objectForKey:key]?:[NSArray array])mutableCopy];
    if (block) {
        [array addObject:block];
    }
    [self.blockReceivedVoidStack setObject:array forKey:key];
    [self doSameThingWithMsg:msg interaction:interaction];
}

- (void)listenMsg:(NSString *)msg observer:(id)observer onReceiveAndProcessing:(MsgPosterReturnAction)block{

    SXMessageInteraction *interaction = [[SXMessageInteraction alloc]init];
    [interaction setObserverID:[observer hash]];
    [interaction setPriority:@(500)];
    [self listenMsg:msg withInteraction:interaction onReceiveAndProcessing:block];
}

- (void)listenMsg:(NSString *)msg withInteraction:(SXMessageInteraction *)interaction onReceiveAndProcessing:(MsgPosterReturnAction)block{
    NSString *key = [msg stringByAppendingString:[NSString stringWithFormat:@"%ld",interaction.observerID]];
    NSMutableArray *array = [([self.blockReceivedReturnStack objectForKey:key]?:[NSArray array])mutableCopy];
    if (block) {
        [array addObject:block];
    }
    [self.blockReceivedReturnStack setObject:array forKey:key];
    [self doSameThingWithMsg:msg interaction:interaction];
}


- (void)doSameThingWithMsg:(NSString *)msg interaction:(SXMessageInteraction *)interaction{
    NSMutableArray *observerArray = [([self.msgObserversStack objectForKey:msg]?:[NSArray array])mutableCopy];
    BOOL isRepeat = NO;
    for (MTBMessageObserver *obs in observerArray) {
        if ([@(obs.objectID) isEqual:@(interaction.observerID)]) {
            isRepeat = YES;
        }
    }
    NSString *msgName = [msg stringByAppendingString:[NSString stringWithFormat:@"%ld",interaction.observerID]];
    if (!isRepeat) {
        MTBMessageObserver *observer = [MTBMessageObserver new];
        [observer setMsgName:msgName];
        [observer setPriority:interaction.priority];
        [observer setObjectID:interaction.observerID];
        [self.obsIndex addObject:@(interaction.observerID)];
        [observerArray addObject:observer];
        [self.msgObserversStack setObject:observerArray forKey:msg];
    }
    
    if (![self.msgStack containsObject:msg]) {
        [self.msgStack addObject:msg];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(workingOnReceived:) name:msg object:nil];
    }
}

#pragma mark -
#pragma mark listen recieved

- (void)workingOnReceived:(NSNotification *)object{
    NSString *name = object.name;
    
    MTBMessageExcuteType excuteType = [[self.msgExcuteType objectForKey:name]integerValue];
    
    NSArray *observerArray = [self.msgObserversStack valueForKey:name];
    if (excuteType == MTBMessageExcuteTypeSync) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_priority" ascending:NO];
        observerArray = [observerArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    for (MTBMessageObserver *obs in observerArray) {
        NSArray *voidBlocks = [self.blockReceivedVoidStack valueForKey:obs.msgName];
        NSArray *returnBlocks = [self.blockReceivedReturnStack valueForKey:obs.msgName];
        
        if(voidBlocks && (voidBlocks.count > 0)){
            for (id voidBlock in voidBlocks) {
                if (excuteType == MTBMessageExcuteTypeSync){
                    [self excuteWithVoidBlockDict:@{@"obs":obs,@"object":object,@"block":voidBlock}];
                }else if (excuteType == MTBMessageExcuteTypeAsync){
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(excuteWithVoidBlockDict:) object:@{@"obs":obs,@"object":object,@"block":voidBlock}];
                    [self.msgQueue addOperation:operation];
                }
            }
        }
        
        if (returnBlocks && (returnBlocks.count >0)){
            for (id returnBlock in returnBlocks) {
                if (excuteType == MTBMessageExcuteTypeSync){
                    [self excuteWithReturnBlockDict:@{@"obs":obs,@"object":object,@"block":returnBlock}];
                }else if (excuteType == MTBMessageExcuteTypeAsync){
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(excuteWithReturnBlockDict:) object:@{@"obs":obs,@"object":object,@"block":returnBlock}];
                    [self.msgQueue addOperation:operation];
                }
            }
        }

        if(returnBlocks.count + voidBlocks.count < 1){
#if TEST || DEBUG
            NSString *errormsg = [NSString stringWithFormat:@"dsxWARNING! this msg <%@> not binding Recieved block",obs.msgName];
            NSLog(@"%@",errormsg);
#endif
        }
    }
}

#pragma mark -
#pragma mark send

- (void)sendMsg:(NSString *)msg onReached:(MsgPosterVoidAction)block
{
    [self sendMsg:msg withObject:nil onReached:block];
}

- (void)sendMsg:(NSString *)msg withObject:(id)object onReached:(MsgPosterVoidAction)block
{
    // default is sync
    [self sendMsg:msg withObject:object type:MTBMessageExcuteTypeSync onReached:block];
}

- (void)sendMsg:(NSString *)msg withObject:(id)object type:(MTBMessageExcuteType)type onReached:(MsgPosterVoidAction)block
{
    [self.msgExcuteType setObject:@(type) forKey:msg];
    if (block) {
        [self.blockReachedStack setObject:block forKey:msg];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:msg object:object];
}


#pragma mark -
#pragma mark remove observer
- (void)removeObserverInObserverStack:(NSNotification  *)no
{
    id observer = no.object;
    if (![self.obsIndex containsObject:@([observer hash])]) return;
    
    [self.msgObserversStack enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray *marray = (NSMutableArray *)obj;
        
        id temobj = nil;
        for (MTBMessageObserver *obs in marray) {
            if ([@(obs.objectID) isEqual:@([observer hash])]) {
                temobj = obs;
            }
        }
        [marray removeObject:temobj];
        [self.msgObserversStack setObject:marray forKey:key];
    }];
}

#pragma mark -
#pragma mark excute block
- (void)excuteWithVoidBlockDict:(NSDictionary *)dict{
    
    MTBMessageObserver *obs = dict[@"obs"];
    NSNotification *object = dict[@"object"];
    id block = dict[@"block"];
    
    MsgPosterVoidAction voidBlockRecieved = (MsgPosterVoidAction)block;
    id innerObject = object.object;
    if(innerObject){
        voidBlockRecieved(innerObject);
    }else{
        // set a default input argument
        voidBlockRecieved([NSObject new]);
    }
    MsgPosterVoidAction blockReached = [self.blockReachedStack valueForKey:object.name];
    if (blockReached) {
        blockReached(obs.msgName);
    }
}

- (void)excuteWithReturnBlockDict:(NSDictionary *)dict{
    
    MTBMessageObserver *obs = dict[@"obs"];
    NSNotification *object = dict[@"object"];
    id block = dict[@"block"];
    
    MsgPosterReturnAction returnBlockRecieved = (MsgPosterReturnAction)block;
    id processingObject = returnBlockRecieved(object.object)?:returnBlockRecieved([NSObject new]);
    MsgPosterVoidAction blockReached = [self.blockReachedStack valueForKey:object.name];
    if (blockReached) {
        // if processingObject is nil .
        blockReached((processingObject?:@"processing result is nil"));
    }else{
#if TEST || DEBUG
        NSString *errormsg = [NSString stringWithFormat:@"dsxWARNING! this msg <%@> not binding Reached block",obs.msgName];
        NSLog(@"%@",errormsg);
#endif
    }
}

@end

@implementation MTBMessageObserver

@end