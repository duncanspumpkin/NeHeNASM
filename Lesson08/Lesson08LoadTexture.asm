;*************************************
;*  LoadTexture.asm by Duncan Frost  *
;*            05/04/2013             *
;*************************************

;Exposes "LoadGLTextures" function - this will
;load the texture specified in fileName variable

;Exposes "texture" object - this is an array of
;all of the loaded textures. It can be more than
;one item due to different filters.

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
extern MessageBoxA


import LocalAlloc kernel32.dll
import LocalFree kernel32.dll
import glGenTextures opengl32.dll
import glBindTexture opengl32.dll
import glTexImage2D opengl32.dll
import glTexParameteri opengl32.dll
import glGetError opengl32.dll
import gluBuild2DMipmaps glu32.dll
import LoadImageA User32.dll
import MessageBoxA User32.dll
import GetObjectA gdi32.dll
import SelectObject gdi32.dll
import CreateCompatibleDC gdi32.dll
import GetDIBits gdi32.dll
import DeleteObject gdi32.dll
import DeleteDC gdi32.dll

global LoadGLTextures
global texture

segment .code public use32 CLASS=CODE

;********************************************
;           LoadBitmap (string FileName)
;
;Loads the bitmap specified by FileName input
;variable. Will convert format to 24bit a pixel
;from whatever the loaded file was.
;
;Returns a pointer to the bitmap pixel data
;The first 2 dwords contain width and length
;Returns zero if failed
; _______ ________ __________________________
;| Width | Height | PixelData 24bit a pixel  |
;|_______|________|__________________________|
;********************************************

LoadBitmap:
 .FileName equ 8

 ;This will contain information on the loaded bitmap
 .ImgInfo equ BITMAP_size
 
 ;This will be used to specify output format of loadbitmap
 .BitmapInfo equ .ImgInfo+BITMAPINFOHEADER_size

 ;Stores handle to bitmap
 .hBitmap equ .BitmapInfo+4
 
 ;Handle to temporary DC required for format changes
 .hDC equ .hBitmap+4
 
 ;Storage of output pointer
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
  jnz .LoadImageGood
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword LDFAILT
  push dword LDFAIL
  push dword 0
  call [MessageBoxA]  
  xor eax,eax
  jmp .LoadBitmapEnd

 .LoadImageGood:
  ;Now that image has loaded correctly we
  ;need to convert to prefered pixel format
  ;i.e. 24bit a pixel

  ;To convert we need some more info on this
  ;bitmap such as height and width.
  lea ebx,[ebp-.ImgInfo]
  push ebx
  push dword BITMAP_size
  push eax
  call [GetObjectA]  ;Fill in the imgInfo
  
  ;Create a DC for our image format changes
  push dword 0
  call [CreateCompatibleDC]
  mov dword [ebp-.hDC],eax
  
  sub eax,0
  jz .LoadBitmapEnd

  ;Select the bitmap onto the DC  
  push dword [ebp-.hBitmap]
  push eax
  call [SelectObject]
  
  ;Specify our new image format. The only important
  ;part is the biBitCount being 24 bits.
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

  ;Calculate the size of the output data. 
  ;bitmap pixel data (width*height*3bytes) + width + height
  mov dword ecx,[ebx+BITMAP.bmWidth]
  mov dword eax,[ebx+BITMAP.bmHeight]
  mul ecx
  mov dword ecx,3
  mul ecx ;3 bytes for each pixel
  
  ;Add on two dwords for width and height at start of data
  add eax,8
  mov dword ebx,eax

  ;Find some clear memory
  push ebx
  push LMEM_ZEROINIT
  call [LocalAlloc]
  mov [ebp-.DataPtr],eax

  ;Save our height & width
  lea ebx,[ebp-.BitmapInfo]
  mov dword ecx,[ebx+BITMAP.bmWidth]
  mov [eax],ecx
  mov dword ecx,[ebx+BITMAP.bmHeight]
  mov [eax+4],ecx
  add dword eax,8

  ;Save our pixel data
  push dword DIB_RGB_COLORS
  push ebx
  push eax 
  push dword [eax-4] 
  push dword 0
  push dword [ebp-.hBitmap]
  push dword [ebp-.hDC]
  call [GetDIBits]
  
  ;Clean up
  push dword [ebp-.hBitmap]
  call [DeleteObject]

  push dword [ebp-.hDC]
  call [DeleteDC]

  ;Present our final output
  mov eax,[ebp-.DataPtr]  
 .LoadBitmapEnd:
  leave
retn 4

;********************************************
;           LoadGLTextures
;
;This function loads the bitmap specified in
;local static variable "fileName" and converts
;the bitmap into a GL texture.
;You can then used the loaded GL texture with 
;the global array "texture".
;Returns non zero on success
;********************************************

LoadGLTextures:
  ;Load our bitmap file returns pointer to data
  push dword fileName
  call LoadBitmap

  sub dword eax,0
  jnz .LoadBitmapGood
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword LDFAILT
  push dword LDBITFAIL
  push dword 0
  call [MessageBoxA]
  xor eax,eax
  jmp .LoadGLTexturesEnd

 .LoadBitmapGood:
  mov ebx,eax
  ;Jump over width & height
  add dword ebx,8

  ;We have 3 different filters we want
  ;to show off so define 3 textures
  push dword texture
  push dword 3  
  call [glGenTextures]
  
  push dword [texture]
  push GL_TEXTURE_2D
  call [glBindTexture]

  ;Specifiy the filter we are using  
  push dword GL_NEAREST
  push dword GL_TEXTURE_MAG_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri]  

  push dword GL_NEAREST
  push dword GL_TEXTURE_MIN_FILTER
  push dword GL_TEXTURE_2D
  call [glTexParameteri] 
 
  ;Generate the texture from the bitmap  
  push dword ebx
  push dword GL_UNSIGNED_BYTE
  ;Bitmaps are generated blue green red not
  ;red green blue. Although this is an extension
  ;in the GPU the format will be flipped back to
  ;BGR so using this ext should in theory be
  ;quicker (depending on openGL implementation)
  push dword GL_BGR_EXT
  push dword 0
  push dword [ebx-4]
  push dword [ebx-8]
  ;3? I think this means 3 bytes - 24 bpp
  push dword 3
  push dword 0
  push dword GL_TEXTURE_2D
  call [glTexImage2D]

  ;Bind the texture to the "texture" var
  push dword [texture+4]
  push GL_TEXTURE_2D
  call [glBindTexture]

  ;Rinse repeat see above but with a different filter  
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

  ;This is just a different type of filter
  ;ultimatly very similar to above two textures
  push dword ebx
  push dword GL_UNSIGNED_BYTE
  push dword GL_BGR_EXT
  push dword [ebx-4]
  push dword [ebx-8]
  push dword 3
  push dword GL_TEXTURE_2D
  call [gluBuild2DMipmaps]

  ;Go back to start of pointer (width + height)
  ;so that we can free all of the pointer
  sub ebx,8
  push ebx
  call [LocalFree]

  mov dword eax,1

 .LoadGLTexturesEnd:
ret

section .bss
texture resd 3

section .data use32
fileName db "Glass.bmp",0  
LDFAIL db "Failed to load Image! Is file name incorrect?",0
LDFAILT db "Load Fail",0
LDBITFAIL db "Failed to load Bitmap!",0