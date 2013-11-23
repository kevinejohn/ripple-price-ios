//
//  RPHelper.m
//  Ripple Report
//
//  Created by Kevin Johnson on 11/22/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "RPHelper.h"

@implementation RPHelper

+(id)safeKey:(NSDictionary*)dic withKey:(NSString*)key
{
    return ![[dic objectForKey:key] isKindOfClass:[NSNull class]] ? [dic objectForKey:key] : nil;
}

+(NSNumber*)safeNumber:(NSDictionary*)dic withKey:(NSString*)key
{
    NSNumber * num;
    id obj = [RPHelper safeKey:dic withKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        static NSNumberFormatter * f;
        if (!f) {
            f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            [f setMaximumFractionDigits:20];
        }
        num = [f numberFromString:obj];
    } else {
        num = obj;
    }
    return num;
}

@end
