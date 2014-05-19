//
// Created by Jan on 19/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAImporter.h"
#import "TATask.h"
#import "TATask+TADBHelper.h"
#import "NSManagedObjectContext+TAManagedObjectContext.h"

@interface TAImporter ()

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation TAImporter
{
}

-(id) initWithManagedObjectContext:(NSManagedObjectContext *) managedObjectContext
{
    self = [super init];
    if ( self )
    {
        self.managedObjectContext = managedObjectContext;
    }

    return self;
}


-(void) importDBRecords:(NSArray *) dbRecords
{

    [self.managedObjectContext performBlock:^{

        [dbRecords enumerateObjectsUsingBlock:^(DBRecord * dbRecord, NSUInteger idx, BOOL *stop) {
            [TATask createOrUpdateWithDBRecord:dbRecord inContext:self.managedObjectContext];
        }];

        [self.managedObjectContext saveContext];
    }];
}

@end