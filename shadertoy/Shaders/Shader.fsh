//
//  Shader.fsh
//  shadertoy
//
//  Created by open kava on 12-12-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
