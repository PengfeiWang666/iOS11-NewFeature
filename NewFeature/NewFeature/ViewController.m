//
//  ViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "ViewController.h"
#import "WPFDragViewController.h"

static NSString *const identifier = @"cellIdentifier";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self _setupNav];
    [self _setupTableView];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
            case 0:
            [self _showDragView];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Method
- (void)_setupNav {
    self.navigationItem.title = @"iOS11-NewFeature";
    self.navigationController.navigationBar.largeTitleTextAttributes = @{
                                                 NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:28],
                                      NSForegroundColorAttributeName:[UIColor blackColor],
                                                                         };
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
}

- (void)_setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.rowHeight = 60;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)_showDragView {
    WPFDragViewController *dragVC = [[WPFDragViewController alloc] init];
    [self.navigationController pushViewController:dragVC animated:YES];
}

#pragma mark - setters && getters

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"拖拽控件", @"UITableView 新特性"];
    }
    return _dataSource;
}

@end
