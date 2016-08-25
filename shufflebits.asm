shufflebits:
        push 0
        push 1
        mov r0,50h
        mov r1,51h
        dec r0 ;
        loop:
                mov a,@r1
                inc r1
                xor a,@r1
                dec r1
                mov @r1,a
                inc r1
                djnz r0,loop 
                mov a,@r1
                xor a,70h
                mov @r1,a
                push 1
                push 0 
                ret 
                
