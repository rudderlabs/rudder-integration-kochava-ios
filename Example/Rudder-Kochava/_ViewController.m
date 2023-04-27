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

- (IBAction)onButtonTap:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [[RSClient sharedInstance] track:ECommOrderCompleted properties:@{
                @"products": @[@{
                    @"product_id": @"1002",
                    @"quantity": @12,
                    @"price": @100.22,
                    @"name": @"P1"
                }, @{
                    @"product_id": @"1003",
                    @"quantity": @5,
                    @"price": @89.50,
                    @"name": @"P2"
                }],
                @"currency": @"INR"
            }];
            break;
        case 1:
            [[RSClient sharedInstance] track:ECommProductAdded properties:@{
                @"product_id": @"1003",
                @"quantity": @5,
                @"price": @89.50,
                @"name": @"P1"
            }];
            break;
        case 2:
            [[RSClient sharedInstance] track:ECommProductAddedToWishList properties:@{
                @"product_id": @"1003",
                @"quantity": @5,
                @"price": @89.50,
                @"name": @"P1"
            }];
            break;
        case 3:
            [[RSClient sharedInstance] track:ECommProductViewed properties:@{
                @"product_id": @"1003",
                @"quantity": @5,
                @"price": @89.50,
                @"name": @"P1"
            }];
            break;
        case 4:
            [[RSClient sharedInstance] track:ECommCheckoutStarted properties:@{
                @"products": @[@{
                    @"product_id": @"1002",
                    @"quantity": @12,
                    @"price": @100.22,
                    @"name": @"P1"
                }, @{
                    @"product_id": @"1003",
                    @"quantity": @5,
                    @"price": @89.50,
                    @"name": @"P2"
                }],
                @"currency": @"INR"
            }];
            break;
        case 5:
            [[RSClient sharedInstance] track:ECommProductReviewed properties:@{
                @"rating": @8.50
            }];
            break;
        case 6:
            [[RSClient sharedInstance] track:ECommProductsSearched properties:@{
                @"query": @"mobile",
                @"key_1" : @"value_1",
                @"key_2" : @"value_2"
            }];
            break;
        case 7:
            [[RSClient sharedInstance] screen:@"Home" properties:@{
                @"key_1" : @"value_1",
                @"key_2" : @"value_2"
            }];
            break;
        case 8:
            [[RSClient sharedInstance] screen:@"Home"];
            break;
        case 9:
            [[RSClient sharedInstance] track:@"New Track event" properties:@{
                @"key_1" : @"value_1",
                @"key_2" : @"value_2"
            }];
            break;
        case 10:
            [[RSClient sharedInstance] track:@"New Track event"];
            break;
        default:
            break;
    }
}

@end
