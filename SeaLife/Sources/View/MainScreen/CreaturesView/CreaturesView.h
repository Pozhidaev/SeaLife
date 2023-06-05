//
//  CreaturesView.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WorldVisualDelegate.h"

@protocol CreatureProtocol;
@class Turn;

NS_ASSUME_NONNULL_BEGIN

@interface CreaturesView : UIView<WorldVisualDelegate>

- (void)play;
- (void)stop;
- (void)reset;
- (void)setAnimationSpeed:(float)animationSpeed;

- (void)createImageViewForCreatures:(NSSet<id<CreatureProtocol>> *)creatures;
- (void)createImageViewForCreature:(id<CreatureProtocol>)creature;
- (void)removeImageViewForCreature:(id<CreatureProtocol>)creature;

- (void)redrawToCellSize:(CGSize)toCellSize;

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^_Nullable)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue;

@end

NS_ASSUME_NONNULL_END
