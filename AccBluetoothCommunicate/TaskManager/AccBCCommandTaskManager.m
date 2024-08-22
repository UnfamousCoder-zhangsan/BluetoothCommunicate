//
//  AccBCCommandTaskManager.m
//  AccBluetoothCommunicate
//
//  Created by hi kobe on 2024/3/27.
//

#import "AccBCCommandTaskManager.h"
#import <AccBluetoothCommunicate/BabyBluetooth.h>
#import <AccBluetoothCommunicate/CommandTaskProtocol.h>

@interface AccBCCommandTaskManager ()
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, weak) id<AccBCManagerDelegate> delegate;
@property (nonatomic, assign) int maxValue;
@property (nonatomic, assign) BOOL stopWriteQueue;
@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *commandArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<CommandTaskProtocol>> *taskDict;
@property (nonatomic, strong) NSLock *taskLock;
@property (nonatomic, strong) NSCondition *commandLock;
@end

@implementation AccBCCommandTaskManager

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral maxMTU:(int)mtu delegate:(id<AccBCManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        self.delegate = delegate;
        self.maxValue = (int)[_peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse] - 3;
        self.maxValue = self.maxValue > mtu ? mtu : self.maxValue;
        self.stopWriteQueue = YES;
    }
    return self;
}

#pragma mark - lazy -
- (NSLock *)taskLock
{
    if (!_taskLock) {
        _taskLock = [[NSLock alloc] init];
    }
    return _taskLock;
}

- (NSMutableArray *)commandArray{
    if (!_commandArray){
        _commandArray = [NSMutableArray array];
    }
    return _commandArray;
}

- (NSMutableDictionary<NSString *, id<CommandTaskProtocol>> *)taskDict
{
    if (!_taskDict){
        _taskDict = [NSMutableDictionary dictionary];
    }
    return _taskDict;
}

- (NSCondition *)commandLock
{
    if (!_commandLock) {
        _commandLock = [[NSCondition alloc] init];
    }
    return _commandLock;
}

- (dispatch_queue_t)writeQueue
{
    if (!_writeQueue) {
        _writeQueue = dispatch_queue_create("com.accsoon.sliderrail.writeData", DISPATCH_QUEUE_CONCURRENT);
    }
    return _writeQueue;
}

#pragma mark - set -
- (void)setNotifyCharacteristic:(CBCharacteristic *)notifyCharacteristic
{
    _notifyCharacteristic = notifyCharacteristic;
    if (notifyCharacteristic.properties & CBCharacteristicPropertyNotify ||  notifyCharacteristic.properties & CBCharacteristicPropertyIndicate) {
        if (!notifyCharacteristic.isNotifying) {
            [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
        }
        [self handleNotify];
    }
}

- (void)setWrireCharacteristic:(CBCharacteristic *)wrireCharacteristic
{
    _wrireCharacteristic = wrireCharacteristic;
}

- (void)startWriteData
{
    dispatch_async(self.writeQueue, ^{
        while (!self.stopWriteQueue) {
            @autoreleasepool {
                [self.commandLock lock];
                while (self.commandArray.count<=0) {
                    if(self.stopWriteQueue){
                        [self.commandLock unlock];
                        break;
                    }
                    [self.commandLock wait];
                }
                if(self.stopWriteQueue){
                    [self.commandLock unlock];
                    break;
                }
                [self.taskLock lock];
                NSMutableData *data = [[NSMutableData alloc] init];
                for (NSNumber *key in self.commandArray) {
                    id<CommandTaskProtocol> task = [self.taskDict valueForKey:[key stringValue]];
                    if ([task respondsToSelector:@selector(startCountdown)]) {
                        [task startCountdown];
                    }
                    [data appendData:task.contentData];
                }
                [self.taskLock unlock];
                [self.commandArray removeAllObjects];
                [self.commandLock unlock];
                [self writeData:data];
            }
        }
    });
}

/**
 *分段发送
 */
- (void)writeData:(NSData *)data
{
    for (int i = 0; i < [data length]; i += self.maxValue) {
        if ((i + self.maxValue) < [data length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, self.maxValue];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            [self sendDataToBLE:subData];
        }else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([data length] - i)];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            [self sendDataToBLE:subData];
        }
        usleep(50 * 1000);
    }
}

- (void)sendDataToBLE:(NSData *)data {
    if (self.wrireCharacteristic == nil) {
        return;
    }
    if (self.wrireCharacteristic.properties && CBCharacteristicPropertyWriteWithoutResponse) {
        [self.peripheral writeValue:data forCharacteristic:self.wrireCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }else if (self.wrireCharacteristic.properties && CBCharacteristicPropertyWrite) {
        [self.peripheral writeValue:data forCharacteristic:self.wrireCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)start {
    if (!self.stopWriteQueue) return;
    [self startWriteData];
}

- (void)stop
{
    [self.commandLock lock];
    self.stopWriteQueue = YES;
    [self.commandLock signal];
    [self.commandLock unlock];
    [self clearDataBuffer];
}

- (void)clearDataBuffer {
    [self.taskLock lock];
    if (self.taskDict.count > 0){
        [self.taskDict removeAllObjects];
    }
    [self.taskLock unlock];
    
    [self.commandLock lock];
    [self.commandArray removeAllObjects];
    [self.commandLock unlock];
}

/**
 处理蓝牙通知消息
 */
- (void)handleNotify {
    __weak __typeof(self)weakSelf = self;
    [[BabyBluetooth shareBabyBluetooth] notify:self.peripheral characteristic:self.notifyCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(handleNotifyMessage:completeBlock:)]) {
            [strongSelf.delegate handleNotifyMessage:characteristics completeBlock:^(id<CommandTaskProtocol> task) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf.taskLock lock];
                if ([task isEqual:[strongSelf.taskDict valueForKey:[@(task.taskID) stringValue]]]) {
                    [strongSelf.taskDict removeObjectForKey:[@(task.taskID) stringValue]];
                }
                [strongSelf.taskLock unlock];
            }];
        }
    }];
}

#pragma mark - 添加/删除任务 -
- (id<CommandTaskProtocol>)getTaskWith:(NSInteger)taskID
{
    [self.taskLock lock];
    id<CommandTaskProtocol> task = [self.taskDict valueForKey:[@(taskID) stringValue]];
    [self.taskLock unlock];
    return task;
}


- (void)addTask:(id<CommandTaskProtocol>)task
{
    //对象是否遵守了该协议
    if (![task conformsToProtocol:@protocol(CommandTaskProtocol)]) return;
    if (self.stopWriteQueue) {
        [self clearDataBuffer];
        return;
    }
    [self.taskLock lock];
    [self.taskDict setValue:task forKey:[@(task.taskID) stringValue]];
    [self.taskLock unlock];
    
    [self.commandLock lock];
    [self.commandArray addObject:@(task.taskID)];
    [self.commandLock signal];
    [self.commandLock unlock];
}

- (void)insertTopTask:(id<CommandTaskProtocol>)task
{
    if (![task conformsToProtocol:@protocol(CommandTaskProtocol)]) return;
    if (self.stopWriteQueue) {
        [self clearDataBuffer];
        return;
    }
    [self.taskLock lock];
    [self.taskDict setValue:task forKey:[@(task.taskID) stringValue]];
    [self.taskLock unlock];
    
    [self.commandLock lock];
    [self.commandArray insertObject:@(task.taskID) atIndex:0];
    [self.commandLock signal];
    [self.commandLock unlock];
}

#pragma mark - CommandTaskDelegate -
- (void)taskTimeout:(id<CommandTaskProtocol>)task
{
    if ([self.delegate respondsToSelector:@selector(taskTimeout:)]) {
        [self.delegate taskTimeout:task];
    }
    [self.taskLock lock];
    if ([task isEqual:[self.taskDict valueForKey:[@(task.taskID) stringValue]]]) {
        [self.taskDict removeObjectForKey:[@(task.taskID) stringValue]];
    }
    [self.taskLock unlock];
}

- (void)clearTaskBuffer {
    [self.taskLock lock];
    if (self.taskDict.count > 0){
        [self.taskDict removeAllObjects];
    }
    [self.taskLock unlock];
    [self.commandLock lock];
    [self.commandArray removeAllObjects];
    [self.commandLock unlock];
}

@end
