//
//  WorldVisualDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 17.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Turn;
@protocol CreatureProtocol;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol WorldVisualDelegate <NSObject>

- (void)play;
- (void)stop;
- (void)reset;

- (void)setAnimationSpeed:(float)animationSpeed;

- (UIImageView *)visualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass;

- (void)placeVisualComponent:(UIImageView *)visualComponent
                 forCreature:(id<CreatureProtocol>)creature
                          at:(struct WorldPosition)position;

- (void)removeVisualComponentForCreature:(id<CreatureProtocol>)creature;

- (void)redrawToCellSize:(CGSize)toCellSize;

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^_Nullable)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue;

@end

NS_ASSUME_NONNULL_END

