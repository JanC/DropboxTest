//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAListViewController.h"



@interface TAFetchedResultControllerDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;

- (id)initWithTableView:(UITableView *)tableView
                context:(NSManagedObjectContext *)context
     configureCellBlock:(TAListViewControllerConfigureCellBlock) configureCellBlock;

-(void) addTask:(NSString *) taskName;

@end