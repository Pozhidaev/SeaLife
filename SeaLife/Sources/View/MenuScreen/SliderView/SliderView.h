//
//  SliderView.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 13.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliderView : UIView

@property (nonatomic) IBOutlet UISlider *slider;

- (void)setTextColor:(UIColor *)textColor;
- (void)setTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
