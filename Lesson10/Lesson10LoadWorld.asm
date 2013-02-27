%include "WIN32N.INC"
%include "Lesson10.INC"

extern CreateFileA
extern ReadFile
extern GetFileSize
extern CloseHandle
extern SetFilePointer
extern LocalAlloc
extern LocalFree

import CreateFileA kernel32.dll
import ReadFile kernel32.dll
import GetFileSize kernel32.dll
import SetFilePointer kernel32.dll
import CloseHandle kernel32.dll
import LocalAlloc kernel32.dll
import LocalFree kernel32.dll


global LoadWorld
global WorldSector

segment .code public use32 CLASS=CODE

;Returns zero on fail
;Parameters: fileName
ReadWorldFile:
.fileName equ 8
.bytesRead equ 4
;Note we have added 2 extra bytes as bitmapFileHdr is 2 bytes short of alignment
.hFile equ .bytesRead+4
.noBytes equ .hFile+4
.fileSize equ .noBytes+4
.ptrFile equ .fileSize+4

  ENTER .ptrFile,0

  push dword 0
  push dword FILE_ATTRIBUTE_NORMAL
  push dword OPEN_EXISTING
  push dword 0
  push dword FILE_SHARE_READ
  push dword GENERIC_READ
  push dword [ebp+.fileName]
  call [CreateFileA]
  mov [ebp-.hFile],eax

  cmp eax,INVALID_HANDLE_VALUE
  jne .CreateFileSuccess
  xor eax,eax
  jmp .ReadWorldFileEnd

 .CreateFileSuccess:

  
  lea ebx,[ebp-.fileSize]
  push ebx 
  ;ebx will be filled with high dword of file size
  ;it will not be needed but needs to be pointed at something
  push eax 
  call [GetFileSize]
  ;eax contains low dword of file size
  mov dword [ebp-.fileSize],eax
  
  ;Add 2 bytes at end of memory to provide a stopping point
  add dword eax,2
  push eax
  push dword LMEM_ZEROINIT
  call [LocalAlloc]
  mov dword [ebp-.ptrFile],eax

  push dword 0
  lea ebx,[ebp-.bytesRead]
  push ebx
  push dword [ebp-.fileSize] ;Fills in file hdr and info hdr
  push dword [ebp-.ptrFile]
  push dword [ebp-.hFile]
  call [ReadFile]

  push eax
  push dword [ebp-.hFile]  
  call [CloseHandle]
  pop dword eax

  mov dword ebx,[ebp-.fileSize]
  cmp dword [ebp-.bytesRead],ebx
  jne .ReadFail
    
  sub eax,0
  jnz .ReadSuccess

 .ReadFail: 
  xor eax,eax
  jmp .ReadWorldFileEnd

 .ReadSuccess:
  
  mov eax,[ebp-.ptrFile]

 .ReadWorldFileEnd:
  leave
ret 4

;Returns non zero on success
LoadWorld:
  push dword fileName
  call ReadWorldFile
  push eax
  call NextGoodLine

  ;Check if next word is NUMPOLLIES
  mov dword esi,eax
  mov dword edi,sNumpollies
  mov dword ecx,sNumpollies.Length ;Length of sNumpollies
  rep cmpsb
  ;Allocate memory for pollies
  jne .LoadWorldFail

  ;Get NUMPOLLIES
  mov dword ebx,esi
  call AtoI
  ;eax now contains NUMPOLLIES
  mov dword [WorldSector+SECTOR.numTriangles],eax
  
  ;Allocate memory for sector
  mov dword ecx,TRIANGLE_size
  mul ecx ;This is amount of memory required
  push eax
  push dword LMEM_ZEROINIT
  call [LocalAlloc]
  mov dword [WorldSector+SECTOR.triangle],eax

  ;Read rest of document
  mov dword ecx,eax ;This points to the current triangle
  mov dword eax,[WorldSector+SECTOR.numTriangles] ;This will count down triangle

  push ebx
  call NextGoodLine
  push ebx
  call AtoF
  mov dword [ecx+VERTEX.x],eax

  call SkipSpace
  push ebx
  call AtoF
  mov dword [ecx+VERTEX.y],eax

  call SkipSpace
  push ebx
  call AtoF
  mov dword [ecx+VERTEX.z],eax

  call SkipSpace
  push ebx
  call AtoF
  mov dword [ecx+VERTEX.u],eax

  call SkipSpace
  push ebx
  call AtoF
  mov dword [ecx+VERTEX.v],eax
  
  call AtoF
 .LoadWorldFail:
  xor eax,eax
  leave
ret

SkipSpace:
  cmp byte [ebx],' '
  jne .endSS
  inc ebx
  jmp SkipSpace
 .endSS:
ret

NextGoodLine:
.File equ 8
  enter 0,0
  mov dword ebx,[ebp+.File]

 .NextLine: 
  mov word ax,[CRLF]
  cmp word [ebx],ax
  jne .NotCRLF
  add dword ebx,2
  jmp .NextLine

 .NotCRLF:
  mov word ax,[COMMENT]
  cmp word [ebx],ax
  jne .NotComment
  add dword ebx,2
 
  .NextCommentByte:
   cmp word [ebx],0
   je .EndOfFile
   mov word ax,[CRLF]
   cmp word [ebx],ax  
   je .NextLine
   inc dword ebx
   jmp .NextCommentByte
  
 .NotComment:
  cmp word [ebx],0
  je .EndOfFile

  cmp byte [ebx],' '
  jne .LineFound
  inc ebx
  jmp .NextLine
 .EndOfFile:
  xor ebx,ebx
 .LineFound:
  mov eax,ebx
  leave
ret 4

;Eax will contain float result Ebx points to last read byte.
AtoF:
.fltStr equ 8
.fltRes equ 4
  enter .fltRes,0
  push ecx
  push edx
  mov dword ebx,[ebp+.fltStr]
  
  call AtoI
  
  push ecx
  push eax
  fild dword [esp]
  fild dword [esp+4]
  fdivp st1,st0
  fstp dword [ebp-.fltRes]
  add dword esp,8
  sub dword edx,0
  jz .EndConv
 
  mov ebx,edx
  inc ebx

  call AtoI
  push eax
;Makes the value x10^100
  fild dword [esp]    ;load the exponent
  fldl2t                  ;load log2(10)
  fmul                    ;->log2(10)*exponent
  pop dword edx

;at this point, only the log base 2 of the 10^exponent is on the FPU
;the FPU can compute the antilog only with the mantissa
;the characteristic of the logarithm must thus be removed
    
  fld   st0             ;copy the logarithm
  frndint                 ;keep only the characteristic
  fsub  st1,st0          ;keeps only the mantissa
  fxch                    ;get the mantissa on top
  f2xm1                   ;->2^(mantissa)-1
  fld1
  fadd                    ;add 1 back

;the number must now be readjusted for the characteristic of the logarithm

  fscale                  ;scale it with the characteristic
      
;the characteristic is still on the FPU and must be removed

  fstp  st1             ;clean-up the register
  fld dword [ebp-.fltRes]
  fmul st0,st1
  fstp st1
  fstp dword [ebp-.fltRes]
 .EndConv:
  mov dword eax,[ebp-.fltRes]
  pop dword edx
  pop dword ecx
  leave
ret 4
;This function assumes ebx is loaded with ptr to string
;It returns eax with the value and ecx with dotMult, edx has the position of E.
AtoI:
.intRes equ 4
.dotMult equ .intRes+4
.sign    equ .dotMult+4
.ePos    equ .sign+4

  Enter .ePos,0
  xor ecx,ecx
  mov dword [ebp-.sign],0
  mov dword [ebp-.dotMult],0
  mov dword [ebp-.intRes],0
  mov dword [ebp-.ePos],0
 .DigitLoop:
  cmp byte [ebx],'0'
  jl .NotADigit
  cmp byte [ebx],'9'
  jg .NotADigit

 .IsDigit:
  xor ecx,ecx
  mov byte cl,[ebx]
  sub byte cl,'0'
  mov dword eax,10
  mul dword [ebp-.intRes]
  add ecx,eax
  mov dword [ebp-.intRes],ecx
  mov dword eax,10
  mul dword [ebp-.dotMult]
  mov dword [ebp-.dotMult],eax
  inc ebx
  jmp .DigitLoop

 .NotADigit:
  cmp byte [ebx],'-'
  jne .NotNeg
  inc dword [ebp-.sign]
  inc ebx
  jmp .DigitLoop

 .NotNeg:
  cmp byte [ebx],'.'
  jne .NotDot
  inc dword [ebp-.dotMult]
  inc ebx
  jmp .DigitLoop

 .NotDot:
  cmp byte [ebx],'E'
  jne .NotE
  mov dword [ebp-.ePos],ebx

 .NotE:
  jmp .EndFloatConv
  ;If not digit neg dot or E end loop

 .EndFloatConv:
  sub dword [ebp-.sign],0
  jz .NoNeging
  neg dword [ebp-.intRes]
 .NoNeging:
  mov dword eax,[ebp-.intRes]
  mov dword ecx,[ebp-.dotMult]
  mov dword edx,[ebp-.ePos]
 leave
ret 

section .bss
WorldSector resb SECTOR_size


section .data use32
fileName db "World.txt",0


sNumpollies db "NUMPOLLIES ",0
sNumpollies.Length equ $-sNumpollies-1 ;-1 as we dont need the 0
CRLF db 0x0D,0x0A,0
COMMENT db "//",0