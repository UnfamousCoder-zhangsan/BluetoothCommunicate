//
//  AccBCCommandTaskManager.h
//  AccBluetoothCommunicate
//
//  Created by hi kobe on 2024/3/27.
//
//  蓝牙收发消息库
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AccBluetoothCommunicate/CommandTaskProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CommandTaskProtocol;
@protocol AccBCManagerDelegate <NSObject>

@required
/**
 任务执行超时代理
 */
- (void)taskTimeout:(id<CommandTaskProtocol>)task;

/**
 解析数据后需要拿到包号，通过包号调用getTaskWith:方法
 */
- (void)handleNotifyMessage:(CBCharacteristic *)characteristics completeBlock:(void(^)( id<CommandTaskProtocol>))completeblock;

@end

@interface AccBCCommandTaskManager : NSObject<CommandTaskDelegate>
@property(nonatomic, strong) CBCharacteristic *wrireCharacteristic;
@property (nonatomic,strong) CBCharacteristic *notifyCharacteristic;
/**
 初始化创建一个管理类
 @param peripheral 外设
 @param mtu 硬件蓝牙    最大MTU
 @param delegate  代理方法相关
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral maxMTU:(int)mtu delegate:(id<AccBCManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 开启发送指令
 */
- (void)start;
/**
 清除待发送任务
 */
- (void)clearTaskBuffer;
/**
 停止发送指令
 */
- (void)stop;

/**
 从已添加的数组中获取已有指令
 */
- (id<CommandTaskProtocol>)getTaskWith:(NSInteger)taskID;

/**
 添加指令
 */
- (void)addTask:(id<CommandTaskProtocol>)task;
/**
 优先发送指令
 */
- (void)insertTopTask:(id<CommandTaskProtocol>)task;

@end

NS_ASSUME_NONNULL_END
