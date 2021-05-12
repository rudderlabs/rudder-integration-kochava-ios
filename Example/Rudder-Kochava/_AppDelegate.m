//
//  _AppDelegate.m
//  Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>
#import <RudderKochavaFactory.h>
#import <CoreLocation/CoreLocation.h>

@interface _AppDelegate () <CLLocationManagerDelegate>
@property(nonatomic) CLLocationManager *locationManager;
@end

@implementation _AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *WRITE_KEY = @"1sQKy1IwZtHx3WgMS7b9npXzRyq";
    NSString *DATA_PLANE_URL = @"http://193.168.0.123:8080/";
    
    RSConfigBuilder *configBuilder = [[RSConfigBuilder alloc] init];
    [configBuilder withDataPlaneUrl:DATA_PLANE_URL];
    [configBuilder withControlPlaneUrl:@"https://29af06ed8710.ngrok.io"];
    [configBuilder withLoglevel:RSLogLevelVerbose];
    [configBuilder withFactory:[RudderKochavaFactory instance]];
    [configBuilder withTrackLifecycleEvens:false];
    [RSClient getInstance:WRITE_KEY config:[configBuilder build]];
    
    [[RSClient sharedInstance] track:@"Audio Played"
       properties:@{@"browser": @"chrome",
                    @"platform": @"youtube"
       }];
    [[RSClient sharedInstance] track:@"product added"
       properties:@{@"name": @"Bag",
                    @"store": @"amazon"
       }];
    [[RSClient sharedInstance] track:@"add to wishlist"
       properties:@{@"name": @"shoes",
                    @"store": @"myntra"
       }];
    [[RSClient sharedInstance] track:@"Order Completed" properties:@{
            @"revenue" : @100,
            @"orderId" : @"101",
            @"currency" : @"USD",
            @"products" : @[
                    @{
                        @"productId" : @"12##89",
                        @"price" : @12,
                        @"quantity" : @1
                    },
                    @{
                        @"productId" : @"8900",
                        @"price" : @21,
                        @"quantity" : @3
                    }
            ]
        }];
    [[RSClient sharedInstance] screen:@"Welcome"
                                       properties:@{@"name": @"Signup",
                                                    @"path": @"/signup"
                                       }];
    
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

@end
