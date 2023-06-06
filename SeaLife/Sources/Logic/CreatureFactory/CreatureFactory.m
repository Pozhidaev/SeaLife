//
//  CreatureFactory.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "CreatureFactory.h"

#import "CreatureProtocol.h"
#import "CreatureDeps.h"
#import "FishCreature.h"
#import "OrcaCreature.h"
#import "TurnHelper.h"
#import "TurnHelperProtocol.h"

@implementation CreatureFactory

+ (Class<TurnHelperProtocol>)turnHelperClassForCreatureClass:(Class<CreatureProtocol>)creatureClass
{
    return [TurnHelper class];
}

+ (id<CreatureProtocol>)creatureWithClass:(Class<CreatureProtocol>)creatureClass
                                     deps:(CreatureDeps *)deps
{
    static dispatch_queue_t timersQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timersQueue = dispatch_queue_create("CreatureTimerParentQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    deps.turnHelperClass = [self turnHelperClassForCreatureClass:creatureClass];
    
    id<CreatureProtocol> creature = [[creatureClass.self alloc] initWithDeps:deps];

    [creature setTimerTargetQueue:timersQueue];

    return creature;
}

+ (id<CreatureProtocol>)orcaCreatureWithDeps:(CreatureDeps *)deps
{
    return [self creatureWithClass:OrcaCreature.class
                              deps:deps];
}

+ (id<CreatureProtocol>)fishCreatureWithDeps:(CreatureDeps *)deps
{
    return [self creatureWithClass:FishCreature.class
                              deps:deps];
}

@end
