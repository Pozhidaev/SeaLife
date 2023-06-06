//
//  AnimationsFactory.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 15.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Direction);

NS_ASSUME_NONNULL_BEGIN

@interface AnimationsFactory : NSObject

+ (NSArray<CAAnimation *> *)emptyAnimationsForLayer:(CALayer *)layer
                                           duration:(float)duration;

+ (NSArray<CAAnimation *> *)moveAnimationsFromDirection:(Direction)fromDirection
                                            toDirection:(Direction)toDirection
                                                  layer:(CALayer *)layer
                                               duration:(float)duration
                                               cellSize:(CGSize)cellSize;

+ (NSArray<CAAnimation *> *)reproduceAnimationsFromDirection:(Direction)fromDirection
                                                 toDirection:(Direction)toDirection
                                                       layer:(CALayer *)layer
                                                    duration:(float)duration
                                                    cellSize:(CGSize)cellSize;

+ (NSArray<CAAnimation *> *)eatAnimationsFromDirection:(Direction)fromDirection
                                           toDirection:(Direction)toDirection
                                                 layer:(CALayer *)layer
                                              duration:(float)duration
                                              cellSize:(CGSize)cellSize;

+ (NSArray<CAAnimation *> *)bornAnimationsWithDuration:(float)duration
                                              cellSize:(CGSize)cellSize;

+ (NSArray<CAAnimation *> *)dieAnimationsForLayer:(CALayer *)layer
                                         duration:(float)duration
                                         cellSize:(CGSize)cellSize;

@end

NS_ASSUME_NONNULL_END
