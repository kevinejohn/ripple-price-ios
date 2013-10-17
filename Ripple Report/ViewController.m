//
//  ViewController.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/17/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"

#define GLOBAL_FACTOR 1000000.0

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel * labelUSD;
@property (weak, nonatomic) IBOutlet UILabel * labelBTC;
@property (weak, nonatomic) IBOutlet UILabel * labelCYN;

@end

@implementation ViewController

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

-(void)updateRippleCharts
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://ripplecharts.com/api/ripplecom.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray * exchange = [responseObject objectForKey:@"exchange_rates"];
        for (NSDictionary * dic in exchange) {
            NSString * currency = [dic objectForKey:@"currency"];
            NSNumber * rate = [self convertNumber:[dic objectForKey:@"rate"]];
            
            if ([currency isEqualToString:@"USD"]) {
                self.labelUSD.text = rate.stringValue;
            }
            else if ([currency isEqualToString:@"BTC"]) {
                self.labelBTC.text = rate.stringValue;
            }
            else if ([currency isEqualToString:@"CNY"]) {
                self.labelCYN.text = rate.stringValue;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self updateRippleCharts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
