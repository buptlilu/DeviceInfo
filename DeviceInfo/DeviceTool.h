//
//  DeviceTool.h
//  DeviceInfo
//
//  Created by lilu on 2017/5/23.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceTool : NSObject

#pragma mark - 电池相关
//获取电池电量
+ (CGFloat)getBatteryQuantity;
//获取电池状态
+ (UIDeviceBatteryState)getBatteryStauts;

#pragma mark - 存储相关
//获取总内存大小
+ (long long)getTotalMemorySize;
//获取当前可用内存
+ (long long)getAvailableMemorySize;
//获取已使用内存
+ (double)getUsedMemory;
//获取总磁盘容量
+ (long long)getTotalDiskSize;
//获取可用磁盘容量
+ (long long)getAvailableDiskSize;
//容量转换
+ (NSString *)fileSizeToString:(unsigned long long)fileSize;

#pragma mark - 传感器相关
@end
