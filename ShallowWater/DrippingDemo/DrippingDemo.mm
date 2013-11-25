//
//  DrippingDemo.mm
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "DrippingDemo.h"

@implementation DrippingDemo

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
    _cameraController.orbit = 60;
    _cameraController.theta = 90;
    _cameraController.phi = 45;
    _cameraController.doubleTapEnabled = NO;
}


-(void) setupScene{
    
    
    //Set light source
    Isgl3dShadowCastingLight *light1  = [[Isgl3dShadowCastingLight alloc] initWithHexColor:@"333333" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.001];
    light1.position = iv3(8, 8, 8);
    light1.isVisible = YES;
    [self.scene addChild:light1];
    
    //Create the container of the scene
    _container = [[self.scene createNode] retain];
    
    //Create the water
    _water = [WaterMeshDripping initWithGeometry:100 dx:0.25];
    [_water startAnimation];
    Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"water05.png" shininess:0.9];
    _tsunami = [_container createNodeWithMesh:_water andMaterial:material];
    _tsunami.alpha = 0.9;
    _tsunami.doubleSided = YES;
    
    // Create a water pool
    Isgl3dTextureMaterial * materialPool = [Isgl3dTextureMaterial materialWithTextureFile:@"wall.jpg" shininess:0.9];

    Isgl3dCube * left = [Isgl3dCube meshWithGeometry:25 height:4 depth:10 nx:2 ny:2];
    Isgl3dMeshNode * leftNode = [ _container createNodeWithMesh:left andMaterial:materialPool];
    Isgl3dVector3 leftPositon = iv3Create(0.0, 3, -17.5);
    [leftNode setPosition:leftPositon];
    
    Isgl3dCube * right = [Isgl3dCube meshWithGeometry:25 height:4 depth:10 nx:2 ny:2];
    Isgl3dMeshNode * rightNode = [ _container createNodeWithMesh:right andMaterial:materialPool];
    Isgl3dVector3 rightPositon = iv3Create(0.0, 3, 17.5);
    [rightNode setPosition:rightPositon];
    
    Isgl3dCube * front = [Isgl3dCube meshWithGeometry:10 height:4 depth:45 nx:2 ny:2];
    Isgl3dMeshNode * frontNode = [ _container createNodeWithMesh:front andMaterial:materialPool];
    Isgl3dVector3 frontPositon = iv3Create(17.5, 3, 0.0);
    [frontNode setPosition:frontPositon];
    
    Isgl3dCube * back = [Isgl3dCube meshWithGeometry:10 height:4 depth:45 nx:2 ny:2];
    Isgl3dMeshNode * backNode = [ _container createNodeWithMesh:back andMaterial:materialPool];
    Isgl3dVector3 backPositon = iv3Create(-17.5, 3, 0.0);
    [backNode setPosition:backPositon];
    
    Isgl3dCube * bottom = [Isgl3dCube meshWithGeometry:25.5 height:1 depth:25.5 nx:2 ny:2];
    Isgl3dMeshNode * bottomNode = [ _container createNodeWithMesh:bottom andMaterial:materialPool];
    Isgl3dVector3 bottomPositon = iv3Create(0, 1.5, 0);
    [bottomNode setPosition:bottomPositon];

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
    Isgl3dView *view = [DrippingDemo view];
    [[Isgl3dDirector sharedInstance] addView:view];
    NSLog(@"What the fuck is going on!");
}

@end
