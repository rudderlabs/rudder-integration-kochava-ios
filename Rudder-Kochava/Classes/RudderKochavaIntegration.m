//  RudderKochavaIntegration.m
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "RudderKochavaIntegration.h"
#import <Rudder/Rudder.h>

@implementation RudderKochavaIntegration

#pragma mark - Initialization

- (instancetype) initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        [RSLogger logDebug:@"Initializing Kochava SDK"];
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
    [RSLogger logDebug:@"Inside reset"];
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if([type isEqualToString:@"track"]){
        // do for track
    }else if ([type isEqualToString:@"screen"]){
        // do for screen
    }else if ([type isEqualToString:@"identify"]){
        // do for identify
    }else if ([type isEqualToString:@"group"]){
        // do for group
    }else if ([type isEqualToString:@"alias"]){
        // do for alias
    }else {
        [RSLogger logDebug:@"Kochava Integration: Message type not supported"];
    }
    
}

@end
