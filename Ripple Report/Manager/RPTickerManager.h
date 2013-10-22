//
//  RPTickerManager.h
//  Ripple Report
//
//  Created by Kevin Johnson on 10/18/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTickerManager : NSObject

+(id)shared;
-(void)updateTickers:(void (^)(NSDictionary *tickers, NSDictionary* average, NSError *error))block;

@end
