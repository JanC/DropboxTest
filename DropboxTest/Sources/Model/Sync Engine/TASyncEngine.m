//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TASyncEngine.h"
#import "TAPeristentStack.h"
#import "TAPeristentStack+TAAppDelegate.h"
#import "TATask.h"
#import "NSManagedObjectContext+TAManagedObjectContext.h"
#import "TAImporter.h"

@interface TASyncEngine ()

@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property(nonatomic, strong, readwrite) TAImporter *importer;
@end

@implementation TASyncEngine
{
}

+ (id)sharedEngine
{
    static dispatch_once_t onceToken;
    static TASyncEngine *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TASyncEngine alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        self.backgroundContext = [TAPeristentStack appPersistentStack].backgroundContext;

        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        NSAssert(account, @"Dropbox must be configured at this point");
        self.store = [DBDatastore openDefaultStoreForAccount:account error:nil];

        self.importer = [[TAImporter alloc] initWithManagedObjectContext:self.backgroundContext];

        __weak typeof (self) weakSelf = self;
        [self.store addObserver:self block:^() {
            if ( weakSelf.store.status & DBDatastoreIncoming )
            {
                NSDictionary *changes = [weakSelf.store sync:nil];
                // Handle the updated data
                [weakSelf.importer importDBRecords:changes[@"tasks"]];
            }
        }];
    }

    return self;
}

- (void)startEngine
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[TAPeristentStack appPersistentStack].mainContext];
}

- (void)triggerSync
{
    DBTable *table = [self.store getTable:@"tasks"];
    NSArray *tasks = [table query:nil error:nil];
    [self.importer importDBRecords:tasks];
}

#pragma mark - Private

- (void)handleDataModelChange:(NSNotification *)note
{
    NSLog(@"Managed object changed");
    NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];

    [self addObjects:insertedObjects];
    [self updateObjects:updatedObjects];
    //[self deleteObjects:deletedObjects];
}

- (void)addObjects:(NSSet *)objects
{
    if ( !objects )
    {
        return;
    }
    DBTable *table = [self.store getTable:@"tasks"];
    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {
        // if uid already set, we do not insert
        if ( !task.uid )
        {
            DBRecord *record = [table insert:@{@"taskname" : task.name, @"completed" : task.completed ? @YES : @NO}];
            task.uid = record.recordId;
        }
    }];

    [[TAPeristentStack appPersistentStack].mainContext saveContext];
    [self syncWithBackend];
}

- (void)updateObjects:(NSSet *)objects
{
    NSMutableSet *objectsForDeletion = [NSMutableSet set];
    DBTable *table = [self.store getTable:@"tasks"];
    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {

        if ( task.deleted )
        {
            [objectsForDeletion addObject:task];
        }
        else
        {

            DBRecord *record = [table getRecord:task.uid error:nil];
            record[@"taskname"] = task.name;
            record[@"completed"] = @(task.completed);
        }
    }];

    [self deleteObjects:objectsForDeletion];
    [self syncWithBackend];
}

- (void)deleteObjects:(NSSet *)objects
{
    if ( !objects )
    {
        return;
    }
    DBTable *table = [self.store getTable:@"tasks"];

    NSMutableArray *coreDataIds = [NSMutableArray array];

    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {
        [coreDataIds addObject:task.objectID];

        DBRecord *record = [table getRecord:task.uid error:nil];
        [record deleteRecord];

        // delete from core data as well
    }];

    [self.backgroundContext performBlock:^{
        [coreDataIds enumerateObjectsUsingBlock:^(NSManagedObjectID *objId, NSUInteger idx, BOOL *stop) {
            NSManagedObject *task = [self.backgroundContext objectWithID:objId];
            [self.backgroundContext deleteObject:task];
        }];

        [self.backgroundContext saveContext];
    }];
}

- (void)syncWithBackend
{
    DBError *error;
    [self.store sync:&error];
    if ( error )
    {
        NSLog(@"sync error: %@", error);
    }
}

@end