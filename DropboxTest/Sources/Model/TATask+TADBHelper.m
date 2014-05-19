//
// Created by Jan on 19/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TATask+TADBHelper.h"
#import "NSManagedObject+TAManagedObject.h"

@implementation TATask (TADBHelper)

+(TATask *) createOrUpdateWithDBRecord:(DBRecord *) dbRecord inContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TATask entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %@", dbRecord.recordId];

    NSError *error;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];

    TATask *task = [result firstObject];
    if(!task)
    {
        task = [[TATask alloc] initWithEntity:[NSEntityDescription entityForName:[TATask entityName] inManagedObjectContext:context]
                       insertIntoManagedObjectContext:context];
    }

    // populate the data

    task.name = dbRecord[@"taskname"];
    task.completed = [dbRecord[@"completed"] boolValue];
    task.uid = dbRecord.recordId;

    return task;
}
@end