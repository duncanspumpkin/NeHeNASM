%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern glClear
extern glLoadIdentity
extern glTranslatef
extern glBegin
extern glVertex3f
extern glColor3f
extern glEnd

import glLoadIdentity opengl32.dll
import glClear opengl32.dll
import glTranslatef opengl32.dll
import glBegin opengl32.dll
import glVertex3f opengl32.dll
import glColor3f opengl32.dll
import glEnd opengl32.dll

global DrawGLScene


segment code public use32 class=CODE

;DrawGLScene This is the part which actually specifies what is being drawn.
;
;In future this will probably be moved to a seperate file to make it a bit 
;easier to follow.

DrawGLScene:
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call [glClear] ;Clear screen and depth
  
  call [glLoadIdentity] ;Reset current modelview matrix

  push dword [trianglePos]
  push dword [trianglePos+4]
  push dword [trianglePos+8]
  call [glTranslatef]

  push dword GL_TRIANGLES
  call [glBegin]
  
  push dword [redColour]
  push dword [redColour+4]
  push dword [redColour+8]
  call [glColor3f]

  push dword [triangleP1]
  push dword [triangleP1+4]
  push dword [triangleP1+8]
  call [glVertex3f]

  push dword [greenColour]
  push dword [greenColour+4]
  push dword [greenColour+8]
  call [glColor3f]

  push dword [triangleP2]
  push dword [triangleP2+4]
  push dword [triangleP2+8]
  call [glVertex3f]

  push dword [blueColour]
  push dword [blueColour+4]
  push dword [blueColour+8]
  call [glColor3f]
  push dword [triangleP3]
  push dword [triangleP3+4]
  push dword [triangleP3+8]
  call [glVertex3f]
 
  call [glEnd]
  
  push dword [squarePos]
  push dword [squarePos+4]
  push dword [squarePos+8]
  call [glTranslatef]

  push dword GL_QUADS
  call [glBegin]

  push dword [lightBlueColour]
  push dword [lightBlueColour+4]
  push dword [lightBlueColour+8]
  call [glColor3f]

  push dword [squareP1]
  push dword [squareP1+4]
  push dword [squareP1+8]
  call [glVertex3f]
  
  push dword [squareP2]
  push dword [squareP2+4]
  push dword [squareP2+8]
  call [glVertex3f]
  
  push dword [squareP3]
  push dword [squareP3+4]
  push dword [squareP3+8]
  call [glVertex3f]
  
  push dword [squareP4]
  push dword [squareP4+4]
  push dword [squareP4+8]
  call [glVertex3f]
  
  call [glEnd]

  mov dword eax,1
ret ;DrawGLScene

section .data use32
trianglePos dd -6.0,0.0,-1.5
triangleP1  dd 0.0,1.0,0.0
triangleP2  dd 0.0,-1.0,-1.0
triangleP3  dd 0.0,-1.0,1.0
redColour dd 0.0,0.0,1.0
blueColour dd 1.0,0.0,0.0
lightBlueColour dd 1.0,0.5,0.5
greenColour dd 0.0,1.0,0.0
squarePos dd 0.0,0.0,3.0
squareP1  dd 0.0,1.0,-1.0
squareP2  dd 0.0,1.0,1.0
squareP3  dd 0.0,-1.0,1.0
squareP4  dd 0.0,-1.0,-1.0