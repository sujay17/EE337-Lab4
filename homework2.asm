; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable


ORG 0000H
ljmp main

ORG 200H 

;-------------------------writing to the LCD routine------------------------------------
lcdwrite: mov a,#80h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with string1 Address
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  ret


;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "New Action", 00H
end



;--------------------------------------readnibble---------------------------------------------
readnibble: 
          mov p1,#0fh ;-- reading mode
          mov a,p1
          anl a,#0fh ;-- take last 4 bits only 
          mov r2,a ;-- store the nibble in register r2 
          ret 
     
;--------------------------------------packnibble---------------------------------------------     
packnibble: 
          push acc
          mov r0,50h ;
          mov r1,51h 
          lcall readnibble ;
          mov a,r2 ;
          swap a 
          lcall delay_5s
          lcall readnibble 
          add a,r2 
          mov 4fh,a
          pop acc
          ret 
       
;--------------------------------------readvalues---------------------------------------------   
readvalues: 
          mov r0,50h
          mov r1,51h 
          loop: 
              lcall packnibbles
              mov @r1,4fh 
              lcall delay_5s
              lcall lcdwrite
              inc r1
              djnz r0,loop 
              ret
 
;--------------------------------------displaymode---------------------------------------------             
displaymode:
              lcall lcd_init ;
              mov p1,#0fh
              mov a,p1 
              anl a,#0fh 
              mov r0,a
              clr c
              subb a,50h
              jc invalid
              mov a,r0
              add a,51h
              mov r0,a 
              mov a,@r0 
              lcall bintoascii
              lcall lcdcommand
              lcall delay_5s 
              sjmp displaymode
    invalid:
              lcall lcd_init 
              lcall delay_5s 
              sjmp displaymode
              ret 

;--------------------------------------main---------------------------------------------
main: 
          mov 50h,#3h
          mov 51h,#70h 
          lcall lcd_init
          lcall lcdwrite
          lcall delay_1s
          lcall readvalues
          lcall delay_5s
          lcall lcdwrite
          lcall delay_5s
          lcall lcdwrite
          lcall displaymode 
          fin: sjmp fin 
end 
          
          
