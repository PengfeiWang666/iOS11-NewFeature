//
//  WPFDragCollectionViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/25.
//  Copyright © 2017年 Leon. All rights reserved.
//

/* Drag 和 Drop 是什么呢？
 * 一种以图形展现的方式数据从一个 app 移动或拷贝到另一个 app（仅限iPad），或者在程序内部进行
 * 充分利用了 iOS11 中新的文件系统，只有在请求数据的时候才会去移动数据，而且保证只传输需要的数据
 * 通过异步的方式进行传输，这样就不会阻塞runloop，从而保证在传输数据的时候用户也有一个顺畅的交互体验
 * 安全性：
   * 拖拽复制的过程不像剪切板那样，而是保证数据只对目标app可见
   * 提供数据源的app可以限制本身的数据源只可在本 app 或者 公司组app 之间有权限使用，当然也可以开放于所有 app，也支持企业用户的管理配置
 * 需要给用户提供 muti-touch 的使用，这一点也是为了支持企业用户的管理配置（比如一个手指选中一段文字，长按其处于lifting状态，另外一个手指选中若干张图片，然后打开邮件，把文字和图片放进邮件，视觉反馈是及时的，动画效果也很棒）
 * dragSession 中的几个概念（过程）
   * Lift ：用户长按 item，item 脱离屏幕
   * Drag ：用户开始拖拽，此时可进行 自定义视图预览、添加其他item添加内容、悬停进行导航（即iPad 中打开别的app）
   * Set Down ：此时用户无非想进行两种操作：取消拖拽 或者 在当前手指离开的位置对 item 进行 drop 操作
   * Data Transfer ：目标app 会向 源app 进行数据请求
 * 这些都是围绕交互这一概念构造的：即类似手势识别器的概念，接收到用户的操作后，进行view层级的改变
 */
// forbiden 比如讲图片放到一个文件夹上，出现这个标志，因为文件夹是只读的

/* Explore the system:看看整个系统都做了什么，传输数据都支持哪些类型
 */


/* 异步加载数据的时候可以用 PlaceHolder 推迟更新数据源，从而保证UI 完全的响应性
 * 使用PlaceHolder 注意事项：（app间拖拽的时候，从A app 拖拽到 B app，确定位置之后，B中还未获取到数据，加载数据的过程中展示占位动画）
   * 1. 不要使用 reloadData，使用 performBatchUpdates: 来替代（因为 reloadData 会重设一切，删除一切 PlaceHolder）
   * 2. 可以使用 collectionView.hasUncommittedUpdates 来判断当前 CollectionView 是否还存在 PlaceHolder
 */

/* Custorming Cell Appearance：重写 DragStateDidChange 方法可以获取这些状态的改变，可以获取到被传进来的新状态
 * none      初始状态
 * lifting   拾取状态，当用户把手指放到cell上，此时cell放大，就是切换到了拾取状态
 * dragging  拖动状态，当用户移动手指开始拖动的时候进入拖动状态，此时透明度减小
 */

#import "WPFDragCollectionViewController.h"
#import "WPFImageCollectionViewCell.h"

static NSString *kImageCellIdentifier = @"kImageCellIdentifier";
static NSString *kItemForTypeIdentifier = @"kItemForTypeIdentifier";

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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemLength = [UIScreen mainScreen].bounds.size.width / 5;
    flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    [flowLayout setSectionInset:UIEdgeInsetsMake(15, 12, 15, 12)];
    self.flowLayout = flowLayout;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[WPFImageCollectionViewCell class] forCellWithReuseIdentifier:kImageCellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.dragDelegate = self;
    _collectionView.dropDelegate = self;
    // 该属性在 iPad 上默认是YES，在 iPhone 默认是 NO
    _collectionView.dragInteractionEnabled = YES;
    /* 这是 CollectionView 独有的属性，因为 其独有的二维网格的布局，因此在重新排序的过程中有时候会发生元素回流了，有时候只是移动到别的位置，不想要这样的效果，就
     * Reordering cadence 重排序节奏 可以调节集合视图重排序的响应性，当它打乱顺序并回流其布局时
     * 默认值是 UICollectionViewReorderingCadenceImmediate. 当开始移动的时候就立即回流集合视图布局，可以理解为实时的重新排序
     * UICollectionViewReorderingCadenceFast 如果你快速移动，CollectionView 不会立即重新布局，只有在停止移动的时候才会重新布局
     */
    _collectionView.reorderingCadence = UICollectionViewReorderingCadenceImmediate;
    
    /* 弹簧加载是一种导航和激活控件的方式，在整个系统中，当处于 dragSession 的时候，只要悬浮在cell上面，就会高亮，然后就会激活
     * UITableView 和 UICollectionView 都可以使用该方式加载，因为他们都遵守 UISpringLoadedInteractionSupporting 协议
     * 当用户在单元格使用弹性加载时，我们要选择 CollectionView 或tableView 中的 item 或cell
     * 使用 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSpringLoadItemAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos); 来自定义也是可以的
     */
    _collectionView.springLoaded = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_collectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WPFImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellIdentifier forIndexPath:indexPath];
    
    cell.targetImageView.image = self.dataSource[indexPath.item];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDragDelegate

/* 提供一个 给定 indexPath 的可进行 drag 操作的 item（类似 hitTest: 方法周到该响应的view ）
 * 如果返回 nil，则不会发生任何拖拽事件
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
//    itemProvider.preferredPresentationSize
//    session.progressIndicatorStyle = UIDropSessionProgressIndicatorStyleNone;
    
    [itemProvider registerItemForTypeIdentifier:kItemForTypeIdentifier loadHandler:^(NSItemProviderCompletionHandler  _Null_unspecified completionHandler, Class  _Null_unspecified __unsafe_unretained expectedValueClass, NSDictionary * _Null_unspecified options) {
        
    }];
    
//    itemProvider registerDataRepresentationForTypeIdentifier:<#(nonnull NSString *)#> visibility:<#(NSItemProviderRepresentationVisibility)#> loadHandler:<#^NSProgress * _Nullable(void (^ _Nonnull completionHandler)(NSData * _Nullable, NSError * _Nullable))loadHandler#>
    
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    self.dragIndexPath = indexPath;
    return @[item];
}

/* 当接收到添加item响应时，会调用该方法向已经存在的drag会话中添加item
 * 如果需要，可以使用提供的点（在集合视图的坐标空间中）进行其他命中测试。
 * 如果该方法未实现，或返回空数组，则不会将任何 item 添加到拖动，手势也会正常的响应
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    return @[item];
}

/* 允许对从取消或返回到 CollectionView 的 item 使用自定义预览
 * UIDragPreviewParameters 有两个属性：visiblePath 和 backgroundColor
 * 如果该方法没有实现或者返回nil，那么整个 cell 将用于预览
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 可以在该方法内使用 贝塞尔曲线 对单元格的一个具体区域进行裁剪
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGFloat previewLength = self.flowLayout.itemSize.width;
    CGRect rect = CGRectMake(0, 0, previewLength, previewLength);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    parameters.backgroundColor = [UIColor clearColor];
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
    UIDragItem *dragItem = coordinator.items.firstObject.dragItem;
    UIImage *image = self.dataSource[self.dragIndexPath.row];
    
    // 正常的加载数据的方法
    if ([dragItem.itemProvider canLoadObjectOfClass:[UIImage class]]) {
        [dragItem.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            // 回调在非主线程
            UIImage *image = (UIImage *)object;
        }];
    }

    // 如果开始拖拽的 indexPath 和 要释放的目标 indexPath 一致，就不做处理
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    // 更新 CollectionView
    [collectionView performBatchUpdates:^{
        // 目标 cell 换位置
        [self.dataSource removeObjectAtIndex:self.dragIndexPath.item];
        [self.dataSource insertObject:image atIndex:destinationIndexPath.item];
        
        [collectionView moveItemAtIndexPath:self.dragIndexPath toIndexPath:destinationIndexPath];
    } completion:^(BOOL finished) {
        
    }];
    
    [coordinator dropItem:dragItem toItemAtIndexPath:destinationIndexPath];
    
    
    
    // 创建 PlaceHolder
//    coordinator
    /* Animate the dragItem to an automatically inserted placeholder item.
     *
     * A placeholder cell will be created for the reuse identifier and inserted at the specified indexPath without requiring a dataSource update.
     *
     * The cellUpdateHandler will be called whenever the placeholder cell becomes visible; -collectionView:cellForItemAtIndexPath: will not be called
     * for the placeholder.
     *
     * Once the dragItem data is available, you can exchange the temporary placeholder cell with the final cell using
     * the placeholder context method -commitInsertionWithDataSourceUpdates:
     *
     * UICollectionViewDropPlaceholderContext also conforms to UIDragAnimating to allow adding alongside animations and completion handlers.
     */
//    - (id<UICollectionViewDropPlaceholderContext>)dropItem:(UIDragItem *)dragItem toPlaceholder:(UICollectionViewDropPlaceholder*)placeholder;
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
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
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
