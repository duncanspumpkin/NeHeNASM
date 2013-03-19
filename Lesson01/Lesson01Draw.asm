%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern glClear
extern glLoadIdentity

import glLoadIdentity opengl32.dll
import glClear opengl32.dll

global DrawGLScene



section .code use32 

;DrawGLScene This is the part which actually specifies what is being drawn.
;
;In future this will probably be moved to a seperate file to make it a bit 
;easier to follow.

DrawGLScene:
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call [glClear] ;Clear screen and depth
  
  call [glLoadIdentity] ;Reset current modelview matrix
  
  ;Return False?
  xor eax,eax
ret ;DrawGLScene