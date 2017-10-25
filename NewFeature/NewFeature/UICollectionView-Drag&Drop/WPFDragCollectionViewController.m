//
//  WPFDragCollectionViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/25.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFDragCollectionViewController.h"
#import "WPFImageCollectionViewCell.h"

static NSString *imageCellIdentifier = @"imageCellIdentifier";

@interface WPFDragCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
/** 记录拖拽的 indexPath */
@property (nonatomic, strong) NSIndexPath *dragIndexPath;

@end

@implementation WPFDragCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
}

#pragma mark - Private Method
- (void)_setupUI {
    self.navigationItem.title = @"UICollectionView - Drag & Drop";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self _setupCollectionView];
}

- (void)_setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemLength = [UIScreen mainScreen].bounds.size.width / 5;
    flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    [flowLayout setSectionInset:UIEdgeInsetsMake(15, 12, 15, 12)];
    self.flowLayout = flowLayout;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[WPFImageCollectionViewCell class] forCellWithReuseIdentifier:imageCellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.dragDelegate = self;
    _collectionView.dropDelegate = self;
    // 该属性在 iPad 上默认是YES，在 iPhone 默认是 NO
    _collectionView.dragInteractionEnabled = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:_collectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WPFImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    
    cell.targetImageView.image = self.dataSource[indexPath.item];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDragDelegate

/* 提供一个 给定 indexPath 的可进行 drag 操作的 item
 * 如果返回 nil，则不会发生任何拖拽事件
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    self.dragIndexPath = indexPath;
    return @[item];
}

/* Called to request items to add to an existing drag session in response to the add item gesture.
 * You can use the provided point (in the collection view's coordinate space) to do additional hit testing if desired.
 * If not implemented, or if an empty array is returned, no items will be added to the drag and the gesture
 * will be handled normally.
 */
//- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
//    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
//    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//    return @[item];
//}

/* 允许对从取消或返回到 CollectionView 的 item 使用自定义预览
 * 如果该方法没有实现或者返回nil，那么整个 cell 将用于预览
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGFloat previewLength = self.flowLayout.itemSize.width;
    CGRect rect = CGRectMake(0, 0, previewLength, previewLength);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    return parameters;
}

/* 当 lift animation 完成之后开始拖拽之前会调用该方法
 * 该方法肯定会对应着 -collectionView:dragSessionDidEnd: 的调用
 */
- (void)collectionView:(UICollectionView *)collectionView dragSessionWillBegin:(id<UIDragSession>)session {
    NSLog(@"dragSessionWillBegin --> drag 会话将要开始");
}

// 拖拽结束的时候会调用该方法
- (void)collectionView:(UICollectionView *)collectionView dragSessionDidEnd:(id<UIDragSession>)session {
    NSLog(@"dragSessionDidEnd --> drag 会话已经结束");
}

#pragma mark - UICollectionViewDropDelegate


/* 当用户开始进行 drop 操作的时候会调用这个方法
 * 使用 dropCoordinator 去置顶如果处理当前 drop 会话的item 到指定的最终位置，同时也会根据drop item返回的数据更新数据源
 * 如果该方法不做任何事，将会执行默认的动画
 */
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
    
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    // 如果开始拖拽的 indexPath 和 要释放的目标 indexPath 一致，就不做处理
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    [collectionView performBatchUpdates:^{
        // 目标 cell 换位置
        [self.dataSource exchangeObjectAtIndex:destinationIndexPath.item withObjectAtIndex:self.dragIndexPath.item];
        [collectionView moveItemAtIndexPath:self.dragIndexPath toIndexPath:destinationIndexPath];
    } completion:^(BOOL finished) {
        
    }];
}

/* 该方法是提供释放方案的方法，虽然是optional，但是最好实现
 * 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
 * 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
 * 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
 * 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
 * 你可以通过 -[session locationInView:] 做你自己的命中测试
 */
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
      CollectionView将会接收drop，但是具体的位置要稍后才能确定
      不会开启一个缺口，可以通过添加视觉效果给用户传达这一信息
    UICollectionViewDropIntentUnspecified,
    
      drop将会被插入到目标索引中
      将会打开一个缺口，模拟最后释放后的布局
    UICollectionViewDropIntentInsertAtDestinationIndexPath,
    
     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
    UICollectionViewDropIntentInsertIntoDestinationIndexPath,
     */
    UICollectionViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}

/* 通过该方法判断对应的item 能否被 执行drop会话
 * 如果返回 NO，将不会调用接下来的代理方法
 * 如果没有实现该方法，那么默认返回 YES
 */
- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session {
    // 假设在该 drop 只能在当前本 app中可执行，在别的 app 中不可以
    if (session.localDragSession == nil) {
        return NO;
    }
    return YES;
}

/* 当drop会话进入到 collectionView 的坐标区域内就会调用，
 * 早于- [collectionView dragSessionWillBegin] 调用
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnter:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidEnter --> dropSession进入目标区域");
}

/* 当 dropSession 不在collectionView 目标区域的时候会被调用
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidExit:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidExit --> dropSession 离开目标区域");
}

/* 当dropSession 完成时会被调用，不管结果如何
 * 适合在这个方法里做一些清理的操作
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidEnd --> dropSession 已完成");
}

/* 当 item 执行drop 操作的时候，可以自定义预览图
 * 如果没有实现该方法或者返回nil，整个cell将会被用于预览图
 *
 * 该方法会经由  -[UICollectionViewDropCoordinator dropItem:toItemAtIndexPath:] 调用
 * 如果要去自定义占位drop，可以查看 UICollectionViewDropPlaceholder.previewParametersProvider
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dropPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {

    return nil;
}

#pragma mark - Getters && Setters

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (NSInteger i = 0; i <= 33; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"thumb%ld", i]];
            [tempArray addObject:image];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}


@end
