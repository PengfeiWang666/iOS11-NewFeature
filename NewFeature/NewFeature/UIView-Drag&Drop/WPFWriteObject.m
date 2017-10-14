//
//  WPFWriteObject.m
//  NewFeature
//
//  Created by Leon on 2017/10/13.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "WPFWriteObject.h"

@implementation WPFWriteObject

#pragma mark - NSItemProviderWriting

- (NSArray<NSString *> *)writableTypeIdentifiersForItemProvider {
    return @[@"111", @"222"];
}



//- (NSItemProviderRepresentationVisibility)itemProviderVisibilityForRepresentationWithTypeIdentifier:(NSString *)typeIdentifier {
//    
//}


// 根据类型标识符去加载数据
- (nullable NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier // One of writableTypeIdentifiersForItemProvider
                   forItemProviderCompletionHandler:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionHandler {
    if ([typeIdentifier isEqualToString:@"111"]) {
        
    } else {
        
    }
    // 调接口，请求网络数据
    // BS返回的数据可以通过 completionHandler 中的 NSData 来传递
    return [[NSProgress alloc] init];
    
}
@end
