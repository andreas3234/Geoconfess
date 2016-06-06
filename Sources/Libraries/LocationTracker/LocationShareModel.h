//
//  LocationShareModel.h
//  Location
//
//  Created by Christian
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationShareModel : NSObject

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) NSTimer * updateIn30Mins;
@property (nonatomic) NSTimer * updateIn2Mins;
@property (nonatomic) BackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;

+(id)sharedModel;

@end
