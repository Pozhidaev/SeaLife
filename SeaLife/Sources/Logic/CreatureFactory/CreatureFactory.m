//
//  CreatureFactory.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "CreatureFactory.h"

#import "CreatureProtocol.h"
#import "FishCreature.h"
#import "OrcaCreature.h"
#import "TurnHelper.h"
#import "WorldProtocol.h"
#import "CreatureAnimator.h"

@implementation CreatureFactory

+ (Class<TurnHelperProtocol>)turnHelperClass
{
    return [TurnHelper class];
}

+ (id<CreatureProtocol>)creatureWithClass:(Class)creatureClass
                                    world:(id<WorldProtocol>)world
                                 animator:(CreatureAnimator *)animator
{
    static dispatch_queue_t timersQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timersQueue = dispatch_queue_create("VisualQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    id<CreatureProtocol> creature = [[creatureClass alloc]
                                     initWithTurnHelperClass:[self turnHelperClass]
                                     world:world
                                     animator:animator];

    [creature setTimerTargetQueue:timersQueue];

    return creature;
}

+ (id<CreatureProtocol>)orcaCreatureForWorld:(id<WorldProtocol>)world
                                    animator:(CreatureAnimator *)animator
{
    return [self creatureWithClass:OrcaCreature.class
                             world:world
                          animator:animator];
}

+ (id<CreatureProtocol>)fishCreatureForWorld:(id<WorldProtocol>)world
                                    animator:(CreatureAnimator *)animator
{
    return [self creatureWithClass:FishCreature.class
                             world:world
                          animator:animator];
}

@end
