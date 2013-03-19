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
extern glBindTexture
extern glTexCoord2f
extern glEnable
extern glDisable

extern texture

import glLoadIdentity opengl32.dll
import glClear opengl32.dll
import glTranslatef opengl32.dll
import glBegin opengl32.dll
import glVertex3f opengl32.dll
import glColor3f opengl32.dll
import glRotatef opengl32.dll
import glEnd opengl32.dll
import glTexCoord2f opengl32.dll
import glBindTexture opengl32.dll
import glDisable opengl32.dll
import glEnable opengl32.dll

global DrawGLScene

%define _immglTranslatef(x,y,z) _glTranslatef __float32__(x),__float32__(y),__float32__(z)

%macro _glTranslatef 3
push dword %3
push dword %2
push dword %1
call [glTranslatef]
%endmacro

%macro _glRotatef 4
push dword %4
push dword %3
push dword %2
push dword %1
call [glRotatef]
%endmacro

%define _immglColor3f(r,g,b) _glColor3f __float32__(r),__float32__(g),__float32__(b)

%macro _glColor3f 3
push dword %3
push dword %2
push dword %1
call [glColor3f]
%endmacro

%define _immglVertex3f(x,y,z) _glVertex3f __float32__(x),__float32__(y),__float32__(z)

%macro _glVertex3f 3
push dword %3
push dword %2
push dword %1
call [glVertex3f]
%endmacro

%define _immglTexCoord2f(x,y) _glTexCoord2f __float32__(x),__float32__(y)

%macro _glTexCoord2f 2
push dword %2
push dword %1
call [glTexCoord2f]
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

  _immglTranslatef(0.0,0.0,-5.0)
  
  _glRotatef  [rotationCube],__float32__(0.4), __float32__(0.2), __float32__(0.3),

  _immglColor3f(1.0,1.0,1.0) ;Clears the colour from above so our texture shows good
  
  push dword [texture]
  push dword GL_TEXTURE_2D
  call [glBindTexture]

  push dword GL_QUADS
  call [glBegin]
    ;; Front Face
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f(-1.0, -1.0,  1.0)
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f( 1.0, -1.0,  1.0)
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f( 1.0,  1.0,  1.0)
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f(-1.0,  1.0,  1.0)

    ;; Back Face
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f(-1.0, -1.0, -1.0)
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f(-1.0,  1.0, -1.0)
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f( 1.0,  1.0, -1.0)
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f( 1.0, -1.0, -1.0)

    ;; Top Face
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f(-1.0,  1.0, -1.0)
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f(-1.0,  1.0,  1.0)
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f( 1.0,  1.0,  1.0)
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f( 1.0,  1.0, -1.0)

    ;; Bottom Face
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f(-1.0, -1.0, -1.0)
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f( 1.0, -1.0, -1.0)
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f( 1.0, -1.0,  1.0)
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f(-1.0, -1.0,  1.0)

    ;; Right face
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f( 1.0, -1.0, -1.0)
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f( 1.0,  1.0, -1.0)
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f( 1.0,  1.0,  1.0)
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f( 1.0, -1.0,  1.0)

    ;; Left Face
    _immglTexCoord2f(0.0, 0.0)
    _immglVertex3f(-1.0, -1.0, -1.0)
    _immglTexCoord2f(1.0, 0.0)
    _immglVertex3f(-1.0, -1.0,  1.0)
    _immglTexCoord2f(1.0, 1.0)
    _immglVertex3f(-1.0,  1.0,  1.0)
    _immglTexCoord2f(0.0, 1.0)
    _immglVertex3f(-1.0,  1.0, -1.0);
  call [glEnd]

  ;push dword 0 ;Resets gl_texture_2d so colours show properly again
  ;push dword GL_TEXTURE_2D
  ;call [glBindTexture]
 
  fld dword [rotationCube]
  fsub dword [rotC]
  fstp dword [rotationCube]

  mov dword eax,1
ret ;DrawGLScene
section .bss use32
rotationCube   resd 1

section .data use32
rotC dd 0.009