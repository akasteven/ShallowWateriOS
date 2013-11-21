//
//  ShallowWaterAppDelegate.h
//  ShallowWater
//
//  Created by StevenQiu on 13-11-21.
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
