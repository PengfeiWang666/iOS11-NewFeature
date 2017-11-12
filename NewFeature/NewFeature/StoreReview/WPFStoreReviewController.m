//
//  WPFStoreReviewController.m
//  NewFeature
//
//  Created by Leon on 2017/11/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFStoreReviewController.h"
#import <StoreKit/StoreKit.h>


@interface WPFStoreReviewController ()

@end

@implementation WPFStoreReviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
}

- (void)_setupUI {
    if (@available(iOS 10.3, *)) {
        UIButton *alertModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        alertModeButton.backgroundColor = [UIColor lightGrayColor];
        [alertModeButton setTitle:@"直接弹框" forState:UIControlStateNormal];
        [alertModeButton addTarget:self action:@selector(_alertModeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:alertModeButton];
        alertModeButton.center = self.view.center;
        alertModeButton.bounds = CGRectMake(0, 0, 200, 50);
    } else {
        self.navigationController.title = @"❌❌最低要求10.3系统❌❌";
    }
    
}

#pragma mark - Target Action
- (void)_alertModeAction:(id)sender {
    // available to the App Store by appending the query params "action=write-review" to a product URL.
    // 官方要求一年内最多给用户展示三次求好评
    // 没有网络不行，打不开UI
    // 不能写评语
    [SKStoreReviewController requestReview];
}



@end
