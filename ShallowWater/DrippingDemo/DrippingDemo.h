//
//  DrippingDemo.h
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "isgl3d.h"
#import "WaterTerrain.h"
#import "WaterMeshDripping.h"
#import "Isgl3dGLParticle.h"
#import "Isgl3dDemoCameraController.h"


@interface DrippingDemo : Isgl3dBasic3DView {

@private
    
    Isgl3dDemoCameraController * _cameraController;
    WaterMeshDripping *_water;
    WaterTerrain * _terrainMesh;
	Isgl3dMeshNode * _tsunami;
    Isgl3dMeshNode *_terrain;
    Isgl3dNode *_container;
    Isgl3dParticleSystem *myparticleSystem;
    
}
@end


#import "ShallowWaterAppDelegate.h"

@interface AppDelegate : ShallowWaterAppDelegate

-(void) createView;

@end