.386
.model flat, stdcall
option casemap:none
include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
           decstr      byte 50 dup(0)      
           ;decstr存放输入的字符串序列
           array       word 10 dup(0)      
           ;定义10个word元素。将ASCII字符串转换成word数据，存到array中。因为每个数转换成数据以十六进制形式储存时，最多占用2字节，所以定义word类型
           res         byte 60 dup(0)      
           ;将排序后的数字的十进制序列转换成ASCII码，用以输出
           num         dword 9
           const10word word 10
           tmp         dword ?
           break       byte ','

.code
main proc
                  invoke StdIn,addr decstr,50      
                  ;输入字符串序列，存至decstr中
                  call   input
                  call   bubble_sort
                  call   output
                  invoke StdOut,addr res           
                  ;输出排序好的字符串序列
                  invoke ExitProcess,0
main endp

input proc
                  mov    eax,0
                  mov    ebx,0
                  mov    ecx,0                     
                  ;借助变址寄存器ecx访问decstr元素
                  mov    esi,0                     
                  ;借助变址寄存器esi访问array元素
      dec2dw:     
                  mov    al,decstr[ecx]            
                  ;间接寻址，等同于[ecx+decstr]，ecx中的值与decstr的偏移地址相加，得到内存decstr的第ecx个字符的地址，并复制到al中
                  sub    al,48                   
                  ;将字符转换成数字
                  xchg   ax,bx                     
                  ;交换ax和bx的值，ax中是上步的结果，bx中是该步处理的数字即现在的个位
                  mul    const10word              
                  ;ax乘16位操作数，将结果存至dx和ax中，事实上，受到数据范围的限制,dx为0
                  add    ax,bx                     
                  ;将bx加至ax中，即上步的结果乘10后加上个位
                  inc    cx                        
                  ;要处理的字符序号加1
                  xchg   ax,bx                     
                  ;交换ax和bx的值，把该步的结果存到bx中
                  mov    al,decstr[ecx]            
                  ;将第ecx个字符（即刚处理完的字符的下一个字符）存至al中
                  cmp    al,','                    
                  ;将字符与','进行隐含的减法操作
                  jz     NumEnd                    
                  ;如果结果为0，二者相等，说明处理完了一个数，跳至NumEnd
                  cmp    al,0                      
                  ;将字符与0进行隐含的减法操作
                  jnz    dec2dw                    
                  ;如果结果不为0，二者不相等，说明未处理完，回到dec2dw，继续处理
                  cmp    al,0                      
                  ;将字符与0进行隐含的减法操作
                  jz     AllEnd                    
                  ;如果结果为0，二者相等，说明全部处理完，跳至AllEnd
      NumEnd:     
                  mov    array[si],bx              
                  ;array[si]表示array中的第si个word元素，在输入','后，一个数处理完，存到array中
                  add    si,type array             
                  ;下个要赋值的是array中的下一个元素，所以si变成si+type array
                  mov    ebx,0
                  mov    eax,0                     
                  ;ebx与eax重新置0
                  inc    ecx                       
                  ;要处理的字符序号加1
                  jmp    dec2dw                    
                  ;回到dec2dw，继续处理后面的字符
      AllEnd:     mov    array[si],bx              
                  ;将处理的最后一个数存在array中
                  ret
input endp

bubble_sort proc
                  mov    ecx,9                     
                  ;外层循环的次数
      Outer:      
                  mov    tmp,ecx
                  mov    ecx,num                   
                  ;修改ecx为内层循环的次数，把外层循环的次数先暂存至tmp中。第一次内层循环为9次，后面逐次递减
                  mov    esi,offset array          
                  ;变址寄存器，esi为array的基地址
      Inner:      
                  mov    ax,[esi]                  
                  ;从第一个数开始，该数为word类型，16位，将该数赋值给ax
                  cmp    ax,[esi+type array]       
                  ;将ax与下一个数进行隐含的减法操作
                  jc     notsort                   
                  ;结果小于0，CF=1，则跳转L3
                  xchg   ax,[esi+type array]
                  mov    [esi],ax
      notsort:    
                  add    esi,type array            
                  ;esi变为第下一个数的地址
                  Loop   Inner                     
                  ;内层循环
                  dec    num                       
                  ;num减1，每次多一个有序数，少循环一次
                  mov    ecx,tmp                   
                  ;外层循环的次数
                  loop   Outer                     
                  ;外层循环
                  ret
bubble_sort endp

output proc
                  mov    eax,0
                  mov    bx,0
                  mov    edx,0
                  mov    ecx,10                    
                  ;循环10次
                  mov    esi,offset array          
                  ;变址寄存器，esi为array的基地址
                  mov    edi,offset res            
                  ;变址寄存器，edi为res的基地址
      todec:      
                  mov    ax,[esi]                  
                  ;esi地址的数赋给ax
      pushnum:    
                  mov    dx,0
                  div    const10word               
                  ;除以word类型的10，除以16位操作数，商存在ax中，余数存在dx中
                  add    dx,48                     
                  ;dx中余数转换成ASCII码
                  push   dx                       
                  ;入栈
                  inc    bx                        
                  ;bx用来记录进入栈的元素数目
                  cmp    ax,0                      
                  ;对ax和0进行隐含的减法操作
                  jnz    pushnum                   
                  ;若ax＝0，即原数的所有位都已经转成ASCII码并压入栈，那么这个数就处理完了；如果没不为0，没处理完，循环L10
      popnum:     
                  pop    dx                        
                  ;栈顶元素赋值给dx
                  mov    [edi],dl                  
                  ;因为元素最多1字节，dx的前8位为0，将dx存到res数组中即将dl存到res数组中
                  dec    bx                        
                  ;栈中元素数目减一
                  add    edi,type res              
                  ;edi向后偏移
                  cmp    bx,0
                  jnz    popnum                    
                  ;如果bx不为0，栈不空，继续出栈
                  cmp    ecx,1
                  jz     theend                    
                  ;ecx等于1时，是处理完所以元素了，直接跳出循环
                  ;下面的操作是在每次每个数把每位存到res后，再把一个','存到res中，以便于输出好看；最后一个数后不用加','所以最后一次循环时在上面跳出不执行后面的操作
                  mov    tmp,ecx
                  mov    cl,break
                  mov    [edi],cl                  
                  ;将','存进去
                  mov    ecx,tmp
                  add    edi,type res              
                  ;edi向后偏移
                  add    esi,type array            
                  ;这个数的每位都处理完了，esi向后偏移
                  loop   todec
      theend:     
                  ret
output endp

end main
