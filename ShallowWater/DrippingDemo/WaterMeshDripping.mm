//
//  WaterMeshDripping.mm
//  ShallowWater
//
//  Created by Steven Qiu on 13-11-24.
//
//

#import "WaterMeshDripping.h"
#import <GLKit/GLKit.h>


inline float getRandom(float min=0.0, float max=1.0)
{
    return min+( (rand()/(RAND_MAX+1.0)) *(max-min) );
}

@implementation WaterMeshDripping

-(id) initWithGeometry:(float)width length:(float)length dx:(float)dx
{
    if ((self = [super init])) {
        _width = width;
        _length = length;
        _dx = dx;
        [self constructVBOData];
    }
    return self;
}

+(id) initWithGeometry:(float)size dx:(float)dx
{
    return [[[self alloc] initWithGeometry:size dx:dx] autorelease];
}

-(id) initWithGeometry:(float)size dx:(float)dx
{
    if ((self = [super init])) {
        srandom(time(NULL));
        
        count  = 0;
        _size = size;
        _dx = dx;
        _dt = 0.05;
        _gravity = -9.8;
        _dxInv = 1.;
        _clampv = 0.5 * _dx / _dt;
        _avgWaterDepth = 0.0f;
        _maxWaterDepth = 5.0f;
        _minWaterDepth = 0.0f;
        [self constructVBOData];
        
        // Calculate number of vertices
        _numberOfVertices = _vertexDataSize / _vboData.stride;
        
        // Store vbo info to avoid recalculation
        _stride = _vboData.stride;
        _positionOffsetX = _vboData.positionOffset;
        _positionOffsetY = _vboData.positionOffset + sizeof(float);
        _positionOffsetZ = _vboData.positionOffset + 2 * sizeof(float);
        _normalOffsetX = _vboData.normalOffset;
        _normalOffsetY = _vboData.normalOffset + sizeof(float);
        _normalOffsetZ = _vboData.normalOffset + 2 * sizeof(float);
        
        // Initialize the height vx vy & temp array
        [self initArray];
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

-(void) fillVertexData:(Isgl3dFloatArray *)vertexData andIndices:(Isgl3dUShortArray *)indices
{
    float x, y, z;
    float nx, ny, nz;
    float u, v;
    x = y = z = 0.0f;
    nx = nz = 0.0f;
    ny = 1.0f;
    u = v = 0.0f;
    
    for (int i=0; i<_size; i++) {
        for (int j=0; j<_size; j++) {
            
            x = (-0.5 * _size + j) * _dx;
            y = y;
            z = (-0.5 * _size + i) * _dx;
            
            u = (float)i / (float)_size;
            v = (float)j / (float)_size;
            
            [vertexData add:x];
            [vertexData add:y];
            [vertexData add:z];
            
            [vertexData add:nx];
            [vertexData add:ny];
            [vertexData add:nz];
            
            [vertexData add:u];
            [vertexData add:v];
            
        }
    }
    unsigned short first, second, third, fourth;
    first = second = third = fourth = 0;
    for (int i=0; i<_size - 1; i++) {
        for (int j=0; j<_size - 1; j++) {
            first = i * _size + j;
            second = (i + 1) * _size + j;
            third = (i + 1) * _size + j + 1;
            fourth = i * _size + j + 1;
            
            [indices add:first];
            [indices add:second];
            [indices add:third];
            [indices add:first];
            [indices add:third];
            [indices add:fourth];
        }
    }
}


- (void) startAnimation {
	if (!_isAnimating) {
		[[Isgl3dScheduler sharedInstance] schedule:self selector:@selector(update:) isPaused:NO];
		_isAnimating = YES;
	}
}

- (void) stopAnimation {
	if (_isAnimating) {
		[[Isgl3dScheduler sharedInstance] unschedule:self];
		_isAnimating = NO;
	}
}

-(void) initArray
{
    _height = (float *)malloc(sizeof(float) * _size * _size);
    _vx = (float *)malloc(sizeof(float) * _size * _size);
    _vy = (float *)malloc(sizeof(float) * _size * _size);
    _temp = (float *)malloc(sizeof(float) * _size * _size);
    _normal = (float *)malloc(sizeof(float) * _size * _size);
    _terrain = (float *)malloc(sizeof(float) * _size * _size);
    _preHeight = (float *)malloc(sizeof(float) * _size * _size);
    
    _eta = (float *)malloc(sizeof(float) * _size * _size);
    int index = 0;
    for (int i=0; i<_size; i++) {
        for (int j=0; j<_size; j++) {
            index = i * _size + j;
            _temp[index] = _vx[index] = _vy[index] = 0.0;
            _preHeight[index] = _height[index] = 4.0;

        }
    }
    
    for (int i=0; i<_size; i++) {
        for (int j=0; j<_size; j++) {
            index = i * _size + j;
            _temp[index] = _vx[index] = _vy[index] = 0.0;
            _avgWaterDepth += _height[index];
        }
    }
    _avgWaterDepth = _avgWaterDepth / (float)(_size * _size);
    
}

- (void) update:(float)dt
{
    [self advect:_height arrayType:0];
    [self advect:_vx arrayType:1];
    [self advect:_vy arrayType:2];
    [self updateHeight];
    [self updateVelocity];
    [self setBoundary];
    [self addRandomDrop];
    [self updateHeightAndNormal];
}

-(void) advect:(float *)array arrayType:(int)arrayType
{
	for (int i=0;i<_size;i++)
	{
		for (int j=0;j<_size;j++)
		{
			const int index = i + j*_size;
			float u = 0.0, v = 0.0;
            switch (arrayType) {
                case 0:
                    u = (_vx[index] + _vx[index+1]) * 0.5;
                    v = (_vy[index] + _vy[index+_size]) * 0.5;
                    break;
                case 1:
                    u = _vx[index];
                    v = (_vy[index] + _vy[index+1] + _vy[index + _size] + _vy[index + _size + 1]) * 0.25;
                    break;
                case 2:
                    v = _vy[index];
                    u = (_vx[index] + _vx[index+1] + _vx[index + _size] + _vx[index + _size + 1]) * 0.25;
                    break;
                default:
                    break;
            }
			u = _vx[index];
			v = _vy[index];
            
			float srcpi = (float)i - u * _dt * _dxInv;
			float srcpj = (float)j - v * _dt * _dxInv;
            
			if(srcpi<0.0)
				srcpi = 0.0;
			if(srcpj<0.0)
				srcpj = 0.0;
			if(srcpi>_size-1.0)
				srcpi = _size-1.;
			if(srcpj>_size-1.0)
				srcpj = _size-1.0;
            
			_temp[index] = [self interpolate:array x:srcpi y:srcpj];
		}
	}
    
	for (int i=0;i<_size;i++)
	{
		for (int j=0;j<_size;j++)
		{
			const int index = i + j*_size;
            array[index] = _temp[index];
            
            // 小岛等碰撞边界
            if (_waterTerrain != NULL) {
                if (arrayType > 0) {
                    float x = (-0.5 * _size + j) * _dx;
                    float z = (-0.5 * _size + i) * _dx;
                    float waterHeight = _height[i + j * _size];
                    float terrainHeight = [_waterTerrain getHeight:x z:z];
                    if (waterHeight < terrainHeight) {
                        array[index] = 0.0;
                    }
                }
            }
		}
	}
}

-(float) interpolate:(float *)array x:(float)x y:(float)y
{
    const int X = (int)x;
	const int Y = (int)y;
	const float s1 = x - X;
	const float s0 = 1.0f - s1;
	const float t1 = y - Y;
	const float t0 = 1.0f-t1;
	double res = (double)(s0*(t0* array[X+_size*Y] + t1*array[X  +_size*(Y+1)])+s1*(t0*array[(X+1)+_size*Y]  + t1*array[(X+1)+_size*(Y+1)] ));
	return (float)res;
}

-(void) updateHeight
{
	for (int i=1;i<_size-1;i++)
	{
		for (int j=1;j<_size-1;j++)
		{
			const int index = i + j*_size;
            float dh = -1.0 * _height[index]  * ((_vx[index+1] - _vx[index]) +(_vy[index+_size] - _vy[index]));
            _preHeight[index] = _height[index];
            _height[index] += dh * _dt;
            //_eta[index] = _height[index] + _terrain[index];
            _eta[index] = _height[index];
		}
	}
    // 控制水面高度稳定
    if (YES) {
        float waterDepthNow = 0.0f;
        for (int i=0; i<_size; i++) {
            for (int j=0; j<_size; j++) {
                const int index = i * _size + j;
                waterDepthNow += _height[index];
            }
        }
        waterDepthNow = waterDepthNow / (float)(_size * _size);
        float deltaDepth = waterDepthNow - _avgWaterDepth;
        for (int i=0; i<_size; i++) {
            for (int j=0; j<_size; j++) {
                const int index = i * _size + j;
                _height[index] -= deltaDepth;
            }
        }
    }
}

-(void) updateVelocity
{
	for (int i=2;i<_size-1;i++)
	{
		for (int j=1;j<_size-1;j++)
		{
			const int index = i + j*_size;
			_vx[index] += _gravity * _dt *  _dxInv * (_eta[index] - _eta[index - 1]);
            if (_vx[index] > _clampv) {
                _vx[index] = _clampv;
            }
		}
	}
    
	for (int i=1;i<_size-1;i++)
	{
		for (int j=2;j<_size-1;j++)
		{
			const int index = i + j*_size;
			_vy[index] += _gravity * _dt * _dxInv * (_eta[index] - _eta[index - _size]);
            if (_vy[index] > _clampv) {
                _vy[index] = _clampv;
            }
		}
	}
    // 时间step结束时需要将陆地以下的水面速度设置为零
    if (_waterTerrain != NULL) {
        for (int i=1; i<_size-1; i++) {
            for (int j=1; j<_size-1; j++) {
                int index = i + j * _size;
                float x = (-0.5 * _size + j) * _dx;
                float z = (-0.5 * _size + i) * _dx;
                float waterHeight = _height[index];
                float terrainHeight = [_waterTerrain getHeight:x z:z];
                if (waterHeight < terrainHeight) {
                    _vx[index] = _vy[index] = 0.0;
                }
            }
        }
    }
}

-(void) addRandomDrop
{
    int px = getRandom() * (float)_size;
    int py = getRandom() * (float)_size;
    [self genWaveByIndex:px y:py height:0.5 range:1 isRandom:YES];
	
}


-(void) genWaveByIndex:(float)x y:(float)y height:(float)height range:(float)range isRandom:(Boolean)isRandom
{
    float h = 0;
    if (isRandom) {
        h  = getRandom(0.01, height);
    }else{
        h = height;
    }
    int index = 0;
    for (int i=x-range; i<x+range; i++) {
        for (int j=y-range; j<y+range; j++) {
            index = i + j * _size;
            if( i<1 || j<1 || i>(_size-1) || j>(_size-1)){
                continue;
            }
            _height[index] += h;
        }
    }
}

-(void) genWaveByCoordinate:(float)x z:(float)z height:(float)height range:(float)range
{
    
    int index = 0;
    int nj = x / _dx + 0.5 * (float)_size;
    int ni = z / _dx + 0.5 * (float)_size;
    
    for (int j=ni-range; j<ni+range; j++) {
        for (int i=nj-range; i<nj+range; i++) {
            index = i + j * _size;
            if( i<1 || j<1 || i>(_size-1) || j>(_size-1)){
                continue;
            }
            _height[index] += height;
        }
    }
}

-(void) setBoundary
{
    for (int i=0; i<_size; i++)
	{
		const int index1 = i + 0*_size;
		const int index2 = i + (_size-1)*_size;
		_height[index1] = _height[index1 + _size];
        _eta[index1] = _eta[index1 + _size];
		_height[index2] = _height[index2 - _size];
        _eta[index2] = _eta[index2 - _size];
	}
	for (int j=0; j<_size; j++)
	{
		const int index1 = 0 + j*_size;
		const int index2 = (_size-1) + j*_size;
		_height[index1] = _height[index1 + 1];
        _eta[index1] = _eta[index1 + 1];
		_height[index2] = _height[index2 - 1];
        _eta[index2] = _eta[index2 - 1];
	}
}

-(void) updateHeightAndNormal
{
    GLKVector3 vec3_1, vec3_2, vec3Normal;
    float fx = 0.0f, fy = 0.0f, fz = 0.0f;
    int nIndex = 0;
    // 时间step结束时需要将陆地以下的水面速度设置为零
    if (_waterTerrain != NULL) {
        for (int i=1; i<_size-1; i++) {
            for (int j=1; j<_size-1; j++) {
                const int index = i + j * _size;
                float x = (-0.5 * _size + j) * _dx;
                float z = (-0.5 * _size + i) * _dx;
                float waterHeight = _height[index];
                if (_height[index] > _maxWaterDepth) {
                    _height[index] = _minWaterDepth;
                }
                if (_height[index] < _minWaterDepth) {
                    _height[index] = _minWaterDepth;
                }
                if (_eta[index] > _maxWaterDepth) {
                    _eta[index] = _maxWaterDepth;
                }
                if (_eta[index] < _minWaterDepth) {
                    _eta[index] = _minWaterDepth;
                }
                float terrainHeight = [_waterTerrain getHeight:x z:z];
                if (2 < terrainHeight) {
                    _eta[index] = _avgWaterDepth;
                }
            }
        }
    }
    
    // Update Height
	for (unsigned int i = 0; i < _numberOfVertices; i++) {
		*((float*)&_vertexData[_stride * i + _positionOffsetY]) = _eta[i];
	}
    // Update Normal
    for (int i=1; i<_size - 1; i++) {
        for (int j=1; j<_size - 1; j++) {
            nIndex = i * _size + j;
            fx = 0.0f;
            fy = (*((float*)&_vertexData[_stride * (nIndex - _size) + _positionOffsetY])  -
                  *((float*)&_vertexData[_stride * (nIndex + _size) + _positionOffsetY]) ) / 2.0;
            fz = -1.0f;
            vec3_1 = GLKVector3Make(fx, fy, fz);
            fx = 1.0f;
            fy = (*((float*)&_vertexData[_stride * (nIndex + 1) + _positionOffsetY])  -
                  *((float*)&_vertexData[_stride * (nIndex - 1) + _positionOffsetY]) ) / 2.0;
            fz = 0.0f;
            vec3_2 = GLKVector3Make(fx, fy, fz);
            vec3Normal = GLKVector3CrossProduct(vec3_2, vec3_1);
            *((float*)&_vertexData[_stride * nIndex + _normalOffsetX])  = vec3Normal.x;
            *((float*)&_vertexData[_stride * nIndex + _normalOffsetY])  = vec3Normal.y;
            *((float*)&_vertexData[_stride * nIndex + _normalOffsetZ])  = vec3Normal.z;
        }
    }
    
    // Update vbo data in GPU
	[[Isgl3dGLVBOFactory sharedInstance] createBufferFromUnsignedCharArray:_vertexData size:_vertexDataSize atIndex:_vboData.vboIndex];
}

-(float) getHeight:(float)x z:(float)z
{
    int ni = 0, nj = 0;
    nj = x / _dx + 0.5 * (float)_size;
    ni = z / _dx + 0.5 * (float)_size;
    if (ni >= _size || nj >= _size)
    {
        return 0.0f;
    }
    else
    {
        return _height[ni * _size + nj];
    }
}

-(GLKVector2) getVelocity2D:(float)x z:(float)z
{
    int ni = 0, nj = 0;
    nj = x / _dx + 0.5 * (float)_size;
    ni = z / _dx + 0.5 * (float)_size;
    GLKVector2 vec2;
    if (ni >= _size || nj >= _size)
    {
        vec2.x = 0;
        vec2.y = 0;
    }
    else
    {
        vec2.x = _vx[ni * _size + nj] * _dt;
        vec2.y = _vy[ni * _size + nj] * _dt;
    }
    return vec2;
}


-(GLKVector3) getVelocity3D:(float)x z:(float)z
{
    int ni = 0, nj = 0;
    nj = x / _dx + 0.5 * (float)_size;
    ni = z / _dx + 0.5 * (float)_size;
    GLKVector3 vec3;
    if (ni >= _size || nj >= _size)
        vec3 = GLKVector3Make(0.0, 0.0, 0.0);
    else
    {
        vec3.x = _vx[ni * _size + nj] ;
        vec3.z = _vy[ni * _size + nj] ;
    }
    
    float preH = [self interpolate:_preHeight x:ni y:nj];
    float H = [self interpolate:_height x:ni y:nj];
    vec3.y = (H - preH) / _dt;
    return vec3;
    
}


-(void) setWaterTerrain:(WaterTerrain *)waterTerrain
{
    if (waterTerrain)
        _waterTerrain = [waterTerrain retain];
        
    if (_waterTerrain) {
        for (int i=0; i<_size; i++) {
            for (int j=0; j<_size; j++) {
                int index = i + j * _size;
                float x = (-0.5 * _size + j) * _dx;
                float z = (-0.5 * _size + i) * _dx;
                float terrainHeight = [_waterTerrain getHeight:x z:z];
                _terrain[index] = terrainHeight;
                    
                if (_terrain[index] > _height[index]) {
                    _eta[index] = 0;
                        // _eta[index] = _terrain[index];
                    _height[index] = 0;
                }
                else
                {
                    _eta[index] = _terrain[index] + _height[index];
                }
            }
        }
    }
}



@end
