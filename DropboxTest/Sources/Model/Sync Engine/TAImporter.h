//
// Created by Jan on 19/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAImporter : NSObject

-(id) initWithManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

-(void) importDBRecords:(NSArray *) dbRecords;
@end