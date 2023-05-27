//
//  WorldVisualDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 17.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Turn;
@protocol CreatureProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol WorldVisualDelegate <NSObject>

- (void)play;
- (void)stop;
- (void)reset;

- (void)createImageViewForCreatures:(NSSet<id<CreatureProtocol>> *)creatures;
- (void)createImageViewForCreature:(id<CreatureProtocol>)creature;
- (void)removeImageViewForCreature:(id<CreatureProtocol>)creature;

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^_Nullable)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue;

@end

NS_ASSUME_NONNULL_END

