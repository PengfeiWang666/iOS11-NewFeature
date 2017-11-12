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
@property (nonatomic, assign, readonly) Class targetVcClass;

+ (instancetype)featureWithTitleString:(NSString *)titleString targetVcClass:(Class)targetVcClass;

@end
