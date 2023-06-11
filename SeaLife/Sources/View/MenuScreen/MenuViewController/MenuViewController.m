//
//  MenuViewController.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "MenuViewController.h"

#import "SliderView.h"
#import "WorldProtocol.h"
#import "WorldInfo.h"

NSString *const kUnwindToMainScreenSegueIdentifier = @"kUnwindToMainScreenSegueIdentifier";

@interface MenuViewController ()
{
    NSInteger _fishCount;
    NSInteger _orcaCount;
    NSInteger _horizontalSize;
    NSInteger _verticalSize;
    
    NSArray *compactHeightConstraints;
    NSArray *regularConstraints;
}

@property (nonatomic) SliderView *fishCountView;
@property (nonatomic) SliderView *orcaCountView;
@property (nonatomic) SliderView *horizontalCountView;
@property (nonatomic) SliderView *verticalCountView;

@property (nonatomic) UIButton *startButton;

@end

@implementation MenuViewController

#pragma mark - Life cycle

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = kDefaultUIElementSpace;
    [view addSubview:stackView];

    self.fishCountView = [[SliderView alloc] init];
    self.orcaCountView = [[SliderView alloc] init];
    self.horizontalCountView = [[SliderView alloc] init];
    self.verticalCountView = [[SliderView alloc] init];

    [stackView addArrangedSubview:self.fishCountView];
    [stackView addArrangedSubview:self.orcaCountView];
    [stackView addArrangedSubview:self.horizontalCountView];
    [stackView addArrangedSubview:self.verticalCountView];
    
    self.startButton = [[UIButton alloc] init];
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.startButton];

    CGFloat regularVerticalMultiplier = 3.0;
    if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
        regularVerticalMultiplier = 10.0;
    }
    regularConstraints = @[
        [stackView.topAnchor constraintEqualToSystemSpacingBelowAnchor:view.safeAreaLayoutGuide.topAnchor multiplier:regularVerticalMultiplier],
        [stackView.widthAnchor constraintEqualToAnchor:view.readableContentGuide.widthAnchor],
        [stackView.centerXAnchor constraintEqualToAnchor:view.readableContentGuide.centerXAnchor],

        [self.startButton.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [view.safeAreaLayoutGuide.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:self.startButton.bottomAnchor multiplier:regularVerticalMultiplier],
    ];

    compactHeightConstraints = @[
        [stackView.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.startButton.leadingAnchor constant:-kDefaultUIElementSpace],
        [stackView.bottomAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.bottomAnchor],
    
        [self.startButton.trailingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.trailingAnchor],
        [self.startButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor]
    ];

    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [NSLayoutConstraint activateConstraints:compactHeightConstraints];
    } else {
        [NSLayoutConstraint activateConstraints:regularConstraints];
    }
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorNamed:@"Menu/Background"];
    self.view.layer.borderWidth = kMenuViewBorderWidth;
    self.view.layer.borderColor = [UIColor colorNamed:@"Menu/Frame"].CGColor;
    self.view.layer.cornerRadius = kMenuViewCornerRadius;

    [self setupButtons];
    
    [self setupSliderViews];
    
    _fishCount = kDefaultfishCount;
    _orcaCount = kDefaultOrcaCount;
    _horizontalSize = kHorizontalWorldSizeDefault;
    _verticalSize = kVerticalWorldSizeDefault;
    
    [self recalculateCreatures];
    [self updateSliders];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.onDismiss) {
        self.onDismiss();
    }
}

#pragma mark - Actions

- (IBAction)sliderValueChange:(UISlider *)sender
{
    if (sender == self.fishCountView.slider) {
        [self setValidFishValueFromValue:sender.value];
    } else if (sender == self.orcaCountView.slider) {
        [self setValidOrcaValueFromValue:sender.value];
    } else if (sender == self.horizontalCountView.slider) {
        [self setValidHorizontalSizeFromValue:sender.value];
    } else if (sender == self.verticalCountView.slider) {
        [self setValidVerticalSizeFromValue:sender.value];
    }
    
    [self recalculateCreatures];
    [self updateSliders];
}

- (IBAction)startButtonPressed:(UIButton *)sender
{
    WorldInfo worldInfo = (WorldInfo){
        .fishCount = _fishCount,
        .orcaCount = _orcaCount,
        .horizontalSize = _horizontalSize,
        .verticalSize = _verticalSize
    };
    self.worldInfo = worldInfo;
    [self performSegueWithIdentifier:kUnwindToMainScreenSegueIdentifier sender:nil];
}

#pragma mark - Private

- (void)setupSliderViews
{
    [self.fishCountView setTitle:Localizable.menuFishCountTitle];
    [self.orcaCountView setTitle:Localizable.menuOrcaCountTitle];
    [self.horizontalCountView setTitle:Localizable.menuXSizeTitle];
    [self.verticalCountView setTitle:Localizable.menuYSizeTitle];
    
    self.fishCountView.layer.cornerRadius = kDefaultCornerRadius;
    self.orcaCountView.layer.cornerRadius = kDefaultCornerRadius;
    self.horizontalCountView.layer.cornerRadius = kDefaultCornerRadius;
    self.verticalCountView.layer.cornerRadius = kDefaultCornerRadius;

    [self.fishCountView.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.orcaCountView.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.horizontalCountView.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.verticalCountView.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];

    self.fishCountView.slider.minimumValue = 0;
    self.orcaCountView.slider.minimumValue = 0;

    self.horizontalCountView.slider.minimumValue = kHorizontalWorldSizeMin;
    self.horizontalCountView.slider.maximumValue = kHorizontalWorldSizeMax;
    self.verticalCountView.slider.minimumValue = kVerticalWorldSizeMin;
    self.verticalCountView.slider.maximumValue = kVerticalWorldSizeMax;
}

- (void)setupButtons
{
    self.startButton.layer.cornerRadius = kDefaultUIElementSpace;
    self.startButton.backgroundColor =  [UIColor colorNamed:@"Menu/StartButtonBackground"];
    self.startButton.contentEdgeInsets = UIEdgeInsetsMake(kDefaultUIElementSpace * 2.0,
                                                          kDefaultUIElementSpace * 4.0,
                                                          kDefaultUIElementSpace * 2.0,
                                                          kDefaultUIElementSpace * 4.0);
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorNamed:@"Menu/StartButtonTitle"],
                                 NSFontAttributeName: [UIFont systemFontOfSize: 24.0]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Menu.Button.Start", "")
                                                                          attributes:attributes];
    [self.startButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)recalculateCreatures
{
    NSInteger worldArea = _horizontalSize * _verticalSize;
    self.fishCountView.slider.maximumValue = worldArea;
    self.orcaCountView.slider.maximumValue = worldArea;

    NSInteger totalCreaturesCount = _fishCount + _orcaCount;
    if (totalCreaturesCount > worldArea) {
        float ratio = (float)_fishCount / (float)_orcaCount;

        _orcaCount = (float)worldArea / (1 + (floorf(ratio * 100)/100) );
        _fishCount = worldArea - _orcaCount;
    }
}

- (void)setValidFishValueFromValue:(NSInteger)value
{
    NSInteger worldArea = _horizontalSize * _verticalSize;
    
    NSInteger fishCount = MIN(value, worldArea);
    NSInteger orcaCount = _orcaCount;
    
    NSInteger totalCount = fishCount + orcaCount;
    if (totalCount > worldArea) {
        orcaCount = worldArea - fishCount;
    }
    
    _orcaCount = orcaCount;
    _fishCount = fishCount;
}

- (void)setValidOrcaValueFromValue:(NSInteger)value
{
    NSInteger worldArea = _horizontalSize * _verticalSize;

    NSInteger fishCount = _fishCount;
    NSInteger orcaCount = MIN(value, worldArea);

    NSInteger totalCount = fishCount + orcaCount;
    if (totalCount > worldArea) {
        fishCount = worldArea - orcaCount;
    }

    _orcaCount = orcaCount;
    _fishCount = fishCount;
}

- (void)setValidHorizontalSizeFromValue:(float)value
{
    [self setValidSizesFromHorizontalSize:value
                             verticalSize:value * kWorldSizeAspectRatio];
}

- (void)setValidVerticalSizeFromValue:(float)value
{
    [self setValidSizesFromHorizontalSize:value / kWorldSizeAspectRatio
                             verticalSize:value];
}

- (void)setValidSizesFromHorizontalSize:(float)horizontalSize
                           verticalSize:(float)verticalSize
{
    float tVertical = verticalSize;
    float tHorizontal = horizontalSize;
    
    tVertical = MIN(kVerticalWorldSizeMax, tHorizontal * kWorldSizeAspectRatio);
    tHorizontal = MIN(kHorizontalWorldSizeMax, tVertical / kWorldSizeAspectRatio);
    tVertical = MAX(kVerticalWorldSizeMin, tHorizontal * kWorldSizeAspectRatio);
    tHorizontal = MAX(kHorizontalWorldSizeMin, tVertical / kWorldSizeAspectRatio);
    
    _verticalSize = (NSInteger)lroundf(tVertical);
    _horizontalSize = (NSInteger)lroundf(tHorizontal);
}

- (void)updateSliders
{
    self.fishCountView.slider.value = _fishCount;
    self.orcaCountView.slider.value = _orcaCount;
    self.horizontalCountView.slider.value = _horizontalSize;
    self.verticalCountView.slider.value = _verticalSize;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if (newCollection.verticalSizeClass != self.traitCollection.verticalSizeClass) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            [NSLayoutConstraint deactivateConstraints:regularConstraints];
            [NSLayoutConstraint activateConstraints:compactHeightConstraints];
        } else {
            [NSLayoutConstraint deactivateConstraints:compactHeightConstraints];
            [NSLayoutConstraint activateConstraints:regularConstraints];
        }
   }
}

@end
