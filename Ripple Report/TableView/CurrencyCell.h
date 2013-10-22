//
//  CurrencyCell.h
//  Ripple Report
//
//  Created by Kevin Johnson on 10/21/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * labelCurrency;
@property (strong, nonatomic) IBOutlet UILabel * labelPrice;
@property (strong, nonatomic) IBOutlet UILabel * labelPriceOther;

@end
