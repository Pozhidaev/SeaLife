//
//  CreatureFactory.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "CreatureFactory.h"

#import "FishCreature.h"
#import "OrcaCreature.h"
#import "TurnHelper.h"
#import "CreatureProtocol.h"

@implementation CreatureFactory

+ (id<CreatureProtocol>)creatureWithClass:(Class)creatureClass
{
    static dispatch_queue_t timersQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timersQueue = dispatch_queue_create("VisualQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    id<CreatureProtocol> creature = [[creatureClass alloc] initWithTurnHelperClass:[TurnHelper class]];
    [creature setTimerTargetQueue:timersQueue];

    return creature;
}

+ (id<CreatureProtocol>)creatureFromCreature:(id<CreatureProtocol>)creature
{
    return [self creatureWithClass:[creature class]];
}

+ (id<CreatureProtocol>)orcaCreature
{
    return [self creatureWithClass:OrcaCreature.class];
}

+ (id<CreatureProtocol>)fishCreature
{
    return [self creatureWithClass:FishCreature.class];
}

@end
