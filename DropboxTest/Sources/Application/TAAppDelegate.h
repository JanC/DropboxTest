//
//  TAAppDelegate.h
//  DropboxTest
//
//  Created by Jan on 17/05/14.
//  Copyright (c) 2014 Tequila Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAPeristentStack;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong, readonly) TAPeristentStack *peristentStack;

@property (strong, nonatomic) UIWindow *window;

@end
