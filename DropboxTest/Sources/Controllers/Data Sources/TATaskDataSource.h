//
// Created by Jan on 17/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAListViewController.h"

@interface TATaskDataSource : NSObject <UITableViewDataSource>

- (id)initWithTableView:(UITableView *)tableView
                dbStore:(DBDatastore *)store
     configureCellBlock:(TAListViewControllerConfigureCellBlock) configureCellBlock;

-(void) addTask:(NSString *) taskName;

@end