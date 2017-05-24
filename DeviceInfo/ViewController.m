//
//  ViewController.m
//  DeviceInfo
//
//  Created by lilu on 2017/5/23.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "ViewController.h"
#import "DeviceTool.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    
    //1.距离传感器  iPhone才有
    [UIDevice currentDevice].proximityMonitoringEnabled  =YES;
    //监听是否有物品靠近
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UIDeviceProximityStateDidChangeNotification object:nil];
}

#pragma mark - functions
- (void)setUpViews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)change:(NSNotificationCenter *)center {
    if ([UIDevice currentDevice].proximityState == YES) {
        NSLog(@"有物体靠近");
    }else{
        NSLog(@"物体离开");
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    NSString *title;
    NSString *detail;
    switch (indexPath.row) {
        case 0:{
            title = @"电池电量";
            //电池相关
            detail = [DeviceTool getBatteryQuantity];
            break;
        }
        case 1:{
            title = @"电池状态";
            /*typedef NS_ENUM(NSInteger, UIDeviceBatteryState) {
                UIDeviceBatteryStateUnknown,
                UIDeviceBatteryStateUnplugged,   // on battery, discharging
                UIDevicBatteryStateCharging,    // plugged in, less than 100%
                UIDeviceBatteryStateFull,        // plugged in, at 100%
            }*/
            //电池相关
            detail = [DeviceTool getBatteryStauts];
            break;
        }
        case 2:{
            title = @"总内存";
            detail = [DeviceTool getTotalMemory];
            break;
        }
        case 3:{
            title = @"已使用内存(不准)";
            detail = [DeviceTool getUsedMemory];
            break;
        }
        case 4:{
            title = @"可用内存";
            detail = [DeviceTool getAvailableMemory];
            break;
        }
        case 5:{
            title = @"总磁盘容量";
            detail = [DeviceTool getTotalDisk];
            break;
        }
        case 6:{
            title = @"可用磁盘容量";
            detail = [DeviceTool getAvailableDisk];
            break;
        }
        case 7:{
            title = @"加速度计";
            [[DeviceTool shareInstance] startUpdateCMDatas];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = [[DeviceTool shareInstance] getAccelerometerData];
                [[DeviceTool shareInstance] stopUpdateCMDatas];
            });
            break;
        }
        case 8:{
            title = @"陀螺仪";
            [[DeviceTool shareInstance] startUpdateCMDatas];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = [[DeviceTool shareInstance] getGyroData];
                [[DeviceTool shareInstance] stopUpdateCMDatas];
            });
            break;
        }
        case 9:{
            title = @"磁场";
            [[DeviceTool shareInstance] startUpdateCMDatas];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = [[DeviceTool shareInstance] getMagnetometerData];
                [[DeviceTool shareInstance] stopUpdateCMDatas];
            });
            break;
        }
        case 10:{
            title = @"旋转矢量";
            [[DeviceTool shareInstance] startUpdateCMDatas];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = [[DeviceTool shareInstance] getRotationRateData];
                [[DeviceTool shareInstance] stopUpdateCMDatas];
            });
            break;
        }
        case 11:{
            title = @"重力";
            [[DeviceTool shareInstance] startUpdateCMDatas];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = [[DeviceTool shareInstance] getGravityData];
                [[DeviceTool shareInstance] stopUpdateCMDatas];
            });
            break;
        }
        default:
            title = @"Device";
            detail = @"Info";
            break;
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}
@end
