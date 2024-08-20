//
//  CommandTaskProtocol.h
//  AccBluetoothCommunicate
//
//  Created by hi kobe on 2024/4/9.
//

#ifndef CommandTaskProtocol_h
#define CommandTaskProtocol_h

@protocol CommandTaskProtocol;
@protocol CommandTaskDelegate <NSObject>
@required
- (void)taskTimeout:(id<CommandTaskProtocol>)task;
@end

@protocol CommandTaskProtocol <NSObject>
///任务ID
@property (nonatomic, assign, readonly) NSInteger taskID;
///超时时间
@property (nonatomic, assign) NSInteger timeout;
///最大重试次数 (默认3次)
@property (nonatomic, assign) NSInteger maxRetryTimes;
///重试次数
@property (nonatomic, assign) NSInteger retryTimes;
///内容
@property (nonatomic, strong) NSData *contentData;

/**
 初始化
 */
- (instancetype)initWithTaskID:(NSInteger)taskID delegate:(id<CommandTaskDelegate>)delegate;
/**
 任务倒计时
 */
- (void)startCountdown;
@end

#endif /* CommandTaskProtocol_h */
