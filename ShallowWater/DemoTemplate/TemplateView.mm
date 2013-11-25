//
//  TemplateView.mm
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "TemplateView.h"

@implementation TemplateView

- (id) init {
	
	if ((self = [super init])) {
    
        [Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
        [Isgl3dDirector sharedInstance].shadowAlpha = 0.1;
        
        [self setupCamera];
        [self setupScene];
        
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


-(void) setupScene{
    
    Isgl3dShadowCastingLight *light1  = [[Isgl3dShadowCastingLight alloc] initWithHexColor:@"333333" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.001];
    light1.position = iv3(8, 8, 8);
    light1.isVisible = YES;
    [self.scene addChild:light1];
    
    _container = [[self.scene createNode] retain];
    
    _water = [ShallowWaterMesh initWithGeometry:100 dx:0.25];
    [_water startAnimation];
    Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"water05.png" shininess:0.9];
    _tsunami = [_container createNodeWithMesh:_water andMaterial:material];
    _tsunami.alpha = 1.0;
    _tsunami.doubleSided = YES;
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
