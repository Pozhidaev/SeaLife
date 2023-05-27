//
//  NSValue+WorldPosition.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "NSValue+WorldPosition.h"
#import "WorldPosition.h"

@implementation NSValue (WorldPosition)

+ (NSValue *)valueWithWorldPosition:(struct WorldPosition)position
{
    return [NSValue value:&position withObjCType:@encode(struct WorldPosition)];
}

- (struct WorldPosition)worldPositionValue
{
    WorldPosition position;
    [self getValue:&position];
    return position;
}

@end
