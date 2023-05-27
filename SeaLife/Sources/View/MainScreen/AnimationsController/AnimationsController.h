//
//  AnimationsController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Turn;

NS_ASSUME_NONNULL_BEGIN

@interface AnimationsController : NSObject

@property (nonatomic) CGSize cellSize;
@property (nonatomic) float animationSpeed;

- (void)play;
- (void)stop;
- (void)reset;
- (void)removeAllAnimationsForCreatureUUID:(NSUUID *)creatureUUID;
- (void)performAnimationsForTurn:(Turn *)turn
                        forLayer:(CALayer *)layer
                  withCompletion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
