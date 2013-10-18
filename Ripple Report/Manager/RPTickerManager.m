//
//  RPTickerManager.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/18/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "RPTickerManager.h"
#import "RPTicker.h"
#import "AFHTTPRequestOperationManager.h"

#define GLOBAL_FACTOR 1000000.0

@interface RPTickerManager () {
    NSMutableArray * tickers;
}

@end

@implementation RPTickerManager

-(NSNumber*)convertNumber:(NSString*)value
{
    static NSNumberFormatter * f;
    if (!f) {
        f = [NSNumberFormatter new];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    
    NSNumber * t = [f numberFromString:value];
    t = [NSNumber numberWithDouble:(t.doubleValue / GLOBAL_FACTOR)];
    return t;
}

-(void)updateTickers:(void (^)(NSArray *tickers, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    [manager GET:@"https://ripplecharts.com/api/ripplecom.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //        NSLog(@"JSON: %@", responseObject);
    //
    //        NSArray * exchange = [responseObject objectForKey:@"exchange_rates"];
    //        for (NSDictionary * dic in exchange) {
    //            NSString * currency = [dic objectForKey:@"currency"];
    //            NSNumber * rate = [self convertNumber:[dic objectForKey:@"rate"]];
    //
    //            if ([currency isEqualToString:@"USD"]) {
    //                self.labelUSD.text = [NSString stringWithFormat:@"USD:Bitstamp %@", rate.stringValue];
    //            }
    //            else if ([currency isEqualToString:@"BTC"]) {
    //                self.labelBTC.text = [NSString stringWithFormat:@"BTC:Bitstamp %@", rate.stringValue];
    //            }
    //            else if ([currency isEqualToString:@"CNY"]) {
    //                self.labelCYN.text = [NSString stringWithFormat:@"CNY:RippleCN %@", rate.stringValue];
    //            }
    //        }
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //        NSLog(@"Error: %@", error);
    //    }];
    
    
    [manager GET:@"https://ripplecharts.com/api/model.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary * dic = [responseObject objectForKey:@"tickers"];
        tickers = [NSMutableArray arrayWithCapacity:dic.count];
        for (NSString * key in dic.allKeys) {
            NSDictionary * value = [dic objectForKey:key];
            
            NSString * sym = [value objectForKey:@"sym"];
            NSNumber * vol = [value objectForKey:@"vol"];
            NSString * b = [value objectForKey:@"last"];
            NSNumber * last = [self convertNumber:b];
            
            RPTicker * ticker = [RPTicker new];
            ticker.sym = sym;
            ticker.vol = vol;
            ticker.last = last;
            
            [tickers addObject:ticker];
        }
        
        block(tickers, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(nil, error);
    }];
}

+(id)shared
{
    static RPTickerManager * shared;
    if (!shared) {
        shared = [RPTickerManager new];
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end
