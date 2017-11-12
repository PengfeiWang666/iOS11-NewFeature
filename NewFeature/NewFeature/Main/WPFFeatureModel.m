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
@property (nonatomic, assign) Class targetVcClass;

@end

@implementation WPFFeatureModel

+ (instancetype)featureWithTitleString:(NSString *)titleString targetVcClass:(Class)targetVcClass {
    WPFFeatureModel *model = [[WPFFeatureModel alloc] init];
    if (model) {
        model.titleString = titleString;
        model.targetVcClass = targetVcClass;
    }
    return model;
}

@end
