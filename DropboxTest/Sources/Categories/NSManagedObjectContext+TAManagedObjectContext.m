//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "NSManagedObjectContext+TAManagedObjectContext.h"

@implementation NSManagedObjectContext (TAManagedObjectContext)

-(void) saveContext
{
    if(self.hasChanges)
    {
        NSError *error;
        [self save:&error];
        if(error)
        {
            NSLog(@"%@", error);
        }
    }

}

@end