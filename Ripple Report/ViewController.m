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
#import "GatewayPriceCell.h"
#import "CurrencyCell.h"
#import "RPAverage.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSTimer * timer;
    NSDictionary * dicTickers;
    NSDictionary * dicAverage;
    NSInteger selectedCurrency;
    
    BOOL   currency_flip;
}

//@property (weak, nonatomic) IBOutlet UILabel * labelUSD;
//@property (weak, nonatomic) IBOutlet UILabel * labelBTC;
//@property (weak, nonatomic) IBOutlet UILabel * labelCYN;

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation ViewController

-(BOOL)isCurrencySelected
{
    if (selectedCurrency >= 0) {
        return YES;
    }
    else {
        return NO;
    }
}

-(NSArray*)getSelectedCurrencyArray
{
    NSArray * array;
    if ([self isCurrencySelected]) {
        array = [dicTickers.allValues objectAtIndex:selectedCurrency];
    }
    return array;
}

-(NSUInteger)numberOfTickersFromSelectedCurrency
{
    NSArray * temp = [dicTickers.allValues objectAtIndex:selectedCurrency];
    return temp.count;
}

-(BOOL)isBottomCell:(NSUInteger)row
{
    if ([self isCurrencySelected] && (row > selectedCurrency && row <= (selectedCurrency + [self numberOfTickersFromSelectedCurrency]))) {
        return YES;
    }
    else {
        return NO;
    }
}

-(NSInteger)getTopCellIndex:(NSInteger)row
{
//    NSInteger total = 0;
//    NSInteger cnt = 0;
//    
//    while (true) {
//        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:total inSection:0]];
//        if (cell.tag == 1) {
//            // Top cell
//            cnt++;
//            if (cnt == row) {
//                return total;
//            }
//        }
//        
//        total++;
//    }
    
    if ([self isCurrencySelected] && row > selectedCurrency) {
        return row - [self numberOfTickersFromSelectedCurrency];
    }
    else {
        return row;
    }
}

-(IBAction)buttonCurrencyPressed:(id)sender
{
    currency_flip = !currency_flip;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier1 = @"Top";
    static NSString * cellIdentifier2 = @"Bottom";
    
    if ([self isBottomCell:indexPath.row]) {
        // Bottom Cell
        
        GatewayPriceCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        cell.tag = 2;
        
        NSArray * tickers = [self getSelectedCurrencyArray];
        NSInteger row = (indexPath.row - selectedCurrency - 1);
        RPTicker * ticker = [tickers objectAtIndex:row];
        
        static NSNumberFormatter *formatterPrice;
        static NSNumberFormatter *formatterVolume;
        if (!formatterPrice) {
            formatterPrice = [NSNumberFormatter new];
            formatterPrice.numberStyle = NSNumberFormatterDecimalStyle;
            [formatterPrice setMaximumFractionDigits:8];
            
            formatterVolume = [NSNumberFormatter new];
            formatterVolume.numberStyle = NSNumberFormatterDecimalStyle;
            [formatterVolume setMaximumFractionDigits:0];
        }
        
        
        cell.labelGateway.text = ticker.gateway;
//        cell.labelPrice.text = [formatterPrice stringFromNumber:ticker.last];
//        cell.labelPriceOther.text = [formatterPrice stringFromNumber:ticker.last_reverse];

        
        cell.labelPrice.text = @"";
        cell.labelVolume.text = [NSString stringWithFormat:@"%@", [formatterVolume stringFromNumber:ticker.vol]];
        
        if (currency_flip) {
            cell.labelPriceOther.text = [formatterPrice stringFromNumber:ticker.last];
        } else {
            cell.labelPriceOther.text = [formatterPrice stringFromNumber:ticker.last_reverse];
        }
        
        return cell;
    }
    else {
        // Top Cell
        
        CurrencyCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        cell.tag = 1;
        
        NSArray * currencies = dicTickers.allKeys;
        NSInteger row = [self getTopCellIndex:indexPath.row];
        NSString * currency = [currencies objectAtIndex:row];
        RPAverage * average = [dicAverage objectForKey:currency];
        
        static NSNumberFormatter *formatterPrice;
        static NSNumberFormatter *formatterPriceReverse;
        static NSNumberFormatter *formatterVolume;
        if (!formatterPrice) {
            formatterPrice = [NSNumberFormatter new];
            formatterPrice.numberStyle = NSNumberFormatterDecimalStyle;
            [formatterPrice setMaximumFractionDigits:2];
            
            formatterPriceReverse = [NSNumberFormatter new];
            formatterPriceReverse.numberStyle = NSNumberFormatterDecimalStyle;
            [formatterPriceReverse setMaximumFractionDigits:8];
            
            formatterVolume = [NSNumberFormatter new];
            formatterVolume.numberStyle = NSNumberFormatterDecimalStyle;
            [formatterVolume setMaximumFractionDigits:0];
        }
        
        cell.labelCurrency.text = currency;
        //cell.labelPrice.text = @"";
        
        if (currency_flip) {
            [cell.buttonPrice setTitle:[formatterPrice stringFromNumber:average.weighted] forState:UIControlStateNormal];
        }
        else {
            [cell.buttonPrice setTitle:[formatterPriceReverse stringFromNumber:average.weighted_reverse] forState:UIControlStateNormal];
            //cell.labelPriceOther.text = [formatterPriceReverse stringFromNumber:average.weighted_reverse];
        }
        
        
        if (row == selectedCurrency) {
            cell.selected = YES;
            cell.highlighted = YES;
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            cell.selected = NO;
            cell.highlighted = NO;
        }
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedCurrency >= 0) {
        return dicTickers.allKeys.count + [self numberOfTickersFromSelectedCurrency];
    }
    else {
        return dicTickers.allKeys.count;
    }
}

-(NSArray*)indexSetOfSelectedCurrency
{
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    NSUInteger num = [self numberOfTickersFromSelectedCurrency];
    for (int i = 1; i <= num; i++) {
        [indexes addObject:[NSIndexPath indexPathForRow:(selectedCurrency + i) inSection:0]];
    }
    return indexes;
}

-(void)collapseCurrency:(BOOL)animated
{
    NSArray * indexes = [self indexSetOfSelectedCurrency];
    selectedCurrency = -1;
    
    if (animated) {
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

-(void)expandCurrency:(NSUInteger)row
{
    selectedCurrency = [self getTopCellIndex:row];
    
    NSArray * indexes = [self indexSetOfSelectedCurrency];
    [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCurrencySelected]) {
        // Expand
        [self expandCurrency:indexPath.row];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (indexPath.row == selectedCurrency) {
        // Collapse tableview
        [self collapseCurrency:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSInteger topRow = [self getTopCellIndex:indexPath.row];
        
        // Expand and collapse
        [self collapseCurrency:NO];
        //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self expandCurrency:topRow];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:topRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isBottomCell:indexPath.row]) {
        return NO;
    }
    else {
        return YES;
    }
}

-(void)updateRippleCharts
{
    [[RPTickerManager shared] updateTickers:^(NSDictionary *t, NSDictionary *a, NSError *error) {
        if (!error) {
            dicTickers = t;
            dicAverage = a;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    selectedCurrency = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRippleCharts) name: UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
