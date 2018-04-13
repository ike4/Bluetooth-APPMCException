//
//  UIViewController+MCException.m
//  Cache
//
//  Created by ike7 on 2018/4/13.
//  Copyright © 2018年 ike7. All rights reserved.
//

#import "UIViewController+MCException.h"
#import "MCBlueTooth.h"


@implementation UIViewController (MCException)

-(void)viewDidLoad{
    [[MCPostTooth Instance] MCReturnReadValueForCharacteristic:^(NSData *mcData) {
        NSLog(@"接收到的数据======>%@",mcData);
        id data = [NSJSONSerialization JSONObjectWithData:mcData options:NSJSONReadingAllowFragments error:nil];
        if (self.mcData) {
            self.mcData(data);
        }
        if([data isKindOfClass:[NSString class]]){
            //服务器给出字段自动返回异常闪退日志
            if ([[NSString stringWithFormat:@"%@",data] isEqualToString:@"MCException"]) {
                NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[getException() stringByAppendingPathComponent:@"MCEXCEPTION"]];
                NSData *mData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                [[MCPostTooth Instance] MCPustToothData:mData WithBlock:^(BOOL isOkSuccess) {
                    NSLog(@"2222222222222222>>>>>>%d",isOkSuccess);
                    if (isOkSuccess) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:getException() error:nil];
                    }
                }];
            }
        }
    }];
}
/**
 接收到异常数据
 
 @param MCExceptionData
 */
void MCExceptionReceiveData(UIViewController *SelfController,void(^MCExceptionData)(id data)){
    SelfController.mcData = MCExceptionData;
}
@end
