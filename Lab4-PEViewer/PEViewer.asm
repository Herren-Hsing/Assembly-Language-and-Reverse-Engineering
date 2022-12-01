.386
.model flat, stdcall
option casemap:none
include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
         file_name byte 50 dup(0)
         str1      byte "Please input a PE file: ",0
         str2      byte "IMAGE_DOS_HEADER",0Ah,0Dh,0
         str3      byte "   e_magic: ",0
         str4      byte "   e_lfanew: ",0
         str5      byte "IMAGE_NT_HEADER",0Ah,0Dh,0
         str6      byte "   Signature: ",0
         str7      byte "IMAGE_FILE_HEADER",0Ah,0Dh,0
         str8      byte "   NumberOfSections: ",0
         str9      byte "   TimeDateStamp: ",0
         str10     byte "   Characteristics: ",0
         str11     byte "IMAGE_OPTIONAL_HEADER",0Ah,0Dh,0
         str12     byte "   AddressOfEntryPoint: ",0
         str13     byte "   ImageBase: ",0
         str14     byte "   SectionAlignment: ",0
         str15     byte "   FileAlignment: ",0
         str_      byte 0Ah,0Dh,0
.data?
         hfile     dword ?
         buf1      dword ?
         buf2      dword ?
.code
    start:
          invoke StdOut,addr str1
          invoke StdIn,addr file_name,50
          invoke StdOut,addr str2
          invoke StdOut,addr str3

          invoke CreateFile,addr file_name,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,0
    ;读文件，这里的参数分别为：指向文件名的指针、允许对设备进行读访问、允许对文件进行共享访问、不指定指向SECURITY_ATTRIBUTES结构的指针、文件必须已经存在标记、归档属性、不指定文件句柄
          mov    hfile,eax
    ;CreateFile函数返回一个打开的指定文件的句柄到eax中，将句柄存到hfile里
          invoke SetFilePointer,hfile,0,0,FILE_BEGIN
    ;SetFilePointer在打开的文件中设置新的读取位置，四个参数分别为：文件句柄、偏移量（低位）、偏移量（高位）、基准位置
    ;FILE_BEGIN是从文档头开始，e_magic就在文档头，所以句柄偏移0字节
          invoke ReadFile,hfile,addr buf1,2,0,0
    ;readfile 从文件指针指向的位置开始将数据读出到一个文件中，五个参数分别为：文件的句柄、用于保存读入数据的一个缓冲区、要读入的字符数、指向实际读取字节数的指针、OVERLAPPED结构体指针
    ;因为e_magic只有2个字节，所以只从句柄处向后移动读取两个字节，将读到的存至buf1中。在读取的过程中，句柄也在向后移动。
          mov    ebx,dword ptr buf1
          invoke dw2hex,ebx,addr buf2
    ;de2hex的参数是32位操作数的地址，将dword数据转成16进制字符串
          invoke StdOut,addr buf2+4
    ;buf2前四个字节为0000，后四个字节是5A4D，所以偏移四个字节输出
          invoke StdOut,addr str_
          invoke StdOut,addr str4

          invoke SetFilePointer,hfile,3Ah,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;e_lfanew在文档头后3Ch处，在文件读完2个字节e_magic后，句柄位于文件头后2字节处，还需偏移3Ah，所以句柄偏移3Ah字节
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;e_lfanew占4个字节，向后读4个字节
          mov    ebx,dword ptr buf1
          invoke dw2hex,ebx,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str5
          invoke StdOut,addr str6

          invoke SetFilePointer,hfile,buf1,0,FILE_BEGIN
    ;IMAGE_DOS_HEADER结构的e_lfanew字段定位PE Header的起始偏移量，加上基址，得到PE文件头的指针
    ;buf1中存放的即为PE Header的起始偏移量
    ;FILE_BEGIN是从文档头开始，句柄向后偏移buf1，这样句柄就到PE header处，PE header的前四个字节即为Signature
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;Signature占4个字节，向后读4个字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str7
          invoke StdOut,addr str8

          invoke SetFilePointer,hfile,2,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;经过上述操作，句柄位于signature后的一个字节处，NumberOfSections在Signature后2字节处，所以句柄向后偏移2个字节
          invoke ReadFile,hfile,addr buf1,2,0,0
    ;NumberOfSections占2个字节，向后读取2字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2+4
    ;输出buf2后四个字节
          invoke StdOut,addr str_
          invoke StdOut,addr str9
         

          invoke SetFilePointer,hfile,0,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;TimeDateStamp在NumberOfSections之后，所以无需偏移，从现在的位置往后读就可以
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;TimeDateStamp占4个字节，向后读取4个字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str10

          invoke SetFilePointer,hfile,10,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;经过上述操作，句柄位于TimeDateStamp后的一个字节处，需要向后偏移10个字节，到达Characteristics位置
          invoke ReadFile,hfile,addr buf1,2,0,0
    ;Characteristics占2个字节，向后读取2字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2+4
    ;输出buf2后四个字节
          invoke StdOut,addr str_
          invoke StdOut,addr str11
          invoke StdOut,addr str12

          invoke SetFilePointer,hfile,16,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;经过上述操作，句柄位于Characteristics后的一个字节处，需要向后偏移16个字节，到达AddressOfEntryPoint位置
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;AddressOfEntryPoint占4个字节，向后读取4个字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str13
           
          invoke SetFilePointer,hfile,8,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;经过上述操作，句柄位于AddressOfEntryPoint后的一个字节处，需要向后偏移8个字节，到达ImageBase位置
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;ImageBase占4个字节，向后读取4个字节
   
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str14

          invoke SetFilePointer,hfile,0,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;SectionAlignment紧跟在 ImageBase之后，所以句柄无需偏移
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;SectionAlignment占4个字节，向后读取4个字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2
          invoke StdOut,addr str_
          invoke StdOut,addr str15

          invoke SetFilePointer,hfile,0,0,FILE_CURRENT
    ;FILE_CURRENT是从文件现在的位置开始
    ;FileAlignment紧跟在 SectionAlignment之后，所以句柄无需偏移
          invoke ReadFile,hfile,addr buf1,4,0,0
    ;FileAlignment占4个字节，向后读取4个字节
          mov    eax,dword ptr buf1
          invoke dw2hex,eax,addr buf2
    ;将dword数据转成16进制字符串
          invoke StdOut,addr buf2
    ;输出buf2后四个字节
          invoke CloseHandle,hfile
    ;关闭打开的对象句柄
 end start