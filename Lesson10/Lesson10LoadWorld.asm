extern ExitProcess
import ExitProcess kernel32.dll

segment .data USE32

afloat db "12.145",0
bfloat db "-123.23",0
cfloat db "1.023E123",0
dfloat db "-1.0223E-13",0

segment .bss USE32
fltStr resd 1
bcdRes resd 6
intRes resd 1
fltRes resd 1
endPos resd 1
dotMult resd 1
ePos   resd 1
sign    resd 1

segment code use32 class=CODE

..start:
  ;First we convert the float into int removing - and . will stop at end or E
  ;When we hit a . we start multing 10 to dotMult so that we can divide at the end
  mov dword [fltStr],dfloat
  mov dword ebx,[fltStr]
  
  call AtoI
  
  push ecx
  push eax
  fild dword [esp]
  fild dword [esp+4]
  fdivp st1,st0
  fst dword [fltRes]

  sub dword edx,0
  jz EndConv
 
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
  fmul st0,st1
  fstp st1
  fstp dword [fltRes]
 EndConv:
  call [ExitProcess]

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
  ;If not digit neg dot or E end loop
  jmp .EndFloatConv 

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