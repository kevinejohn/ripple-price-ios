//
//  SettingsViewController.m
//  Ripple Report
//
//  Created by Kevin Johnson on 10/25/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "RPTickerManager.h"
#import <MessageUI/MFMailComposeViewController.h>


#define FEEDBACK_EMAIL @"ios-support@ripple.com"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    NSArray * currencies;
    
    NSMutableSet * setFilter;
}

//@property (weak, nonatomic) IBOutlet UILabel * labelConvertionType;
//@property (weak, nonatomic) IBOutlet UISwitch * switchConvertionType;
@property (weak, nonatomic) IBOutlet UISegmentedControl * segmentControlType;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation SettingsViewController

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
	switch (result)
	{
		case MFMailComposeResultSent: {
			UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Thank You!"
                                  message: nil
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
			break;
		case MFMailComposeResultSaved:
			//[self sendDidFinish];
			break;
		case MFMailComposeResultCancelled:
			//[self sendDidCancel];
			break;
		case MFMailComposeResultFailed:
			//[self sendDidFailWithError:nil];
			break;
	}
}

-(IBAction)feedbackButtonPressed:(id)sender
{
    if (![MFMailComposeViewController canSendMail]) {
        // TODO: Cannot send email
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Email is not configured on this device"
                              message: [NSString stringWithFormat:@"Please send an email to %@", FEEDBACK_EMAIL]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	if (!mailController) {
		// e.g. no mail account registered (will show alert)
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Email is not configured on this device"
                              message: [NSString stringWithFormat:@"Please send an email to %@", FEEDBACK_EMAIL]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
		return;
	}
	
	mailController.mailComposeDelegate = self;
	
	[mailController setSubject:[NSString stringWithFormat:@"%@ %@ Feedback",
                                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                ]];
    [mailController setToRecipients:[NSArray arrayWithObject:FEEDBACK_EMAIL]];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

-(IBAction)switchPressed:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        //self.labelConvertionType.text = @"1 XRP = USD";
        [RPTickerManager shared].xrpOverCurrency = NO;
        
    }
    else {
        //self.labelConvertionType.text = @"1 USD = XRP";
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
    
    if ([RPTickerManager shared].xrpOverCurrency) {
        [self.segmentControlType setSelectedSegmentIndex:1];
    }
    else {
        [self.segmentControlType setSelectedSegmentIndex:0];
    }
    
    //[self switchPressed:self.switchConvertionType];
    
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
