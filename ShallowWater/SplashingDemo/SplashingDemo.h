//
//  SplashingDemo.h
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "isgl3d.h"
#import "WaterTerrain.h"
#import "WaterMeshSplashing.h"
#import "Isgl3dGLParticle.h"
#import "Isgl3dDemoCameraController.h"

class btDefaultCollisionConfiguration;
class btDbvtBroadphase;
class btCollisionDispatcher;
class btSequentialImpulseConstraintSolver;
class btDiscreteDynamicsWorld;
@class Isgl3dPhysicsWorld;

@interface SplashingDemo : Isgl3dBasic3DView {

@private
    
    Isgl3dDemoCameraController * _cameraController;
    WaterMeshSplashing *_water;
    WaterTerrain * _terrainMesh;
	Isgl3dMeshNode * _tsunami;
    Isgl3dMeshNode *_terrain;
    Isgl3dNode *_container;
    Isgl3dParticleSystem *myparticleSystem;
    
    NSMutableArray * _physicsObjects;
    btDefaultCollisionConfiguration * _collisionConfig;
    btDbvtBroadphase * _broadphase;
    btCollisionDispatcher * _collisionDispatcher;
    btSequentialImpulseConstraintSolver * _constraintSolver;
    btDiscreteDynamicsWorld * _discreteDynamicsWorld;
    Isgl3dPhysicsWorld * _physicsWorld;
    
}
@end


#import "ShallowWaterAppDelegate.h"

@interface AppDelegate : ShallowWaterAppDelegate

-(void) createView;

@end