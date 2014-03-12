end_of_copy1 equ 200h+(end_copy1-copy1)
start_of_copy2 equ end_of_copy1
end_of_copy2 equ start_of_copy2+(end_copy2-copy2)
end_of_address_woodey1 equ end_of_copy2+2h
end_of_callfar_woodey1 equ end_of_address_woodey1+4h
address_woodey2 equ end_of_callfar_woodey1
_cmd equ 0A5h
loc_18D:
push ax
add ax, zombie
mov [0], ax
pop ax
; nop
; nop
; nop
; nop
nop
nop
nop
mov	di, 200h
mov	si, ax
add	si, copy1
mov	cx, ((end_copy2-copy1)/2)
copy1_2_start: rep movsw
bomb1:mov dx,ax ; save first positin
push ds
push es
pop ds
pop es
push cs
pop ss
mov bx, address_woodey2
;a place in our private segment. in this location the address of the call far is loaded
mov	si, end_of_copy2
lodsw ;[ds:si]-->ax  it's the address of woodey1
add ax,8300h ;ax<- the place of woodey1's call far + half-screen
mov al,0A3h
mov sp,ax 
sub sp,0A904h ; adjust this number to run over self with 0A5h
mov word [bx+2], cs ;puts the address to our place in the private segment.
mov word [bx], ax
push ds
push es
pop ds
mov di,ax
mov si,dx ;dx is the original address. look at "bomb1"
add si,call_far
movsw
dec di
mov si,start_of_copy2
pop ds
jmp ax
call_far:call dword [bx] ;33
bomb1_end:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copy1:
db ((label2 - label1 )) dup _cmd   ;was ((label2 - label1 )+1)
label1:
add	bx, bp
label2:
db ((label4 - label3 )) dup _cmd 
label3:
add	sp, cx
label4:
db ((label6 - label5 )) dup _cmd
label5:
xor	si, si ;optional:make it mov si,X. than in the beginning to put stuff that will allow to combine "try"
mov	di, bx; will look like: es-> combiniing "try"(will happen once)...BOMBING ZORG STYLE (will happen everytime)...some important addresses
movsw
call	bx 
label6:
end_copy1:
copy2:
db ((label8 - label7 )) dup _cmd
label7:	
mov	bx, di
add bx, 500h
label8:
db ((label10 - label9 )) dup _cmd
label9:
mov	bp, 17A8h
label10:
db ((label12 - label11 )) dup _cmd
label11:
; mov	dx, 0CCCCh
mov dx, 26ffh
label12:
db ((label14 - label13 )) dup _cmd
label13:
mov	cx, 19AAh
label14:
db ((label16 - label15 )) dup _cmd
label15:
lea	sp, [bx-500h]            
label16:
db ((label18 - label17 )) dup _cmd
label17:
mov	di, bx
xor	si, si
movsw
call bx
label18:
end_copy2:

zombie:
push cs
pop es
mov bx, 0C683h
mov cx, 0A559h
mov ax, 0CCCCh
mov dx, 0CCCCh
int 87h
int 87h