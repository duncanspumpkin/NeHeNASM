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
extern hInstance
extern BitBlt
extern CreateCompatibleDC
extern CreateBitmap
extern CreateDIBSection
extern GetProcessHeap
extern HeapAlloc
extern HeapFree
;extern DeleteObjectW

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
import BitBlt gdi32.dll
import CreateCompatibleDC gdi32.dll
import CreateBitmap gdi32.dll
import CreateDIBSection gdi32.dll
import GetProcessHeap kernel32.dll
import HeapAlloc kernel32.dll
import HeapFree kernel32.dll
;import DeleteObjectW gdi32.dll

global LoadGLTextures
global texture

segment .code public use32 CLASS=CODE

;Returns non zero on success
LoadGLTextures:
.ImgInfo equ BITMAP_size
.BmpInfo equ .ImgInfo+BITMAPINFO_size
.BmpInfoHdr equ BITMAPINFOHEADER_size + .BmpInfo
  enter .BmpInfoHdr,0
  push dword LR_LOADFROMFILE|LR_CREATEDIBSECTION
  push dword 0
  push dword 0
  push dword IMAGE_BITMAP
  push dword fileName
  push dword [hInstance]
  call [LoadImageA]
  mov dword [hBitmap],eax
  sub eax,0
  jz .LoadGLTexturesEnd
  
  push dword 0
  call [CreateCompatibleDC]
  mov dword [hDCMem],eax

  push dword [hBitmap]
  push dword [hDCMem]
  call [SelectObject]

  call [GetProcessHeap]
  mov ebx,eax
  
  push dword 0x100*0x100*4
  push HEAP_ZERO_MEMORY
  push ebx
  call [HeapAlloc]
  mov [BitsPointer],eax

  push dword 0
  push dword 0
  push dword [BitsPointer]
  push dword DIB_RGB_COLORS
  lea ecx,[ebp-.BmpInfoHdr]
  mov dword [ebp+BITMAPINFOHEADER.biSize],BITMAPINFO_size
  mov dword [ebp+BITMAPINFOHEADER.biCompression],BI_RGB
  mov dword [ebp+BITMAPINFOHEADER.biBitCount],32
  mov dword [ebp+BITMAPINFOHEADER.biPlanes],1
  mov dword [ebp+BITMAPINFOHEADER.biHeight],0x100
  mov dword [ebp+BITMAPINFOHEADER.biWidth],0x100
  push dword ecx
  push dword [hDCMem]
  call [CreateDIBSection]
  mov ebx,eax

  lea ecx,[ebp-.ImgInfo]
  push ecx
  push dword BITMAP_size
  push ebx
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
  push dword [ecx+BITMAP.bmBits]
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
  push dword [ecx+BITMAP.bmBits]
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
  push dword [ecx+BITMAP.bmBits]
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
hDCMem resd 1
hDCAct resd 1
hBitmap resd 1
BitsPointer resd 1
section .data use32
fileName db "Crate.bmp",0  