//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAPeristentStack.h"

@interface TAPeristentStack ()

@property(nonatomic, strong, readwrite) NSURL *modelURL;
@property(nonatomic, strong, readwrite) NSURL *storeURL;

@property(nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@end

@implementation TAPeristentStack
{
}

- (id)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    self = [super init];
    if ( self )
    {
        self.modelURL = modelURL;
        self.storeURL = storeURL;
        [self setupStack];
    }
    return self;
}



#pragma mark - Helpers

- (void)setupStack
{

    self.mainContext = [self createManagedContextWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.undoManager = [[NSUndoManager alloc] init];


//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleDataModelChange:)
//                                                 name:NSManagedObjectContextObjectsDidChangeNotification
//                                               object:self.mainContext];

    self.backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.backgroundContext.parentContext = self.mainContext;


    //
    // merge changes from background context to main one
    //

//
//    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
//                                                      object:nil
//                                                       queue:nil usingBlock:^(NSNotification *note) {
//        // merge from background to main
//
//        if ( note.object != self.mainContext )
//        {
//            [self.mainContext performBlock:^{
//                [self.mainContext mergeChangesFromContextDidSaveNotification:note];
//            }];
//        }
//
//        // merge from main to background
//        if ( note.object != self.backgroundContext )
//        {
//            [self.backgroundContext performBlock:^{
//                [self.backgroundContext mergeChangesFromContextDidSaveNotification:note];
//            }];
//        }
//    }];
}

- (NSManagedObjectContext *)createManagedContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];

    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];

    managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    NSError *error;
    [managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                  configuration:nil
                                                                            URL:self.storeURL
                                                                        options:nil error:&error];
    if(error)
    {
        NSLog(@"%@", error);
    }

    return managedObjectContext;
}



#pragma mark - Private

- (void)handleDataModelChange:(NSNotification *)note
{
    NSLog(@"Managed object changed");
    NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
}
@end