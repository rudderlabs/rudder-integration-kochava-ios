//  RudderKochavaFactory.m
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "RudderKochavaFactory.h"
#import "RudderKochavaIntegration.h"

@implementation RudderKochavaFactory

static RudderKochavaFactory *sharedInstance;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return @"Kochava";
}

-(id<RSIntegration>)initiate:(NSDictionary *)config client:(RSClient *)client rudderConfig:(RSConfig *)rudderConfig{
    [RSLogger logDebug:@"Creating RudderIntegrationFactory: Kochava"];
    return [[RudderKochavaIntegration alloc] initWithConfig:config
                                                withAnalytics:client
                                             withRudderConfig:rudderConfig];
}
@end
