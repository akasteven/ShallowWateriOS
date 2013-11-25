//
//  WaterMeshBreakingWave.h
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-24.
//
//


#import "isgl3d.h"
#import "Isgl3dPrimitive.h"
#import <GLKit/GLKit.h>
#import "Isgl3dVector.h"
#import "WaterTerrain.h"

@interface WaterMeshBreakingWave : Isgl3dPrimitive
{
@private
    float _width;
    float _length;
    int _size;
    float _dx;
    float _dxInv;
    
    float _gravity;
    float _dt;
    
    float *_normal;
    float *_height;
    float * _preHeight;
    float *_terrain;
    float *_eta;
    float *_vx;
    float *_vy;
    float *_temp;
    BOOL _isAnimating;
    
    float _clampv;
    float _avgWaterDepth;
    float _maxWaterDepth;
    float _minWaterDepth;
    
    
    
    unsigned int _numberOfVertices;
	unsigned int _stride;
	unsigned int _positionOffsetX;
	unsigned int _positionOffsetY;
	unsigned int _positionOffsetZ;
	unsigned int _normalOffsetX;
	unsigned int _normalOffsetY;
	unsigned int _normalOffsetZ;
    
    WaterTerrain *_waterTerrain;
    
    Isgl3dUVMap * _uvMap;
    
    Isgl3dParticleSystem  *_particleSystem;
    
    int count ;
    
}
+(id) initWithGeometry:(float) size dx:(float)dx;

-(id) initWithGeometry:(float) width length:(float)length dx:(float)dx;

-(void) startAnimation;

-(void) stopAnimation;

-(void) update:(float)dt;

-(void) initArray;

-(float) interpolate:(float *) array x:(float) x y:(float) y;

-(void) advect:(float *) array arrayType:(int) arrayType;

-(void) updateHeight;

-(void) updateVelocity;

-(void) addRandomDrop;

-(void) setBoundary;

-(void) updateHeightAndNormal;

-(void) genWaveByIndex:(float) x y:(float) y height:(float) height range:(float) range isRandom:(Boolean)isRandom;

-(void) genWaveByCoordinate:(float) x z:(float) z height:(float) height range:(float) range;

-(float) getHeight:(float) x z:(float) z;

-(GLKVector2) getVelocity2D:(float) x z:(float) z;

-(GLKVector3) getVelocity3D:(float) x z:(float) z;

-(void) setWaterTerrain:(WaterTerrain *)waterTerrain;

-(void) setParticleSystem:(Isgl3dParticleSystem *) parsys;

-(void) BreakWave;

-(void) SetParticleBoundary;

-(void) RemoveParticles;

-(void) MoveParticles;


@end
