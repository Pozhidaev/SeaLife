//
//  CreatureFactory.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreatureProtocol;
@protocol WorldProtocol;
@protocol WorldVisualDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface CreatureFactory : NSObject

+ (id<CreatureProtocol>)creatureWithClass:(Class)creatureClass
                                    world:(id<WorldProtocol>)world
                           visualDelegate:(id<WorldVisualDelegate>)visualDelegate
                          visualComponent:(UIImageView *)visualComponent;

+ (id<CreatureProtocol>)orcaCreatureForWorld:(id<WorldProtocol>)world
                              visualDelegate:(id<WorldVisualDelegate>)visualDelegate
                             visualComponent:(UIImageView *)visualComponent;

+ (id<CreatureProtocol>)fishCreatureForWorld:(id<WorldProtocol>)world
                              visualDelegate:(id<WorldVisualDelegate>)visualDelegate
                             visualComponent:(UIImageView *)visualComponent;

@end

NS_ASSUME_NONNULL_END
