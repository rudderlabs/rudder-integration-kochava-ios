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
        KVAEvent *event;
        if(eventsMapping[[message.event lowercaseString]])
        {
            event = [KVAEvent eventWithType:eventsMapping[[message.event lowercaseString]]];
            if([[message.event lowercaseString] isEqual:@"order completed"])
            {
                if(message.properties[@"revenue"])
                {
                    event.priceDoubleNumber = (NSNumber*)message.properties[@"revenue"];
                }
                if(message.properties[@"currency"])
                {
                    event.currencyString = (NSString*) message.properties[@"currency"];
                }
            }
        }
        else{
            event = [KVAEvent customEventWithNameString:message.event];
        }
        if(message.properties)
        {
            event.infoDictionary = message.properties;
        }
        [event send];
        
    }else if ([type isEqualToString:@"screen"]){
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
