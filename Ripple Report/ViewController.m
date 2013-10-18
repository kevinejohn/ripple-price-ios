//
//  ViewController.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/17/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "ViewController.h"
#import "RPTicker.h"
#import "RPTickerManager.h"

@interface ViewController () {
    NSTimer * timer;
    
    NSArray * tickers;
}

@property (weak, nonatomic) IBOutlet UILabel * labelUSD;
@property (weak, nonatomic) IBOutlet UILabel * labelBTC;
@property (weak, nonatomic) IBOutlet UILabel * labelCYN;

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation ViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    
    UITableViewCell * cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    RPTicker * ticker = [tickers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ Volume: %@", ticker.sym, ticker.last.stringValue, ticker.vol.stringValue];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tickers.count;
}



-(void)updateRippleCharts
{
    [[RPTickerManager shared] updateTickers:^(NSArray *t, NSError *error) {
        if (!error) {
            tickers = t;
            [self.tableView reloadData];
        }
    }];
    
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateRippleCharts) userInfo:nil repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRippleCharts) name: UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
