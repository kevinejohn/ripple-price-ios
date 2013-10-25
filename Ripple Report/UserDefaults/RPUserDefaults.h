//
//  RPUserDefaults.h
//  Ripple Report
//
//  Created by Kevin Johnson on 10/25/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPUserDefaults : NSObject

+(void)saveFilter:(NSSet*)filter;
+(NSMutableSet*)getFilter;

+(BOOL)getXrpOver;
+(void)saveXrpOver:(BOOL)xrpOver;

@end
