//
//  RPUserDefaults.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/25/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "RPUserDefaults.h"

@implementation RPUserDefaults

+(NSMutableSet*)getFilter
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * temp = [defaults objectForKey:@"filter"];
    if (temp) {
        return [NSMutableSet setWithArray:temp];
    }
    else {
        return [NSMutableSet set];
    }
    
}

+(void)saveFilter:(NSSet*)filter
{
    if (filter) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[filter allObjects] forKey:@"filter"];
        [defaults synchronize];
    }
}

+(void)saveXrpOver:(BOOL)xrpOver
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:xrpOver] forKey:@"xrp_over"];
    [defaults synchronize];
}

+(BOOL)getXrpOver
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * num = [defaults objectForKey:@"xrp_over"];
    if (num) {
        return num.boolValue;
    }
    else {
        return NO;
    }
}

@end
