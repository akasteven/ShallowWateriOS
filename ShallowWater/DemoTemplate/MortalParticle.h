//
//  MortalParticle.h
//  ProjectDemo
//
//  Created by StevenQiu on 13-11-18.
//  Copyright (c) 2013年 vrlab@buaa. All rights reserved.
//

#import "Isgl3dGLParticle.h"
#import "Isgl3dVector.h"

@interface MortalParticle : Isgl3dGLParticle
{
    float _lifetime;
    float _velx, _vely, _velz;
}


@property (nonatomic)  float lifetime;
@property (nonatomic)  float velx;
@property (nonatomic)  float vely;
@property (nonatomic)  float velz;

-(id) init;


-(id) initWithPosition:(Isgl3dVector3) pos Color:(Isgl3dVector3) col Size:(float) size Lifetime:(float) lifetime andVelocity:(Isgl3dVector3) vel;

@end
