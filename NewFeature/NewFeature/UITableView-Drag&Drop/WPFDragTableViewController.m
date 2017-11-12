//
//  WPFDragTableViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/9.
//  Copyright © 2017年 Leon. All rights reserved.
// 本地调用和索引路径进行优化

/**
 在 iPad 中可以跨 app 使用，相比 iPhone 中使用就有些局限
 
 两个方法互相独立，也可只使用其中一个，也可以结合使用实现拖动重新排序的效果
 dragDelegate 初始化和自定义的方法
 dropDelegate 完成拖动数据迁移和动画优化
 */


#import "WPFDragTableViewController.h"
#import "WPFImageTableViewCell.h"

static NSString *const identifier = @"kDragCellIdentifier";

@interface WPFDragTableViewController () <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath *dragIndexPath;

@end

@implementation WPFDragTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WPFImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.numberOfLines = 0;
    cell.targetImageView.image = self.dataSource[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context {
    
    return YES;
}

#pragma mark - UITableViewDragDelegate
/**
 开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
 如果返回 nil，则不会发生任何拖拽事件
 */
- (nonnull NSArray<UIDragItem *> *)tableView:(nonnull UITableView *)tableView itemsForBeginningDragSession:(nonnull id<UIDragSession>)session atIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.row]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    self.dragIndexPath = indexPath;
    return @[item];
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.row]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    return @[item];
}

- (nullable UIDragPreviewParameters *)tableView:(UITableView *)tableView dragPreviewParametersForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15];
    return parameters;
}

#pragma mark - UITableViewDropDelegate
// 当用户开始初始化 drop 手势的时候会调用该方法
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator {
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    
    // 如果开始拖拽的 indexPath 和 要释放的目标 indexPath 一致，就不做处理
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    [tableView performBatchUpdates:^{
        // 目标 cell 换位置
        id obj = self.dataSource[self.dragIndexPath.row];
        [self.dataSource removeObjectAtIndex:self.dragIndexPath.row];
        [self.dataSource insertObject:obj atIndex:destinationIndexPath.row];
        [tableView deleteRowsAtIndexPaths:@[self.dragIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[destinationIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    } completion:^(BOOL finished) {
        
    }];
}

// 该方法是提供释放方案的方法，虽然是optional，但是最好实现
// 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
// 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
// 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
// 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
// 你可以通过 -[session locationInView:] 做你自己的命中测试
- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
     // TableView江湖接受drop，但是具体的位置还要稍后才能确定T
     // 不会打开一个缺口，也许你可以提供一些视觉上的处理来给用户传达这一信息
     UITableViewDropIntentUnspecified,
     
     // drop 将会插入到目标索引路径
     // 将会打开一个缺口，模拟最后释放后的布局
     UITableViewDropIntentInsertAtDestinationIndexPath,
     
     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
     UITableViewDropIntentInsertIntoDestinationIndexPath,
     
     tableView 会根据dro 手势的位置在 .insertAtDestinationIndexPath 和 .insertIntoDestinationIndexPath 自动选择，
     UITableViewDropIntentAutomatic
     */
    UITableViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}


#pragma mark - Private Method
- (void)_setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[WPFImageTableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.dragDelegate = self;
    _tableView.dropDelegate = self;
    _tableView.dragInteractionEnabled = YES;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.rowHeight = 250;
    [self.view addSubview:_tableView];
}

#pragma mark - setters && getters

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (NSInteger i = 0; i <= 5; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld", i]];
            [tempArray addObject:image];
                              
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}




@end
