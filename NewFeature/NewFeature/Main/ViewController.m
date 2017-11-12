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
#import "WPFStoreReviewController.h"
#import "WPFFeatureModel.h"
#import "WPFChangeAppIconViewController.h"

static NSString *const identifier = @"cellIdentifier";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupNav];
    [self _setupTableView];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"iOS11 新特性";
    } else {
        return @"iOS10.3 新特性";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataSource[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    WPFFeatureModel *model = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.text = model.titleString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WPFFeatureModel *featureModel = self.dataSource[indexPath.section][indexPath.row];
    if (featureModel.targetVcClass) {
        UIViewController *targetVC =[[featureModel.targetVcClass alloc] init];
        targetVC.navigationItem.title = featureModel.titleString;
        targetVC.view.backgroundColor = [UIColor whiteColor];
        targetVC.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        [self.navigationController pushViewController:targetVC animated:YES];
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
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.rowHeight = 60;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - setters && getters

- (NSArray *)dataSource {
    if (!_dataSource) {
        WPFFeatureModel *model1 = [WPFFeatureModel featureWithTitleString:@"UICollectionView-Drag & Drop" targetVcClass:[WPFDragCollectionViewController class]];
        WPFFeatureModel *model2 = [WPFFeatureModel featureWithTitleString:@"UITableView-Drag & Drop" targetVcClass:[WPFDragTableViewController class]];
        WPFFeatureModel *model3 = [WPFFeatureModel featureWithTitleString:@"UIView-Drag & Drop" targetVcClass:[WPFNormalDragViewController class]];
        WPFFeatureModel *model4 = [WPFFeatureModel featureWithTitleString:@"UITableView Swipe手势新特性" targetVcClass:[WPFSwipeViewController class]];
//        WPFFeatureModel *model5 = [WPFFeatureModel featureWithTitleString:@"Core NFC 暂未完成" targetVcClass:[]];
        WPFFeatureModel *model6 = [WPFFeatureModel featureWithTitleString:@"快速评价" targetVcClass:[WPFStoreReviewController class]];
        WPFFeatureModel *model7 = [WPFFeatureModel featureWithTitleString:@"更换 App 头像" targetVcClass:[WPFChangeAppIconViewController class]];
        _dataSource = @[@[model1, model2, model3, model4], @[model6, model7]];
    }
    return _dataSource;
}

@end
