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
    
    //NSMutableDictionary * dicCurrency;
    //NSMutableDictionary * dicAverage;
    
    NSMutableArray * arrayAverage;
}

@end

@implementation RPTickerManager

-(NSArray*)averages
{
    NSMutableArray * array = [NSMutableArray array];
    for (RPAverage * average in arrayAverage) {
        [array addObject:average.currency];
    }
    return array;
}

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

-(RPAverage*)rpAverageForCurrency:(NSString*)currency
{
    for (RPAverage * average in arrayAverage) {
        if ([average.currency isEqualToString:currency]) {
            return average;
        }
    }
    return nil;
}

-(void)filterCurrencies
{
    [RPUserDefaults saveFilter:self.setFilter];
    
    self.arrayFiltered = [NSMutableArray array];
    for (RPAverage * average in arrayAverage) {
        if ([self.setFilter containsObject:average.currency]) {
            // Filter out
        }
        else {
            [self.arrayFiltered addObject:average];
        }
    }
}

-(void)setXrpOverCurrency:(BOOL)xrpOverCurrency
{
    [RPUserDefaults saveXrpOver:xrpOverCurrency];
    _xrpOverCurrency = xrpOverCurrency;
}

-(void)updateTickers:(void (^)(NSArray *average, NSError *error))block
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
        
        //dicCurrency = [NSMutableDictionary dictionary];
        arrayAverage = [NSMutableArray array];
        
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
            if (ticker.vol.integerValue < 100 ||
                ticker.last.doubleValue == 0.0 ||
                [ticker.gateway isEqualToString:@"WeExchange"]) {
                // Don't add
            }
            else {
                // Add
                
                RPAverage * average = [self rpAverageForCurrency:ticker.currency];
                if (!average) {
                    average = [RPAverage new];
                    average.currency = ticker.currency;
                    average.tickers = [NSMutableArray array];
                    
                    [arrayAverage addObject:average];
                }
                [average.tickers addObject:ticker];
            }
        }
        
        
        // Sort blocks by volume
        for (RPAverage * average in arrayAverage) {
            
            NSArray * sorted = [average.tickers sortedArrayUsingComparator:^NSComparisonResult(RPTicker* a, RPTicker* b) {
                return [b.vol compare:a.vol];
            }];
            average.tickers = [NSMutableArray arrayWithArray:sorted];
        }
        
        // Find weighted average
        for (RPAverage * average in arrayAverage) {
            
            double total_volume = 0;
            // Find total volume
            for (RPTicker * t in average.tickers) {
                total_volume += t.vol.doubleValue;
            }
            
            double weighted_price = 0;
            double weighted_price_reverse = 0;
            for (RPTicker * t in average.tickers) {
                double vol = t.vol.doubleValue;
                double weight = vol / total_volume;
                
                weighted_price += (t.last.doubleValue * weight);
                weighted_price_reverse += (t.last_reverse.doubleValue * weight);
            }
            average.weighted = [NSNumber numberWithDouble:weighted_price];
            average.weighted_reverse = [NSNumber numberWithDouble:weighted_price_reverse];
            average.total_volume = [NSNumber numberWithDouble:total_volume];
        }
        
        // Sort by total volume
        NSArray * sorted = [arrayAverage sortedArrayUsingComparator:^NSComparisonResult(RPAverage* a, RPAverage* b) {
            return [b.total_volume compare:a.total_volume];
        }];
        arrayAverage = [NSMutableArray arrayWithArray:sorted];
        
        
        // Filter
        [self filterCurrencies];
        
        block(self.arrayFiltered, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(nil, error);
    }];
}

+(RPTickerManager*)shared
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
        self.setFilter = [RPUserDefaults getFilter];
        self.xrpOverCurrency = [RPUserDefaults getXrpOver];
    }
    return self;
}

@end
