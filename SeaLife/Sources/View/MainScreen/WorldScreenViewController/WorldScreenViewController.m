//
//  WorldScreenViewController.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "WorldScreenViewController.h"

#import "WorldViewController.h"
#import "MenuViewController.h"
#import "WorldViewControllerDelegate.h"
#import "SliderView.h"
#import "WorldCompletionReason.h"
#import "Utils.h"
#import "WorldInfo.h"
#import "WorldPosition.h"

NSInteger kMinCreatureSpeedSliderValue  = 1.0;
NSInteger kMaxCreatureSpeedSliderValue  = 100.0;

NSInteger kMinAnimationSpeedSliderValue = 1.0;
NSInteger kMaxAnimationSpeedSliderValue = 100.0;

NSString * const kSegueIdPresentMenuScreenFullScreen = @"kSegueIdPresentMenuScreenFullScreen";
NSString * const kSegueIdPresentMenuScreenFormSheet = @"kSegueIdPresentMenuScreenFormSheet";
NSString * const kSegueIdWorldViewContainer = @"kSegueIdWorldViewContainer";

@interface WorldScreenViewController ()
{
    BOOL _isPlaying;
    BOOL _configured;
    WorldInfo _worldInfo;
}

@property (nonatomic, weak) IBOutlet WorldViewController *worldViewController;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;

@property (nonatomic, weak) IBOutlet UIView *controlPanel;
@property (nonatomic, weak) IBOutlet UIStackView *speedControlStackView;

@property (nonatomic) UILabel *creatureSpeedValueLabel;
@property (nonatomic) UILabel *animationSpeedValueLabel;
@property (nonatomic) UISlider *creatureSpeedSlider;
@property (nonatomic) UISlider *animationSpeedSlider;

@end

@implementation WorldScreenViewController

#pragma mark - Memory

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _isPlaying = NO;
        _configured = NO;
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"MainScreenBackgroundColor"];
    
    [self setupControlPanel];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.worldViewController setAnimationSpeed:kDefaultAnimationSpeed];
    self.animationSpeedSlider.value = kFastestAnimationSpeed + (kSlowestAnimationSpeed - kDefaultAnimationSpeed);

    float initialCreaturesSpeed = kDefaultCreatureSpeed;
    self.worldViewController.creaturesSpeed = initialCreaturesSpeed;
    self.creatureSpeedSlider.value = kFastestCreatureSpeed + (kSlowestCreatureSpeed - initialCreaturesSpeed);
    
    if (!_configured) {
        [self showMenuFullScreen:YES];
    }
}

#pragma mark - Public

- (IBAction)play:(UIButton *)sender
{
    if (_isPlaying) {
        [self stop];
    } else {
        [self play];
    }
}

- (IBAction)resetWorld:(UIButton *)sender
{
    [self stop];
    [self.worldViewController reset];
}

- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self stop];
    [self showMenuFullScreen:NO];
}

- (void)animationSpeedSliderChanged:(UISlider *)sender
{
    float speed = kSlowestAnimationSpeed - (sender.value - kFastestAnimationSpeed);
    self.animationSpeedValueLabel.text = [NSString stringWithFormat:@"%.1fs", speed];
    [self.worldViewController setAnimationSpeed:speed];
}

- (void)creatureSpeedSliderChanged:(UISlider *)sender
{
    float speed = kSlowestCreatureSpeed - (sender.value - kFastestCreatureSpeed);
    self.creatureSpeedValueLabel.text = [NSString stringWithFormat:@"%.1fs", speed];
    self.worldViewController.creaturesSpeed = speed;
}

#pragma mark - Private methods

- (void)showMenuFullScreen:(BOOL)fullScreen
{
    if (fullScreen) {
        [self performSegueWithIdentifier:kSegueIdPresentMenuScreenFullScreen sender:nil];
    } else {
        [self performSegueWithIdentifier:kSegueIdPresentMenuScreenFormSheet sender:nil];
    }
}

- (void)play
{
    [self.worldViewController play];
    _isPlaying = YES;
    [self updateControls];
}

- (void)stop
{
    [self.worldViewController stop];
    _isPlaying = NO;
    [self updateControls];
}

- (void)updateControls
{
    self.resetButton.enabled = !_isPlaying;
    
    NSString *playTitle = NSLocalizedString(@"Button.Pause", "");
    NSString *pauseTitle = NSLocalizedString(@"Button.Play", "");
    NSString *title = (_isPlaying) ? playTitle : pauseTitle;
    [self.playButton setTitle:title
                     forState:UIControlStateNormal];
}

- (void)setupControlPanel
{
    self.controlPanel.backgroundColor = [UIColor colorNamed:@"MainScreenControlPanelBackgroundColor"];
    self.controlPanel.layer.borderColor = [UIColor colorNamed:@"MainScreenControlPanelFrameColor"].CGColor;
    self.controlPanel.layer.borderWidth = kMainScreenControlPanelViewBorderWidth;
    self.controlPanel.layer.cornerRadius = kDefaultCornerRadius;
    
    [self setupButtons];
    
    [self setupCreatureSpeedSlider];

    [self setupAnimationSpeedSlider];
}

- (void)setupCreatureSpeedSlider
{
    UILabel *creatureSpeedTitleLabel = [[UILabel alloc] init];
    creatureSpeedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    creatureSpeedTitleLabel.text = NSLocalizedString(@"MainScreen.CreaturesSpeed", "");
    creatureSpeedTitleLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];

    self.creatureSpeedValueLabel = [[UILabel alloc] init];
    self.creatureSpeedValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.creatureSpeedValueLabel.text = [NSString stringWithFormat:@"%.1fs", kDefaultCreatureSpeed];
    self.creatureSpeedValueLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];
    
    UILabel *creatureSpeedMinLabel = [[UILabel alloc] init];
    creatureSpeedMinLabel.translatesAutoresizingMaskIntoConstraints = NO;
    creatureSpeedMinLabel.text = [NSString stringWithFormat:@"%.1fs", kSlowestCreatureSpeed];
    creatureSpeedTitleLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];

    UILabel *creatureSpeedMaxLabel = [[UILabel alloc] init];
    creatureSpeedMaxLabel.translatesAutoresizingMaskIntoConstraints = NO;
    creatureSpeedMaxLabel.text = [NSString stringWithFormat:@"%.1fs", kFastestCreatureSpeed];
    creatureSpeedTitleLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];

    self.creatureSpeedSlider = [[UISlider alloc] init];
    self.creatureSpeedSlider.minimumValue = kFastestCreatureSpeed;
    self.creatureSpeedSlider.maximumValue = kSlowestCreatureSpeed;
    self.creatureSpeedSlider.tintColor = [UIColor colorNamed:@"MainScreenSliderTintColor"];
    [self.creatureSpeedSlider addTarget:self action:@selector(creatureSpeedSliderChanged:) forControlEvents:UIControlEventValueChanged];

    UIStackView *creatureSpeedTitleStackView = [[UIStackView alloc] init];
    creatureSpeedTitleStackView.alignment = UIStackViewAlignmentLeading;
    creatureSpeedTitleStackView.distribution = UIStackViewDistributionFillEqually;
    [creatureSpeedTitleStackView addArrangedSubview:creatureSpeedTitleLabel];
    [creatureSpeedTitleStackView addArrangedSubview:self.creatureSpeedValueLabel];
    [self.speedControlStackView addArrangedSubview:creatureSpeedTitleStackView];
    
    UIStackView *creatureSpeedSliderStackView = [[UIStackView alloc] init];
    [creatureSpeedSliderStackView addArrangedSubview:creatureSpeedMinLabel];
    [creatureSpeedSliderStackView addArrangedSubview:self.creatureSpeedSlider];
    [creatureSpeedSliderStackView addArrangedSubview:creatureSpeedMaxLabel];
    [self.speedControlStackView addArrangedSubview:creatureSpeedSliderStackView];
}

- (void)setupAnimationSpeedSlider
{
    UILabel *animationSpeedTitleLabel = [[UILabel alloc] init];
    animationSpeedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    animationSpeedTitleLabel.text = NSLocalizedString(@"MainScreen.AnimationSpeed", "");
    animationSpeedTitleLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];
    
    self.animationSpeedValueLabel = [[UILabel alloc] init];
    self.animationSpeedValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.animationSpeedValueLabel.text = [NSString stringWithFormat:@"%.1fs", kDefaultAnimationSpeed];
    self.animationSpeedValueLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];
    
    UILabel *animationSpeedMinLabel = [[UILabel alloc] init];
    animationSpeedMinLabel.translatesAutoresizingMaskIntoConstraints = NO;
    animationSpeedMinLabel.text = [NSString stringWithFormat:@"%.1fs", kSlowestAnimationSpeed];
    animationSpeedMinLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];
    [self.controlPanel addSubview:animationSpeedMinLabel];

    UILabel *animationSpeedMaxLabel = [[UILabel alloc] init];
    animationSpeedMaxLabel.translatesAutoresizingMaskIntoConstraints = NO;
    animationSpeedMaxLabel.text = [NSString stringWithFormat:@"%.1fs", kFastestAnimationSpeed];
    animationSpeedMaxLabel.textColor = [UIColor colorNamed:@"MainScreenTextColor"];
    [self.controlPanel addSubview:animationSpeedMaxLabel];

    self.animationSpeedSlider = [[UISlider alloc] init];
    self.animationSpeedSlider.minimumValue = kFastestAnimationSpeed;
    self.animationSpeedSlider.maximumValue = kSlowestAnimationSpeed;
    self.animationSpeedSlider.tintColor = [UIColor colorNamed:@"MainScreenSliderTintColor"];
    [self.animationSpeedSlider addTarget:self action:@selector(animationSpeedSliderChanged:) forControlEvents:UIControlEventValueChanged];

    UIStackView *animationSpeedTitleStackView = [[UIStackView alloc] init];
    animationSpeedTitleStackView.alignment = UIStackViewAlignmentLeading;
    animationSpeedTitleStackView.distribution = UIStackViewDistributionFillEqually;
    [animationSpeedTitleStackView addArrangedSubview:animationSpeedTitleLabel];
    [animationSpeedTitleStackView addArrangedSubview:self.animationSpeedValueLabel];
    [self.speedControlStackView addArrangedSubview:animationSpeedTitleStackView];
    
    UIStackView *animationSpeedSliderStackView = [[UIStackView alloc] init];
    [animationSpeedSliderStackView addArrangedSubview:animationSpeedMinLabel];
    [animationSpeedSliderStackView addArrangedSubview:self.animationSpeedSlider];
    [animationSpeedSliderStackView addArrangedSubview:animationSpeedMaxLabel];
    [self.speedControlStackView addArrangedSubview:animationSpeedSliderStackView];
}

- (void)setupButtons
{
    self.playButton.layer.cornerRadius = kDefaultCornerRadius;
    self.resetButton.layer.cornerRadius = kDefaultCornerRadius;
    self.menuButton.layer.cornerRadius = kDefaultCornerRadius;
    
    self.resetButton.backgroundColor = [UIColor colorNamed:@"MainScreenResetButtonColor"];
    self.menuButton.backgroundColor = [UIColor colorNamed:@"MainScreenMenuButtonColor"];
    self.playButton.backgroundColor = [UIColor colorNamed:@"MainScreenPlayButtonColor"];

    [self.resetButton setTitle:NSLocalizedString(@"Button.Reset", "")
                      forState:UIControlStateNormal];
    [self.menuButton setTitle:NSLocalizedString(@"Button.Menu", "")
                      forState:UIControlStateNormal];
    [self.playButton setTitle:NSLocalizedString(@"Button.Play", "")
                     forState:UIControlStateNormal];
}

#pragma mark - WorldViewController delegate

- (void)worldViewController:(WorldViewController *)worldViewController
      didCompleteWithReason:(WorldCompletionReason)reason
{
    [Utils performOnMainThread:^{
        [self stop];
        
        NSString *message;
        switch (reason) {
            case WorldCompletionReasonEmpty: { message = NSLocalizedString(@"World.Finish.Empty", ""); } break;
            case WorldCompletionReasonFull: { message = NSLocalizedString(@"World.Finish.Full", ""); } break;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Button.Ok", "")
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self.worldViewController reset];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }];
}

#pragma mark - Segues

- (IBAction)unwindToMainScreenViewController:(UIStoryboardSegue *)unwindSegue
{
    // if there will be many place for unwinding from, it better to move logic
    // in prepare for segue and compare segue identifiers
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    if ([sourceViewController isMemberOfClass:MenuViewController.class]) {
        WorldInfo worldInfo = ((MenuViewController *)sourceViewController).worldInfo;
        [self.worldViewController createWorldWithInfo:worldInfo];
        self->_configured = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueIdWorldViewContainer]) {
        self.worldViewController = (WorldViewController *)segue.destinationViewController;
        self.worldViewController.delegate = self;
    }
}

@end
