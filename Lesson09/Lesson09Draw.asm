%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"
%include "Lesson09.INC"

extern glClear
extern glLoadIdentity
extern glTranslatef
extern glBegin
extern glVertex3f
extern glColor3f
extern glColor4ub
extern glRotatef
extern glEnd
extern glBindTexture
extern glTexCoord2f
extern glEnable
extern glDisable
extern glNormal3f
extern texture
extern zoom
extern tilt
extern stars
extern twinkle

import glLoadIdentity opengl32.dll
import glClear opengl32.dll
import glTranslatef opengl32.dll
import glBegin opengl32.dll
import glVertex3f opengl32.dll
import glColor3f opengl32.dll
import glColor4ub opengl32.dll
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

ALIGN 4
DrawGLScene:
.Loop equ 4
  enter .Loop,0
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call [glClear] ;Clear screen and depth
  
  push dword [texture] 
  push dword GL_TEXTURE_2D
  call [glBindTexture]

  mov dword ebx,stars ;ebx will point to current star
  mov dword [ebp-.Loop],0         ;loop will count loop num.
 .StarLoop:
  cmp dword [ebp-.Loop],numStars
  je .EndStarLoop
  call [glLoadIdentity] ;Reset current modelview matrix

  _glTranslatef __float32__(0.0),__float32__(0.0),[zoom]
  _glRotatef [tilt],__float32__(1.0),__float32__(0.0),__float32__(0.0)

  _glRotatef [ebx+Star.angle],__float32__(0.0),__float32__(1.0),__float32__(0.0)
  _glTranslatef [ebx+Star.dist],__float32__(0.0),__float32__(0.0)

  push dword __float32__(0.0)
  push dword __float32__(1.0)
  push dword __float32__(0.0)  
  push dword [ebx+Star.angle]
  xor dword [esp],0x80000000
  call [glRotatef]   

  push dword __float32__(0.0)
  push dword __float32__(0.0)
  push dword __float32__(1.0)
  push dword [tilt]
  xor dword [esp],0x80000000
  call [glRotatef]   

 ;****************
  sub dword [twinkle],0
  jz .NoTwinkle
  push ebx
  mov dword ebx,stars
  add dword ebx,numStars-1
  sub dword ebx,[ebp-.Loop]
  push dword 255
  xor eax,eax
  mov byte al,[ebx+Star.b]
  push eax
  mov byte al,[ebx+Star.g]
  push eax
  mov byte al,[ebx+Star.r]
  push eax
  call [glColor4ub]

  pop dword ebx

  push dword GL_QUADS
  call [glBegin]
   _immglTexCoord2f(0.0,0.0)
   _immglVertex3f(-1.0,-1.0,0.0)
   _immglTexCoord2f(1.0,0.0)
   _immglVertex3f(1.0,-1.0,0.0)
   _immglTexCoord2f(1.0,1.0)
   _immglVertex3f(1.0,1.0,0.0)
   _immglTexCoord2f(0.0,1.0)
   _immglVertex3f(-1.0,1.0,0.0)   
  call [glEnd]
 .NoTwinkle:
 ;*****************

  _glRotatef [spin],__float32__(0.0),__float32__(0.0),__float32__(1.0)
  push dword 255
  xor eax,eax
  mov byte al,[ebx+Star.b]
  push eax
  mov byte al,[ebx+Star.g]
  push eax
  mov byte al,[ebx+Star.r]
  push eax
  call [glColor4ub]

  push dword GL_QUADS
  call [glBegin]
   _immglTexCoord2f(0.0,0.0)
   _immglVertex3f(-1.0,-1.0,0.0)
   _immglTexCoord2f(1.0,0.0)
   _immglVertex3f(1.0,-1.0,0.0)
   _immglTexCoord2f(1.0,1.0)
   _immglVertex3f(1.0,1.0,0.0)
   _immglTexCoord2f(0.0,1.0)
   _immglVertex3f(-1.0,1.0,0.0)   
  call [glEnd]


  fld dword [spin]
  fadd dword [spingap]
  fstp dword [spin]

  fld dword [ebx+Star.angle]
  fild dword [ebp-.Loop]
  push dword numStars
  fild dword [esp]
  pop dword eax
  fdivp st1,st0
  faddp st1,st0
  fstp dword [ebx+Star.angle]
  
  fld dword [ebx+Star.dist]
  fsub dword [distgap]
  ftst
  fstsw ax
  fstp dword [ebx+Star.dist]
  fwait
  sahf
  
  ja .NoDistReset
  mov dword eax,__float32__(5.0)
  mov dword [ebx+Star.dist],eax
  ;ftst
  ;fstsw
  ;fwait
  ;sahf
  ;jb

  ;If Star.dist < 0.0 add 5.0 and create new color
 .NoDistReset:
  add dword ebx,Star_size
  inc dword [ebp-.Loop]
  jmp .StarLoop
 .EndStarLoop:
  mov dword eax,1
 leave
ret ;DrawGLScene

section .data USE32
spin  dd 0.0
spingap dd 0.01
distgap dd 0.01
zeropzero dd 0.0