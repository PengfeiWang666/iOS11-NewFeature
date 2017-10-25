//
//  WPFImageTableViewCell.m
//  NewFeature
//
//  Created by Leon on 2017/10/12.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFImageTableViewCell.h"



@implementation WPFImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupUI];
    }
    return self;
}

- (void)_setupUI {
    [self.contentView addSubview:self.targetImageView];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat margin = 20;
    self.targetImageView.frame = CGRectMake(margin, margin, self.bounds.size.width-2*margin, self.bounds.size.height-2*margin);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters && getters
- (UIImageView *)targetImageView {
    if (!_targetImageView) {
        _targetImageView = [[UIImageView alloc] init];
        _targetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _targetImageView.layer.cornerRadius = 10;
        _targetImageView.clipsToBounds = YES;
    }
    return _targetImageView;
}

@end
