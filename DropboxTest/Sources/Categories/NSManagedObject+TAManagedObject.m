//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "NSManagedObject+TAManagedObject.h"

@implementation NSManagedObject (TAManagedObject)




+(NSString *) entityName
{
    return NSStringFromClass([self class]);
}


@end