//
//  WPFFeatureModel.m
//  NewFeature
//
//  Created by Leon on 2017/11/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFFeatureModel.h"

@interface WPFFeatureModel ()

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *selectorString;

@end

@implementation WPFFeatureModel

+ (instancetype)featureWithTitleString:(NSString *)titleString selectorString:(NSString *)selectorString {
    WPFFeatureModel *model = [[WPFFeatureModel alloc] init];
    if (model) {
        model.titleString = titleString;
        model.selectorString = selectorString;
    }
    return model;
}

@end
