//
//  CreatureProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CreatureAnimator;
@class CreatureDeps;
typedef NS_ENUM(NSInteger, Direction);
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol CreatureProtocol <NSObject>

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
