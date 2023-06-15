//
//  OrcaTurnHelper.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 15.06.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "OrcaTurnHelper.h"
#import "WorldPosition.h"

@implementation OrcaTurnHelper

#pragma mark - TurnHelperProtocol

+ (NSSet<NSValue *> *)possibleTurnPositionsFrom:(struct WorldPosition)position
{
    //return [self leftMoveRule](position); // for testing
    NSSet *movePositions = [self positionsRuleForMove](position);
    NSSet *reproducePositions = [self positionsRuleForReproduce](position);
    NSSet *eatPositions = [self positionsRuleForEat](position);
    return [[movePositions setByAddingObjectsFromSet:reproducePositions] setByAddingObjectsFromSet:eatPositions];
}

#pragma mark - Private

+ (PositionsRuleFunction)positionsRuleForMove {
    return ^NSSet *(struct WorldPosition position){
        NSMutableSet<NSValue *> *positions = [[NSMutableSet alloc] init];
        [positions addObject:[[self upMoveRule](position) anyObject]];
        [positions addObject:[[self downMoveRule](position) anyObject]];
        [positions addObject:[[self leftMoveRule](position) anyObject]];
        [positions addObject:[[self rightMoveRule](position) anyObject]];
        return [positions copy];
    };
}

+ (PositionsRuleFunction)positionsRuleForReproduce
{
    return [self positionsRuleForMove];
}

+ (PositionsRuleFunction)positionsRuleForEat
{
    return [self positionsRuleForMove];
}

@end
