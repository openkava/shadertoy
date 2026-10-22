#import "AppDelegate.h"

#import "HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.window.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];

    HomeViewController *home = [[HomeViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:home];
    navigation.navigationBar.tintColor = [UIColor colorWithRed:0.45 green:0.78 blue:1.0 alpha:1.0];

    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    navigation.navigationBar.standardAppearance = appearance;
    navigation.navigationBar.scrollEdgeAppearance = appearance;
    navigation.navigationBar.compactAppearance = appearance;

    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
