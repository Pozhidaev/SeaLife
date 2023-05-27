//
//  UIImage+Creature.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright (c) 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreatureProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Creature)

+ (UIImage * _Nullable)imageFor:(id<CreatureProtocol>)creature;

@end

NS_ASSUME_NONNULL_END
