//
//  WorldViewControllerDelegate.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright (c) 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WorldViewController;
typedef NS_ENUM(NSInteger, WorldCompletionReason);

NS_ASSUME_NONNULL_BEGIN

@protocol WorldViewControllerDelegate <NSObject>

- (void)worldViewController:(WorldViewController *)worldViewController
      didCompleteWithReason:(WorldCompletionReason)reason;

@end

NS_ASSUME_NONNULL_END
