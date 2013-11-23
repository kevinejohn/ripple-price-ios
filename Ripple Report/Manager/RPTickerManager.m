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
#import "RPHelper.h"

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

-(NSNumber*)convertNumber:(NSNumber*)num
{
    return [NSNumber numberWithDouble:(num.doubleValue / GLOBAL_FACTOR)];
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
    
    for (RPAverage * average in self.arrayFiltered) {
        RPTicker * ticker = [average.tickers objectAtIndex:0];
        average.weighted = ticker.last;
        average.weighted_reverse = ticker.last_reverse;
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
    
    static NSNumberFormatter * f;
    if (!f) {
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    
    
    [manager GET:@"https://ripplecharts.com/api/model.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject);
        
        //dicCurrency = [NSMutableDictionary dictionary];
        arrayAverage = [NSMutableArray array];
        
        NSDictionary * dic = [RPHelper safeKey:responseObject withKey:@"tickers"];
        
        if (!dic || dic.allKeys.count == 0) {
            NSLog(@"%@: Invalid key: tickers",self);
        }
        
        //NSMutableArray * unsorted = [NSMutableArray arrayWithCapacity:dic.count];
        for (NSString * key in dic.allKeys) {
            NSDictionary * value = [dic objectForKey:key];
            
            NSString * sym = [RPHelper safeKey:value withKey:@"sym"];
            NSDictionary * d1 = [RPHelper safeKey:value withKey:@"d1"];
            NSNumber * vol = [RPHelper safeNumber:d1 withKey:@"vol"];
            NSNumber * last = [RPHelper safeNumber:value withKey:@"last"];
            last = [self convertNumber:last];
            
            RPTicker * ticker = [RPTicker new];
            ticker.currency = [[sym componentsSeparatedByString: @":"] objectAtIndex:0];
            ticker.gateway = [[sym componentsSeparatedByString: @":"] objectAtIndex:1];
            ticker.vol = vol;
            ticker.last = last;
            ticker.last_reverse = [NSNumber numberWithDouble:(1.0/last.doubleValue)];
            
            // Filter tickers with 0 volume or price
            if (//ticker.vol.integerValue < 1 ||
                //ticker.last.doubleValue == 0.0 ||
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
        
        // Find total volume
        for (RPAverage * average in arrayAverage) {
            
            double total_volume = 0;
            // Find total volume
            for (RPTicker * t in average.tickers) {
                total_volume += t.vol.doubleValue;
            }
            
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
