//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAFetchedResultControllerDataSource.h"
#import "TATask.h"
#import "NSManagedObject+TAManagedObject.h"
#import "NSManagedObjectContext+TAManagedObjectContext.h"
#import "TASyncEngine.h"

@interface TAFetchedResultControllerDataSource() <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSManagedObjectContext *context;
@property(nonatomic, copy) TAListViewControllerConfigureCellBlock configureCellBlock;

@end


@implementation TAFetchedResultControllerDataSource
{
}

- (id)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context configureCellBlock:(TAListViewControllerConfigureCellBlock)configureCellBlock
{
    self = [super init];
    if(self)
    {
        NSAssert(configureCellBlock, @"must not be nil");

        self.tableView = tableView;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TATAListViewControllerCellId];
        self.context = context;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}


#pragma mark - Public

- (void)addTask:(NSString *)taskName
{

    TATask *task = [[TATask alloc] initWithEntity:[NSEntityDescription entityForName:[TATask entityName] inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    task.name = taskName;
    [self.context saveContext];

}


#pragma mark
#pragma mark - Protocols

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TATAListViewControllerCellId forIndexPath:indexPath];

    TATask *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.configureCellBlock(cell, task);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        TATask *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        task.deleted = YES;
        [self.context saveContext];
    }
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if(type == NSFetchedResultsChangeInsert)
    {
        [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }

    if(type == NSFetchedResultsChangeDelete)
    {
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }

    if(type == NSFetchedResultsChangeUpdate)
    {
        if( [[self.tableView indexPathsForVisibleRows] containsObject:indexPath] )
        {
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}



#pragma mark - Accessors

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    _fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;

    [[TASyncEngine sharedEngine] triggerSync];

    NSError *error;
    [_fetchedResultsController performFetch:&error];

    if(error)
    {
        NSLog(@"%@", error);
    }
}

@end