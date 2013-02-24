struc SECTOR
 .numTriangles resd 1 
 .triangle     resd 1 ;Pointer to triangle array
endstruc

struc TRIANGLE
 .vertex resb 3*VERTEX_size ;3 vertex make a triangle
endstruc

struc VERTEX
 .x resd 1
 .y resd 1 ;3D coordinates
 .z resd 1
 
 .u resd 1 ;Texture coordinates
 .v resd 1
endstruc