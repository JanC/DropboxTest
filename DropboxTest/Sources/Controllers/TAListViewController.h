//
// Created by Jan on 17/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TAListViewControllerConfigureCellBlock)(UITableViewCell *cell, id task);

extern NSString *const TATAListViewControllerCellId;

@class TATaskDataSource;

@interface TAListViewController : UIViewController

@end