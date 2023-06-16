//
//  CreaturePool.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.06.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface CreaturePool : NSObject

- (void)addCreature:(id<CreatureProtocol>)creature;
- (id<CreatureProtocol> _Nullable)getCreature;

@end

NS_ASSUME_NONNULL_END
