//
//  WorldCell.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "WorldCell.h"
#import "WorldPosition.h"

@interface WorldCell ()

@property(nonatomic, readwrite) struct WorldPosition position;

@end

@implementation WorldCell

- (instancetype)initWithPosition:(struct WorldPosition)position
{
    self = [super init];
    if (self) {
        self.position = position;
    }
    return self;
}

- (NSString *)debugDescription
{
    NSMutableString *description = [[NSMutableString alloc] init];

    [description appendFormat:@"position { x:%li y:%li } ", (long)self.position.x, (long)self.position.y];
    [description appendFormat:@"creature :: %@\n", self.creature];

    return [description copy];
}

@end
