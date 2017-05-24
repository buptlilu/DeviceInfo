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

#pragma mark - init
+ (instancetype)shareInstance;

#pragma mark - 电池相关
//获取电池电量
+ (NSString *)getBatteryQuantity;
//获取电池状态
+ (NSString *)getBatteryStauts;

#pragma mark - 存储相关
//获取总内存大小
+ (NSString *)getTotalMemory;
//获取当前可用内存
+ (NSString *)getAvailableMemory;
//获取已使用内存
+ (NSString *)getUsedMemory;
//获取总磁盘容量
+ (NSString *)getTotalDisk;
//获取可用磁盘容量
+ (NSString *)getAvailableDisk;
//容量转换
+ (NSString *)fileSizeToString:(unsigned long long)fileSize;

#pragma mark - 传感器相关
//开始采集传感器数据
- (void)startUpdateCMDatas;
//停止采集数据
- (void)stopUpdateCMDatas;
//加速度计
- (NSString *)getAccelerometerData;
//陀螺仪
- (NSString *)getGyroData;
//磁场
- (NSString *)getMagnetometerData;
//旋转矢量
- (NSString *)getRotationRateData;
//重力
- (NSString *)getGravityData;
@end
