//
//  TemplateView.h
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "isgl3d.h"
#import "WaterTerrain.h"
#import "ShallowWaterMesh.h"
#import "Isgl3dGLParticle.h"
#import "Isgl3dDemoCameraController.h"


@interface TemplateView : Isgl3dBasic3DView {

@private
    
    Isgl3dDemoCameraController * _cameraController;
    ShallowWaterMesh *_water;
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