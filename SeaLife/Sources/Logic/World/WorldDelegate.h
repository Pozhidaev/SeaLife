//
//  WorldDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WorldCompletionReason);

NS_ASSUME_NONNULL_BEGIN

@protocol WorldDelegate <NSObject>

- (void)worldDidFinishedWithReason:(WorldCompletionReason)reason;

@end

NS_ASSUME_NONNULL_END
