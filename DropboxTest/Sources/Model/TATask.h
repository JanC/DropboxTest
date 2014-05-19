//
//  TATask.h
//  DropboxTest
//
//  Created by Jan on 18/05/14.
//  Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TATask : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, assign) BOOL deleted;

@end
