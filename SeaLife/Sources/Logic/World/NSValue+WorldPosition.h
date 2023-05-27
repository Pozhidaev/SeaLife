//
//  NSValue+WorldPosition.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (WorldPosition)

+ (NSValue *)valueWithWorldPosition:(struct WorldPosition)position;
- (struct WorldPosition)worldPositionValue;

@end

NS_ASSUME_NONNULL_END
