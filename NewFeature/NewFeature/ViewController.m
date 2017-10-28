//
//  ViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "ViewController.h"
#import "WPFDragCollectionViewController.h"
#import "WPFDragTableViewController.h"
#import "WPFSwipeViewController.h"
#import "WPFNormalDragViewController.h"

static NSString *const identifier = @"cellIdentifier";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

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
            [self _showCollectionViewDragView];
            break;
            
            case 1:
            [self _showTableViewDragView];
            break;
            
            case 2:
            [self _showNormalDragView];
            break;
            
            case 3:
            [self _showTableViewFeatureVC];
            break;
            
            case 4:
            [self _showCoreNFCVC];
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
                                      NSForegroundColorAttributeName:[UIColor orangeColor],
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

- (void)_showCollectionViewDragView {
    WPFDragCollectionViewController *collectionDragVC = [[WPFDragCollectionViewController alloc] init];
    [self.navigationController pushViewController:collectionDragVC animated:YES];
}

- (void)_showNormalDragView {
    
    WPFNormalDragViewController *normalDragVC = [[WPFNormalDragViewController alloc] init];
    [self.navigationController pushViewController:normalDragVC animated:YES];
}

- (void)_showTableViewDragView {
    WPFDragTableViewController *tableDragVC = [[WPFDragTableViewController alloc] init];
    [self.navigationController pushViewController:tableDragVC animated:YES];
}

- (void)_showTableViewFeatureVC {
    WPFSwipeViewController *tableViewVC = [[WPFSwipeViewController alloc] init];
    [self.navigationController pushViewController:tableViewVC animated:YES];
}

- (void)_showCoreNFCVC {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"该demo暂未完成" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:confirmAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - setters && getters

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"UICollectionView-Drag & Drop", @"UITableView-Drag & Drop", @"UIView-Drag & Drop", @"UITableView Swipe手势新特性", @"Core NFC 暂未完成"];
    }
    return _dataSource;
}

@end
