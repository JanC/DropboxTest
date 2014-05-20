//
// Created by Jan on 17/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAListViewController.h"

#import "TAFetchedResultControllerDataSource.h"
#import "TAPeristentStack.h"
#import "TAPeristentStack+TAAppDelegate.h"
#import "TATask.h"
#import "NSManagedObject+TAManagedObject.h"
#import "NSManagedObjectContext+TAManagedObjectContext.h"

NSString *const TATAListViewControllerCellId = @"TATAListViewControllerCellId";

@interface TAListViewController () <UISearchBarDelegate, UITableViewDelegate>

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) DBDatastore *store;

@property(nonatomic, strong, readwrite) UISearchBar *searchBar;
@property(nonatomic, strong) TAFetchedResultControllerDataSource *dataSource;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation TAListViewController
{
}

- (void)loadView
{
    [super loadView];

    //
    // Setup Table View
    //
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"Add task";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;


    //
    // Data Source
    //
    self.context = [TAPeristentStack appPersistentStack].mainContext;
    self.dataSource = [[TAFetchedResultControllerDataSource alloc] initWithTableView:self.tableView
                                                                             context:self.context
                                                                  configureCellBlock:^(UITableViewCell *cell, id model) {
                                                                      TATask *task = model;
                                                                      cell.textLabel.text = task.name;
                                                                      cell.textLabel.textColor = task.deleted ? [UIColor grayColor] : [UIColor blackColor];
                                                                      cell.textLabel.textColor = task.completed ? [UIColor grayColor] : [UIColor blackColor];
                                                                  }];

    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[TATask entityName]];
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deleted = NO"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    self.dataSource.fetchedResultsController = fetchedResultsController;

    //
    // Auto Layout
    //
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, self.searchBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if ( !account )
    {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

#pragma mark 
#pragma mark - Protocols

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TATask *task = [self.dataSource objectAtIndexPath:indexPath];
    task.completed = !task.completed;
    [self.context saveContext];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Add task %@", self.searchBar.text);
    [self.dataSource addTask:self.searchBar.text];

    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];


}

#pragma mark - Private



@end