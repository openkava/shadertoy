
precision mediump float;

varying lowp vec4 DestinationColor; // 1

uniform  float time ;
uniform  vec2 mouse ;
uniform  vec2 resolution ;


void main(void) { // 2
   // gl_FragColor = DestinationColor; // 3
    
    vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 2.0;
    
	float color = 0.2;
	color += sin( position.x * cos( time / 10.0 ) * 100.0 ) + cos( position.y * cos( time / 5.0 ) * 10.0 );
	//color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 15.0 ) * 80.0 );
	color += sin( position.x * sin( time / 10.0 ) * 10.0 ) + sin( position.y * sin( time / 5.0 ) * 80.0 );
	color *= sin( time / 100.0 ) * 2.5;
    
	gl_FragColor = vec4( vec3( color * 0.5, color * 0.2, sin( color + time) * 0.15 ), 1.0 );
    //gl_FragColor =vec4(1.0,sin(time),0.0,1.0);
}