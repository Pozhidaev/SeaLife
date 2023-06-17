// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#import "Localizable.h"

@interface BundleToken : NSObject
@end

@implementation BundleToken
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"

static NSString* tr(NSString *tableName, NSString *key, NSString *value, ...) {
    NSBundle *bundle = [NSBundle bundleForClass:BundleToken.class];
    NSString *format = [bundle localizedStringForKey:key value:value table:tableName];
    NSLocale *locale = [NSLocale currentLocale];

    va_list args;
    va_start(args, value);
    NSString *result = [[NSString alloc] initWithFormat:format locale:locale arguments:args];
    va_end(args);

    return result;
};
#pragma clang diagnostic pop

@implementation Localizable : NSObject
+ (NSString*)buttonMenu {
    return tr(@"Localizable", @"Button.Menu", @"Menu");
}
+ (NSString*)buttonOk {
    return tr(@"Localizable", @"Button.Ok", @"Ok");
}
+ (NSString*)buttonPause {
    return tr(@"Localizable", @"Button.Pause", @"Pause");
}
+ (NSString*)buttonPlay {
    return tr(@"Localizable", @"Button.Play", @"Play");
}
+ (NSString*)buttonReset {
    return tr(@"Localizable", @"Button.Reset", @"Reset");
}
+ (NSString*)mainScreenAnimationSpeed {
    return tr(@"Localizable", @"MainScreen.AnimationSpeed", @"Animation Speed");
}
+ (NSString*)mainScreenCreaturesSpeed {
    return tr(@"Localizable", @"MainScreen.CreaturesSpeed", @"Creatures Speed");
}
+ (NSString*)menuButtonStart {
    return tr(@"Localizable", @"Menu.Button.Start", @"Start");
}
+ (NSString*)menuFishCountTitle {
    return tr(@"Localizable", @"Menu.FishCount.Title", @"Fish count");
}
+ (NSString*)menuOrcaCountTitle {
    return tr(@"Localizable", @"Menu.OrcaCount.Title", @"Orca count");
}
+ (NSString*)menuXSizeTitle {
    return tr(@"Localizable", @"Menu.XSize.Title", @"Horizontal size");
}
+ (NSString*)menuYSizeTitle {
    return tr(@"Localizable", @"Menu.YSize.Title", @"Vertical Size");
}
+ (NSString*)timeSeconds {
    return tr(@"Localizable", @"Time.Seconds", @"sec");
}
+ (NSString*)worldFinishEmpty {
    return tr(@"Localizable", @"World.Finish.Empty", @"World become empty");
}
+ (NSString*)worldFinishFull {
    return tr(@"Localizable", @"World.Finish.Full", @"World become full with no move");
}
@end

