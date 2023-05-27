//
//  Utils.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 21.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)performOnMainThread:(void(^)(void))performBlock
{
    if ([NSThread isMainThread]) {
        performBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            performBlock();
        });
    }
}

@end
