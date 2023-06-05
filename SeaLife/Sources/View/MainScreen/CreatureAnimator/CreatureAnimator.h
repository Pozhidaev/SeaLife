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

@interface CreatureAnimator : NSObject

@property (nonatomic) CGSize cellSize;
@property (nonatomic) float animationSpeed;

- (void)play;
- (void)pause;
- (void)reset;

- (void)removeAllAnimationsForCreatureUUID:(NSUUID *)creatureUUID;

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue;

@end

NS_ASSUME_NONNULL_END
