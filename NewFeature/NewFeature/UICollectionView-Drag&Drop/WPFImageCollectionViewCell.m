//
//  WPFImageCollectionViewCell.m
//  NewFeature
//
//  Created by Leon on 2017/10/25.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFImageCollectionViewCell.h"

@implementation WPFImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupUI];
    }
    return self;
}

- (void)_setupUI {
    [self.contentView addSubview:self.targetImageView];
    self.targetImageView.frame = self.contentView.bounds;
}

#pragma mark - setters && getters
- (UIImageView *)targetImageView {
    if (!_targetImageView) {
        _targetImageView = [[UIImageView alloc] init];
        _targetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _targetImageView.layer.cornerRadius = 5;
        _targetImageView.clipsToBounds = YES;
    }
    return _targetImageView;
}

@end
