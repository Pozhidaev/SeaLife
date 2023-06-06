//
//  AnimationsFactory.m
//  SeaLife
//
//  d by Sergey Pozhidaev on 15.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "AnimationsFactory.h"
#import "Direction.h"

@implementation AnimationsFactory

+ (NSArray<CAAnimation *> *)emptyAnimationsForLayer:(CALayer *)layer
                                           duration:(float)duration
{
    CATransform3D rotate1Transform = CATransform3DRotate(layer.transform, M_PI_4 * 0.2, 0.0, 0.0, 1.0);
    CABasicAnimation *rotate1Animation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotate1Animation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotate1Animation.toValue = [NSValue valueWithCATransform3D:rotate1Transform];
    rotate1Animation.duration = duration / 3.0;
    
    CATransform3D rotate2Transform = CATransform3DRotate(layer.transform, -M_PI_4 * 0.4, 0.0, 0.0, 1.0);
    CABasicAnimation *rotate2Animation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotate2Animation.fromValue = [NSValue valueWithCATransform3D:rotate1Transform];
    rotate2Animation.toValue = [NSValue valueWithCATransform3D:rotate2Transform];
    rotate2Animation.duration = duration / 3.0;
    
    CABasicAnimation *rotate3Animation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotate3Animation.fromValue = [NSValue valueWithCATransform3D:rotate2Transform];
    rotate3Animation.toValue = [NSValue valueWithCATransform3D:layer.transform];
    rotate3Animation.duration = duration / 3.0;
    
    [rotate3Animation setValue:[NSValue valueWithCATransform3D:layer.transform] forKey:kAnimationFinalTransform];
    return @[rotate1Animation, rotate2Animation, rotate3Animation];
}

+ (NSArray<CAAnimation *> *)moveAnimationsFromDirection:(Direction)fromDirection
                                            toDirection:(Direction)toDirection
                                                  layer:(CALayer *)layer
                                               duration:(float)duration
                                               cellSize:(CGSize)cellSize
{
    NSInteger rotateCount = fromDirection - toDirection;
    CATransform3D rotateTransform = CATransform3DRotate(layer.transform, M_PI_2 * rotateCount, 0.0, 0.0, 1.0);
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:rotateTransform];
    rotateAnimation.duration = duration / 2.0;
    
    CATransform3D moveTransform = CATransform3DTranslate(rotateTransform, cellSize.width, 0.0, 0.0);
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    moveAnimation.fromValue = [NSValue valueWithCATransform3D:rotateTransform];
    moveAnimation.toValue = [NSValue valueWithCATransform3D:moveTransform];
    moveAnimation.duration = duration / 2.0;
    
    [moveAnimation setValue:[NSValue valueWithCATransform3D:rotateTransform] forKey:kAnimationFinalTransform];
    return @[rotateAnimation, moveAnimation];
}

+ (NSArray<CAAnimation *> *)reproduceAnimationsFromDirection:(Direction)fromDirection
                                                 toDirection:(Direction)toDirection
                                                       layer:(CALayer *)layer
                                                    duration:(float)duration
                                                    cellSize:(CGSize)cellSize
{
    NSInteger rotateCount = fromDirection - toDirection;
    CATransform3D rotateTransform = CATransform3DRotate(layer.transform, M_PI_2 * rotateCount, 0.0, 0.0, 1.0);
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:rotateTransform];
    rotateAnimation.duration = duration / 3.0;
    
    CATransform3D moveTransformFov = CATransform3DTranslate(rotateTransform, cellSize.width/2.0, 0.0, 0.0);
    CABasicAnimation *moveAnimationFov = [CABasicAnimation animationWithKeyPath:kTransformKey];
    moveAnimationFov.fromValue = [NSValue valueWithCATransform3D:rotateTransform];
    moveAnimationFov.toValue = [NSValue valueWithCATransform3D:moveTransformFov];
    moveAnimationFov.duration = duration / 3.0;
    
    CABasicAnimation *moveAnimationBack = [CABasicAnimation animationWithKeyPath:kTransformKey];
    moveAnimationBack.fromValue = [NSValue valueWithCATransform3D:moveTransformFov];
    moveAnimationBack.toValue = [NSValue valueWithCATransform3D:rotateTransform];
    moveAnimationBack.duration = duration / 3.0;
    
    [moveAnimationBack setValue:[NSValue valueWithCATransform3D:rotateTransform] forKey:kAnimationFinalTransform];
    return @[rotateAnimation, moveAnimationFov, moveAnimationBack];
}

+ (NSArray<CAAnimation *> *)eatAnimationsFromDirection:(Direction)fromDirection
                                           toDirection:(Direction)toDirection
                                                 layer:(CALayer *)layer
                                              duration:(float)duration
                                              cellSize:(CGSize)cellSize
{
    NSInteger rotateCount = fromDirection - toDirection;
    CATransform3D rotateTransform = CATransform3DRotate(layer.transform, M_PI_2 * rotateCount, 0.0, 0.0, 1.0);
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:rotateTransform];
    rotateAnimation.duration = duration / 2.0;
    
    CATransform3D moveTransform = CATransform3DTranslate(rotateTransform, cellSize.width, 0.0, 0.0);
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    moveAnimation.fromValue = [NSValue valueWithCATransform3D:rotateTransform];
    moveAnimation.toValue = [NSValue valueWithCATransform3D:moveTransform];
    moveAnimation.duration = duration / 2.0;
    
    [moveAnimation setValue:[NSValue valueWithCATransform3D:rotateTransform] forKey:kAnimationFinalTransform];
    return @[rotateAnimation, moveAnimation];
}

+ (NSArray<CAAnimation *> *)bornAnimationsWithDuration:(float)duration
                                              cellSize:(CGSize)cellSize
{
    CATransform3D transform = CATransform3DMakeScale(0.2, 0.2, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    animation.fromValue = [NSValue valueWithCATransform3D:transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = duration;
    
    [animation setValue:[NSValue valueWithCATransform3D:CATransform3DIdentity] forKey:kAnimationFinalTransform];
    return @[animation];
}

+ (NSArray<CAAnimation *> *)dieAnimationsForLayer:(CALayer *)layer
                                         duration:(float)duration
                                         cellSize:(CGSize)cellSize
{
    CATransform3D transform = CATransform3DScale(layer.transform, 0.2, 0.2, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kTransformKey];
    animation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.duration = duration;
    
    [animation setValue:[NSValue valueWithCATransform3D:transform] forKey:kAnimationFinalTransform];
    return @[animation];
}



@end
