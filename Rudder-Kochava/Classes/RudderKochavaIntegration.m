//  RudderKochavaIntegration.m
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "RudderKochavaIntegration.h"
#import <Rudder/Rudder.h>
#import <KochavaTrackeriOS/KochavaTracker.h>

static NSDictionary *eventsMapping;

@implementation RudderKochavaIntegration

#pragma mark - Initialization

- (instancetype) initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        [RSLogger logDebug:@"Initializing Kochava SDK"];
        [self setEventsMapping];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(config == nil) {
                [RSLogger logError:@"Config is null. Cannot send events."];
            }
            self.appGUID = config[@"apiKey"];
            if(self.appGUID!=nil)
            {
                [KVATracker.shared startWithAppGUIDString:self.appGUID];
                [self setLogLevel : [rudderConfig logLevel]];
                [RSLogger logDebug:@"Initialized Kochava SDK"];
            }
            else
            {
                [RSLogger logWarn:@"Failed to Initialize Kochava SDK"];
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
    [RSLogger logDebug:@"Kochava doesn't support's Reset Call"];
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if([type isEqualToString:@"track"]){
        if(eventsMapping[[message.event lowercaseString]])
        {
            KVAEvent *event = [KVAEvent eventWithType:eventsMapping[[message.event lowercaseString]]];
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
            event.infoDictionary = message.properties;
            [event send];
        }
        else{
            KVAEvent *event = [KVAEvent customEventWithNameString:message.event];
            event.infoDictionary = message.properties;
            [event send];
        }
    }else if ([type isEqualToString:@"screen"]){
        NSString *screenName = message.event;
        NSDictionary *screenProperties = message.properties;
        if(screenProperties)
        {
            [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                screenName] infoDictionary:screenProperties];
        }
        else
        {
            [KVAEvent sendCustomWithNameString:[NSString stringWithFormat:@"screen view %@",
                                                screenName]];
        }
    }else {
        [RSLogger logDebug:@"Kochava Integration: Message type not supported"];
    }
    
}

#pragma mark - Utils

-(void) setLogLevel:(int) rsLogLevel {
    if(rsLogLevel == RSLogLevelVerbose)
    {
        KVALog.shared.level = KVALogLevel.trace;
    }
    else if(rsLogLevel == RSLogLevelDebug)
    {
        KVALog.shared.level = KVALogLevel.debug;
    }
    else if(rsLogLevel == RSLogLevelInfo)
    {
        KVALog.shared.level = KVALogLevel.info;
    }
    else if(rsLogLevel == RSLogLevelWarning)
    {
        KVALog.shared.level = KVALogLevel.warn;
    }
    else if(rsLogLevel == RSLogLevelError)
    {
        KVALog.shared.level = KVALogLevel.error;
    }
    else if(rsLogLevel == RSLogLevelNone)
    {
        KVALog.shared.level = KVALogLevel.never;
    }
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
