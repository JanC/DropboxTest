//
// Created by Jan on 18/05/14.
// Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TASyncEngine : NSObject

+(id) sharedEngine;

-(void) startEngine;

/**
* Triggers loading sync that populates incoming data to local core data
*/
-(void) triggerSync;

@end