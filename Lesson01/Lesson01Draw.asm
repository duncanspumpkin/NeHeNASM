;*************************************
;*    Draw.asm by Duncan Frost       *
;*            05/04/2013             *
;*************************************

;Exposes "DrawGLScene" function - this will draw
;gl scene for this lesson this is a blank window


%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern glClear
extern glLoadIdentity

import glLoadIdentity opengl32.dll
import glClear opengl32.dll

global DrawGLScene



section .code use32 

;*********************************
;*       DrawGLScene             *
;*                               *
;* For this lesson will draw a   *
;* blank window.                 *
;* Returns 0 on failure (not     *
;* actually possible in this     *
;* version).                     *
;*********************************

DrawGLScene:
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call [glClear] ;Clear screen and depth
  
  call [glLoadIdentity] ;Reset current modelview matrix
  
  ;Return true
  mov dword eax,1
ret ;DrawGLScene