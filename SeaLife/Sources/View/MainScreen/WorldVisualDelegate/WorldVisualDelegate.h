//
//  WorldVisualDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 17.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreatureProtocol;
@class CreatureAnimator;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol WorldVisualDelegate <NSObject>

- (void)reset;
- (void)setAnimationSpeed:(float)animationSpeed;
- (void)redrawToCellSize:(CGSize)toCellSize;
- (void)addAnimator:(CreatureAnimator *)animator;

- (UIImageView *)createVisualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass;
- (void)placeVisualComponentOfCreature:(id<CreatureProtocol>)creature
                                    at:(struct WorldPosition)position;
- (void)removeVisualComponentOfCreature:(id<CreatureProtocol>)creature;

@end

NS_ASSUME_NONNULL_END

