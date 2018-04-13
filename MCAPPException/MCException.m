//
//  MCException.m
//  Ceches
//
//  Created by ike7 on 2018/4/8.
//  Copyright © 2018年 ike7. All rights reserved.
//

#import "MCException.h"
#import "MCBlueTooth.h"

@implementation MCException
void mcUncaughtExceptionHandler(NSException *exception){
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    
    NSString *reason = [exception reason];
    
    // 异常名称
    //    NSString *name = [exception name];
    //    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception stack：%@\nNSRangeException====>%@", stackArray,reason];
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:stackArray];
    [tmpArr insertObject:reason atIndex:0];
    //保存到本地  --  当然你可以在下次启动的时候，上传这个log
    //    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/%ld",MCExceptionPath,time(NULL)] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[getException() stringByAppendingPathComponent:@"MCEXCEPTION"]];
    [array addObject:@{[NSString stringWithFormat:@"%ld",time(NULL)]:tmpArr}];
    [array writeToFile:[NSString stringWithFormat:@"%@/MCEXCEPTION",getException()] atomically:YES];
}


NSString *getException(){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取Documents路径
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString*path=[paths objectAtIndex:0];
    NSString *testDirectory = [path stringByAppendingPathComponent:@"MCException"];
    // 创建目录
    [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSLog(@"%@",testDirectory);
    return testDirectory;
}
void MCSetAPPreceiveException(id data){
    NSData *mcData = [NSJSONSerialization dataWithJSONObject:@{[NSString stringWithFormat:@"%ld",time(NULL)]:data} options:NSJSONWritingPrettyPrinted error:nil];
    [[MCPostTooth Instance] MCPustToothData:mcData WithBlock:^(BOOL isOkSuccess) {
        NSLog(@"2222222222222222>>>>>>%d",isOkSuccess);
    }];
}
void MCSetLogExceptionData(){
    NSSetUncaughtExceptionHandler(&mcUncaughtExceptionHandler);
}
@end
