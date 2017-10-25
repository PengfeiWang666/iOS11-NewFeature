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

/**
 提供一个 给定 indexPath 的可进行 drag 操作的 item
 如果返回 nil，则不会发生任何拖拽事件
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

/** 允许对从取消或返回到 CollectionView 的 item 使用自定义预览
    如果该方法没有实现或者返回nil，那么整个 cell 将用于预览
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGFloat previewLength = self.flowLayout.itemSize.width;
    CGRect rect = CGRectMake(0, 0, previewLength, previewLength);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    return parameters;
}

#pragma mark - UICollectionViewDropDelegate


/** 当用户开始进行 drop 操作的时候会调用这个方法
   使用 dropCoordinator 去置顶如果处理当前 drop 会话的item 到指定的最终位置，同时也会根据drop item返回的数据更新数据源
   如果该方法不做任何事，将会执行默认的动画
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

/* Called frequently while the drop session being tracked inside the collection view's coordinate space.
 * When the drop is at the end of a section, the destination index path passed will be for a item that does not yet exist (equal
 * to the number of items in that section), where an inserted item would append to the end of the section.
 * The destination index path may be nil in some circumstances (e.g. when dragging over empty space where there are no cells).
 * Note that in some cases your proposal may not be allowed and the system will enforce a different proposal.
 * You may perform your own hit testing via -[UIDropSession locationInView]
 */
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
      Collection view will accept the drop, but the location is not yet known and will be determined later.
     * Will not open a gap. You may wish to provide some visual treatment to communicate this to the user.
    UICollectionViewDropIntentUnspecified,
    
    The drop will be placed in item(s) inserted at the destination index path.
     * Opens a gap at the specified location simulating the final dropped layout.
    UICollectionViewDropIntentInsertAtDestinationIndexPath,
    
     The drop will be placed inside the item at the destination index path (e.g. the item is a container of other items).
     * Will not open a gap. Collection view will highlight the item at the destination index path.
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
