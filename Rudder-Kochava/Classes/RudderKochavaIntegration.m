//  RudderKochavaIntegration.m
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "RudderKochavaIntegration.h"
#import <Rudder/Rudder.h>
#import <KochavaTrackeriOS/KochavaTracker.h>
#import <KochavaAdNetworkiOS/KVAAdNetworkProduct.h>

static NSDictionary *eventsMapping;

@implementation RudderKochavaIntegration

#pragma mark - Initialization

- (instancetype) initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        [RSLogger logDebug:@"Initializing Kochava Factory"];
        [self setEventsMapping];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(config == nil) {
                [RSLogger logError:@"Failed to Initialize Kochava Factory as Config is null"];
            }
            self.appGUID = config[@"apiKey"];
            if(self.appGUID!=nil)
            {
                if([[config objectForKey:@"appTrackingTransparency"] boolValue])
                {
                    KVATracker.shared.appTrackingTransparency.enabledBool= YES;
                }
                if([[config objectForKey:@"skAdNetwork"] boolValue])
                {
                    [KVAAdNetworkProduct.shared register];
                }
                [KVATracker.shared startWithAppGUIDString:self.appGUID];
                [self setLogLevel : [rudderConfig logLevel]];
                [RSLogger logDebug:@"Initialized Kochava Factory"];
            }
            else
            {
                [RSLogger logWarn:@"Failed to Initialize Kochava Factory"];
            }
        });
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
    } @catch (NSException *ex) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"%@", ex]];
    }
}

- (void)reset {
    [RSLogger logDebug:@"Kochava Factory doesn't support Reset Call"];
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if([type isEqualToString:@"track"]){
        if(message.event) {
            NSString* eventName = [message.event lowercaseString];
            NSMutableDictionary<NSString*, NSObject*>* eventProperties = [message.properties mutableCopy];
            KVAEvent *event;
            if(eventsMapping[eventName])
            {
                event = [KVAEvent eventWithType:eventsMapping[eventName]];
                if(eventProperties)
                {
                    if([eventName isEqual:@"order completed"])
                    {
                        [self setProductsProperties:eventProperties withEvent:event];
                        if(eventProperties[@"revenue"])
                        {
                            event.priceDoubleNumber = (NSNumber*)eventProperties[@"revenue"];
                            [eventProperties removeObjectForKey:@"revenue"];
                        }
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if([eventName isEqual:@"product added"])
                    {
                        
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                        if(eventProperties[@"quantity"])
                        {
                            event.quantityDoubleNumber = (NSNumber*)eventProperties[@"quantity"];
                            [eventProperties removeObjectForKey:@"quantity"];
                        }
                    }
                    if([eventName isEqual:@"add to wishlist"])
                    {
                        eventProperties = [self setProductProperties:eventProperties withEvent:event];
                    }
                    if([eventName isEqual:@"checkout started"])
                    {
                        [self setProductsProperties:eventProperties withEvent:event];
                        eventProperties = [self setCurrency:eventProperties withEvent:event];
                    }
                    if([eventName isEqual:@"product reviewed"])
                    {
                        if(eventProperties[@"rating"])
                        {
                            event.ratingValueDoubleNumber = (NSNumber*)eventProperties[@"rating"];
                            [eventProperties removeObjectForKey:@"rating"];
                        }
                    }
                    if([eventName isEqual:@"products searched"])
                    {
                        if(eventProperties[@"query"])
                        {
                            event.uriString = (NSString*) eventProperties[@"query"];
                            [eventProperties removeObjectForKey:@"query"];
                        }
                    }
                }
            }
            else{
                event = [KVAEvent customEventWithNameString:message.event];
            }
            if(eventProperties)
            {
                event.infoDictionary = eventProperties;
            }
            [event send];
        }
    }else if ([type isEqualToString:@"screen"]){
        if(message.event) {
            if(message.properties)
            {
                [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                    message.event] infoDictionary:message.properties];
            }
            else
            {
                [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                    message.event]];
            }
        }
    }else {
        [RSLogger logDebug:@"Kochava Integration: Message type not supported"];
    }
    
}

#pragma mark- Push Notification methods

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [KVAPushNotificationsToken addWithData:deviceToken];
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo withActionString:(NSString*) actionString
{
    KVAEvent *event = [KVAEvent eventWithType:KVAEventType.pushOpened];
    event.payloadDictionary = userInfo;
    event.actionString = actionString;
    [event send];
}

#pragma mark - Utils

-(void) setLogLevel:(int) rsLogLevel {
    if(rsLogLevel == RSLogLevelVerbose)
    {
        KVALog.shared.level = KVALogLevel.trace;
        return;
    }
    if(rsLogLevel == RSLogLevelDebug)
    {
        KVALog.shared.level = KVALogLevel.debug;
        return;
    }
    if(rsLogLevel == RSLogLevelInfo)
    {
        KVALog.shared.level = KVALogLevel.info;
        return;
    }
    if(rsLogLevel == RSLogLevelWarning)
    {
        KVALog.shared.level = KVALogLevel.warn;
        return;
    }
    if(rsLogLevel == RSLogLevelError)
    {
        KVALog.shared.level = KVALogLevel.error;
        return;
    }
    KVALog.shared.level = KVALogLevel.never;
}

-(NSMutableDictionary*) setCurrency:(NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if(eventProperties[@"currency"])
    {
        event.currencyString = (NSString*)eventProperties[@"currency"];
        [eventProperties removeObjectForKey:@"currency"];
    }
    return eventProperties;
}


-(NSMutableDictionary*) setProductProperties: (NSMutableDictionary*) eventProperties withEvent: (KVAEvent*) event{
    if(eventProperties[@"name"])
    {
        event.nameString = (NSString*)eventProperties[@"name"];
        [eventProperties removeObjectForKey:@"name"];
    }
    if(eventProperties[@"product_id"])
    {
        event.contentIdString = (NSString*)eventProperties[@"product_id"];
        [eventProperties removeObjectForKey:@"product_id"];
        return eventProperties;
    }
    if(eventProperties[@"productId"])
    {
        event.contentIdString = (NSString*)eventProperties[@"productId"];
        [eventProperties removeObjectForKey:@"productId"];
    }
    return eventProperties;
}

-(void) setProductsProperties: (NSDictionary*) eventProperties withEvent: (KVAEvent*) event {
    if(eventProperties[@"products"])
    {
        NSArray *products = eventProperties[@"products"];
        NSString* productNames = [self getProductProperties:products type:@"name"];
        if(productNames)
        {
            event.nameString = productNames;
        }
        NSString* productIds = [self getProductProperties:products type:@"product_id"];
        if(productIds)
        {
            event.contentIdString = productIds;
        }
    }
}

- (NSString*) getProductProperties: (NSArray*) products type:(NSString*) type
{
    NSMutableArray<NSString*>* productProperties = [[NSMutableArray alloc] init];
    if(products)
    {
        for(NSDictionary *product in products)
        {
            if(product[type])
            {
                [productProperties addObject:product[type]];
            }
            if([type isEqual:@"product_id"] && product[@"productId"])
            {
                [productProperties addObject:product[@"productId"]];
            }
        }
    }
    return [self getJsonString:productProperties];
}

-(NSString*) getJsonString:(NSMutableArray<NSString*>*) mutableArray {
    if(![mutableArray count])
    {
        return nil;
    }
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(void) setEventsMapping{
    eventsMapping =
    @{
        @"product added": KVAEventType.addToCart,
        @"add to wishlist": KVAEventType.addToWishList,
        @"checkout started": KVAEventType.checkoutStart,
        @"order completed": KVAEventType.purchase,
        @"product reviewed": KVAEventType.rating,
        @"products searched": KVAEventType.search
    };
}

@end
