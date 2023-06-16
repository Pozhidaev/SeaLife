//
//  Creature.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CreatureProtocol.h"

@class CreatureDeps;
@class CreatureAnimator;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface Creature : NSObject<CreatureProtocol>

@property (nonatomic, readonly) NSUUID *uuid;
@property (nonatomic) BOOL busy;
@property (nonatomic) struct WorldPosition position;
@property (nonatomic) Direction direction;

@property (nonatomic, readonly) CreatureAnimator *animator;

- (void)setSpeed:(float)speed;
- (void)start;
- (void)pause;
- (void)stop;

- (instancetype)initWithDeps:(CreatureDeps *)deps;

- (NSString *)debugDescriptionIndent:(NSInteger)indent
                             caption:(NSString *)caption;

@end

NS_ASSUME_NONNULL_END
