//
//  WPFChangeAppIconViewController.m
//  NewFeature
//
//  Created by Leon on 2017/11/10.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFChangeAppIconViewController.h"

@interface WPFChangeAppIconViewController ()

@end

@implementation WPFChangeAppIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
}

- (void)_setupUI {
    if (@available(iOS 10.3, *)) {
        UIButton *changeIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
        changeIconButton.backgroundColor = [UIColor lightGrayColor];
        [changeIconButton setTitle:@"开始换头像！" forState:UIControlStateNormal];
        [changeIconButton addTarget:self action:@selector(_changeIconAction:) forControlEvents:UIControlEventTouchUpInside];
        changeIconButton.center = self.view.center;
        changeIconButton.bounds = CGRectMake(0, 0, 200, 60);
        [self.view addSubview:changeIconButton];
    } else {
        self.navigationController.title = @"❌❌最低要求10.3系统❌❌";
    }
    
}

#pragma mark - Target Action
- (void)_changeIconAction:(id)sender {
    if ([[UIApplication sharedApplication].alternateIconName isEqualToString:@"icon1"]) {
        [[UIApplication sharedApplication] setAlternateIconName:@"icon2" completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"set AlternateIcon error: %@",error.description);
            }
        }];
    } else {
        
        [[UIApplication sharedApplication] setAlternateIconName:@"icon1" completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"set AlternateIcon error: %@",error.description);
            }
        }];
    }
}



@end
