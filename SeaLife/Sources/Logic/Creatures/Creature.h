//
//  Creature.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CreatureProtocol.h"

@protocol WorldProtocol;
@protocol WorldVisualDelegate;
@protocol TurnHelperProtocol;
@class World;
@class Turn;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface Creature : NSObject<CreatureProtocol>

@property (nonatomic, readonly) NSUUID *uuid;
@property (nonatomic) BOOL busy;
@property (nonatomic) struct WorldPosition position;
@property (nonatomic) Direction direction;

- (void)setTimerTargetQueue:(dispatch_queue_t)queue;
- (void)setSpeed:(float)speed;
- (void)start;
- (void)pause;
- (void)stop;

- (instancetype)initWithTurnHelperClass:(Class<TurnHelperProtocol>)turnHelperClass
                                  world:(id<WorldProtocol>)world
                         visualDelegate:(id<WorldVisualDelegate>)visualDelegate;

- (NSString *)debugDescriptionIndent:(NSInteger)indent
                             caption:(NSString *)caption;

@end

NS_ASSUME_NONNULL_END
