//
//  Shader.fsh
//  opengles
//
//  Created by ydf on 12-12-12.
//  Copyright (c) 2012年 ydf. All rights reserved.
//

precision mediump float;
varying lowp vec4 colorVarying;


uniform  float time ;
uniform  vec2 mouse ;
uniform  vec2 resolution ;

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.99, -0.48,
              -0.60, -0.9,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}


float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    
    f = f*f*(3.0-2.0*f);
    
    float n = p.x + p.y*57.0 + 113.0*p.z;
    
    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f = 0.0;
    
    f += 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    
    return f/0.9375;
}

float biteNoise(vec3 p) {
	return sin(p.y*50.0) * cos(p.x*10.0) * 0.02;
	
}
vec2 sdSphere( vec3 p, float s )
{
    float nse = biteNoise(p);
    return vec2(length(p)-s + nse, 1.0);
}




vec2 appleShapeX( vec3 p )
{
    p.y -= 0.75*pow(dot(p.xz,p.xz),0.2) ;
    //   return length(p) - 1.0;
    
	
    vec2 d1 = vec2( length(p) - 1.0, 1.0 );
    vec2 d2 = vec2( p.y+0.55, 2.0 );
    if( d2.x<d1.x) d1=d2;
    return d1;
}


vec2 appleShape( vec3 p ) {
	
	p.x = mod(p.x,5.0)-2.5 + 0.5*sin(time);
  	p.z = mod(p.z,5.0)-2.5 + 0.5*sin(time);
	vec2 d1 = appleShapeX(p);
	vec2 d2 = sdSphere( p - vec3(1.3,1.0,0.0), 0.6);
	
	return  max(d1,-d2);
	//return d1;
}
vec3 appleColor( in vec3 pos, in vec3 nor, out vec2 spe )
{
    spe.x = 1.0;
    spe.y = 1.0;
    
    float a = atan(pos.x,pos.z);
    float r = length(pos.xz);
    float f = smoothstep( 0.0, 1.0, fbm(pos*1.0) );
	
    // red
    vec3 col;
    vec3 bite = pos - vec3(1.3,1.0,0.0);
    //vec2 bite = sdSphere(pos, 0.6);
    if ( (length(bite) + biteNoise(bite)) < .615) {
    	col = vec3(0.8,0.8,0.8);
        col = mix( col, vec3(0.8,1.0,0.2), f );
    } else
        col = vec3(1.0,0.0,0.0);
    
    // green
    
    col = mix( col, vec3(0.8,1.0,0.2), f );
    
    // dirty
    f = smoothstep( 0.0, 1.0, fbm(pos*4.0) );
    col *= 0.8+0.2*f;
    
    // frekles
    f = smoothstep( 0.0, 1.0, fbm(pos*48.0) );
    f = smoothstep( 0.7,0.9,f);
    col = mix( col, vec3(0.9,0.9,0.6), f*0.5 );
    
    // stripes
    f = fbm( vec3(a*7.0 + pos.z,3.0*pos.y,pos.x)*2.0);
    f = smoothstep( 0.2,1.0,f);
    f *= smoothstep(0.4,1.2,pos.y + 0.75*(noise(4.0*pos.zyx)-0.5) );
    col = mix( col, vec3(0.4,0.2,0.0), 0.5*f );
    spe.x *= 1.0-0.35*f;
    spe.y = 1.0-0.5*f;
    
    // top
    f = 1.0-smoothstep( 0.14, 0.2, r );
    col = mix( col, vec3(0.6,0.6,0.5), f );
    spe.x *= 1.0-f;
    
    // tint more red
    col.yz *= 0.8;
    
    float ao = 0.5 + 0.5*nor.y;
    col *= ao*1.2;
    return col;
}

vec3 floorColor( in vec3 pos, in vec3 nor, out vec2 spe )
{
    spe.x = 1.0;
    spe.y = 1.0;
    vec3 col = vec3(0.5,0.4,0.3)*1.7;
    
    float f = fbm( 4.0*pos*vec3(6.0,0.0,0.5) );
    col = mix( col, vec3(0.3,0.2,0.1)*1.7, f );
    spe.y = 1.0 + 4.0*f;
    
    f = fbm( 2.0*pos );
    col *= 0.7+0.3*f;
    
    // frekles
    f = smoothstep( 0.0, 1.0, fbm(pos*48.0) );
    f = smoothstep( 0.7,0.9,f);
    col = mix( col, vec3(0.2), f*0.75 );
    
    // fake ao
    f = smoothstep( 0.1, 1.55, length(pos.xz) );
    col *= f*f*1.4;
    col.x += 0.15*(1.0-f);
    return col;
}

vec2 intersect( in vec3 ro, in vec3 rd )
{
    float t=0.0;
    float dt = 0.05;
    float nh = 0.0;
    float lh = 0.0;
    float lm = -1.0;
    for(int i=0;i<256;i++)
    {
        vec2 ma = appleShape(ro+rd*t);
        nh = ma.x;
        if(nh>0.0) { lh=nh; t+=dt;  } lm=ma.y;
    }
    
    if( nh>0.0 ) return vec2(-1.0);
    t = t - dt*nh/(nh-lh);
    
    return vec2(t,lm);
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float dt = 0.05;
    float t = mint;
    for( int i=0; i<80; i++ )
    {
        float h = appleShape(ro + rd*t).x;
        if( h>0.001 )
            res = min( res, k*h/t );
        else
            res = 0.0;
        t += dt;
    }
    return res;
}
vec3 calcNormal( in vec3 pos )
{
    vec3  eps = vec3(.001,0.0,0.0);
    vec3 nor;
    nor.x = appleShape(pos+eps.xyy).x - appleShape(pos-eps.xyy).x;
    nor.y = appleShape(pos+eps.yxy).x - appleShape(pos-eps.yxy).x;
    nor.z = appleShape(pos+eps.yyx).x - appleShape(pos-eps.yyx).x;
    return normalize(nor);
}

void main(void)
{
    vec2 q = gl_FragCoord.xy / resolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= resolution.x/resolution.y;
    
    // camera
    vec3 ro = 5.5*normalize(vec3(cos(0.2*time),1.15+0.4*cos(time*.11),sin(0.2*time)));
    //vec3 ro = 2.5*normalize(vec3(0.0, 1.0, 0.0));
    vec3 ww = normalize(vec3(0.0,0.5,0.0) - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );
    
    // raymarch
    vec3 col = vec3(0.96,0.98,1.0);
    vec2 tmat = intersect(ro,rd);
    if( tmat.y>0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
        vec3 ref = reflect(rd,nor);
        vec3 lig = normalize(vec3(1.0,0.8,-0.6));
        
        float con = 1.0;
        float amb = 0.5 + 0.5*nor.y;
        float dif = max(dot(nor,lig),0.0);
        float bac = max(0.2 + 0.8*dot(nor,vec3(-lig.x,lig.y,-lig.z)),0.0);
        float rim = pow(1.0+dot(nor,rd),3.0);
        float spe = pow(clamp(dot(lig,ref),0.0,1.0),16.0);
        
        // shadow
        float sh = softshadow( pos, lig, 0.06, 4.0, 4.0 );
        
        // lights
        col  = 0.10*con*vec3(0.80,0.90,1.00);
        col += 0.70*dif*vec3(1.00,0.97,0.85)*vec3(sh, (sh+sh*sh)*0.5, sh*sh );
        col += 0.15*bac*vec3(1.00,0.97,0.85);
        col += 0.20*amb*vec3(0.10,0.15,0.20);
        
        
        // color
        vec2 pro;
        if( tmat.y<1.5 )
            col *= appleColor(pos,nor,pro);
        else
            col *= floorColor(pos,nor,pro);
        
        // rim and spec
        col += 0.60*rim*vec3(1.0,0.97,0.85)*amb*amb;
        col += 0.60*pow(spe,pro.y)*vec3(1.0)*pro.x*sh;
        
        col = 0.3*col + 0.7*sqrt(col);
    }
    
    col *= 0.25 + 0.75*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );
    
    gl_FragColor = vec4(col,1.0);
}

