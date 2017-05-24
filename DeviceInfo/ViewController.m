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
}

#pragma mark - functions
- (void)setUpViews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
            CGFloat batteryLevel = [DeviceTool getBatteryQuantity];
            NSLog(@"batteryLevel:%f", batteryLevel);
            detail = [NSString stringWithFormat:@"batteryLevel:%f", batteryLevel];
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
            UIDeviceBatteryState batteryState = [DeviceTool getBatteryStauts];
            NSLog(@"batteryState:%ld", (long)batteryState);
            detail = [NSString stringWithFormat:@"batteryState:%ld", (long)batteryState];
            break;
        }
        case 2:{
            title = @"总内存";
            detail = [DeviceTool fileSizeToString:[DeviceTool getTotalMemorySize]];
            break;
        }
        case 3:{
            title = @"已使用内存(不准)";
            detail = [DeviceTool fileSizeToString:[DeviceTool getUsedMemory]];
            break;
        }
        case 4:{
            title = @"可用内存";
            detail = [DeviceTool fileSizeToString:[DeviceTool getAvailableMemorySize]];
            break;
        }
        case 5:{
            title = @"总磁盘容量";
            detail = [DeviceTool fileSizeToString:[DeviceTool getTotalDiskSize]];
            break;
        }
        case 6:{
            title = @"可用磁盘容量";
            detail = [DeviceTool fileSizeToString:[DeviceTool getAvailableDiskSize]];
            break;
        }
        default:
            title = @"Device";
            detail = @"Info";
            break;
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    return cell;
}
@end
