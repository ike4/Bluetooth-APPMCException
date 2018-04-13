//
//  PTooth.m
//  Tooth
//
//  Created by ike7 on 2018/4/3.
//  Copyright © 2018年 ike7. All rights reserved.
//

#import "MCBlueTooth.h"
#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@implementation MCBlueTooth

+(instancetype)Instance{
    static MCBlueTooth* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MCBlueTooth alloc] init];
        // 创建中心设备管理器，会回调centralManagerDidUpdateState
        manager.centralManager = [[CBCentralManager alloc] initWithDelegate:manager queue:dispatch_get_main_queue()];
    });
    return manager;
}
/**
 监听蓝牙是否可用
 
 @param block 默认设置可用
 */
-(void)MCReturnCentralManagerDidUpdateState:(MCReturnCBCentralManagerState)Stateblock{
    self.MCmanagerState = Stateblock;
}
/**
 蓝牙断开连接
 
 @param block 不调用此方法默认 重新连接
 // 断开连接可以设置重新连接
 [central connectPeripheral:peripheral options:nil];
 */
-(void)MCErrorCentralManagerError:(MCReturnCBCentralManagerState)block{
    self.MCmanagerError = block;
}
/**
 手动获取蓝牙数据
 */
-(void)MCGetReadValueForCharacteristic{
     [self.peripheral readValueForCharacteristic:self.characteristic];
}
/**
 自动获取蓝牙数据
 
 @param block <#block description#>
 */
-(void)MCReturnReadValueForCharacteristic:(MCReturnGatData)block{
    self.mcData = block;
}
/**
 发送数据
 
 @param data <#data description#>
 */
-(void)MCPustToothData:(NSData *)data{
    // 根据上面的特征self.characteristic来写入数据
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 蓝牙可用，开始扫描外设
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙可用");
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
    }
    if(central.state==CBManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
    }
    if (central.state==CBManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
    }
    if(self.MCmanagerState){
        self.MCmanagerState(central);
    }
}
/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 对外设对象进行强引用
    self.peripheral = peripheral;
    
    //    if ([peripheral.name hasPrefix:@"WH"]) {
    //        // 可以根据外设名字来过滤外设
    //        [central connectPeripheral:peripheral options:nil];
    //    }
    
    // 连接外设
    [central connectPeripheral:peripheral options:nil];
}
/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    NSLog(@"连接成功");
}
/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
    if(self.MCmanagerState){
        self.MCmanagerState(central);
    }
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    if (self.MCmanagerError) {
        self.MCmanagerError(central);
    }else{
        // 断开连接可以设置重新连接
        [central connectPeripheral:peripheral options:nil];
    }
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务：%@",service);
    }
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
    self.characteristic = service.characteristics.lastObject;
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    [peripheral readValueForCharacteristic:self.characteristic];
    
    // 订阅通知
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    NSData *data = characteristic.value;
    if (self.mcData) {
      self.mcData(data);
    }
//    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
}
@end

#pragma mark ----------------------- MCPostTooth --------------
@implementation MCPostTooth
/**
 初始化
 
 @return <#return value description#>
 */
+(instancetype)Instance{
    static MCPostTooth* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MCPostTooth alloc] init];
        // 创建中心设备管理器，会回调centralManagerDidUpdateState
        manager.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:manager queue:dispatch_get_main_queue()];
    });
    return manager;
}
/**
 监听蓝牙是否可用
 
 @param Stateblock 默认设置可用
 */
-(void)MCReturnCentralManagerDidUpdateState:(MCReturnCBCentralManagerState)Stateblock{
    self.MCmanagerState = Stateblock;
}
/**
 蓝牙断开连接
 
 @param block 不调用此方法默认 重新连接
 // 断开连接可以设置重新连接
 [central connectPeripheral:peripheral options:nil];
 */
-(void)MCErrorCentralManagerError:(MCReturnCBCentralManagerState)block{
    self.MCmanagerError = block;
}

/**
 自动获取蓝牙数据
 
 @param block <#block description#>
 string: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 dict  : [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
 array : [NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingAllowFragments error:nil];
 */
-(void)MCReturnReadValueForCharacteristic:(MCReturnGatData)block{
    self.mcData = block;
}
/**
 发送数据
 
 @param data <#data description#>
 */
-(void)MCPustToothData:(NSData *)data WithBlock:(void(^)(BOOL isOkSuccess))block{
    if (self.characteristic) {
        // 根据上面的特征self.characteristic来写入数据
        block([self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:nil]);
    }
}
/** 设备的蓝牙状态
 CBManagerStateUnknown = 0,未知
 CBManagerStateResetting,重置中
 CBManagerStateUnsupported,不支持
 CBManagerStateUnauthorized,未验证
 CBManagerStatePoweredOff,未启动
 CBManagerStatePoweredOn,可用
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        // 创建Service（服务）和Characteristics（特征）
        [self setupServiceAndCharacteristics];
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    }
    if (self.MCmanagerState) {
        self.MCmanagerState(peripheral);
    }
}
/** 创建服务和特征 */
- (void)setupServiceAndCharacteristics {
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    self.characteristic = [
                           [CBMutableCharacteristic alloc]
                           initWithType:characteristicID
                           properties:
                           CBCharacteristicPropertyRead |
                           CBCharacteristicPropertyWrite |
                           CBCharacteristicPropertyNotify
                           value:nil
                           permissions:CBAttributePermissionsReadable |
                           CBAttributePermissionsWriteable];
    // 特征添加进服务
    service.characteristics = @[self.characteristic];
    // 服务加入管理
    [self.peripheralManager addService:service];
    
}
///** 中心设备读取数据的时候回调 */
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//    // 请求中的数据，这里把文本框中的数据发给中心设备
//    request.value = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
//    // 成功响应请求
//    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
//}

/** 中心设备写入数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    NSData *data = request.value;
    if (self.mcData) {
        self.mcData(data);
    }
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error{
    if (self.MCmanagerError) {
        self.MCmanagerError(peripheral);
    }
}
/** 订阅成功回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

/** 取消订阅回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}
@end
