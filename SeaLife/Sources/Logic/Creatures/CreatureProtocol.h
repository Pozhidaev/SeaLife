//
//  CreatureProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WorldVisualDelegate;
@protocol TurnHelperProtocol;
@protocol WorldProtocol;
typedef NS_ENUM(NSInteger, Direction);
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol CreatureProtocol <NSObject>

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
