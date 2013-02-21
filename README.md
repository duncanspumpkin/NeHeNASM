NeHeNASM
========

NeHe's OpenGL Tutorial in NASM

This is an attempt to recreate the NeHe OpenGL tutorial from http://nehe.gamedev.net/ in NASM assembler. I will try make sure there are lots of comments throughout the source code. This has been attempted to increase my knowledge of x86 assembler and OpenGL.

In order to compile these you will need NASM and ALINK at least or someother linker. To compile I use the following in a batch script.

    ;Turn off echo so it looks nice
    @echo off 
    
    ;Work out which folder we are in i.e if in C:\foo\bar\ it would return bar
    for %%i in (.) do set folder=%%~ni
    ;Our output filename will be the foldername.exe
    set outName=%folder%\%folder%.exe
    ;Go up one directory so we use win32n.inc and such
    ;The reason we dont do this the other way round i.e. run from the folder
    ;and search for files up one directory is that nasm will not like that.
    cd /D "%~dp0.."

    ;Required so that we can use the for loop to record all of the .obj's
    setlocal enabledelayedexpansion
    ;Compiles all .asm files in folder. Output is .obj which is also saved.
    for %%i in (%folder%\*.asm) do @echo Compiling file: %%i&^
    set params=!params! "%folder%\%%~ni.obj"&"C:\Program Files (x86)\NASM\nasm"^
     -f obj %%i -i%folder%\
    setlocal disabledelayedexpansion
    
    @echo Starting ALINK:
    ;Link our .obj files.
    "C:\Program Files (x86)\NASM\alink" -c -oPE -o %outName% -subsys gui %params%
    cd "%~dp0"
    ;Optionally delete all left over obj files
    DEL *.obj
    ;Pause so we can see if it completed successfully. Could have used an IF but i
    ;prefer pause incase successful compile but lots of warnings.
    PAUSE

Lesson 1: Setting Up An OpenGL Window - Complete

Lesson 2: Your First Polygon - Complete

Lesson 3: Adding Color - Complete

Lesson 4: Rotation - Complete

Lesson 5: 3D Shapes - Complete

Lesson 6: Texture Mapping - Complete

Lesson 7: Texture Filters, Lighting and Keyboard Control - Complete

Lesson 8: Blending - Complete

Lesson 9: Moving Bitmaps in 3D Space - Complete

Lesson 10: Loading and Moving Through A 3D World
...
