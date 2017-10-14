//
//  WPFNormalDragViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/13.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFNormalDragViewController.h"

@interface WPFNormalDragViewController () <UIDragInteractionDelegate>

@property (nonatomic, strong) UIView *dragView;

@end

@implementation WPFNormalDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupUI];
}

#pragma mark - Private Method
-(void)_setupUI {
    self.navigationItem.title = @"UIView - Drag & Drop";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self.view addSubview:self.dragView];
    self.dragView.frame = CGRectMake(100, 100, 200, 50);
}

- (void)_addDragInterraction:(UIView *)view {
    // 想让一个控件可被拖动，首先要给该控件添加 UIDragInteraction 对象
    UIDragInteraction *interatcion = [[UIDragInteraction alloc] initWithDelegate:self];
    [view addInteraction:interatcion];
    view.userInteractionEnabled = YES;
    
}

#pragma mark - UIDragInteractionDelegate

/**
 开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
 如果返回 nil，则不会发生任何拖拽事件
 */
- (nonnull NSArray<UIDragItem *> *)dragInteraction:(nonnull UIDragInteraction *)interaction itemsForBeginningSession:(nonnull id<UIDragSession>)session {
    NSLog(@"itemsForBeginningSession");
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.dragView];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
    dragItem.localObject = self.dragView;
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
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 400, 100) cornerRadius:15];
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
    [animator addAnimations:^{
        
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



#pragma mark - Setters & Getters

- (UIView *)dragView {
    if (!_dragView) {
        _dragView = [[UIView alloc] init];
        _dragView.backgroundColor = [UIColor cyanColor];
        [self _addDragInterraction:_dragView];
    }
    return _dragView;
}



@end
