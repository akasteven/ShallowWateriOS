//
//  MortalParticle.m
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-18.
//  Copyright (c) 2013年 vrlab@buaa. All rights reserved.
//

#import "MortalParticle.h"

@implementation MortalParticle
@synthesize lifetime = _lifetime ;
@synthesize velx = _velx ;
@synthesize vely = _vely ;
@synthesize velz = _velz ;

-(id) init
{
    	if ((self = [super init])) {
            _lifetime = 0.0;
        }
    return self;
}

-(id) initWithPosition:(Isgl3dVector3) pos Color:(Isgl3dVector3) col Size:(float) size Lifetime:(float) lifetime andVelocity:(Isgl3dVector3) vel
{
    if ((self = [super init])) {
		
		_x = pos.x;
		_y = pos.y;
		_z = pos.z;
        
		_size = size;
		
        
		_color[0] = col.x;
		_color[1] = col.y;
		_color[2] = col.z;
		_color[3] = 1.0;
		
		_renderColor[0] = col.x;
		_renderColor[1] = col.y;
		_renderColor[2] = col.z;
		_renderColor[3] = 1.0;
		
		_attenuation[0] = 1.0;
		_attenuation[1] = 0.0;
		_attenuation[2] = 0.0;
		
        _lifetime = lifetime;
        
        _velx = vel.x;
        _vely = vel.y;
        _velz = vel.z;
        
		_dirty = YES;
	}
	
	return self;
}

-(void) setPos:(float) x y:(float) y z:(float)z
{
    [self setX:x];
    [self setY:y];
    [self setZ:z];
}



@end
