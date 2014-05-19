//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import "TAPeristentStack+TAAppDelegate.h"
#import "TAAppDelegate.h"

@implementation TAPeristentStack (TAAppDelegate)

+(TAPeristentStack *) appPersistentStack
{
    TAAppDelegate *appDelegate = (TAAppDelegate *) [UIApplication sharedApplication].delegate;
    return appDelegate.peristentStack;
}

@end