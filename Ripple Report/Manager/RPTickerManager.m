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
#import "RPAverage.h"

#define GLOBAL_FACTOR 1000000.0

@interface RPTickerManager () {
    //NSArray * tickers;
    
    NSMutableDictionary * dicCurrency;
    NSMutableDictionary * dicAverage;
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

-(void)updateTickers:(void (^)(NSDictionary *tickers, NSDictionary* average, NSError *error))block
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
        
        dicCurrency = [NSMutableDictionary dictionary];
        
        NSDictionary * dic = [responseObject objectForKey:@"tickers"];
        //NSMutableArray * unsorted = [NSMutableArray arrayWithCapacity:dic.count];
        for (NSString * key in dic.allKeys) {
            NSDictionary * value = [dic objectForKey:key];
            
            NSString * sym = [value objectForKey:@"sym"];
            NSNumber * vol = [value objectForKey:@"vol"];
            NSString * b = [value objectForKey:@"last"];
            NSNumber * last = [self convertNumber:b];
            
            RPTicker * ticker = [RPTicker new];
            ticker.currency = [[sym componentsSeparatedByString: @":"] objectAtIndex:0];
            ticker.gateway = [[sym componentsSeparatedByString: @":"] objectAtIndex:1];
            ticker.vol = vol;
            ticker.last = last;
            ticker.last_reverse = [NSNumber numberWithDouble:(1.0/last.doubleValue)];
            
            // Filter tickers with 0 volume or price
            if (ticker.vol.integerValue < 100 || ticker.last.doubleValue == 0.0) {
                // Don't add
            }
            else {
                // Add
                NSMutableArray * tickers = [dicCurrency objectForKey:ticker.currency];
                if (!tickers) {
                    tickers = [NSMutableArray array];
                }
                [tickers addObject:ticker];
                [dicCurrency setObject:tickers forKey:ticker.currency];
            }
        }
        
        // Sort blocks by volume
        for (NSString * key in dicCurrency.allKeys) {
            NSArray * value = [dicCurrency objectForKey:key];
            
            value = [value sortedArrayUsingComparator:^NSComparisonResult(RPTicker* a, RPTicker* b) {
                return [b.vol compare:a.vol];
            }];
            [dicCurrency setObject:value forKey:key];
        }
        
        // Find weighted average
        dicAverage = [NSMutableDictionary dictionary];
        for (NSString * key in dicCurrency.allKeys) {
            NSArray * array = [dicCurrency objectForKey:key];
            
            double total_volume = 0;
            // Find total volume
            for (RPTicker * t in array) {
                total_volume += t.vol.doubleValue;
            }
            
            double weighted_price = 0;
            double weighted_price_reverse = 0;
            for (RPTicker * t in array) {
                double vol = t.vol.doubleValue;
                double weight = vol / total_volume;
                
                weighted_price += (t.last.doubleValue * weight);
                weighted_price_reverse += (t.last_reverse.doubleValue * weight);
            }
            RPAverage * average = [RPAverage new];
            average.weighted = [NSNumber numberWithDouble:weighted_price];
            average.weighted_reverse = [NSNumber numberWithDouble:weighted_price_reverse];
            [dicAverage setObject:average forKey:key];
        }
        
        block(dicCurrency, dicAverage, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(nil, nil, error);
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
