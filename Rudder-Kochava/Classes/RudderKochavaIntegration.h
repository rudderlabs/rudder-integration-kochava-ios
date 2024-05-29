//  RudderKochavaIntegration.h
//  Pods-Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderKochavaIntegration : NSObject<RSIntegration>

@property (nonatomic) NSString *appGUID;

-(instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig*) rudderCinfig;

@end

NS_ASSUME_NONNULL_END
