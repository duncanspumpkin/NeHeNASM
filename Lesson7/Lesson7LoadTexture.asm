%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"

extern CreateFileA
extern ReadFile
extern CloseHandle
extern SetFilePointer
extern GetProcessHeap
extern HeapAlloc
extern HeapFree
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
extern hInstance
extern GetDIBits
;extern DeleteObjectW
;extern ReleaseDC

import CreateFileA kernel32.dll
import ReadFile kernel32.dll
import SetFilePointer kernel32.dll
import CloseHandle kernel32.dll
import GetProcessHeap kernel32.dll
import HeapAlloc kernel32.dll
import HeapFree kernel32.dll
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
;import DeleteObjectW gdi32.dll

global LoadGLTextures
global texture

segment .code public use32 CLASS=CODE

;Returns non zero on success
LoadGLTextures:
.ImgInfo equ BITMAP_size
.BitmapInfo equ BITMAPINFOHEADER_size + .ImgInfo
  enter .BitmapInfo,0
  push dword LR_LOADFROMFILE|LR_CREATEDIBSECTION
  push dword 0
  push dword 0
  push dword IMAGE_BITMAP
  push dword fileName
  push dword [hInstance]
  call [LoadImageA]
  mov ebx,eax
  mov [hBitmap],eax
  sub eax,0
  jz .LoadGLTexturesEnd


  push dword 0
  call [CreateCompatibleDC]
  mov dword [hDCMem],eax
  
  push dword [hBitmap]
  push eax
  call [SelectObject]
  
  lea ebx,[ebp-.BitmapInfo]
  
  mov dword [ebx+BITMAPINFOHEADER.biSize],BITMAPINFOHEADER_size
  mov dword [ebx+BITMAPINFOHEADER.biWidth],0x100
  mov dword [ebx+BITMAPINFOHEADER.biHeight],0x100
  mov word [ebx+BITMAPINFOHEADER.biPlanes],0x1
  mov word [ebx+BITMAPINFOHEADER.biBitCount],24
  mov dword [ebx+BITMAPINFOHEADER.biCompression],0
  mov dword [ebx+BITMAPINFOHEADER.biSizeImage],0
  mov dword [ebx+BITMAPINFOHEADER.biXPelsPerMeter],0
  mov dword [ebx+BITMAPINFOHEADER.biYPelsPerMeter],0
  mov dword [ebx+BITMAPINFOHEADER.biClrUsed],0x0
  mov dword [ebx+BITMAPINFOHEADER.biClrImportant],0x0

  call [GetProcessHeap]

  push dword 0x100*0x100*3
  push HEAP_ZERO_MEMORY
  push eax
  call [HeapAlloc]
  mov [ptrBits],eax

  lea ebx,[ebp-.BitmapInfo]
  
  push dword DIB_RGB_COLORS
  push ebx
  push dword [ptrBits]
  push dword 0x100
  push dword 0
  push dword [hBitmap]
  push dword [hDCMem]
  call [GetDIBits]
  mov ebx,[ptrBits]  

  
  lea ecx,[ebp-.ImgInfo]
  push ecx
  push dword BITMAP_size
  push dword [hBitmap]
  call [GetObjectA]  

  push dword texture
  push dword 3  
  call [glGenTextures]
  
  push dword [texture]
  push GL_TEXTURE_2D
  call [glBindTexture]
  
  push dword GL_NEAREST
  push dword GL_TEXTURE_MAG_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  push dword GL_NEAREST
  push dword GL_TEXTURE_MIN_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri] 
 
  lea ecx,[ebp-.ImgInfo]
  push dword [ptrBits]
  push dword GL_UNSIGNED_BYTE
  push dword GL_BGR_EXT
  push dword 0
  push dword [ecx+BITMAP.bmHeight]
  push dword [ecx+BITMAP.bmWidth]
  push dword 3
  push dword 0
  push dword GL_TEXTURE_2D
  call [glTexImage2D]

  push dword [texture+4]
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

  lea ecx,[ebp-.ImgInfo]
  push dword [ptrBits]
  push dword GL_UNSIGNED_BYTE
  push dword GL_BGR_EXT
  push dword 0
  push dword [ecx+BITMAP.bmHeight]
  push dword [ecx+BITMAP.bmWidth]
  push dword 3
  push dword 0
  push dword GL_TEXTURE_2D
  call [glTexImage2D]

  push dword [texture+8]
  push GL_TEXTURE_2D
  call [glBindTexture]
  
  push dword GL_LINEAR
  push dword GL_TEXTURE_MAG_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  push dword GL_LINEAR_MIPMAP_NEAREST
  push dword GL_TEXTURE_MIN_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  lea ecx,[ebp-.ImgInfo]
  push dword [ptrBits]
  push dword GL_UNSIGNED_BYTE
  push dword GL_BGR_EXT
  push dword [ecx+BITMAP.bmHeight]
  push dword [ecx+BITMAP.bmWidth]
  push dword 3
  push dword GL_TEXTURE_2D
  call [gluBuild2DMipmaps]

  ;push ebx
  ;call [DeleteObjectW]

  mov dword eax,1

 .LoadGLTexturesEnd:
  leave
ret

section .bss
nBytes resd 1
texture resd 3
hDCMem  resd 1
hBitmap resd 1
ptrBits resd 1
rgb     resq 1

section .data use32
fileName db "Crate.bmp",0  