//
//  SliderView.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 13.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "SliderView.h"

NSString * const kSliderValueKey = @"value";
NSString * const kSliderMinimumValueKey = @"minimumValue";
NSString * const kSliderMaximumValueKey = @"maximumValue";

@interface SliderView ()

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *minimumValueLabel;
@property (nonatomic) IBOutlet UILabel *maximumValueLabel;

@end

@implementation SliderView

#pragma mark - Memory

- (instancetype)init
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    assert(nib);
    
    NSArray *viewArray = [nib instantiateWithOwner:self options:nil];
    SliderView *view = [viewArray lastObject];
    assert(view);
    
    return view;
}

#pragma mark - Life Cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.slider addObserver:self
                  forKeyPath:kSliderValueKey
                     options:NSKeyValueObservingOptionInitial
                     context:nil];
    [self.slider addObserver:self
                  forKeyPath:kSliderMinimumValueKey
                     options:NSKeyValueObservingOptionInitial
                     context:nil];
    [self.slider addObserver:self
                  forKeyPath:kSliderMaximumValueKey
                     options:NSKeyValueObservingOptionInitial
                     context:nil];
    
    self.backgroundColor = [UIColor colorNamed:@"SliderView/Background"];
    self.tintColor = [UIColor colorNamed:@"SliderView/Slider"];
}

#pragma mark - Public methods

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    self.slider.tintColor = tintColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.titleLabel.textColor = textColor;
    self.valueLabel.textColor = textColor;
    self.minimumValueLabel.textColor = textColor;
    self.maximumValueLabel.textColor = textColor;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

#pragma mark - Private methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kSliderValueKey]) {
        self.valueLabel.text = [NSString stringWithFormat:@"%.0f", ((UISlider *)object).value];
    }
    if ([keyPath isEqualToString:kSliderMinimumValueKey]) {
        self.minimumValueLabel.text = [NSString stringWithFormat:@"%.0f", ((UISlider *)object).minimumValue];
    }
    if ([keyPath isEqualToString:kSliderMaximumValueKey]) {
        self.maximumValueLabel.text = [NSString stringWithFormat:@"%.0f", ((UISlider *)object).maximumValue];
    }
}

@end
