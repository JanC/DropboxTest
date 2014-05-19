//
// Created by Jan on 17/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TATaskDataSource.h"

#pragma mark - Constants



@interface TATaskDataSource ()

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, copy) TAListViewControllerConfigureCellBlock configureCellBlock;
@property(nonatomic, strong) NSArray *tasks;
@property(nonatomic, strong) DBTable *tasksTbl;

@end

@implementation TATaskDataSource
{
}

- (id)initWithTableView:(UITableView *)tableView
                dbStore:(DBDatastore *)store
     configureCellBlock:(TAListViewControllerConfigureCellBlock)configureCellBlock
{
    self = [self init];
    if ( self )
    {
        NSAssert(configureCellBlock, @"must not be nil");

        self.tableView = tableView;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TATAListViewControllerCellId];
        self.store = store;
        self.tasksTbl = [self.store getTable:@"tasks"];
        self.configureCellBlock = configureCellBlock;

        __weak typeof(self) weakSelf = self;
        [self.store addObserver:self block:^() {

            if (weakSelf.store.status & DBDatastoreIncoming) {
                NSDictionary *changes = [weakSelf.store sync:nil];
                // Handle the updated data
                [weakSelf.tableView reloadData];

            }
        }];

        [self reloadDataSource];
    }
    return self;
}

#pragma mark - Public

- (void)addTask:(NSString *)taskName
{
    [self.tasksTbl insert:@{@"taskname" : taskName, @"completed" : @NO}];

    DBError *error;
    [self.store sync:&error];
    if ( error )
    {
        NSLog(@"Failed to sync: %@", error.localizedDescription);
    }
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        DBRecord *task = self.tasks[(NSUInteger) indexPath.row];
        [task deleteRecord];
        [self reloadDataSource];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // completed, not completed
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TATAListViewControllerCellId forIndexPath:indexPath];
    DBRecord *task = self.tasks[(NSUInteger) indexPath.row];

    self.configureCellBlock(cell, task);

    return cell;
}

#pragma mark - Private

- (void)reloadDataSource
{
    self.tasks = [self.tasksTbl query:nil error:nil];
    [self.tableView reloadData];
}

@end