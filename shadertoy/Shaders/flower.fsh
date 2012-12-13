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

// minimal modified http://glsl.heroku.com/.... sorry don't find it anymore :<
// another mod by MrOMGWTF, the symmetry code isn't mine..

vec3 sim(vec3 p,float s){
    vec3 ret=p;
    ret=p+s/2.0;
    ret=fract(ret/s)*s-s/2.0;
    return ret;
}

vec2 rot(vec2 p,float r){
    vec2 ret;
    ret.x=p.x*cos(r)-p.y*sin(r);
    ret.y=p.x*sin(r)+p.y*cos(r);
    return ret;
}

vec2 rotsim(vec2 p,float s){
    vec2 ret=p;
    ret=rot(p,-3.14/(s*2.0));
    ret=rot(p,floor(atan(ret.x,ret.y)/3.14*s)*(3.14/s));
    return ret;
}
vec2 makeSymmetry(vec2 p){ //nice stuff :)
    vec2 ret=p;
    ret=rotsim(ret,16.0);
    ret.x=abs(ret.x);
    return ret;
}

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float sampleRand(vec2 P, int dx, int dy)
{
	return rand(P + vec2(dx, dy));
}

float myNoise(vec2 P, out vec2 D) {
	vec2 i = floor(P);
	vec2 u = P-i;
	
	// cubic
	//u.x = smoothstep(0., 1., u.x);
	//u.y = smoothstep(0., 1., u.y);
    
	// derivatives
	float du = 30.0*u.x*u.x*(u.x*(u.x-2.0)+1.0);
    float dv = 30.0*u.y*u.y*(u.y*(u.y-2.0)+1.0);
	
	// quintic
	u.x = u.x*u.x*u.x*(u.x*(u.x*6.0-15.0)+10.0);
    u.y = u.y*u.y*u.y*(u.y*(u.y*6.0-15.0)+10.0);
	
	float a = sampleRand(i, 0, 0);
	float b = sampleRand(i, 1, 0);
	float c = sampleRand(i, 0, 1);
	float d = sampleRand(i, 1, 1);
	
	float k0 = a;
	float k1 = b - a;
	float k2 = c - a;
	float k3 = a - b - c + d;
	
	D.x = du*(k1 + k3*u.y);
	D.y = dv*(k2 + k3*u.x);
	
	return k0 + k1*u.x + k2*u.y + k3*(u.x*u.y);
    
	//return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 P, out vec2 D) {
	float f = 0.0;
	float w = 0.5;
	float x = 1.0;
	D.x = 0.0;
	D.y = 0.0;
	for (int i = 0; i < 4; ++i) {
		vec2 d;
		f += w*myNoise(x*P, d)/ (1.0 + dot(D, D));
		D += d;
		w *= 0.5;
		x *= 2.0;
	}
	
	return f;
}

vec3 rock(vec2 r) {
	// xy in 0..1
	vec2 P = (gl_FragCoord.xy / resolution.xy) * 13.0;
	P = mix(P, r, 0.1);
	P.x -= time * 0.006; P += r * 0.01;
	vec2 D;
	float N = fbm(8.0*P, D);
	vec3 stone = vec3(0.5*(D+1.0), 0.1);
	stone = normalize(stone);
	stone = vec3( dot(stone.xyz, normalize(vec3(1.5, 1.0, 1.5))) );
	return stone * stone * stone * 0.3;
}





// minimal modified http://glsl.heroku.com/e#3028.1

void main() {
    
	vec2 posScale = vec2(2.0);
	vec2 position = (( gl_FragCoord.xy / resolution.xy - 0.5) * 2.0 );
	position = makeSymmetry(position);
	float sum = 0.;
	float sum2 = 0.;
	float qsum = 0.;
	float t = time * 0.5;
	
	for (float i = 0.; i < 40.0; i++) {
		float x2 = i*i*.3165+(i*0.01);
		float y2 = i*.161235+sin(t*i*0.13)*0.1;
		vec2 p = (fract(position-vec2(x2,y2))-vec2(.5))/posScale;
		float a = atan(p.y,p.x);
		float r = length(p)*100.;
		float e = exp(-r*.2);
		float e2 = e*atan(r);
		sum += sin(r+a+time)*e2;
		sum2 += cos(r+a+time)*e2;
		qsum += e;
	}
	
	float color = sqrt(sum*sum+sum2*sum2)/qsum;
    
	float g = (1.0 - color) * 0.85;
	gl_FragColor = vec4(g, g*g*g*g*g, 0.0, 1.0 );
    
	vec2 r = vec2(-sum2, -sum) * 0.1;
	vec4 stone = vec4(rock(r),1.0);
	float a = (1.0 - color);
	a = smoothstep(0.4, 1.0, a);
	a *= a; a = a + 0.6;
	gl_FragColor = mix(stone, gl_FragColor, a*a*a);
}

