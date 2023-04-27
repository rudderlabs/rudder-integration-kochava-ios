//  RudderKochavaIntegration.m
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "RudderKochavaIntegration.h"
#import <Rudder/Rudder.h>

@import KochavaTracker;

static NSDictionary *eventsMapping;

@implementation RudderKochavaIntegration

#pragma mark - Initialization

- (instancetype) initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        [RSLogger logDebug:@"Initializing Kochava Factory"];
        [self setEventsMapping];
        if (config == nil) {
            [RSLogger logError:@"Failed to Initialize Kochava Factory as Config is null"];
        }
        
        self.appGUID = config[@"apiKey"];
        if (self.appGUID!=nil) {
            if ([[config objectForKey:@"appTrackingTransparency"] boolValue]) {
                KVATracker.shared.appTrackingTransparency.enabledBool= YES;
            }
            [KVATracker.shared startWithAppGUIDString:self.appGUID];
            [self setLogLevel:rudderConfig.logLevel];
            [RSLogger logDebug:@"Initialized Kochava Factory"];
        }
        else {
            [RSLogger logWarn:@"Failed to Initialize Kochava Factory"];
        }
    }
    return self;
}

- (void) dump:(RSMessage *)message {
    @try {
        if (message != nil) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self processRudderEvent:message];
            });
        }
    }
    @catch (NSException *ex) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"%@", ex]];
    }
}

- (void)reset {
    [RSLogger logDebug:@"Kochava Factory doesn't support Reset Call"];
}

- (void)flush {
    
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if ([type isEqualToString:@"track"]) {
        if (message.event) {
            NSString* eventName = message.event;
            NSMutableDictionary<NSString*, NSObject*>* eventProperties = [[NSMutableDictionary alloc] initWithDictionary:message.properties];
            KVAEvent *event;
            if (eventsMapping[eventName]) {
                event = [KVAEvent eventWithType:eventsMapping[eventName]];
                if (eventProperties) {
                    if ([eventName isEqual:ECommOrderCompleted]) {
                        [self setProductsProperties:eventProperties withEvent:event];
                        if (eventProperties[KeyRevenue]) {
                            event.priceDoubleNumber = (NSNumber*)eventProperties[KeyRevenue];
                            [eventProperties removeObjectForKey:KeyRevenue];
                        }
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:ECommProductAdded]) {
                        
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                        if (eventProperties[KeyQuantity]) {
                            event.quantityDoubleNumber = (NSNumber*)eventProperties[KeyQuantity];
                            [eventProperties removeObjectForKey:KeyQuantity];
                        }
                    }
                    if ([eventName isEqual:ECommProductAddedToWishList]) {
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:ECommCheckoutStarted]) {
                        [self setProductsProperties:eventProperties withEvent:event];
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:ECommProductReviewed]) {
                        if (eventProperties[KeyRating]) {
                            event.ratingValueDoubleNumber = (NSNumber*)eventProperties[KeyRating];
                            [eventProperties removeObjectForKey:KeyRating];
                        }
                    }
                    if ([eventName isEqual:ECommProductsSearched]) {
                        if (eventProperties[KeyQuery]) {
                            event.uriString = (NSString*) eventProperties[KeyQuery];
                            [eventProperties removeObjectForKey:KeyQuery];
                        }
                    }
                }
            } else {
                event = [KVAEvent customEventWithNameString:message.event];
            }
            if (eventProperties) {
                event.infoDictionary = eventProperties;
            }
            [event send];
        }
    } else if ([type isEqualToString:@"screen"]) {
        if (message.event) {
            if (message.properties) {
                [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                    message.event] infoDictionary:message.properties];
            }
            else {
                [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                    message.event]];
            }
        }
    } else {
        [RSLogger logDebug:@"Kochava Integration: Message type not supported"];
    }
}

#pragma mark- Push Notification methods

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [KVAPushNotificationsToken registerWithData:deviceToken];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    KVAEvent *event = [KVAEvent eventWithType:KVAEventType.pushOpened];
    event.payloadDictionary = response.notification.request.content.userInfo;
    event.actionString = response.actionIdentifier;
    [event send];
}

#pragma mark - Utils

- (void) setLogLevel:(int) rsLogLevel {
    if (rsLogLevel == RSLogLevelVerbose) {
        KVALog.shared.level = KVALogLevel.trace;
        return;
    }
    if (rsLogLevel == RSLogLevelDebug) {
        KVALog.shared.level = KVALogLevel.debug;
        return;
    }
    if (rsLogLevel == RSLogLevelInfo) {
        KVALog.shared.level = KVALogLevel.info;
        return;
    }
    if (rsLogLevel == RSLogLevelWarning) {
        KVALog.shared.level = KVALogLevel.warn;
        return;
    }
    if (rsLogLevel == RSLogLevelError) {
        KVALog.shared.level = KVALogLevel.error;
        return;
    }
    KVALog.shared.level = KVALogLevel.never;
}

- (NSMutableDictionary*) setCurrency:(NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if (eventProperties[KeyCurrency]) {
        event.currencyString = (NSString*)eventProperties[KeyCurrency];
        [eventProperties removeObjectForKey:KeyCurrency];
    }
    return eventProperties;
}


- (NSMutableDictionary*) setProductProperties: (NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event{
    if (eventProperties[@"name"]) {
        event.nameString = (NSString*)eventProperties[@"name"];
        [eventProperties removeObjectForKey:@"name"];
    }
    if (eventProperties[KeyProductId]) {
        event.contentIdString = (NSString*)eventProperties[KeyProductId];
        [eventProperties removeObjectForKey:KeyProductId];
    }
    return eventProperties;
}

- (void) setProductsProperties: (NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if (eventProperties[KeyProducts]) {
        NSArray *products = eventProperties[KeyProducts];
        NSString* productNames = [self getProductProperties:products type:@"name"];
        if (productNames) {
            event.nameString = productNames;
        }
        NSString* productIds = [self getProductProperties:products type:KeyProductId];
        if (productIds) {
            event.contentIdString = productIds;
        }
        [eventProperties removeObjectForKey:KeyProducts];
    }
}

- (NSString*) getProductProperties: (NSArray*) products type:(NSString*) type {
    NSMutableArray<NSString*>* productProperties = [[NSMutableArray alloc] init];
    if (products) {
        for(NSDictionary *product in products) {
            if (product[type]) {
                [productProperties addObject:product[type]];
            }
        }
    }
    return [self getJsonString:productProperties];
}

- (NSString*) getJsonString:(NSMutableArray<NSString*>*) mutableArray {
    if (![mutableArray count]) {
        return nil;
    }
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void) setEventsMapping{
    eventsMapping =
    @{
        ECommProductAdded: KVAEventType.addToCart,
        ECommProductAddedToWishList: KVAEventType.addToWishList,
        ECommCheckoutStarted: KVAEventType.checkoutStart,
        ECommOrderCompleted: KVAEventType.purchase,
        ECommProductReviewed: KVAEventType.rating,
        ECommProductsSearched: KVAEventType.search,
        ECommProductViewed: KVAEventType.view
    };
}

@end
