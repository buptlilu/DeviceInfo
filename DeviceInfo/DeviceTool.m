//
//  DeviceTool.m
//  DeviceInfo
//
//  Created by lilu on 2017/5/23.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "DeviceTool.h"
#import <mach/mach.h>
#import <sys/mount.h>
#import <CoreMotion/CMMotionManager.h>

@interface DeviceTool ()
@property (nonatomic, strong) CMMotionManager *motionManager;
//加速度计
@property (nonatomic, copy) NSString *accelerometerData;
//陀螺仪
@property (nonatomic, copy) NSString *gyroData;
//磁场
@property (nonatomic, copy) NSString *magnetometerData;
//旋转矢量
@property (nonatomic, copy) NSString *rotationRateData;
//重力
@property (nonatomic, copy) NSString *gravityData;

//获取总内存大小
+ (long long)getTotalMemorySize;
//获取当前可用内存
+ (long long)getAvailableMemorySize;
//获取已使用内存
+ (double)getUsedMemorySize;
//获取总磁盘容量
+ (long long)getTotalDiskSize;
//获取可用磁盘容量
+ (long long)getAvailableDiskSize;

@end

@implementation DeviceTool

#pragma mark - init
+ (instancetype)shareInstance {
    static DeviceTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[DeviceTool alloc] init];
        tool.motionManager = [[CMMotionManager alloc] init];
    });
    return tool;
}

#pragma mark - 电池相关
+ (NSString *)getBatteryQuantity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    int batteryLevel = (int)([[UIDevice currentDevice] batteryLevel] * 100);
    NSString *str = [NSString stringWithFormat:@"&bat_lev=%d&bat_sca=100", batteryLevel];
    return str;
}

+ (NSString *)getBatteryStauts {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [NSString stringWithFormat:@"&bat_plu=%d", [UIDevice currentDevice].batteryState];
}

#pragma mark - 存储相关
//获取总内存大小
+ (NSString *)getTotalMemory {
    return [self fileSizeToString:[self getTotalMemorySize]];
}

+ (long long)getTotalMemorySize {
    return [NSProcessInfo processInfo].physicalMemory;
}

//获取当前可用内存
+ (NSString *)getAvailableMemory {
    return [self fileSizeToString:[self getAvailableMemorySize]];
}

+ (long long)getAvailableMemorySize {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}

//获取已使用内存
+ (NSString *)getUsedMemory {
    return [self fileSizeToString:[self getUsedMemorySize]];
}

+ (double)getUsedMemorySize {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

//获取总磁盘容量
+ (NSString *)getTotalDisk {
    return [self fileSizeToString:[self getTotalDiskSize]];
}

+ (long long)getTotalDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}

//获取可用磁盘容量
+ (NSString *)getAvailableDisk {
    return [self fileSizeToString:[self getAvailableDiskSize]];
}

+ (long long)getAvailableDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

+ (NSString *)fileSizeToString:(unsigned long long)fileSize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)  {
        return @"0 B";
    }else if (fileSize < KB)    {
        return @"< 1 KB";
    }else if (fileSize < MB)    {
        return [NSString stringWithFormat:@"%dK",(int)(fileSize/KB)];
    }else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%dM",(int)(fileSize/MB)];
    }else   {
        return [NSString stringWithFormat:@"%dG",(int)(fileSize/GB)];
    }
}

#pragma mark - 传感器相关
- (void)startUpdateDatas {
//    self.accelerometerData = @"";
//    self.gyroData = @"";
//    self.magnetometerData = @"";
//    self.rotationRateData = @"";
//    self.gravityData = @"";
    [self startUpdateDatasAccelerometer];
    [self startUpdateDatasGyro];
    [self startUpdateDatasMagnetometer];
    [self startUpdateDatasDevice];
}

- (void)startUpdateDatasAccelerometer {
    //1.加速计
    self.accelerometerData = @"";
    if (_motionManager.isAccelerometerAvailable) {
        _motionManager.accelerometerUpdateInterval = updateInterval;
        if (isUseHandle) {
            [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"获取加速计数据出现错误");
                }else {
                    //获取加速计信息
                    NSLog(@"111111%s", __func__);
                    self.accelerometerData = [NSString stringWithFormat:@"&sen_acc=%@", [self formattingStringWithX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z]];
                    [self stopUpdateDatasAccelerometer];
                    [self startUpdateDatasGyro];
                }
            }];
        }else {
            [_motionManager startAccelerometerUpdates];
        }
    }
}
- (void)startUpdateDatasGyro {
    //2.陀螺仪
    self.gyroData = @"";
    if (_motionManager.isGyroAvailable) {
        _motionManager.gyroUpdateInterval = updateInterval;
        if (isUseHandle) {
            [_motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"获取陀螺仪数据出现错误");
                }else {
                    NSLog(@"222222%s", __func__);
                    self.gyroData = [NSString stringWithFormat:@"&sen_gyr=%@", [self formattingStringWithX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z]];
                    [self stopUpdateDatasGyro];
                    [self startUpdateDatasMagnetometer];
                }
            }];
        }else {
            [_motionManager startGyroUpdates];
        }
    }
}
- (void)startUpdateDatasMagnetometer {
    //3.磁场
    self.magnetometerData = @"";
    if (_motionManager.isMagnetometerAvailable) {
        _motionManager.magnetometerUpdateInterval = updateInterval;
        if (isUseHandle) {
            [_motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"获取磁场数据失败");
                }else{
                    NSLog(@"333333%s", __func__);
                    self.magnetometerData = [NSString stringWithFormat:@"&sen_magn=%@", [self formattingStringWithX:magnetometerData.magneticField.x y:magnetometerData.magneticField.y z:magnetometerData.magneticField.z]];
                    [self stopUpdateDatasMagnetometer];
                    [self startUpdateDatasDevice];
                }
            }];
            
        }else {
            [_motionManager startMagnetometerUpdates];
        }
    }
}
- (void)startUpdateDatasDevice {
    //4.device
    self.rotationRateData = @"";
    self.gravityData = @"";
    if (_motionManager.isDeviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = updateInterval;
        if (isUseHandle) {
            [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"获取device数据失败");
                }else{
                    NSLog(@"444444%s", __func__);
                    self.rotationRateData = [NSString stringWithFormat:@"&sen_rota=%@", [self formattingStringWithX:motion.rotationRate.x y:motion.rotationRate.y z:motion.rotationRate.z]];
                    self.gravityData = [NSString stringWithFormat:@"&sen_gra=%@", [self formattingStringWithX:motion.gravity.x y:motion.gravity.y z:motion.gravity.z]];
                    [self stopUpdateDatasDevice];
                }
            }];
        }else {
            [_motionManager startDeviceMotionUpdates];
        }
    }
}

- (NSString *)formattingStringWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z {
    return [NSString stringWithFormat:@"{\"0\":%f,\"1\":%f,\"2\":%f}", x, y, z];
}

- (void)stopUpdateDatas {
    if (!isUseHandle) {
        //获取加速计信息
        self.accelerometerData = [NSString stringWithFormat:@"&sen_acc=%@", [self formattingStringWithX:_motionManager.accelerometerData.acceleration.x y:_motionManager.accelerometerData.acceleration.y z:_motionManager.accelerometerData.acceleration.z]];
        self.gyroData = [NSString stringWithFormat:@"&sen_gyr=%@", [self formattingStringWithX:_motionManager.gyroData.rotationRate.x y:_motionManager.gyroData.rotationRate.y z:_motionManager.gyroData.rotationRate.z]];
        self.magnetometerData = [NSString stringWithFormat:@"&sen_magn=%@", [self formattingStringWithX:_motionManager.magnetometerData.magneticField.x y:_motionManager.magnetometerData.magneticField.y z:_motionManager.magnetometerData.magneticField.z]];
        self.rotationRateData = [NSString stringWithFormat:@"&sen_rota=%@", [self formattingStringWithX:_motionManager.deviceMotion.rotationRate.x y:_motionManager.deviceMotion.rotationRate.y z:_motionManager.deviceMotion.rotationRate.z]];
        self.gravityData = [NSString stringWithFormat:@"&sen_gra=%@", [self formattingStringWithX:_motionManager.deviceMotion.gravity.x y:_motionManager.deviceMotion.gravity.y z:_motionManager.deviceMotion.gravity.z]];
    }
    
    [self stopUpdateDatasAccelerometer];
    [self stopUpdateDatasGyro];
    [self stopUpdateDatasMagnetometer];
    [self stopUpdateDatasDevice];
}

- (void)stopUpdateDatasAccelerometer {
    [_motionManager stopAccelerometerUpdates];
}

- (void)stopUpdateDatasGyro {
    [_motionManager stopGyroUpdates];
}

- (void)stopUpdateDatasMagnetometer {
    [_motionManager stopMagnetometerUpdates];
}

- (void)stopUpdateDatasDevice {
    [_motionManager stopDeviceMotionUpdates];
}

- (NSString *)getAccelerometerData {
    //加速计
    return self.accelerometerData ? : @"";
}

- (NSString *)getGyroData {
    //陀螺仪
    return self.gyroData ? : @"";
}

- (NSString *)getMagnetometerData {
    //磁场
    return self.magnetometerData ? : @"";
}

- (NSString *)getRotationRateData {
    return self.rotationRateData ? : @"";
}

- (NSString *)getGravityData {
    return self.gravityData ? : @"";
}
@end
