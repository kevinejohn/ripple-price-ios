//
//  RPHelper.h
//  Ripple Report
//
//  Created by Kevin Johnson on 11/22/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPHelper : NSObject

+(id)safeKey:(NSDictionary*)dic withKey:(NSString*)key;
+(NSNumber*)safeNumber:(NSDictionary*)dic withKey:(NSString*)key;

@end
