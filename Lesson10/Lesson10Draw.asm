%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"
%include "Lesson10.INC"

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
extern glNormal3f

extern texture
extern filter
extern xpos
extern yrot
extern zpos
extern WorldSector

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
import glNormal3f opengl32.dll

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

%define _immglNormal3f(x,y,z) _glNormal3f __float32__(x),__float32__(y),__float32__(z)

%macro _glNormal3f 3
push dword %3
push dword %2
push dword %1
call [glNormal3f]
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
  
  ;Look up and down
  _glRotatef __float32__(0.0),__float32__(1.0),__float32__(0.0),__float32__(0.0) 
  fld dword [yrot]
  fldpi
  fdivp st1,st0
  push dword __float32__(180.00)
  fld dword [esp]
  fmul st1,st0
  fstp st0
  mov dword [esp],__float32__(360.00)
  fld dword [esp]
  fsub st0,st1
  fstp dword [esp]
  fstp st0
  pop dword eax
  _glRotatef eax,__float32__(0.0),__float32__(1.0),__float32__(0.0) 
  ;Look left and right

  push dword [zpos]
 ; xor dword [esp],0x80000000
  push dword __float32__(-0.25) 
  push dword [xpos]
 ; xor dword [esp],0x80000000
  call [glTranslatef] 

  push dword [texture] 
  push dword GL_TEXTURE_2D
  call [glBindTexture]

  mov dword ebx,[WorldSector+SECTOR.triangle]
  push dword [WorldSector+SECTOR.numTriangles]

 .NextTriangle:
  push dword GL_TRIANGLES
  call [glBegin]

   _immglNormal3f( 0.0, 0.0, 1.0)
   push dword 3

  .NextVertex:
   push dword [ebx+VERTEX.v]
   push dword [ebx+VERTEX.u]
   call [glTexCoord2f]

   push dword [ebx+VERTEX.z]
   push dword [ebx+VERTEX.y]
   push dword [ebx+VERTEX.x]
   call [glVertex3f]
 
   add dword ebx,VERTEX_size
   dec dword [esp]
   jnz .NextVertex

   pop dword eax
  call [glEnd]

  dec dword [esp]
  jnz .NextTriangle

  pop dword eax
ret ;DrawGLScene

section .data use32
;rotX dd 0.0
;rotY dd 0.0