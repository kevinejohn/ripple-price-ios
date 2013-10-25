//
//  SettingsViewController.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/25/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "RPTickerManager.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray * currencies;
    
    NSMutableSet * setFilter;
}

@property (weak, nonatomic) IBOutlet UILabel * labelConvertionType;
@property (weak, nonatomic) IBOutlet UISwitch * switchConvertionType;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation SettingsViewController

-(IBAction)switchPressed:(UISwitch*)sender
{
    if (!sender.on) {
        self.labelConvertionType.text = @"1 XRP = USD";
        [RPTickerManager shared].xrpOverCurrency = NO;
        
    }
    else {
        self.labelConvertionType.text = @"1 USD = XRP";
        [RPTickerManager shared].xrpOverCurrency = YES;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString * currency = [currencies objectAtIndex:indexPath.row];
    cell.textLabel.text = currency;
    
    if (![setFilter containsObject:currency]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currencies.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * currency = [currencies objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([setFilter containsObject:currency]) {
        // Is filtered. Unfilter
        [setFilter removeObject:currency];
    }
    else {
        [setFilter addObject:currency];
    }
    
    [tableView reloadData];
}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return [UIView new];
//}


-(IBAction)buttonBackPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.switchConvertionType.on = [RPTickerManager shared].xrpOverCurrency;
    [self switchPressed:self.switchConvertionType];
    
    currencies = [[RPTickerManager shared] averages];
    setFilter = [[RPTickerManager shared] setFilter];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RPTickerManager shared] filterCurrencies];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
