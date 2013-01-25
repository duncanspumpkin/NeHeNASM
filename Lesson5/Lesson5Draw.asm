%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern glClear
extern glLoadIdentity
extern glTranslatef
extern glBegin
extern glVertex3f
extern glColor3f
extern glRotatef
extern glEnd

import glLoadIdentity opengl32.dll
import glClear opengl32.dll
import glTranslatef opengl32.dll
import glBegin opengl32.dll
import glVertex3f opengl32.dll
import glColor3f opengl32.dll
import glRotatef opengl32.dll
import glEnd opengl32.dll

global DrawGLScene


%macro _glTranslatef 1
push dword [%1]
push dword [%1+4]
push dword [%1+8]
call [glTranslatef]
%endmacro

%macro _glRotatef 4
push dword %1
push dword %2
push dword %3
push dword %4
call [glRotatef]
%endmacro

%macro _glColor3f 1
push dword [%1]
push dword [%1+4]
push dword [%1+8]
call [glColor3f]
%endmacro

%macro _glVertex3f 1
push dword [%1]
push dword [%1+4]
push dword [%1+8]
call [glVertex3f]
%endmacro

segment code public use32 class=CODE

;DrawGLScene This is the part which actually specifies what is being drawn.
;
;In future this will probably be moved to a seperate file to make it a bit 
;easier to follow.

DrawGLScene:
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call [glClear] ;Clear screen and depth
  
  call [glLoadIdentity] ;Reset current modelview matrix

  _glTranslatef pyPos
  
  _glRotatef 0, __float32__(1.0), 0, [rotationPy]
  
  push dword GL_TRIANGLES
  call [glBegin]
  
   _glColor3f redColour
   _glVertex3f pyFrontP1
  
   _glColor3f greenColour
   _glVertex3f pyFrontP2

   _glColor3f blueColour
   _glVertex3f pyFrontP3
 
   _glColor3f redColour
   _glVertex3f pyRightP1
  
   _glColor3f greenColour
   _glVertex3f pyRightP2

   _glColor3f blueColour
   _glVertex3f pyRightP3

   _glColor3f redColour
   _glVertex3f pyBackP1
  
   _glColor3f greenColour
   _glVertex3f pyBackP2

   _glColor3f blueColour
   _glVertex3f pyBackP3

   _glColor3f redColour
   _glVertex3f pyLeftP1
  
   _glColor3f greenColour
   _glVertex3f pyLeftP2

   _glColor3f blueColour
   _glVertex3f pyLeftP3

  call [glEnd]
  
  call [glLoadIdentity]

  _glTranslatef cubePos
  
  _glRotatef __float32__(1.0), __float32__(1.0), __float32__(1.0), [rotationCube]
 
  push dword GL_QUADS
  call [glBegin]
  
   _glColor3f greenColour
  
   _glVertex3f cubeTopP1
   _glVertex3f cubeTopP2
   _glVertex3f cubeTopP3
   _glVertex3f cubeTopP4
  
   _glColor3f orangeColour
  
   _glVertex3f cubeBottomP1
   _glVertex3f cubeBottomP2
   _glVertex3f cubeBottomP3
   _glVertex3f cubeBottomP4

   _glColor3f redColour
  
   _glVertex3f cubeFrontP1
   _glVertex3f cubeFrontP2
   _glVertex3f cubeFrontP3
   _glVertex3f cubeFrontP4

   _glColor3f yellowColour
  
   _glVertex3f cubeBackP1
   _glVertex3f cubeBackP2
   _glVertex3f cubeBackP3
   _glVertex3f cubeBackP4

   _glColor3f blueColour
  
   _glVertex3f cubeLeftP1
   _glVertex3f cubeLeftP2
   _glVertex3f cubeLeftP3
   _glVertex3f cubeLeftP4

   _glColor3f violetColour
  
   _glVertex3f cubeRightP1
   _glVertex3f cubeRightP2
   _glVertex3f cubeRightP3
   _glVertex3f cubeRightP4

  call [glEnd]
  
  fld dword [rotationPy]
  fadd dword [rotP]
  fstp dword [rotationPy]

  fld dword [rotationCube]
  fsub dword [rotC]
  fstp dword [rotationCube]

  mov dword eax,1
ret ;DrawGLScene
section .bss use32
rotationPy resd 1
rotationCube   resd 1

section .data use32
rotP dd 0.02
rotC dd 0.015

pyPos dd -6.0,0.0,-1.5

pyLeftP1  dd 0.0,1.0,0.0
pyLeftP2  dd -1.0,-1.0,-1.0
pyLeftP3  dd 1.0,-1.0,-1.0

pyBackP1  dd 0.0,1.0,0.0
pyBackP2  dd -1.0,-1.0,1.0
pyBackP3  dd -1.0,-1.0,-1.0

pyFrontP1  dd 0.0,1.0,0.0
pyFrontP2  dd 1.0,-1.0,-1.0
pyFrontP3  dd 1.0,-1.0,1.0

pyRightP1  dd 0.0,1.0,0.0
pyRightP2  dd 1.0,-1.0,1.0
pyRightP3  dd -1.0,-1.0,1.0

redColour dd 0.0,0.0,1.0
blueColour dd 1.0,0.0,0.0
greenColour dd 0.0,1.0,0.0
orangeColour dd 0.0,0.5,1.0
yellowColour dd 0.0,1.0,1.0
violetColour dd 1.0,0.0,1.0

cubePos dd -6.0,0.0,1.5

cubeTopP1  dd -1.0,1.0,1.0
cubeTopP2  dd -1.0,1.0,-1.0
cubeTopP3  dd 1.0,1.0,-1.0
cubeTopP4  dd 1.0,1.0,1.0

cubeBottomP1  dd 1.0,-1.0,1.0
cubeBottomP2  dd 1.0,-1.0,-1.0
cubeBottomP3  dd -1.0,-1.0,-1.0
cubeBottomP4  dd -1.0,-1.0,1.0

cubeFrontP1  dd 1.0,1.0,1.0
cubeFrontP2  dd 1.0,1.0,-1.0
cubeFrontP3  dd 1.0,-1.0,-1.0
cubeFrontP4  dd 1.0,-1.0,1.0

cubeBackP1  dd -1.0,-1.0,1.0
cubeBackP2  dd -1.0,-1.0,-1.0
cubeBackP3  dd -1.0,1.0,-1.0
cubeBackP4  dd -1.0,1.0,1.0

cubeLeftP1  dd 1.0,1.0,-1.0
cubeLeftP2  dd -1.0,1.0,-1.0
cubeLeftP3  dd -1.0,-1.0,-1.0
cubeLeftP4  dd 1.0,-1.0,-1.0

cubeRightP1  dd -1.0,1.0,1.0
cubeRightP2  dd 1.0,1.0,1.0
cubeRightP3  dd 1.0,-1.0,1.0
cubeRightP4  dd -1.0,-1.0,1.0