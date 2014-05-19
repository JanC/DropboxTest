//
// Created by Jan on 19/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TATask.h"

@interface TATask (TADBHelper)

+(TATask *) createOrUpdateWithDBRecord:(DBRecord *) dbRecord inContext:(NSManagedObjectContext *) context;

@end