//
//  CreaturePool.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.06.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreaturePool.h"
#import "CreatureProtocol.h"

@interface CreaturePool()
{
    NSMutableArray *_pool;
    NSLock *_lock;
}

@end

@implementation CreaturePool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _pool = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addCreature:(id<CreatureProtocol>)creature
{
    [_lock lock];
    
    [_pool addObject:creature];
    
    [_lock unlock];
}

- (id<CreatureProtocol>)getCreature
{
    id<CreatureProtocol> creature;

    [_lock lock];

    creature = [_pool lastObject];
    if (creature) {
        [_pool removeObjectAtIndex:[_pool count] - 1];
    }
    
    [_lock unlock];

    return creature;
}

@end

