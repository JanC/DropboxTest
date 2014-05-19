//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAPeristentStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;

-(id) initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *) storeURL;


@end