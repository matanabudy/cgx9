end_of_copy1 equ 200h+(end_copy1-copy1)
start_of_copy2 equ end_of_copy1
end_of_copy2 equ start_of_copy2+(end_copy2-copy2)
end_of_address_woodey1 equ end_of_copy2+2h
end_of_callfar_woodey1 equ end_of_address_woodey1+4h
address_woodey2 equ end_of_callfar_woodey1
_cmd equ 0A5h
loc_18D:
xchg	ax, bx
mov	ax, 0A552h ; PUSH DX. MOVSW.
mov	dx, ax 
int	86h		; Heavy Bombing with opcodes
int	86h	
xchg	ax, bx

mov	di, end_of_copy2
stosw ;[es:di]<--ax PRIVATE SEGMANT
;Copy "copy1+copy2" to private segmant
mov	di, 200h ;because of heavy bombing
mov	si, ax
add	si, copy1
mov	cx, ((end_copy2-copy1)/2)
copy1_2_start: rep movsw

bomb1:
mov dx,27b0h ; save begining position
push ds
push es
pop ds
pop es
push cs
pop ss
;SS,ES <- Public.    DS<-Private
; mov sp,ax
; sub sp,7F02h ; adjust this number to run over self with 0A5h
mov si,ax
add si,call_far
mov bx, end_of_address_woodey1 ;a place in our private segment. in this location the address of the call far is loaded
add ax,2FEh ;3 rows down
mov al,0A1h
mov sp,ax 
sub sp,2eeh ; adjust this number to run over self with 0A5h. puts the stack-pointer
mov word [bx+2], cs ;puts the call far address to our place in the private segment.
mov word [bx], ax
push ds
push es
pop ds
;DS <-public
mov di,ax
movsw ;Copying the FF1F (call far) to the arena, 3 lines under the begining of the code. column of 0A3.
movsw
dec di ;re-adujst in order to run over ourself
mov si,start_of_copy2 ;Private Segmant
pop ds ;DS<-Private
jmp ax  ;to the copied call far
call_far:
sub sp, dx
call dword [bx]
bomb1_end:
;After running over ourself, will execute Copy2 (once in the entire round).

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

copy2: ;Currently runs only one time
db ((label8 - label7 )) dup _cmd
label7:
mov	bx, di
add bx, 500h 
label8:
db ((label10 - label9 )) dup _cmd
label9:
mov	bp, 17A8h ;forword jump constant. determins how lower will this bombing be.
label10:
db ((label12 - label11 )) dup _cmd
label11:
; mov	dx, 0CCCCh
mov dx, 26ffh ; the actual attack. we throw it as the backwords garabage. this is opcode for :jmp[0]
label12:
db ((label14 - label13 )) dup _cmd
label13:
mov	cx, 19AAh ;stack-jump constant
label14:
db ((label16 - label15 )) dup _cmd
label15:
lea	sp, [bx-500h]            
label16:
db ((label18 - label17 )) dup _cmd
label17:
mov	di, bx ;the place to where we copy our new bombing
xor	si, si ;si->0A552h   in the private segmant
movsw ; copy the first 0A552h
call bx ;start runnig 0A552h
label18:
end_copy2:
