//
//  WPFNormalDragViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/13.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFNormalDragViewController.h"

@interface WPFNormalDragViewController () <UIDragInteractionDelegate, UIDropInteractionDelegate>

@property (nonatomic, strong) UIImageView *dragView;

@end

@implementation WPFNormalDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
}

#pragma mark - Private Method
-(void)_setupUI {
    self.navigationItem.title = @"UIView - Drag & Drop";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self.view addSubview:self.dragView];
    self.dragView.frame = CGRectMake(50, 100, 276, 184);
    [self _addDragAndDropInterraction:self.dragView];
}

- (void)_addDragAndDropInterraction:(UIView *)view {
    // 想让一个控件可被拖动，首先要给该控件添加 UIDragInteraction 对象
    UIDragInteraction *dragInteratcion = [[UIDragInteraction alloc] initWithDelegate:self];
#warning 一定要添加这个代码！！！
    dragInteratcion.enabled = YES;
    [view addInteraction:dragInteratcion];
    
    UIDropInteraction *dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
    
    [view addInteraction:dropInteraction];
}

- (void)_loadImageWithItemProvider:(NSItemProvider *)itemProvider center:(CGPoint)center {
    NSLog(@"_loadImageWithItemProvider:center:");
    [itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = (UIImage *)object;
            self.dragView.image = image;
//            self.dragView.center = center;
        });
    }];
}

#pragma mark - UIDragInteractionDelegate

/**
 开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
 如果返回 nil，则不会发生任何拖拽事件
 */
- (nonnull NSArray<UIDragItem *> *)dragInteraction:(nonnull UIDragInteraction *)interaction itemsForBeginningSession:(nonnull id<UIDragSession>)session {
    NSLog(@"itemsForBeginningSession");
    
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.dragView.image];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
    dragItem.localObject = self.dragView.image;
    return @[dragItem];
}

/**
 对刚开始拖动处于 lift 状态的 item 会有一个 preview 的预览功效，其动画是系统自动生成的，但是需要我们通过该方法提供 preview 的相关信息
 如果返回 nil，就相当于指明该 item 没有预览效果
 如果没有实现该方法，interaction.view 就会生成一个 UITargetedDragPreview
 */
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session {
    
    NSLog(@"previewForLiftingItem");
    
    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:self.dragView.bounds cornerRadius:10];
    previewParameters.backgroundColor = [UIColor redColor];
    UITargetedDragPreview *dragPreview = [[UITargetedDragPreview alloc] initWithView:interaction.view parameters:previewParameters];
    return dragPreview;
}

// 向当前已经存在的拖拽事件中添加一个新的 UIDragItem
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point {
    return nil;
}

// 当 lift 动画准备执行的时候会调用该方法，可以在这个方法里面对拖动的 item 添加动画
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    NSLog(@"willAnimateLiftWithAnimator:session:");
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionEnd) {
            self.dragView.alpha = 0.6;
        }
    }];
}

// 当取消动画准备执行的时候会调用这个方法
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator {
    NSLog(@"item:willAnimateCancelWithAnimator:");
    [animator addAnimations:^{
        
    }];
}

// 当用户完成一次拖拽操作，并且所有相关的动画都执行完毕的时候会调用这个方法，这时候被拖动的item 应该恢复正常的展示外观
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation {
    NSLog(@"session:didEndWithOperation:");
    
}

#pragma mark - UIDropInteractionDelegate

- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    // 可以加载image的控件都可以
    return [session canLoadObjectsOfClass:[UIImage class]];
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    
    // 如果 session.localDragSession 为nil，说明这一操作源自另外一个app，
    UIDropOperation dropOperation = session.localDragSession ? UIDropOperationMove : UIDropOperationCopy;

    UIDropProposal *dropProposal = [[UIDropProposal alloc] initWithDropOperation:dropOperation];
    return dropProposal;
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    // 同样的，在这个方法内部也要判断是否源自本app
    if (!session.localDragSession) {
        CGPoint dropPoint = [session locationInView:interaction.view];
        for (UIDragItem *item in session.items) {
            [self _loadImageWithItemProvider:item.itemProvider center:dropPoint];
        }
    }
}

- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    if (item.localObject) {
        CGPoint dropPoint = defaultPreview.view.center;
        UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:_dragView center:dropPoint];
        return [defaultPreview retargetedPreviewWithTarget:previewTarget];
    } else {
        return nil;
    }
}

// 产生本地动画
- (void)dropInteraction:(UIDropInteraction *)interaction item:(UIDragItem *)item willAnimateDropWithAnimator:(id<UIDragAnimating>)animator {
    
    [animator addAnimations:^{
        _dragView.alpha = 0;
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        _dragView.alpha = 1;
    }];
    
}

#pragma mark - Setters & Getters

- (UIImageView *)dragView {
    if (!_dragView) {
        _dragView = [[UIImageView alloc] init];
        _dragView.image = [UIImage imageNamed:@"image5"];
        _dragView.layer.cornerRadius = 10;
        _dragView.layer.masksToBounds = YES;
        _dragView.userInteractionEnabled = YES;
    }
    return _dragView;
}


@end
