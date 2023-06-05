//
//  UIImage+Creature.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright (c) 2023 Sergey Pozhidaev. All rights reserved.
//

#import "UIImage+Creature.h"

#import "OrcaCreature.h"
#import "FishCreature.h"
#import "CreatureProtocol.h"

@implementation UIImage (Creature)

+ (UIImage *)imageFor:(Class<CreatureProtocol>)creatureClass
{
    if (creatureClass == OrcaCreature.class) {
        UIImage *image = [UIImage imageNamed:@"Orca"];
        return image;
    } else if (creatureClass == FishCreature.class) {
        UIImage *image = [UIImage imageNamed:@"Fish"];
        return image;
    }
    return nil;
}

@end
