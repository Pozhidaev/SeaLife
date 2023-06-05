//
//  WorldVisualDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 17.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreatureProtocol;
@class AnimationsController;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol WorldVisualDelegate <NSObject>

- (void)reset;

- (void)setAnimationSpeed:(float)animationSpeed;

- (UIImageView *)visualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass;

- (void)placeVisualComponent:(UIImageView *)visualComponent
                          at:(struct WorldPosition)position;

- (void)redrawToCellSize:(CGSize)toCellSize;

- (void)addAnimator:(AnimationsController *)animator;

@end

NS_ASSUME_NONNULL_END

