//
//  CreatureProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TurnHelperProtocol;
@protocol WorldProtocol;
@class AnimationsController;
typedef NS_ENUM(NSInteger, Direction);
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol CreatureProtocol <NSObject>

@property (nonatomic, readonly) NSUUID *uuid;
@property (nonatomic) BOOL busy;
@property (nonatomic) struct WorldPosition position;
@property (nonatomic) Direction direction;

@property (nonatomic, readonly) UIImageView *visualComponent;
@property (nonatomic, readonly) AnimationsController *animator;

- (void)setTimerTargetQueue:(dispatch_queue_t)queue;
- (void)setSpeed:(float)speed;
- (void)start;
- (void)pause;
- (void)stop;

- (instancetype)initWithTurnHelperClass:(Class<TurnHelperProtocol>)turnHelperClass
                                  world:(id<WorldProtocol>)world
                               animator:(AnimationsController *)animator
                        visualComponent:(UIImageView *)visualComponent;

- (NSString *)debugDescriptionIndent:(NSInteger)indent
                             caption:(NSString *)caption;
@end

NS_ASSUME_NONNULL_END
