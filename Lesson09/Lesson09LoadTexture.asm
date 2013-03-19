%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern LocalAlloc
extern LocalFree
extern glGenTextures
extern glBindTexture
extern glTexImage2D
extern glTexParameteri
extern glGetError
extern gluBuild2DMipmaps
extern LoadImageA
extern GetObjectA
extern SelectObject
extern CreateCompatibleDC
extern GetDIBits
extern DeleteObject
extern DeleteDC


import LocalAlloc kernel32.dll
import LocalFree kernel32.dll
import glGenTextures opengl32.dll
import glBindTexture opengl32.dll
import glTexImage2D opengl32.dll
import glTexParameteri opengl32.dll
import glGetError opengl32.dll
import gluBuild2DMipmaps glu32.dll
import LoadImageA User32.dll
import GetObjectA gdi32.dll
import SelectObject gdi32.dll
import CreateCompatibleDC gdi32.dll
import GetDIBits gdi32.dll
import DeleteObject gdi32.dll
import DeleteDC gdi32.dll

global LoadGLTextures
global texture

segment .code public use32 CLASS=CODE

;Returns a pointer to the bitmap data
;The first 2 dwords contain width and length
LoadBitmap:
 .FileName equ 8

 .ImgInfo equ BITMAP_size
 .BitmapInfo equ .ImgInfo+BITMAPINFOHEADER_size
 .hBitmap equ .BitmapInfo+4
 .hDC equ .hBitmap+4
 .DataPtr equ .hDC+4
  enter .DataPtr,0

  push dword LR_LOADFROMFILE|LR_CREATEDIBSECTION
  push dword 0
  push dword 0
  push dword IMAGE_BITMAP
  push dword [ebp+.FileName]
  push dword 0
  call [LoadImageA]
  mov [ebp-.hBitmap],eax

  sub eax,0
  jz .LoadBitmapEnd

  lea ebx,[ebp-.ImgInfo]
  push ebx
  push dword BITMAP_size
  push eax
  call [GetObjectA]  ;Fill in the imgInfo
  

  push dword 0
  call [CreateCompatibleDC]
  mov dword [ebp-.hDC],eax
  
  sub eax,0
  jz .LoadBitmapEnd
  
  push dword [ebp-.hBitmap]
  push eax
  call [SelectObject]
  
  lea ecx,[ebp-.BitmapInfo]
  mov dword [ecx+BITMAPINFOHEADER.biSize],BITMAPINFOHEADER_size
  mov dword eax,[ebx+BITMAP.bmWidth]
  mov dword [ecx+BITMAPINFOHEADER.biWidth],eax
  mov dword eax,[ebx+BITMAP.bmHeight]
  mov dword [ecx+BITMAPINFOHEADER.biHeight],eax
  mov word [ecx+BITMAPINFOHEADER.biPlanes],0x1
  mov word [ecx+BITMAPINFOHEADER.biBitCount],24 ;Remember to change heap alloc as well
  mov dword [ecx+BITMAPINFOHEADER.biCompression],0
  mov dword [ecx+BITMAPINFOHEADER.biSizeImage],0
  mov dword [ecx+BITMAPINFOHEADER.biXPelsPerMeter],0
  mov dword [ecx+BITMAPINFOHEADER.biYPelsPerMeter],0
  mov dword [ecx+BITMAPINFOHEADER.biClrUsed],0x0
  mov dword [ecx+BITMAPINFOHEADER.biClrImportant],0x0

  mov dword ecx,[ebx+BITMAP.bmWidth]
  mov dword eax,[ebx+BITMAP.bmHeight]
  mul ecx
  mov dword ecx,3
  mul ecx ;3 bytes for each pixel
  add eax,8 ;2 dwords for width/height
  mov dword ebx,eax

  push ebx
  push LMEM_ZEROINIT
  call [LocalAlloc]
  mov [ebp-.DataPtr],eax


  lea ebx,[ebp-.BitmapInfo]
  mov dword ecx,[ebx+BITMAP.bmWidth]
  mov [eax],ecx
  mov dword ecx,[ebx+BITMAP.bmHeight]
  mov [eax+4],ecx
  add dword eax,8

  push dword DIB_RGB_COLORS
  push ebx
  push eax
  push dword [eax-4]
  push dword 0
  push dword [ebp-.hBitmap]
  push dword [ebp-.hDC]
  call [GetDIBits]
  
  push dword [ebp-.hBitmap]
  call [DeleteObject]

  push dword [ebp-.hDC]
  call [DeleteDC]

  mov eax,[ebp-.DataPtr]  
 .LoadBitmapEnd:
  leave
retn 4

;Returns non zero on success
LoadGLTextures:

  push dword fileName
  call LoadBitmap
  mov ebx,eax
  add dword ebx,8

  push dword texture
  push dword 1 
  call [glGenTextures]
  
  push dword [texture]
  push GL_TEXTURE_2D
  call [glBindTexture]
  
  push dword GL_LINEAR
  push dword GL_TEXTURE_MAG_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  push dword GL_LINEAR
  push dword GL_TEXTURE_MIN_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  push dword ebx
  push dword GL_UNSIGNED_BYTE
  push dword GL_BGR_EXT
  push dword 0
  push dword [ebx-4]
  push dword [ebx-8]
  push dword 3
  push dword 0
  push dword GL_TEXTURE_2D
  call [glTexImage2D]

  sub ebx,8
  push ebx
  call [LocalFree]

  mov dword eax,1

 .LoadGLTexturesEnd:
ret

section .bss
texture resd 1

section .data use32
fileName db "Star.bmp",0  