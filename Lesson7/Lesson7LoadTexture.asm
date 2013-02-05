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

global LoadGLTextures
global texture

segment .code public use32 CLASS=CODE

;Returns zero on fail
;Parameters: fileName
;Basically assumes file will be 24bpp
ReadBitmap:
.fileName equ 8
.bitmapFileHdr equ BITMAPFILEHEADER_size
.bitmapInfoHdr equ .bitmapFileHdr+BITMAPINFOHEADER_size
.bytesRead equ .bitmapInfoHdr+6 
;Note we have added 2 extra bytes as bitmapFileHdr is 2 bytes short of alignment
.hFile equ .bytesRead+4
.hHeap equ .hFile+4
.noBytes equ .hHeap+4
.ptrPixel equ .noBytes+4
  ENTER .ptrPixel,0
  push dword 0
  push dword FILE_ATTRIBUTE_NORMAL
  push dword OPEN_EXISTING
  push dword 0
  push dword FILE_SHARE_READ
  push dword GENERIC_READ
  push dword fileName;[ebp+.fileName]
  call [CreateFileA]
  mov [ebp-.hFile],eax

  cmp eax,INVALID_HANDLE_VALUE
  jne .CreateFileSuccess
  xor eax,eax
  jmp .ReadBitmapEnd

 .CreateFileSuccess:

  push dword 0
  lea ebx,[ebp-.bytesRead]
  push ebx
  push dword .bitmapInfoHdr ;Fills in file hdr and info hdr
  lea ebx,[ebp-.bitmapInfoHdr]
  push ebx
  push eax
  call [ReadFile]

  cmp dword [ebp-.bytesRead],.bitmapInfoHdr
  jne .ReadFail

  sub eax,0
  jnz .ReadSuccess

 .ReadFail: 
  xor eax,eax
  jmp .ReadBitmapEnd

 .ReadSuccess:
  
  ;We have loaded the file in reverse
  ;so we need to remember to look at it back to front
  
  ;Reposition in file for pixel data
  push dword FILE_BEGIN
  push dword 0
  push dword [ebx+BITMAPFILEHEADER.bfOffBits] ;NOT CORRECT
  push dword [ebp-.hFile]
  call [SetFilePointer]

  sub eax,0
  jnz .SetFP
  xor eax,eax
  jmp .ReadBitmapEnd

 .SetFP:
  ;((bitsperpix*width+31)/32)*4*height
  lea ebx,[ebp-BITMAPINFOHEADER_size]
  xor eax,eax
  mov ax,[ebx+BITMAPINFOHEADER.biBitCount]
  mov edi,[ebx+BITMAPINFOHEADER.biWidth]
  mul edi
  add eax,31
  shr eax,5
  shl eax,2
  mov edi,[ebx+BITMAPINFOHEADER.biHeight]
  mul edi ;number of bytes in for data.
  mov ebx,eax
  mov [ebp-.noBytes],eax
  add ebx,8 ;Add space for x*y
  
  call [GetProcessHeap]
  mov [ebp-.hHeap],eax
  
  push ebx
  push HEAP_ZERO_MEMORY
  push eax
  call [HeapAlloc]
  mov [ebp-.ptrPixel],eax

  sub eax,0
  jnz .HeapAlloced
  xor eax,eax
  jmp .ReadBitmapEnd

 .HeapAlloced:
  lea ebx,[ebp-BITMAPINFOHEADER_size]
  mov dword edi,[ebx+BITMAPINFOHEADER.biWidth]
  mov [eax],edi 
  add eax,4
  mov dword edi,[ebx+BITMAPINFOHEADER.biHeight]
  mov [eax],edi
  add eax,4
  push dword 0
  lea ebx,[ebp-.bytesRead]
  push ebx
  push dword [ebp-.noBytes]
  push eax
  push dword [ebp-.hFile]
  call [ReadFile]
  
  push dword [ebp-.hFile]
  call [CloseHandle] 
  mov eax,[ebx]
  cmp [ebp-.noBytes],eax
  je .ReadBitSuccess
  xor eax,eax
  jmp .ReadBitmapEnd

 .ReadBitSuccess:
  ;Swap bytes so pixels in rgb format not bgr
  mov eax,[ebp-.ptrPixel]
  add eax,8 ;Jump over x/y dimensions
  mov edx,eax
  add edx,[ebp-.noBytes]

 .SwapLoop:
  mov dword ecx,[eax]
  mov ebx,ecx
  bswap ebx
  shr ebx,8
  and ecx,0xff000000
  or ebx,ecx
  mov dword [eax],ebx
  add eax,3
  cmp eax,edx
  jl .SwapLoop
  
  ;Add code to switch from bottom to top to top to bottom pixel rows
  mov eax,[ebp-.ptrPixel]

 .ReadBitmapEnd:
  leave
ret 4

;Returns non zero on success
LoadGLTextures:
  push fileName
  call ReadBitmap
  mov ebx,eax

  sub eax,0
  jz .LoadGLTexturesEnd
  
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

  add ebx,8
  push ebx
  push dword GL_UNSIGNED_BYTE
  push dword GL_RGB;GL_BGR_EXT
  push dword 0
  sub ebx,4
  push dword [ebx]
  sub ebx,4
  push dword [ebx]
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

  add ebx,8
  push ebx
  push dword GL_UNSIGNED_BYTE
  push dword GL_RGB;GL_BGR_EXT
  push dword 0
  sub ebx,4
  push dword [ebx]
  sub ebx,4
  push dword [ebx]
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

  add ebx,8
  push ebx
  push dword GL_UNSIGNED_BYTE
  push dword GL_RGB;GL_BGR_EXT
  sub ebx,4
  push dword [ebx]
  sub ebx,4
  push dword [ebx]
  push dword 3
  push dword GL_TEXTURE_2D
  call [gluBuild2DMipmaps]

  call [GetProcessHeap]
  push ebx
  push 0
  push eax
  call [HeapFree]
  ;free heap

  mov dword eax,1

 .LoadGLTexturesEnd:
ret

section .bss
nBytes resd 1
texture resd 3

section .data use32
fileName db "Crate.bmp",0  