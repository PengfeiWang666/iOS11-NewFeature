//
//  WPFDragViewController.m
//  NewFeature
//
//  Created by Leon on 2017/10/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFDragViewController.h"

@interface WPFDragViewController () <UIDragInteractionDelegate>

@end

@implementation WPFDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupView];
}

#pragma mark - UIDragInteractionDelegate

//- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session {
//    NSArray *items = [self ]
//}

#pragma mark - Private Method
- (void)_setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 60)];
    dragView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:dragView];
    UIDragInteraction *dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
    
    [dragView addInteraction:dragInteraction];
    
//    NSItemProvider *itemProvider =
//    UIDragItem *dragItem = [UIDragItem alloc] initWithItemProvider:<#(nonnull NSItemProvider *)#>
}

//- (NSArray*)_itemsForSession:(id<UIDragSession>)session {
//    NSItemProvider* provider = [[NSItemProvider alloc] initWithObject:_item];
//    UIDragItem* item = [[UIDragItem alloc] initWithItemProvider:provider];
//    item.localObject = _item;
//
//    return @[item];
//}

@end
