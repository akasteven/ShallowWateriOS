//
//  ShallowWaterAppDelegate.h
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

@class Isgl3dViewController;

@interface ShallowWaterAppDelegate : NSObject <UIApplicationDelegate> {

@private
	Isgl3dViewController * _viewController;
	UIWindow * _window;
}

@property (nonatomic, retain) UIWindow * window;

@end
