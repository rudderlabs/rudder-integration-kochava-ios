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
            [self setLogLevel:rudderConfig.logLevel];
            if ([[config objectForKey:@"appTrackingTransparency"] boolValue]) {
                KVATracker.shared.appTrackingTransparency.enabledBool = YES;
            }
            [KVATracker.shared startWithAppGUIDString:self.appGUID];
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
            [self processRudderEvent:message];
        }
    }
    @catch (NSException *ex) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"%@", ex]];
    }
}

- (void)reset {
    [KVAEventDefaultParameter registerWithUserIdString:nil];
    [RSLogger logDebug:@"Kochava reset api is called."];
}

- (void)flush {
    
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if ([type isEqualToString:@"identify"]) {
        NSString *userId = message.userId;
        if (userId != nil) {
            [KVAEventDefaultParameter registerWithUserIdString:message.userId];
            [RSLogger logInfo:[NSString stringWithFormat:@"User ID: %@ is set successfully in Kochava", userId]];
        }
    } else if ([type isEqualToString:@"track"]) {
        if (message.event) {
            NSString* eventName = [message.event lowercaseString];
            NSMutableDictionary<NSString*, NSObject*>* eventProperties = [[NSMutableDictionary alloc] initWithDictionary:message.properties];
            KVAEvent *event;
            // Standard ECommerce Events
            if (eventsMapping[eventName]) {
                event = [KVAEvent eventWithType:eventsMapping[eventName]];
                if (eventProperties) {
                    if ([eventName isEqual:@"order completed"]) {
                        [self setProductsProperties:eventProperties withEvent:event];
                        if (eventProperties[KeyRevenue]) {
                            event.priceDoubleNumber = (NSNumber*)eventProperties[KeyRevenue];
                            [eventProperties removeObjectForKey:KeyRevenue];
                        }
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:@"product added"]) {
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                        if (eventProperties[KeyQuantity]) {
                            event.quantityDoubleNumber = (NSNumber*)eventProperties[KeyQuantity];
                            [eventProperties removeObjectForKey:KeyQuantity];
                        }
                    }
                    if ([eventName isEqual:@"product added to wishlist"]) {
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:@"checkout started"]) {
                        [self setProductsProperties:eventProperties withEvent:event];
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if ([eventName isEqual:@"product reviewed"]) {
                        if (eventProperties[KeyRating]) {
                            event.ratingValueDoubleNumber = (NSNumber*)eventProperties[KeyRating];
                            [eventProperties removeObjectForKey:KeyRating];
                        }
                    }
                    if ([eventName isEqual:@"products searched"]) {
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


- (NSMutableDictionary*) setProductProperties: (NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if (eventProperties[@"name"]) {
        event.nameString = (NSString*)eventProperties[@"name"];
        [eventProperties removeObjectForKey:@"name"];
    }
    if (eventProperties[@"product_id"]) {
        event.contentIdString = (NSString*)eventProperties[@"product_id"];
        [eventProperties removeObjectForKey:@"product_id"];
        return eventProperties;
    }
    if (eventProperties[@"productId"]) {
        event.contentIdString = (NSString*)eventProperties[@"productId"];
        [eventProperties removeObjectForKey:@"productId"];
    }
    return eventProperties;
}

- (void) setProductsProperties: (NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if (eventProperties[KeyProducts]) {
        NSMutableArray<NSString*>* nameProperties = [[NSMutableArray alloc] init];
        NSMutableArray<NSString*>* productIdProperties = [[NSMutableArray alloc] init];
        
        NSArray *products = eventProperties[KeyProducts];
        if (products) {
            for(NSDictionary *product in products) {
                if (product[@"name"]) {
                    [nameProperties addObject:product[@"name"]];
                }
                
                if (product[@"product_id"]) {
                    [productIdProperties addObject:product[@"product_id"]];
                } else if (product[@"productId"]) {
                    [productIdProperties addObject:product[@"productId"]];
                }
            }
        }
        
        NSString* productNames = [self getJsonString:nameProperties];
        if (productNames) {
            event.nameString = productNames;
        }
        NSString* productIds = [self getJsonString:productIdProperties];
        if (productIds) {
            event.contentIdString = productIds;
        }
        
        [eventProperties removeObjectForKey:KeyProducts];
    }
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
        @"product added": KVAEventType.addToCart,
        @"product added to wishlist": KVAEventType.addToWishList,
        @"checkout started": KVAEventType.checkoutStart,
        @"order completed": KVAEventType.purchase,
        @"product reviewed": KVAEventType.rating,
        @"products searched": KVAEventType.search
    };
}

@end
