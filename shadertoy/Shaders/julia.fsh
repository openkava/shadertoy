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

void main() {
    vec2 c = vec2(gl_FragCoord.x - 200.0, gl_FragCoord.y) / resolution.xy;
    vec2 z = c;
    
    bool diverged = false;
    for (int i = 0; i < 50; ++i) {
        z = vec2(z.x * z.x - z.y * z.y + c.x, 2.0 * z.x * z.y + c.y);
        if (z.x * z.x + z.y * z.y > 100.0) {
            diverged = true;
            break;
        }
    }
    
    if (diverged)
        gl_FragColor = vec4(1, 1, 1, 1);
    else
        gl_FragColor = vec4(0, 0, 0, 1);
}

