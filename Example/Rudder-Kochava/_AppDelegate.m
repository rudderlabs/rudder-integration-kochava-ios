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
#import <RudderKochavaIntegration.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface _AppDelegate () <CLLocationManagerDelegate>
@property(nonatomic) CLLocationManager *locationManager;
@end

@implementation _AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
        NSString *WRITE_KEY = @"1rQzF38dtwHk7n6A196Wmo5pPCw";
        NSString *DATA_PLANE_URL = @"https://90bfd4953624.ngrok.io";
        
        // register for push notifications
    //    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //    center.delegate = self;
    //    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
    //                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //        if (granted)
    //        {
    //            dispatch_async(dispatch_get_main_queue(), ^(void) {
    //                [[UIApplication sharedApplication] registerForRemoteNotifications];
    //            });
    //        }
    //    }];
        
        
        RSConfigBuilder *configBuilder = [[RSConfigBuilder alloc] init];
        [configBuilder withDataPlaneUrl:DATA_PLANE_URL];
        [configBuilder withControlPlaneUrl:@"https://api.dev.rudderlabs.com"];
        [configBuilder withLoglevel:RSLogLevelVerbose];
        [configBuilder withFactory:[RudderKochavaFactory instance]];
        [configBuilder withTrackLifecycleEvens:false];
        [RSClient getInstance:WRITE_KEY config:[configBuilder build]];
        
        //1. Send custom track/screen call with custom properties (date/string/numbers/boolean/array/object)
        
        
        //date (job_id=1)
        NSDate *date= [NSDate date];
        [[RSClient sharedInstance] track:@"Track 1" properties:@{
            @"val" : date
        }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 1" properties:@{
    //        @"val" : date
    //    }];
        
        //string
    //    [[RSClient sharedInstance] track:@"Track 2" properties:@{
    //        @"val" : @"this is track 2"
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 2" properties:@{
    //        @"val" : @"this is screen 2"
    //    }];
        
    //    //integer
    //    [[RSClient sharedInstance] track:@"Track 3" properties:@{
    //        @"val" : @1000
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 3" properties:@{
    //        @"val" : @2000
    //    }];
        
        //double
    //    [[RSClient sharedInstance] track:@"Track 4" properties:@{
    //        @"val" : @334.89
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 4" properties:@{
    //        @"val" : @890.77
    //    }];
    //
    //    //boolean
    //    [[RSClient sharedInstance] track:@"Track 5" properties:@{
    //        @"val" : @YES
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 5" properties:@{
    //        @"val" : @NO
    //    }];
        
        //array
    //    [[RSClient sharedInstance] track:@"Track 6" properties:@{
    //        @"val" : @[@"red", @"blue"]
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 6" properties:@{
    //        @"val" : @[@1, @3]
    //    }];
    //
        //object (job_id=7)
    //    [[RSClient sharedInstance] track:@"Track 7" properties:@{
    //        @"val" : @{
    //                @"id": @"id_9##789"
    //        }
    //    }];
    //
    //    [[RSClient sharedInstance] screen:@"screen 7" properties:@{
    //        @"val" : @{
    //                @"id": @"id_9##790"
    //        }
    //    }];
        
        
        //2. Send "Product Added"/"Add To Wishlist"/Checkout Started"/"Order Completed"/"Product Reviewed"/"Products Searched" event with expected standard properties, some custom (object/number/boolean) property and unexpected standard  property
        
        //product added
        //build an info object and convert to json
    //    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];

    //    NSMutableDictionary *mutableDictionary = [myDictionary mutableCopy];
    //    NSData *data = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
    //    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];


    //    [[RSClient sharedInstance] track:@"Product Added" properties:@{
    //        @"product_id": @"pro123",
    //        @"name": @"joggers",
    //        @"quantity": @12,
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": jsonString,
    //        @"revenue": @3000.00
    //    }];
        
    //    //Add To Wishlist
    //    NSDictionary *dict = @{ @"key" : @"value"};
    //    [[RSClient sharedInstance] track:@"Product Added to Wishlist" properties:@{
    //        @"product_id": @"pro123",
    //        @"name": @"joggers",
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": dict,
    //        @"revenue": @8.99
    //    }];
        
        //Checkout Started (job_id=10)
    //    [[RSClient sharedInstance] track:@"Checkout Started" properties:@{
    //        @"order_id": @"order123",
    //        @"product_id": @"pro123",
    //        @"name": @"joggers",
    //        @"currency": @"USD",
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": @{
    //                @"key": @"value"
    //        },
    //        @"revenue": @8.99,
    //        @"products": @[
    //            @{
    //              @"product_id": @123,
    //              @"sku": @"G-32",
    //              @"name": @"Monopoly",
    //              @"price": @14,
    //              @"quantity": @1
    //            }
    //          ]
    //    }];
    //
    //    //Order Completed (job_id=11)
    //    [[RSClient sharedInstance] track:@"Order Completed" properties:@{
    //        @"order_id": @"order123",
    //        @"checkout_id": @"check12345",
    //        @"product_id": @"pro123",
    //        @"name": @"joggers",
    //        @"currency": @"USD",
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": @{
    //                @"key": @"value"
    //        },
    //        @"revenue": @8.99,
    //        @"quantity": @2,
    //        @"products": @[
    //            @{
    //              @"product_id": @123,
    //              @"sku": @"G-32",
    //              @"name": @"Monopoly",
    //              @"price": @14,
    //              @"quantity": @1
    //            }
    //          ]
    //    }];
    //
    //    //Product Reviewed (job_id=12)
    //    [[RSClient sharedInstance] track:@"Product Reviewed" properties:@{
    //        @"product_id": @"pro123",
    //        @"rating": @"5",
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": @{
    //                @"key": @"value"
    //        }
    //    }];
    //
    ////    //Products Searched
    //    [[RSClient sharedInstance] track:@"Products Searched" properties:@{
    //        @"query": @"HP CAMBLE",
    //        @"custom_1": @"string value",
    //        @"custom_2": @99,
    //        @"custom_3": @YES,
    //        @"custom_4": @{
    //                @"key": @"value"
    //        }
    //    }];
        
        
    //    //3. Send "Product Added" event with quantity (String/Integer)
    //        [[RSClient sharedInstance] track:@"Product Added" properties:@{
    //            @"product_id": @"pro123",
    //            @"quantity": @200
    //        }];
    //
    //     [[RSClient sharedInstance] track:@"Product Added" properties:@{
    //        @"product_id": @"pro123",
    //        @"quantity": @"100"
    //    }];
        
        
    //    //4. Send "Order Completed" event with revenue (String/number) property
    //
    //      [[RSClient sharedInstance] track:@"Order Completed" properties:@{
    //            @"order_id": @"order123",
    //            @"checkout_id": @"check12345",
    //            @"product_id": @"pro123",
    //            @"name": @"joggers",
    //            @"revenue": @"1000"
    //        }];
    //
    //    [[RSClient sharedInstance] track:@"Order Completed" properties:@{
    //          @"order_id": @"order123",
    //          @"checkout_id": @"check12345",
    //          @"product_id": @"pro123",
    //          @"name": @"joggers",
    //          @"revenue": @2000
    //      }];
    //
    //    [[RSClient sharedInstance] track:@"Order Completed" properties:@{
    //          @"order_id": @"order123",
    //          @"checkout_id": @"check12345",
    //          @"product_id": @"pro123",
    //          @"name": @"joggers",
    //          @"revenue": @3000.89
    //      }];
        
        
    //    //5. Send "Order Completed" event without revenue property
    //    [[RSClient sharedInstance] track:@"Order Completed" properties:@{
    //              @"order_id": @"order123",
    //              @"checkout_id": @"check12345",
    //              @"product_id": @"pro123",
    //              @"name": @"joggers"
    //          }];
        
        
    //    //6. Send screen call with name, category, properties
    //        [[RSClient sharedInstance] screen:@"flipkart" properties:@{
    //            @"category" : @"flipkart category",
    //            @"url": @"www.flipkart.com",
    //            @"search": @"/.flipkart"
    //        }];
    //
    //    //7. Sed screen call with name, category
    //    [[RSClient sharedInstance] screen:@"amazon" properties:@{
    //        @"category" : @"amazon category"
    //    }];
    //
    //    //8. Send screen call only with name
    //    [[RSClient sharedInstance] screen:@"zomato"];
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[RudderKochavaIntegration alloc] registeredForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    [[RudderKochavaIntegration alloc] receivedRemoteNotification:response.notification.request.content.userInfo withActionString:response.actionIdentifier];
}


@end
