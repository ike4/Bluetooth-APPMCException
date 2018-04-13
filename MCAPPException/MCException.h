//
//  MCException.h
//  Ceches
//
//  Created by ike7 on 2018/4/8.
//  Copyright © 2018年 ike7. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


typedef void(^MCExceptionData)(id data);
@interface MCException : NSObject

/**
 在AppDelegate 导入引用
 输出异常日志
 */
void MCSetLogExceptionData();
//
///**
// 获取异常路径
//
// @return <#return value description#>
// */
//NSString *getException();


/**
 蓝牙发送数据
 
 @param data 默认key 为当前时间戳
 */
void MCSetAPPreceiveException(id data);

/**
 接收到异常数据
 
 默认闪退  （APP再次打开）服务器调取(字符串为 “MCException”)自动发送到服务器端
 @param MCExceptionData
 */
void MCExceptionReceiveData(UIViewController *SelfController,MCExceptionData);
@end
