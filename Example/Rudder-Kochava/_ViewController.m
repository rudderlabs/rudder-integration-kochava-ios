//
//  _ViewController.m
//  Rudder-Kochava
//
//  Created by Desu Sai Venkat on 11/05/2021.
//  Copyright (c) 2021 Desu Sai Venkat. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)identify:(id)sender {
    [[RSClient sharedInstance] identify:@"user id 1"];
}

- (IBAction)reset:(id)sender {
    [[RSClient sharedInstance] reset:NO];
}

- (IBAction)orderCompletedWithMultipleProducts:(id)sender {
    [[RSClient sharedInstance] track:ECommOrderCompleted properties:@{
        @"products": @[@{
            @"product_id": @"1002",
            @"name": @"P1"
        }, @{
            @"product_id": @"1003",
            @"name": @"P2"
        }],
        @"revenue": @123,
        @"currency": @"INR",
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)orderCompletedWithSingleProduct:(id)sender {
    [[RSClient sharedInstance] track:ECommOrderCompleted properties:@{
        @"products": @[@{
            @"product_id": @"1003",
            @"name": @"P3"
        }],
        @"revenue": @123,
        @"currency": @"INR",
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)checkoutStarted:(id)sender {
    [[RSClient sharedInstance] track:ECommCheckoutStarted properties:@{
        @"products": @[@{
            @"product_id": @"1004",
            @"name": @"P4"
        }],
        @"currency": @"INR",
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)productAdded:(id)sender {
    [[RSClient sharedInstance] track:ECommProductAdded properties:@{
        @"product_id": @"1003",
        @"name": @"P1",
        @"quantity": @5,
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)productAddedToWishlist:(id)sender {
    [[RSClient sharedInstance] track:ECommProductAddedToWishList properties:@{
        @"product_id": @"1003",
        @"name": @"P1",
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)productReviewed:(id)sender {
    [[RSClient sharedInstance] track:ECommProductReviewed properties:@{
        @"rating": @8.50,
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)productSearched:(id)sender {
    [[RSClient sharedInstance] track:ECommProductsSearched properties:@{
        @"query": @"www.facebook.com",
        
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)customTrackWithProperties:(id)sender {
    [[RSClient sharedInstance] track:@"Custom track with properties" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @235,
        @"key_3" : @YES,
    }];
}

- (IBAction)customTrackWithoutProperties:(id)sender {
    [[RSClient sharedInstance] track:@"Custom track without properties"];
}

- (IBAction)screenWithProperties:(id)sender {
    [[RSClient sharedInstance] screen:@"Screen with properties" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @235
    }];
}

- (IBAction)screenWithoutProperties:(id)sender {
    [[RSClient sharedInstance] screen:@"Screen without properties"];
}

@end
