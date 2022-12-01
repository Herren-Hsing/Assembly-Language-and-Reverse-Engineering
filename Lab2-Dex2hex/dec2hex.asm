.386
.model flat, stdcall
option casemap:none
include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
decstr   db 20 DUP(0)
  res    db 8 DUP(48)
  ten    dd 10
  decnum dd 0
  str_input db "Please input a decimal number(0~4294967295): ", 0
  str_output db "The hexdecimal number is : ", 0

.code
dec2dw PROC
invoke StdOut,addr str_input
 invoke StdIn,addr decstr,20
 mov  edx,0
 mov  ecx,0
 mov  eax,0
  L1:  
 mov  dl,[decstr+ecx]
 sub  dl,48
 mov  ebx,eax
 shl  ebx,3
 shl  eax,1
 add  eax,ebx
 add  eax,edx
 inc  ecx
 mov  dl,[decstr+ecx]
 cmp  dl,0
 jnz  L1 
 mov decnum,eax
 ret
dec2dw ENDP
d2hex PROC
 call dec2dw
 mov  edx,7
 mov  ecx,0
  L2:  
 mov eax,decnum
 mov  ebx,ecx
 shl  ebx,2
  L3:  
 cmp  ebx,0
 je   L4
 shr  eax,1
 dec  ebx
 jmp  L3
  L4:  
 and  eax,15
 cmp  eax,9
 jle  L5
 add  eax,87
 jmp  L6
  L5:  
 add  eax,48
  L6:  
 mov  [res+edx],al
 inc  ecx
 cmp  edx,0
 je   L7
 dec  edx
 jmp  L2
  L7:  
 invoke StdOut, addr str_output
 invoke StdOut, addr res
 invoke ExitProcess,0
d2hex ENDP
end d2hex