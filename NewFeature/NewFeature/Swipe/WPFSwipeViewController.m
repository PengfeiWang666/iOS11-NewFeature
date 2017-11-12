//
//  WPFSwipeViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFSwipeViewController.h"

static NSString *const identifier = @"kSwipeCellIdentifier";

@interface WPFSwipeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation WPFSwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) return 95;
    
    return 60;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= 2) {
        UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self.dataSource removeObjectAtIndex:0];
            
            completionHandler(YES);
        }];
        if (indexPath.row > 0) {
            deleteRowAction.image = [UIImage imageNamed:@"deleteRow"];
        }
        UISwipeActionsConfiguration *deleteRowConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
        return deleteRowConfiguration;
    }
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        UIContextualAction *favourRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"收藏" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CGFloat red   = (arc4random() % 256) / 256.0;
            CGFloat green = (arc4random() % 256) / 256.0;
            CGFloat blue  = (arc4random() % 256) / 256.0;
            
            cell.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            
            completionHandler(YES);
        }];
        favourRowAction.backgroundColor = [UIColor orangeColor];
        
        UISwipeActionsConfiguration *favourRowConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[favourRowAction]];
        return favourRowConfiguration;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context {
    
    return YES;
}

#pragma mark - Private Method
- (void)_setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - setters && getters

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:@[@"👈试试左滑删除", @"👈这个左滑删除带图标哦", @"👈同时存在title和image，行高超过一定高度才会显示title（👆那个cell就没显示title）", @"👉试试右滑（多试几次哦）"]];
    }
    return _dataSource;
}

@end
