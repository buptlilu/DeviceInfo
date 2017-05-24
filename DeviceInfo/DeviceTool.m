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
+ (CGFloat)getBatteryQuantity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [[UIDevice currentDevice] batteryLevel];
}

+ (UIDeviceBatteryState)getBatteryStauts {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [UIDevice currentDevice].batteryState;
}

#pragma mark - 存储相关
+ (long long)getTotalMemorySize {
    return [NSProcessInfo processInfo].physicalMemory;
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

+ (double)getUsedMemory {
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

+ (long long)getTotalDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
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
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize)/KB];
    }else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize)/MB];
    }else   {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize)/GB];
    }
}

#pragma mark - 传感器相关
- (void)startUpdateCMDatas {
    //1.加速计
    if (_motionManager.isAccelerometerAvailable) {
        _motionManager.accelerometerUpdateInterval = 0.05;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"获取加速计数据出现错误");
            }else {
                //获取加速计信息
                CMAcceleration acceleration = accelerometerData.acceleration;
                self.accelerometerData = [NSString stringWithFormat:@"加速计Accelerayion_X:%f Y:%f Z:%f",acceleration.x,acceleration.y,acceleration.z];
            }
        }];
    }
    
    //2.陀螺仪
    if (_motionManager.isGyroAvailable) {
        _motionManager.gyroUpdateInterval = 0.05;
        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"获取陀螺仪数据出现错误");
            }else {
                self.gyroData = [NSString stringWithFormat:@"陀螺仪gyro:%f Y:%f Z:%f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
            }
        }];
    }
    
    //3.磁场
    if (_motionManager.isMagnetometerAvailable) {
        _motionManager.magnetometerUpdateInterval = 0.05;
        [_motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"获取磁场数据失败");
            }else{
                self.magnetometerData = [NSString stringWithFormat:@"磁场magnet_X:%f Y:%f Z:%f",magnetometerData.magneticField.x,magnetometerData.magneticField.y,magnetometerData.magneticField.z];
            }
        }];
    }
    
    //4.device
    if (_motionManager.isDeviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = 0.05;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (error) {
                NSLog(@"获取device数据失败");
            }else{
                self.rotationRateData = [NSString stringWithFormat:@"旋转rotation_X:%f Y:%f Z:%f",motion.rotationRate.x,motion.rotationRate.y,motion.rotationRate.z];
                self.gravityData = [NSString stringWithFormat:@"重力gravity_X:%f Y:%f Z:%f",motion.gravity.x,motion.gravity.y,motion.gravity.z];
            }
        }];
    }
}

- (void)stopUpdateCMDatas {
    [_motionManager stopAccelerometerUpdates];
    [_motionManager stopGyroUpdates];
    [_motionManager stopMagnetometerUpdates];
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
@end
