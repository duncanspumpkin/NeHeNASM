;; Define the externs for the functions that we'll use in this program. 
%include "WIN32N.INC"
%include "OPENGL32N.INC"
%include "GLU32N.INC"
extern GetModuleHandleA 
extern GetCommandLineA 
extern ExitProcess 
extern MessageBoxA 
extern LoadIconA 
extern LoadCursorA 
extern RegisterClassA 
extern CreateWindowExA 
extern ShowWindow 
extern UpdateWindow 
extern GetMessageA 
extern TranslateMessage 
extern DispatchMessageA 
extern PostQuitMessage 
extern DefWindowProcA 
extern ChangeDisplaySettingsA
extern ShowCursor
extern ReleaseDC
extern DestroyWindow
extern ChangeDisplaySettingsA
extern AdjustWindowRectEx
extern UnregisterClassA
extern GetDC
extern ChoosePixelFormat
extern SetPixelFormat
extern SetForegroundWindow
extern SetFocus
extern PeekMessageA
extern DispatchMessageA
extern SwapBuffers
extern glViewport
extern glMatrixMode
extern glLoadIdentity
extern glShadeModel
extern glClearColor
extern glClearDepth
extern glEnable
extern glDisable
extern glDepthFunc
extern glHint
extern glLightfv
extern wglCreateContext
extern wglMakeCurrent
extern wglDeleteContext
extern gluPerspective

extern LoadGLTextures
extern DrawGLScene


;; Import the Win32 API functions. 
import GetModuleHandleA kernel32.dll 
import GetCommandLineA kernel32.dll 
import ExitProcess kernel32.dll 
import ChoosePixelFormat gdi32.dll
import SetPixelFormat gdi32.dll
import SwapBuffers gdi32.dll
import MessageBoxA user32.dll 
import LoadIconA user32.dll 
import LoadCursorA user32.dll 
import RegisterClassA user32.dll 
import CreateWindowExA user32.dll 
import ShowWindow user32.dll 
import UpdateWindow user32.dll 
import GetMessageA user32.dll 
import TranslateMessage user32.dll 
import DispatchMessageA user32.dll 
import PostQuitMessage user32.dll 
import DefWindowProcA user32.dll 
import ChangeDisplaySettingsA user32.dll
import ShowCursor user32.dll
import ReleaseDC user32.dll
import DestroyWindow user32.dll
import ChangeDisplaySettingsA user32.dll
import AdjustWindowRectEx user32.dll
import UnregisterClassA user32.dll
import GetDC user32.dll
import SetForegroundWindow user32.dll
import SetFocus user32.dll
import PeekMessageA user32.dll
import DispatchMessageA user32.dll
import glViewport opengl32.dll
import glMatrixMode opengl32.dll
import glLoadIdentity opengl32.dll
import glShadeModel opengl32.dll
import glClearColor opengl32.dll
import glClearDepth opengl32.dll
import glEnable opengl32.dll
import glDisable opengl32.dll
import glDepthFunc opengl32.dll
import glHint opengl32.dll
import glClear opengl32.dll
import glLightfv opengl32.dll
import wglMakeCurrent opengl32.dll
import wglDeleteContext opengl32.dll
import wglCreateContext opengl32.dll
import gluPerspective glu32.dll

global xspeed
global yspeed
global zpos

segment code public use32 class=CODE

;; In order to make this code as similar as possible to NeHe's OpenGL tutorial
;; we will first get all of the params of WinMain and call the WinMain function
;; if we were going for as small a program as possible this could be done all in
;; the WinMain function.

;; Entry point of program
..start: 
push dword 0 
;; GetModuleHandleA returns handle to the file used to create this proc when null (0) is param
call [GetModuleHandleA] 

;;Store the result in the ebx reg.
mov ebx, eax 

;; Returns a pointer to the command line arguments. If we are not using commandline params this is
;; not requried.
call [GetCommandLineA] 
;;Since we only use this to send to WinMain there is no point saving it to a variable

;; For the sake of making things look like a normal C prog we have a winmain func
;; this will be passed all the normal winmain params (i.e. handle to instance, previous instance,
;; commandline params, show param).
push dword SW_SHOWDEFAULT 
push eax   ;;push pointer to command line arguments 
;; And a NULL 
push dword 0 
;; Then the hInstance variable. 
push ebx 

;; And we make a call to WindowMain(). See below.
call WindowMain 

;; The program should be complete now push the result of our prog and exit.
push eax 
call [ExitProcess] 
;; Exit Point of our program


;; Resize the OpenGL Scene
;;
;; 2 params width and height

ResizeGLScene:
.width equ 8
.height equ 12
.aspectRatio equ 8 ;Aspect ratio is a qword and takes 8 bytes
  enter .aspectRatio,0 ;Aspect ratio is furthest in stack
  
  ;Adds one to height if 0 to prevent divide by 0 problem
  cmp dword [ebp+.height],0
  jne .heightCheck 
  inc dword [ebp+.height]
 .heightCheck:

  push dword [ebp+.height]
  push dword [ebp+.width]
  push dword 0
  push dword 0
  call [glViewport] ;Change the viewport

  push dword GL_PROJECTION
  call [glMatrixMode]

  call [glLoadIdentity]  
  
  ;Now we need to do a little maths to work out the aspect ratio
  fild dword [ebp+.width]
  fild dword [ebp+.height]
  fdivp st1,st0 ;width/height ? I think...
  fstp qword [ebp-.aspectRatio] ;Store the aspect ratio

  push dword [RGlS_gluFAR+4]
  push dword [RGlS_gluFAR]
  push dword [RGlS_gluNEAR+4]
  push dword [RGlS_gluNEAR] ;Problem area
  push dword [ebp-.aspectRatio+4]
  push dword [ebp-.aspectRatio]
  push dword [RGlS_gluFOV+4]
  push dword [RGlS_gluFOV]
  call [gluPerspective]

  push dword GL_MODELVIEW
  call [glMatrixMode]

  call [glLoadIdentity]
  
  ;As we do not check for errors return true.
  mov dword eax,1
  leave
ret 8;ResizeGLScene 2 dword Params



;InitGL does what it says on the tin
;
;
;

InitGL:
  call LoadGLTextures
  sub eax,0
  jz .InitGLEnd
  
  push dword GL_TEXTURE_2D
  call [glEnable]

  push dword GL_SMOOTH
  call [glShadeModel] ;Smooth shader model

  push dword 0
  push dword 0
  push dword 0
  push dword 0
  call [glClearColor] ;Black background colour

  push dword [IGl_DEPTH+4] ;1.0
  push dword [IGl_DEPTH]
  call [glClearDepth] ;Depth buffer setup

  push dword GL_DEPTH_TEST
  call [glEnable] ;Enable depth testing

  push dword GL_LEQUAL
  call [glDepthFunc] ;Type of depth test

  push dword GL_NICEST
  push dword GL_PERSPECTIVE_CORRECTION_HINT
  call [glHint] ;Nice calculations. Performance hit to make look better
  
  push dword LightAmbient
  push dword GL_AMBIENT
  push dword GL_LIGHT1
  call [glLightfv]

  push dword LightDiffuse
  push dword GL_DIFFUSE
  push dword GL_LIGHT1
  call [glLightfv]

  push dword LightPosition
  push dword GL_POSITION
  push dword GL_LIGHT1
  call [glLightfv]

  push dword GL_LIGHT1
  call [glEnable]

  push dword GL_LIGHTING ;Debug code REMOVE
  call [glEnable]
  ;Return true. We didnt check for errors so we assume it worked fine.
  mov dword eax,1
 .InitGLEnd:
ret ;InitGL


;Performs a graceful killing of the OpenGL window
;
;

KillGLWindow:
  sub dword [fullscreen],0
  jz .NotFullScreen

  push dword 0 
  push dword 0 ;Switch back to desktop
  call [ChangeDisplaySettingsA]

  push dword 1 ;Show cursor.
  call [ShowCursor]

 .NotFullScreen:
  mov dword eax, [hRC] ;Check if rendering context
  or eax,eax
  jz .NoRenderContext
  
  push dword 0
  push dword 0
  call [wglMakeCurrent] ;Returns true if we can release RC
  or eax,eax
  jnz .ReleaseableRC

  push dword MB_OK | MB_ICONINFORMATION ;Word??
  push dword SHUTDWN
  push dword RRCDCFAIL
  push dword 0
  call [MessageBoxA]

 .ReleaseableRC:
  push dword [hRC]
  call [wglDeleteContext]

  or eax,eax
  jnz .ClearRC

  push dword MB_OK | MB_ICONINFORMATION
  push dword SHUTDWN
  push dword RRCFAIL
  push dword 0
  call [MessageBoxA]

 .ClearRC:
  mov dword [hRC],0

 .NoRenderContext: ;We should have no RC if we are here
  sub dword [hDC],0
  jz .NoDeviceContext

  push dword [hDC]
  push dword [hWnd]
  call [ReleaseDC]

  or eax,eax
  jnz .NoDeviceContext
  push dword MB_OK | MB_ICONINFORMATION
  push dword SHUTDWN
  push dword RDCFAIL
  push dword 0
  call [MessageBoxA]
  
  mov dword [hDC],0 ;Delete device context
 
 .NoDeviceContext:
  sub dword [hWnd],0
  jz .NohWnd

  push dword [hWnd]
  call [DestroyWindow]
  
  or eax,eax
  jnz .NohWnd

  push dword MB_OK | MB_ICONINFORMATION
  push dword SHUTDWN
  push dword RHWNDFAIL
  push dword 0
  call [MessageBoxA]
  
 .NohWnd:
  mov dword [hWnd],0
  ;Unregister WndClass
  push dword [hInstance]
  push dword ClassName
  call [UnregisterClassA]
  or eax,eax

  jnz .KillGLEnd 
  push dword MB_OK|MB_ICONINFORMATION
  push dword SHUTDWN
  push dword UCLASSFAIL
  push dword 0
  call [MessageBoxA]

 .KillGLEnd:
  mov dword [hInstance],0

ret ;KillGLWindow

; Creates a new window
; has the following 5 params: char* title, int width, int height, int bits, bool fullscreen
; 4*5 16 bytes
;
CreateGLWindow: 
.title equ 8
.width equ 12
.height equ 16
.bits equ 20
.fullscreen equ 24
.PixelFormat equ 4
.dwExStyle equ 4+.PixelFormat
.dwStyle equ 4+.dwExStyle
.wndClass equ WNDCLASS_size + .dwStyle
.windowRect equ RECT_size + .wndClass
.DmScreenSettings equ .windowRect + DEVMODE_size
.pfd equ .DmScreenSettings + PIXELFORMATDESCRIPTOR_size
  enter .pfd,0

  lea ebx, [ebp-.windowRect]
  mov dword [ebx+RECT.left], 0
  mov dword eax,[ebp+.width]
  mov dword [ebx+RECT.right],eax
  mov dword [ebx+RECT.top], 0
  mov dword eax,[ebp+.height]
  mov dword [ebx+RECT.bottom],eax
  
  mov dword eax,[ebp+.fullscreen]
  mov dword [fullscreen],eax ;Possibly wrong will need to test

  push dword 0
  call [GetModuleHandleA]
  mov dword [hInstance],eax

  ;; Now fill out wndclass
  lea ebx, [ebp-.wndClass]                  ;; We load EBX with the address of our WNDCLASSEX structure. 

  ;; The structure of WNDCLASSEX can be found at this page: 
  ;; http://msdn.microsoft.com/en-us/library/ms633577(v=vs.85).aspx
    
  ;mov dword [ebx+WNDCLASSEX.cbSize], WNDCLASSEX_size   ;; Offset 00 is the size of the structure. 
  mov dword [ebx+WNDCLASS.style], CS_HREDRAW | CS_VREDRAW | CS_OWNDC   
  mov dword [ebx+WNDCLASS.lpfnWndProc], WindowProcedure             ;; Offset 08 is the address of our window procedure. 
  mov dword [ebx+WNDCLASS.cbClsExtra], 0      ;; I'm not sure what offset 12 and offset 16 are for. 
  mov dword [ebx+WNDCLASS.cbWndExtra], 0      ;; But I do know that they're supposed to be NULL, at least for now. 
  mov dword eax,[hInstance]
  mov dword [ebx+WNDCLASS.hInstance], eax  ;; Offset 20 is the hInstance value. 

  mov dword [ebx+WNDCLASS.hbrBackground], 0   ;; Offset 32 is the handle to the background brush. We set that to COLOR_WINDOW + 1. 
  mov dword [ebx+WNDCLASS.lpszMenuName], 0      ;; Offset 36 is the menu name, what we set to NULL, because we don't have a menu. 
  mov dword [ebx+WNDCLASS.lpszClassName], ClassName                     ;; Offset 40 is the class name for our window class. 

  ;; Note that when we're trying to pass a string, we pass the memory address of the string, and the 
  ;; function to which we pass that address takes care of the rest. 

  ;; LoadIcon(0, IDI_APPLICATION) where IDI_APPLICATION is equal to 32512. 
  push dword IDI_WINLOGO 
  push dword 0 
  call [LoadIconA] 

  ;; All Win32 API functions preserve the EBP, EBX, ESI, and EDI registers, so it's 
  ;; okay if we use EBX to store the address of the WNDCLASSEX structure, for now. 
        
  mov dword [ebx+WNDCLASS.hIcon], eax  ;; Offset 24 is the handle to the icon for our window. 
  ;mov dword [ebx+WNDCLASS.hIconSm], eax  ;; Offset 44 is the handle to the small icon for our window. 

        
  ;; LoadCursor(0, IDC_ARROW) where IDC_ARROW is equal to 32512. 
  push dword IDC_ARROW 
  push dword 0 
  call [LoadCursorA] 
        
  mov dword [ebx+WNDCLASS.hCursor], eax  ;; Offset 28 is the handle to the cursor for our window. 
  
  push ebx
  call [RegisterClassA]      
  
  sub eax,0 
  jnz .RegisterClassOkay
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword SHUTDWN
  push dword REGWNDFAIL
  push dword 0
  call [MessageBoxA]
  xor eax,eax
  jmp .ExitCreateGL

 .RegisterClassOkay:
  sub word [fullscreen],0
  jz .GoWindowed

  mov dword ecx, DEVMODE_size
  lea edi,[ebp-.DmScreenSettings]
  xor ax,ax
  rep stosb

  lea ebx,[ebp-.DmScreenSettings]
  mov word [ebx+DEVMODE.dmSize],DEVMODE_size
  mov dword eax,[ebp+.width]
  mov dword [ebx+DEVMODE.dmPelsWidth],eax
  mov dword eax,[ebp+.height]
  mov dword [ebx+DEVMODE.dmPelsHeight],eax
  mov dword eax,[ebp+.bits]
  mov dword [ebx+DEVMODE.dmBitsPerPel],eax
  mov dword [ebx+DEVMODE.dmFields],DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT

  push dword CDS_FULLSCREEN
  push ebx ;Push the dmscreensettings
  call [ChangeDisplaySettingsA]

  cmp eax,DISP_CHANGE_SUCCESSFUL
  jz .FullSuccess
  
  push dword MB_YESNO|MB_ICONEXCLAMATION
  push dword GENERR
  push dword FSFAIL
  push dword 0
  call [MessageBoxA]
  
  cmp eax,IDYES
  jz .GoWindowed

  push dword MB_OK|MB_ICONSTOP
  push dword SHUTDWN
  push dword GENFAIL
  push dword 0
  call [MessageBoxA]

  xor eax,eax
  jmp .ExitCreateGL

 .GoWindowed:
  mov dword [fullscreen],0
  mov dword [ebp-.dwStyle],WS_OVERLAPPEDWINDOW
  mov dword [ebp-.dwExStyle],WS_EX_APPWINDOW|WS_EX_WINDOWEDGE
  jmp .AdjustWindow  

 .FullSuccess:
  mov dword [ebp-.dwStyle],WS_POPUP
  mov dword [ebp-.dwExStyle],WS_EX_APPWINDOW

  push dword 0
  call [ShowCursor]

 .AdjustWindow: ;This is where everything comes back to.
  ;push dword [ebp-.dwExStyle]
  ;push dword 0
  ;push dword [ebp-.dwStyle]
  lea ebx,[ebp-.windowRect]
  ;push ebx
  ;call [AdjustWindowRectEx]

  push dword 0
  push dword [hInstance]
  push dword 0
  push dword 0
  push dword [ebp+.height];Not quite right use wndRect.right-wndRect.left
  push dword [ebp+.width]
  push dword 0
  push dword 0
  
  or dword [ebp-.dwStyle],WS_CLIPSIBLINGS|WS_CLIPCHILDREN

  push dword [ebp-.dwStyle]
  push dword [ebp+.title]
  push dword ClassName
  push dword [ebp-.dwExStyle]
  call [CreateWindowExA]

  mov dword [hWnd],eax
  sub eax,0
  jnz .CreateWndSuccess

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword CWNDFAIL
  push dword 0
  call [MessageBoxA]
  xor eax,eax
  jmp .ExitCreateGL
 .CreateWndSuccess:
  
  ;Set our Pixel format description
  lea ebx,[ebp-.pfd]
  mov word [ebx+PIXELFORMATDESCRIPTOR.nSize],PIXELFORMATDESCRIPTOR_size
  mov word [ebx+PIXELFORMATDESCRIPTOR.nVersion],1
  mov dword [ebx+PIXELFORMATDESCRIPTOR.dwFlags],PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER
  mov byte [ebx+PIXELFORMATDESCRIPTOR.iPixelType],PFD_TYPE_RGBA
  mov dword eax,[ebp+.bits]
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cColorBits],al
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cRedBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cRedShift],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cGreenBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cGreenShift],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cBlueBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cBlueShift],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAlphaBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAlphaShift],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAccumBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAccumRedBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAccumGreenBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAccumBlueBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAccumAlphaBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cDepthBits],16
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cStencilBits],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.cAuxBuffers],0
  mov byte [ebx+PIXELFORMATDESCRIPTOR.iLayerType],PFD_MAIN_PLANE
  mov byte [ebx+PIXELFORMATDESCRIPTOR.bReserved],0
  mov dword [ebx+PIXELFORMATDESCRIPTOR.dwLayerMask],0
  mov dword [ebx+PIXELFORMATDESCRIPTOR.dwVisibleMask],0
  mov dword [ebx+PIXELFORMATDESCRIPTOR.dwDamageMask],0

  push dword [hWnd]
  call [GetDC]
  mov dword [hDC],eax
  sub eax,0
  jnz .HaveDC

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword CDCFAIL
  push dword 0
  call [MessageBoxA]  
  xor eax,eax
  jmp .ExitCreateGL

 .HaveDC:
  push dword ebx
  push dword [hDC]
  call [ChoosePixelFormat]
  mov dword [ebp-.PixelFormat],eax
  sub eax,0
  jnz .FoundPFD

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword FINDPFFAIL
  push dword 0
  call [MessageBoxA]    
  xor eax,eax
  jmp .ExitCreateGL

 .FoundPFD:
  push ebx
  push eax
  push dword [hDC]
  call [SetPixelFormat]
  
  sub eax,0
  jnz .SetPFD

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword SETPFFAIL
  push dword 0
  call [MessageBoxA]    
  xor eax,eax
  jmp .ExitCreateGL

 .SetPFD:
  push dword [hDC]
  call [wglCreateContext]
  mov dword [hRC],eax
  sub eax,0
  jnz .RCSuccess
  
  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword CRCFAIL
  push dword 0
  call [MessageBoxA]    
  xor eax,eax
  jmp .ExitCreateGL
 
 .RCSuccess:
  push eax
  push dword [hDC]
  call [wglMakeCurrent]
  sub eax,0
  jnz .ActiveRC

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword ACTRCFAIL
  push dword 0
  call [MessageBoxA]  
  xor eax,eax
  jmp .ExitCreateGL

 .ActiveRC:
  push dword SW_SHOW
  push dword [hWnd]
  call [ShowWindow]
  push dword [hWnd]
  call [SetForegroundWindow]
  push dword [hWnd]
  call [SetFocus]
  push dword [ebp+.height]
  push dword [ebp+.width]
  call ResizeGLScene

  call InitGL
  sub eax,0
  jnz .InitSuccess

  call KillGLWindow
  push dword MB_OK|MB_ICONEXCLAMATION
  push dword GENERR
  push dword INITFAIL
  push dword 0
  call [MessageBoxA]  
  xor eax,eax
  jmp .ExitCreateGL
  
 .InitSuccess:
  mov dword eax,1
 .ExitCreateGL:
  leave
ret 20 ;CreateGLWindow 5 params

;; This is now the WindowMain() function. 
;; We will want to reserve enough stack space for a WNDCLASSEX structure so 
;; we can make a class for our window, a MSG structure so we can receive messages 
;; from our window when some event happens, and an HWND, which is just a 
;; double-word that's used for storing the handle to our window. 

WindowMain: 
.hInstance equ 8
.hPrevInstance equ 12
.lpCmdLine equ 16
.nCmdShow equ 20
.msg equ MSG_size
.done equ MSG_size+4

  enter MSG_size+4, 0 
  mov dword [ebp-.done],0
  mov dword [active],1

  mov dword ecx,256
  lea edi,[keys]
  xor ax,ax
  rep stosb

  push dword MB_YESNO|MB_ICONQUESTION
  push dword STRTFS
  push dword FSREQ
  push dword 0
  call [MessageBoxA]

  cmp eax,IDYES
  jnz .FSFalse
  mov dword [fullscreen],1
  jmp .FSEnd
 .FSFalse:
  mov dword [fullscreen],0
 .FSEnd:
  
  
  push dword [fullscreen]
  push dword 16
  push dword 480
  push dword 640
  push dword ApplicationName
  call CreateGLWindow

  sub eax,0
  jz .EndWinMain

 .MsgLoop:
  lea ebx,[ebp-.msg] 
  sub dword [ebp-.done],0 
  jnz .EndMsgLoop

  
  push dword PM_REMOVE
  push dword 0
  push dword 0
  push dword 0
  push ebx
  call [PeekMessageA]
  sub eax,0
  jz .NoMsg  
  
  cmp dword [ebx+MSG.message],WM_QUIT ;Something not quite right here
  jz .QuitMsg
  push ebx
  call [TranslateMessage]
  push ebx
  call [DispatchMessageA]
  jmp .MsgLoop

 .QuitMsg:
  mov dword [ebp-.done],1 
  jmp .MsgLoop

 .NoMsg:
  sub dword [active],0
  jnz .MsgLoop

  sub byte [keys+VK_ESCAPE],0
  jnz .QuitMsg

  sub byte [keys+VK_F1],0
  jnz .SwitchFullScreen

  sub byte [keys+'L'],0
  jnz .LightToggle
  
  mov dword [lp],0
  call DrawGLScene

  push dword [hDC]
  call [SwapBuffers]

  jmp .MsgLoop

 .LightToggle:
  sub dword [lp],0
  jnz .MsgLoop
  mov dword [lp],1
  mov dword [light],1

  push dword GL_LIGHTING
  sub dword [light],0
  jz .LightOff
  call [glEnable]
  jmp .MsgLoop
 .LightOff:
  call [glDisable]  
  jmp .MsgLoop

 .SwitchFullScreen:
  mov byte [keys+VK_F1],0
  call KillGLWindow

  xor dword [fullscreen],1
  
  push dword [fullscreen]
  push dword 16
  push dword 480
  push dword 640
  push dword ApplicationName
  call CreateGLWindow

  sub eax,0
  jnz .MsgLoop
  xor eax,eax
  jmp .EndWinMain

 .EndMsgLoop:
  call KillGLWindow
  mov eax,[ebp-.msg-MSG.message]

 .EndWinMain:
  leave
ret 16


;; We also need a procedure to handle the events that our window sends us. 
;; We call that procedure WindowProcedure(). 
;; It also has to take 4 arguments, which are as follows: 
;;      hWnd                     The handle to the window that sent us that event. 
;;                                       This would be the handle to the window that uses 
;;                                       our window class. 
;;      uMsg                     This is the message that the window sent us. It 
;;                                       describes the event that has happened. 
;;      wParam             This is a parameter that goes along with the 
;;                                       event message. 
;;      lParam             This is an additional parameter for the message. 
;; If we process the message, we have to return 0. 
;; Otherwise, we have to return whatever the DefWindowProc() function 
;; returns. DefWindowProc() is kind of like the "default window procedure" 
;; function. It takes the default action, based on the message. 
;; For now, we only care about the WM_DESTROY message, which tells us 
;; that the window has been closed. If we don't take care of the 
;; WM_DESTROY message, who knows what will happen. 
;; Later on, of course, we can expand our window to process other 
;; messages too. 
WindowProcedure: 
.hWnd equ 8
.uMsg equ 12
.wParam equ 16
.lParam equ 20
  
  ;; We don't really need any local variables, for now, besides the function arguments. 
  enter 0, 0 
        
  ;; We need to retrieve the uMsg value. 
  mov eax, dword [ebp+.uMsg]            ;;uMsg moved to eax
        
  ;cmp eax, WM_DESTROY ;Remember WM_DESTROY is sent when resolution is changed
  ;jz .window_destroy  ;DO NOT RUN windows_close as that will close the window
                       ;right after a resolution change!

  cmp eax,WM_ACTIVATE
  jz .window_active
  
  cmp eax,WM_SYSCOMMAND
  jz .window_syscmd
  
  cmp eax,WM_CLOSE
  jz .window_close
  
  cmp eax,WM_KEYDOWN
  jz .key_down
 
  cmp eax,WM_KEYUP
  jz .key_up

  ;cmp eax,WM_SIZE
  ;jz .window_size

  ;; If the processor doesn't jump to the .window_destroy label, it means that 
  ;; the result of the comparison is not equal. In that case, the message 
  ;; must be something else. 
  ;; In cases like this we can either take care of the message right now, or 
  ;; we can jump to another location in the code that would take care of the 
  ;; message. 
  ;; We'll just jump to the window_default label. 
  jmp .window_default 

  ;; We need to define the .window_destroy label, now. 
 .window_close: 
  ;; If uMsg is equal to WM_CLOSE, then the processor will execute this 
  ;; code next. 
          
  ;; We pass 0 as an argument to the PostQuitMessage() function, to tell it 
  ;; to pass 0 as the value of wParam for the next message. At that point, 
  ;; GetMessage() will return 0, and the message loop will terminate. 
  push dword 0 
  ;; Now we call the PostQuitMessage() function. 
  call [PostQuitMessage] 
               
  ;; When we're done doing what we need to upon the WM_CLOSE condition, 
  ;; we need to jump over to the end of this area, or else we'd end up 
  ;; in the .window_default code, which won't be very good. 
  jmp .window_finish 
  ;; And we define the .window_default label. 
 .window_default: 
  ;; Right now we don't care about what uMsg is; we just use the default 
  ;; window procedure. 
                
  push dword [ebp+.lParam] ;;lParam
  push dword [ebp+.wParam] ;;wParam
  push dword [ebp+.uMsg] ;;uMsg
  push dword [ebp+.hWnd] ;;Hwnd
  call [DefWindowProcA] 
                
  leave 
  ret 16 
 
 .window_active:
  sub word [ebp+.wParam+2],0
  lahf
  shr ah,7
  and ah,1
  mov [active],ah
  ;hmm is the above worth it 1 conditonal jump or a bunch of maths
 ; jz .SetInActive
 ; mov dword [active],1
 ; jmp .window_finish
 ;.SetInActive:
 ; mov dword [active],0
  jmp .window_finish
 
 .window_size: ;Add ReSizeGLScene(LOWORD(lParam),HIWORD(lParam));
  mov dword eax,[ebp+.lParam]
  mov ebx,eax
  and eax,0xffff
  shr ebx,16
  
  push ebx
  push eax
  call ResizeGLScene
  jmp .window_finish 

 .window_syscmd: ;Prevent screensaver and monitor low power mode
  cmp dword [ebp+.wParam],SC_SCREENSAVE
  jz .window_finish
  cmp dword [ebp+.wParam],SC_MONITORPOWER
  jz .window_finish
  jmp .window_default 

 .key_down:
  mov dword ebx,keys
  add dword ebx,[ebp+.wParam]
  mov byte [ebx],1
  jmp .window_finish
 .key_up:
  mov dword ebx,keys
  add dword ebx,[ebp+.wParam]
  mov byte [ebx],0
  jmp .window_finish
  ;; This is where the we want to jump to after doing everything we need to. 
 .window_finish: 
        
  ;; Unless we use the DefWindowProc() function, we need to return 0. 
  xor eax, eax                              ;; XOR EAX, EAX is a way to clear EAX. 
                                                                  ;; Same applies for any other register. 
  leave 
;; And, as said earlier, we free 16 bytes (our params), after returning. 
ret 16 


section .data USE32

RRCDCFAIL   db "Release Of DC And RC Failed.",0
RRCFAIL     db "Release Rendering Context Failed.",0
RDCFAIL     db "Release Device Context Failed.",0
RHWNDFAIL   db "Could Not Release hWnd.",0
UCLASSFAIL  db "Could Not Unregister Class.",0
REGWNDFAIL  db "Failed To Register The Window Class.",0
FSFAIL      db "The Requested Fullscreen Mode Is Not Supported By Your Video Card. Use Windowed Mode Instead?",0
GENFAIL     db "Program Will Now Close.",0
CDCFAIL    db "Can't Create a GL Device Context",0
FINDPFFAIL  db "Can't Find A Suitable PixelFormat.",0
SETPFFAIL   db "Can't Set The PixelFormat",0
CRCFAIL     db "Can't Create A GL Rendering Context.",0
ACTRCFAIL   db "Can't Activate The GL Rendering Context.",0
INITFAIL    db "Initalization Failed.",0
FSREQ      db "Would You Like To Run In FullScreen Mode",0
CWNDFAIL    db "Window Creation Error.",0
SHUTDWN     db "SHUTDOWN",0
STRTFS      db "Start FullScreen",0
GENERR      db "ERROR",0

;; Window Class name
ClassName         db "SimpleWindowClass", 0 
;; Application name placed on the window title 
ApplicationName   db "NeHE's OpenGL Framework", 0 
ALIGN 4
;; Doubles that will be used for defineing perspective
RGlS_gluFAR       dq __float64__(100.0) ;Field of view angle
RGlS_gluNEAR      dq __float64__(0.1)   ;Near clipping plane
RGlS_gluFOV       dq 45.0  ;Far clipping plane
;; Double for defineing depth buffer
IGl_DEPTH         dq 1.0   ;Depth buffer
LightAmbient      dd 0.5, 0.5, 0.5, 1.0
LightDiffuse      dd 1.0, 1.0, 1.0, 1.0
LightPosition     dd 0.0, 0.0, 2.0, 1.0
zpos              dd -5.0
section .bss USE32
;; And we reserve a double-word for hInstance, hWnd, hDC, hRC.
hInstance         resd 1 
hWnd              resd 1
hDC               resd 1
hRC               resd 1
filter            resd 1
light             resd 1
lp                resd 1
fp                resd 1

xspeed            resd 1
yspeed            resd 1
;; Fullscreen and active are just booleans and we could use a byte but a dword is easier to deal with. 
fullscreen        resd 1
active            resd 1
;; Keys contains the state of keys pressed.
keys              resd 256