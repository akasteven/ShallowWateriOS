//
//  HelloWorldView.m
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "TemplateView.h"

@implementation TemplateView

- (id) init {
	
	if ((self = [super init])) {
        
        [self setupCamera];
        
        [Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
        [Isgl3dDirector sharedInstance].shadowAlpha = 0.1;

		[self schedule:@selector(tick:)];
	}
	return self;
}

-(void) setupCamera{
    
    _cameraController = [[Isgl3dDemoCameraController alloc] initWithCamera:self.camera andView:self];
    _cameraController.orbit = 40;
    _cameraController.theta = 120;
    _cameraController.phi = 30;
    _cameraController.doubleTapEnabled = NO;
}

- (void) dealloc {

	[super dealloc];
}


- (void) tick:(float)dt {
    
    [_cameraController update];

}

// Callback for touch event on 3D object
- (void) objectTouched:(Isgl3dEvent3D *)event {
	// Update camera target
	_cameraController.target = event.object;
}

- (void) onActivated {
	// Add camera controller to touch-screen manager
	[[Isgl3dTouchScreen sharedInstance] addResponder:_cameraController];
}

@end


@implementation AppDelegate

-(void) createView{
    
    [Isgl3dDirector sharedInstance].deviceOrientation = Isgl3dOrientationLandscapeLeft;
    Isgl3dView *view = [TemplateView view];
    [[Isgl3dDirector sharedInstance] addView:view];
    NSLog(@"What the fuck is going on!");
}

@end
