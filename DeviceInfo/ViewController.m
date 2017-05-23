//
//  ViewController.m
//  DeviceInfo
//
//  Created by lilu on 2017/5/23.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "ViewController.h"

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
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"电池电量";
            //电池相关
            [UIDevice currentDevice].batteryMonitoringEnabled = YES;
            CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
            NSLog(@"batteryLevel:%f", batteryLevel);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"batteryLevel:%f", batteryLevel];
            break;
        }
        case 1:{
            cell.textLabel.text = @"电池状态";
            /*typedef NS_ENUM(NSInteger, UIDeviceBatteryState) {
                UIDeviceBatteryStateUnknown,
                UIDeviceBatteryStateUnplugged,   // on battery, discharging
                UIDeviceBatteryStateCharging,    // plugged in, less than 100%
                UIDeviceBatteryStateFull,        // plugged in, at 100%
            }*/
            //电池相关
            [UIDevice currentDevice].batteryMonitoringEnabled = YES;
            UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
            NSLog(@"batteryState:%ld", (long)batteryState);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"batteryState:%ld", (long)batteryState];
            break;
        }
        case 2:{
            
            break;
        }
            
        default:
            cell.textLabel.text = @"Device";
            cell.detailTextLabel.text = @"Info";
            break;
    }
    return cell;
}
@end
