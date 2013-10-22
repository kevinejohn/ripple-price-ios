//
//  GatewayPriceCell.h
//  Ripple Report
//
//  Created by Kevin Johnson on 10/21/13.
//  Copyright (c) 2013 Ripple Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GatewayPriceCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * labelGateway;
@property (strong, nonatomic) IBOutlet UILabel * labelPrice;
@property (strong, nonatomic) IBOutlet UILabel * labelPriceOther;
@property (strong, nonatomic) IBOutlet UILabel * labelVolume;


@end
