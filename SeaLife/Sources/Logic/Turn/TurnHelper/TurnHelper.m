//
//  TurnHelper.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "TurnHelper.h"

#import "WorldCell.h"
#import "CreatureFactory.h"
#import "FishCreature.h"
#import "CreatureProtocol.h"
#import "WorldPosition.h"
#import "NSValue+WorldPosition.h"

@implementation TurnHelper

#pragma mark - Cells

+ (WorldCell *)cellFromCells:(NSSet<WorldCell *> *)cells
          withFilterFunction:(BOOL(^)(WorldCell *cell))filterRule
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> *bindings) {
        return filterRule((WorldCell *)evaluatedObject);
    }];
    NSSet *validCells = [cells filteredSetUsingPredicate:predicate];
    if (validCells.count == 0) {
        return nil;
    }
    NSInteger randomIndex = (NSInteger)arc4random_uniform((int)validCells.count);
    WorldCell *targetCell = [[validCells allObjects] objectAtIndex:randomIndex];
    return targetCell;
}

#pragma mark - Position Rules

+ (PositionsRuleFunction)upMoveRule {
    return ^NSSet *(struct WorldPosition position){
        NSValue *positionValue = [NSValue valueWithWorldPosition:(struct WorldPosition){.x = position.x, .y = position.y - 1}];
        return [NSSet setWithObject:positionValue];
    };
}

+ (PositionsRuleFunction)downMoveRule {
    return ^NSSet *(struct WorldPosition position){
        NSValue *positionValue = [NSValue valueWithWorldPosition:(struct WorldPosition){.x = position.x, .y = position.y + 1}];
        return [NSSet setWithObject:positionValue];
    };
}

+ (PositionsRuleFunction)leftMoveRule {
    return ^NSSet *(struct WorldPosition position){
        NSValue *positionValue = [NSValue valueWithWorldPosition:(struct WorldPosition){.x = position.x - 1, .y = position.y}];
        return [NSSet setWithObject:positionValue];
    };
}

+ (PositionsRuleFunction)rightMoveRule {
    return ^NSSet *(struct WorldPosition position){
        NSValue *positionValue = [NSValue valueWithWorldPosition:(struct WorldPosition){.x = position.x + 1, .y = position.y}];
        return [NSSet setWithObject:positionValue];
    };
}

+ (NSSet<NSValue *> *)possibleTurnPositionsFrom:(struct WorldPosition)position
{
    assert(false); // must be overrided
}

#pragma mark - Filter Rules

+ (MoveRuleFunction)moveRuleFunction
{
    return ^BOOL(WorldCell *cell){
        return cell.creature == nil;
    };
}

+ (MoveRuleFunction)eatingRuleFunction
{
    return ^BOOL(WorldCell *cell){
        return cell.creature.class == FishCreature.class && cell.creature.live == YES;
    };
}

+ (MoveRuleFunction)reproduceRuleFunction
{
    return ^BOOL(WorldCell *cell){
        return cell.creature == nil;
    };
}

@end
