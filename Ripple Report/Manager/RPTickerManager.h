//
//  RPTickerManager.h
//  Ripple Report
//
//  Created by Kevin Johnson on 10/18/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTickerManager : NSObject {
    
}

@property (nonatomic) BOOL xrpOverCurrency;
@property (strong, nonatomic) NSMutableSet   * setFilter;
@property (strong, nonatomic) NSMutableArray * arrayFiltered;

+(RPTickerManager*)shared;
-(void)updateTickers:(void (^)(NSArray* average, NSError *error))block;

-(NSArray*)averages;
-(void)filterCurrencies;

@end
