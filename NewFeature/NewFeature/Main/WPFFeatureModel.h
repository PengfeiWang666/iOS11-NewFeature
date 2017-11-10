//
//  WPFFeatureModel.h
//  NewFeature
//
//  Created by Leon on 2017/11/9.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPFFeatureModel : NSObject

@property (nonatomic, copy, readonly) NSString *titleString;
@property (nonatomic, copy, readonly) NSString *selectorString;

+ (instancetype)featureWithTitleString:(NSString *)titleString selectorString:(NSString *)selectorString;

@end
