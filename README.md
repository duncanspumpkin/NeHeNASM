NeHeNASM
========

NeHe's OpenGL Tutorial in NASM

This is an attempt to recreate the NeHe OpenGL tutorial from http://nehe.gamedev.net/ in NASM assembler. I will try make sure there are lots of comments throughout the source code. This has been attempted to increase my knowledge of x86 assembler and OpenGL.

In order to compile these you will need NASM and ALINK at least or someother linker. To compile I use the following in a batch script.

    ::Turn off echo so it looks nice
    @echo off
    
    ::Work out which folder we are in for the output name
    ::i.e if in C:\foo\bar\ it would return bar.exe
    for %%i in (.) do set outName=%%~ni.exe
    
    ::Make sure we are in the starting directory
    cd /D "%~dp0"
    
    for %%i in (*.asm) do (
    ::We have to do this to save the obj file
    call :saveparam "%%~ni.obj"
    
    @echo Compiling file: %%i
    "H:\NonworkRelated\nasm\nasm" -f obj %%i -i..\
    )
    
    
    @echo Starting ALINK:
    ::Link our .obj files.
    "H:\NonworkRelated\nasm\alink" -c -oPE -o %outName% -subsys gui %params%
    
    ::Optionally delete all left over obj files
    DEL *.obj
    PAUSE
    exit /b
    
    :saveparam
    set "params=%1 %params%"
    exit /b

Lesson 1: Setting Up An OpenGL Window - Complete

Lesson 2: Your First Polygon - Complete

Lesson 3: Adding Color - Complete

Lesson 4: Rotation - Complete

Lesson 5: 3D Shapes - Complete

Lesson 6: Texture Mapping - Complete

Lesson 7: Texture Filters, Lighting and Keyboard Control - Complete

Lesson 8: Blending - Complete

Lesson 9: Moving Bitmaps in 3D Space - Complete

Lesson 10: Loading and Moving Through A 3D World - Complete

Code Review! - Started

...
