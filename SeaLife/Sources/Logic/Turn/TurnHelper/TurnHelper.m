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
        return cell.creature.class == FishCreature.class;
    };
}

+ (MoveRuleFunction)reproduceRuleFunction
{
    return ^BOOL(WorldCell *cell){
        return cell.creature == nil;
    };
}

@end
