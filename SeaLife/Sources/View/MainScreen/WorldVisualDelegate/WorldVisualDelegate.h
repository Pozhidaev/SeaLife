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

- (void)addCreature:(id<CreatureProtocol>)creature at:(struct WorldPosition)position;
- (void)removeCreature:(id<CreatureProtocol>)creature;

@end

NS_ASSUME_NONNULL_END

