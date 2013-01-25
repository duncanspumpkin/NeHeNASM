NeHeNASM
========

NeHe's OpenGL Tutorial in NASM

This is an attempt to recreate the NeHe OpenGL tutorial from http://nehe.gamedev.net/ in NASM assembler. I will try make sure there are lots of comments throughout the source code. This has been attempted to increase my knowledge of x86 assembler and OpenGL.

In order to compile these you will need NASM and ALINK at least or someother linker. To compile I use the following in a batch script.

    cd "C:\Program Files (x86)\NASM\"
    set outName="%~dpn1.exe"
    :NasmLoop
    IF "%~1" NEQ "" (
    nasm -f obj %1
    set params="%~dpn1.obj" %params%
    shift
    goto NasmLoop
    )
    alink -c -oPE -o %outName% -subsys gui %params%
    DEL %params%
    PAUSE

Lesson 1: Setting Up An OpenGL Window - Complete

Lesson 2: Your First Polygon - Complete

Lesson 3: Adding Color - Complete

Lesson 4: Rotation - Complete

Lesson 5: 3D Shapes - Complete

Lesson 6: Texture Mapping - Not Started

...
