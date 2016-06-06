//
//  BackgroundTaskManager.h
//  Tapin
//
//  Created by Christian on 11/20/14.
//  Copyright (c) 2014 Christian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
