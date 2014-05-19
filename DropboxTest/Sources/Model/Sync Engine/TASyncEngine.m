//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TASyncEngine.h"
#import "TAPeristentStack.h"
#import "TAPeristentStack+TAAppDelegate.h"
#import "TATask.h"
#import "NSManagedObjectContext+TAManagedObjectContext.h"

@interface TASyncEngine ()

@property(nonatomic, strong) DBDatastore *store;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
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
    }

    return self;
}

-(void) startEngine
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[TAPeristentStack appPersistentStack].mainContext];
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
    if(!objects)
    {
        return;
    }
    DBTable *table = [self.store getTable:@"tasks"];
    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {
        DBRecord *record = [table insert:@{@"taskname" : task.name, @"completed" : task.completed ? @YES : @NO }];

        task.uid = record.recordId;

    }];

    [[TAPeristentStack appPersistentStack].mainContext saveContext];
    [self syncWithBackend];
}

-(void) updateObjects:(NSSet *) objects
{
    if(!objects)
    {
        return;
    }

    NSMutableSet *objectsForDeletion = [NSMutableSet set];
    DBTable *table = [self.store getTable:@"tasks"];
    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {

        if(task.deleted)
        {
            [objectsForDeletion addObject:task];

        }
        else
        {
            NSArray *tasks = [table query:@{@"id" : task.uid } error:nil];
            DBRecord *record = [tasks firstObject];
            record[@"taskname"] = task.name;
        }
    }];

    [self deleteObjects:objectsForDeletion];
    [self syncWithBackend];
}


-(void) deleteObjects:(NSSet *) objects
{
    if(!objects)
    {
        return;
    }
    DBTable *table = [self.store getTable:@"tasks"];


    NSMutableArray *coreDataIds = [NSMutableArray array];

    [objects enumerateObjectsUsingBlock:^(TATask *task, BOOL *stop) {
        [coreDataIds addObject:task.objectID];
        NSArray *tasks = [table query:@{@"id" : task.uid } error:nil];
        DBRecord *record = [tasks firstObject];
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
    if(error)
    {
        NSLog(@"sync error: %@", error);

    }
}

@end