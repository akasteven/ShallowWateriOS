//
//  BreakingWaveDemo.mm
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "BreakingWaveDemo.h"

@implementation BreakingWaveDemo

- (id) init {
	
	if ((self = [super init])) {
    
        [Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
        [Isgl3dDirector sharedInstance].shadowAlpha = 0.1;
        
        [self setupCamera];
        [self setupScene];
        [self setupParticle];
        
		[self schedule:@selector(tick:)];
	}
	return self;
}

-(void) setupCamera{
    
    _cameraController = [[Isgl3dDemoCameraController alloc] initWithCamera:self.camera andView:self];
    _cameraController.orbit = 70;
    _cameraController.theta = 100;
    _cameraController.phi = 30;
    _cameraController.doubleTapEnabled = NO;
}


-(void) setupScene{
    
    Isgl3dShadowCastingLight *light1  = [[Isgl3dShadowCastingLight alloc] initWithHexColor:@"333333" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.001];
    light1.position = iv3(8, 8, 8);
    light1.isVisible = YES;
    [self.scene addChild:light1];
    
    _container = [[self.scene createNode] retain];
    
    _water = [WaterMeshBreakingWave initWithGeometry:120 dx:0.25];
    [_water startAnimation];
    Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"water1.jpg" shininess:0.9];
    _tsunami = [_container createNodeWithMesh:_water andMaterial:material];
    _tsunami.alpha = 1.0;
    _tsunami.doubleSided = YES;
    
}

-(void) setupParticle{
    
    Isgl3dTextureMaterial *  spriteMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"particle.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
    myparticleSystem = [Isgl3dParticleSystem particleSystem];
    [myparticleSystem setAttenuation:0.01 linear:0.02 quadratic:0.007];
    [self.scene createNodeWithParticle:myparticleSystem andMaterial:spriteMaterial];

    [_water setParticleSystem:myparticleSystem];

    
}

- (void) dealloc {

	[super dealloc];
}


- (void) tick:(float)dt {
    
    [_cameraController update];
    NSLog(@"%d Particles generated :", [myparticleSystem numberOfPoints]);

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
    Isgl3dView *view = [BreakingWaveDemo view];
    [[Isgl3dDirector sharedInstance] addView:view];
    NSLog(@"What the fuck is going on!");
}

@end
