//
//  SplashingDemo.mm
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-23.
//  Copyright 2013年 vrlab@buaa. All rights reserved.
//

#import "SplashingDemo.h"

#import "Isgl3dPhysicsWorld.h"
#import "Isgl3dPhysicsObject3D.h"
#import "Isgl3dMotionState.h"

#include "btBulletDynamicsCommon.h"
#include "btBox2dShape.h"
#include "btBoxShape.h"
#include "btHeightfieldTerrainShape.h"

@implementation SplashingDemo

- (id) init {
	
	if ((self = [super init])) {
    
        [Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
        [Isgl3dDirector sharedInstance].shadowAlpha = 0.1;
        
        [self setupCamera];
        [self setupScene];
        [self setupParticle];
        [self setupPhysicalObjects];
        

		[self schedule:@selector(tick:)];
	}
	return self;
}

-(void) setupCamera{
    
    _cameraController = [[Isgl3dDemoCameraController alloc] initWithCamera:self.camera andView:self];
    _cameraController.orbit = 60;
    _cameraController.theta = 90;
    _cameraController.phi = 40;
    _cameraController.doubleTapEnabled = NO;
}


-(void) setupScene{
    
    Isgl3dShadowCastingLight *light1  = [[Isgl3dShadowCastingLight alloc] initWithHexColor:@"333333" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.001];
    light1.position = iv3(8, 8, 8);
    light1.isVisible = YES;
    [self.scene addChild:light1];
    
    _container = [[self.scene createNode] retain];
    
    _water = [WaterMeshSplashing initWithGeometry:100 dx:0.25];
    [_water startAnimation];
    Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"water05.png" shininess:0.9];
    _tsunami = [_container createNodeWithMesh:_water andMaterial:material];
    _tsunami.alpha = 0.9;
    _tsunami.doubleSided = YES;
    
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

-(void) setupParticle{
    
    Isgl3dTextureMaterial *  spriteMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"particle.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
    myparticleSystem = [Isgl3dParticleSystem particleSystem];
    [myparticleSystem setAttenuation:0.01 linear:0.02 quadratic:0.007];
    [self.scene createNodeWithParticle:myparticleSystem andMaterial:spriteMaterial];

    [_water setParticleSystem:myparticleSystem];

    
}

-(void) setupPhysicalObjects{
    _physicsObjects = [[NSMutableArray alloc] init];
    
    _collisionConfig = new btDefaultCollisionConfiguration();
    _collisionDispatcher = new btCollisionDispatcher(_collisionConfig);
    _broadphase = new btDbvtBroadphase();
    _constraintSolver = new btSequentialImpulseConstraintSolver();
    _discreteDynamicsWorld = new btDiscreteDynamicsWorld(_collisionDispatcher, _broadphase, _constraintSolver, _collisionConfig);
    _discreteDynamicsWorld->setGravity(btVector3(0,-10,0));
    
    _physicsWorld = [[Isgl3dPhysicsWorld alloc] init];
    [_physicsWorld setDiscreteDynamicsWorld:_discreteDynamicsWorld];
    [self.scene addChild:_physicsWorld];
    
    btVector3 vel0 = btVector3(0, 0, 0);

    
    Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"wood4.jpg" shininess:0.9];
    Isgl3dCylinder * cylinderMesh = [Isgl3dCylinder meshWithGeometry:4 radius:1 ns:32 nt:32 openEnded:NO];
    Isgl3dMeshNode * woodNode = [_container createNodeWithMesh:cylinderMesh andMaterial:material];
    Isgl3dMeshNode * woodNode2 = [_container createNodeWithMesh:cylinderMesh andMaterial:material];
    
    woodNode.rotationX = 90.0;
    woodNode.x = 0.0;
    woodNode.y = 10.0;
    woodNode.z = 0.0;
    
    woodNode2.rotationX = 90.0;
    woodNode2.rotationZ = 90.0;
    woodNode2.x = 3.0;
    woodNode2.y = 8.0;
    woodNode2.z = 5.0;
    
    btCollisionShape * woodShape =  new btCylinderShape(btVector3(3.0,1.0,1.0));
    [self createPhysicsObject:woodNode shape:woodShape mass:2 restitution:0.1  linVel:vel0];
    [self createPhysicsObject:woodNode2 shape:woodShape mass:2 restitution:0.1  linVel:vel0];
    
    
    Isgl3dTextureMaterial * materialBox = [Isgl3dTextureMaterial materialWithTextureFile:@"box.png" shininess:0.9];
    int nBoxNum = 3;
    Isgl3dCube **box;
    Isgl3dMeshNode **boxNode;
    box = (Isgl3dCube **)malloc(sizeof(Isgl3dCube*) * nBoxNum);
    boxNode = (Isgl3dMeshNode **)malloc(sizeof(Isgl3dNode *) * nBoxNum);
    for (int i = 0; i < nBoxNum; i ++) {
        box[i] = [Isgl3dCube meshWithGeometry:1 height:1 depth:1 nx:1 ny:1];
        boxNode[i] = [_container createNodeWithMesh:box[i] andMaterial:materialBox];
    }

    boxNode[0].x = 3;    boxNode[0].y = 5;    boxNode[0].z = 0;
    boxNode[1].x = -7;    boxNode[1].y = 8;    boxNode[1].z = -7;
    boxNode[2].x = 5;    boxNode[2].y = 9;    boxNode[2].z = 4;
    
    btCollisionShape ** boxShape;
    boxShape = (btCollisionShape **)malloc(sizeof(btCollisionShape *) * nBoxNum);
    for (int i=0; i<nBoxNum; i++)
    {
        boxShape[i] = new btBoxShape(btVector3(box[i].width / 2, box[i].height / 2, box[i].depth / 2));
        [self createPhysicsObject:boxNode[i] shape:boxShape[i] mass:2 restitution:0.1  linVel:vel0];
    }
    
}

- (void) dealloc {

	[super dealloc];
}


- (void) tick:(float)dt {
    
    [_cameraController update];
    
    
    for(int i = 0 ; i < _physicsObjects.count ; i ++ ){
        Isgl3dPhysicsObject3D *physicsObject = [_physicsObjects objectAtIndex:i];
        Isgl3dNode * node =  physicsObject.node;
        int shapeType = physicsObject.rigidBody->getCollisionShape()->getShapeType();
        
        float waterHeight = [_water getHeight:node.x z:node.z];
        float boxBottom = node.y - 1.0;
        float boxInWater = waterHeight - boxBottom;
        
        
        if(boxInWater > 0.0)
        {
            btVector3 buoyance;
            if(boxInWater > 2.0f)
                buoyance = btVector3(0.0, 40, 0.0f);
            else
                buoyance = btVector3(0.0, 20*boxInWater, 0.0);
            physicsObject.rigidBody->applyForce(buoyance, btVector3(0, 0, 0));
            
            btVector3 dragForce;
            
            GLKVector3 waterVel = [_water getVelocity3D:node.x z:node.z];
            btVector3 waterVelocity(waterVel.x,waterVel.y,waterVel.z);
            btVector3 objectVelocity = physicsObject.rigidBody->getLinearVelocity();
            btVector3 relativeVelocity  = waterVelocity - objectVelocity;
            const float visCof = 5.0;
            dragForce = relativeVelocity * visCof;
            physicsObject.rigidBody->applyForce(dragForce, btVector3(0, 0, 0));
            
            
            float volumn = objectVelocity.length() * dt * 1;
            float dh = volumn / (0.25 * 0.25);
            float Cdisp = 0.05;
            if(shapeType == 13){
                
                [_water genWaveByCoordinate:node.x z:node.z+1 height:dh * Cdisp range:2];
                [_water genWaveByCoordinate:node.x z:node.z-1 height:dh * Cdisp range:2];
                [_water genWaveByCoordinate:node.x z:node.z height:dh * Cdisp range:1];
            }
            
            else{
                [_water genWaveByCoordinate:node.x z:node.z height:dh * Cdisp range:2];
            }
            physicsObject.rigidBody->setAngularVelocity(physicsObject.rigidBody->getAngularVelocity() * 0.3) ;

        }
        
        if (physicsObject.node.x > 12) {
            btVector3 bv(12,0,0);
            physicsObject.rigidBody->translate(bv);
        } else if (physicsObject.node.x < -12) {
            btVector3 bv(-12, 0, 0);
            physicsObject.rigidBody->translate(bv);
        }
        if (physicsObject.node.z > 12) {
            btVector3 bv(0, 0, 12);
            physicsObject.rigidBody->translate(bv);
        } else if (physicsObject.node.z < -12) {
            btVector3 bv(0, 0, -12);
            physicsObject.rigidBody->translate(bv);
        }
    }
    
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


- (Isgl3dPhysicsObject3D *) createPhysicsObject:(Isgl3dMeshNode *)node shape:(btCollisionShape *)shape mass:(float)mass restitution:(float)restitution linVel:(btVector3) linVel;
{
    
	Isgl3dMotionState * motionState = new Isgl3dMotionState(node);
	
	btVector3 localInertia(0, 0, 0);
	shape->calculateLocalInertia(mass, localInertia);
	btRigidBody * rigidBody = new btRigidBody(mass, motionState, shape, localInertia);
	rigidBody->setRestitution(restitution);
    rigidBody->setLinearVelocity(linVel);
    rigidBody->setActivationState(DISABLE_DEACTIVATION);  //SHIT! This line was missing in the previous version, which cost me 5days wondering what the hell was going on!
    
	Isgl3dPhysicsObject3D * physicsObject = [[Isgl3dPhysicsObject3D alloc] initWithNode:node andRigidBody:rigidBody];
	[_physicsWorld addPhysicsObject:physicsObject];
	
    [_physicsObjects addObject:physicsObject];
    
	return [physicsObject autorelease];
}


@end



@implementation AppDelegate

-(void) createView{
    
    [Isgl3dDirector sharedInstance].deviceOrientation = Isgl3dOrientationLandscapeLeft;
    Isgl3dView *view = [SplashingDemo view];
    [[Isgl3dDirector sharedInstance] addView:view];
    NSLog(@"What the fuck is going on!");
}

@end
