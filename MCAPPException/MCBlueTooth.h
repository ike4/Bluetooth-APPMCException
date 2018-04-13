//
//  PTooth.h
//  Tooth
//
//  Created by ike7 on 2018/4/3.
//  Copyright © 2018年 ike7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//需要导入 CoreBluetooth 库
/** 判断手机蓝牙状态 state
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
typedef void (^MCReturnCBCentralManagerState)(CBManager *manger);
typedef void (^MCReturnGatData)(NSData *mcData);
#pragma mark ----------------------- MangerTooth --------------
@interface MCBlueTooth : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, copy) MCReturnCBCentralManagerState MCmanagerState;
@property (nonatomic, copy) MCReturnCBCentralManagerState MCmanagerError;
@property (nonatomic, copy)MCReturnGatData mcData;
/**
 初始化

 @return <#return value description#>
 */
+(instancetype)Instance;

/**
 监听蓝牙是否可用
 
 @param Stateblock 默认设置可用
 */
-(void)MCReturnCentralManagerDidUpdateState:(MCReturnCBCentralManagerState)Stateblock;

/**
 蓝牙断开连接

 @param block 不调用此方法默认 重新连接
 // 断开连接可以设置重新连接
 [central connectPeripheral:peripheral options:nil];
 */
-(void)MCErrorCentralManagerError:(MCReturnCBCentralManagerState)block;

/**
 手动获取接收蓝牙数据
 */
-(void)MCGetReadValueForCharacteristic;

/**
 自动接收蓝牙数据
 @param block data
 string: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 dict  : [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
 array : [NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingAllowFragments error:nil];
 */
-(void)MCReturnReadValueForCharacteristic:(MCReturnGatData)block;

/**
 发送数据
 
 @param data
 [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
 [string dataUsingEncoding:NSUTF8StringEncoding];
 [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
 */
-(void)MCPustToothData:(NSData *)data;

@end

#pragma mark ----------------------- PostTooth --------------

@interface MCPostTooth : NSObject <CBPeripheralManagerDelegate>
@property (nonatomic, copy) MCReturnCBCentralManagerState MCmanagerState;
@property (nonatomic, copy) MCReturnCBCentralManagerState MCmanagerError;
@property (nonatomic, copy) MCReturnGatData mcData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
/**
 初始化
 
 @return <#return value description#>
 */
+(instancetype)Instance;

/**
 监听蓝牙是否可用
 
 @param Stateblock 默认设置可用
 */
-(void)MCReturnCentralManagerDidUpdateState:(MCReturnCBCentralManagerState)Stateblock;

/**
 蓝牙断开连接
 
 @param block 不调用此方法默认 重新连接
 // 断开连接可以设置重新连接
 [central connectPeripheral:peripheral options:nil];
 */
-(void)MCErrorCentralManagerError:(MCReturnCBCentralManagerState)block;

/**
 自动接收蓝牙数据
 @param block data
 string: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 dict  : [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
 array : [NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingAllowFragments error:nil];
 */
-(void)MCReturnReadValueForCharacteristic:(MCReturnGatData)block;

/**
 发送数据
 
 @param data
 [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
 [string dataUsingEncoding:NSUTF8StringEncoding];
 [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
 */
-(void)MCPustToothData:(NSData *)data WithBlock:(void(^)(BOOL isOkSuccess))block;
@end
