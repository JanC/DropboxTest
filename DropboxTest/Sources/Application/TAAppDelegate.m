//
//  TAAppDelegate.m
//  DropboxTest
//
//  Created by Jan on 17/05/14.
//  Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TAListViewController.h"
#import "TAPeristentStack.h"
#import "TASyncEngine.h"

@interface TAAppDelegate ()



@property(nonatomic, strong, readonly) NSURL *modelURL;
@property(nonatomic, strong, readonly) NSURL *storeURL;

@property(nonatomic, strong, readwrite) TAPeristentStack *peristentStack;
@end

@implementation TAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"g34d6pgzsauvw23" secret:@"jxxj83bakgoxqsf"];
    [DBAccountManager setSharedManager:accountManager];

    self.peristentStack = [[TAPeristentStack alloc] initWithModelURL:self.modelURL storeURL:self.storeURL];

    [[TASyncEngine sharedEngine] startEngine];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TAListViewController alloc] init]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if ( account )
    {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

#pragma mark - Core Data

-(NSURL *)storeURL
{
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:YES
                                                                          error:NULL];
    return  [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSURL *)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
}

@end
