end_of_zorg_copy equ 200h+(fin_zorg_copy-zorg_copy)
start_of_from_cf_to_zorg equ end_of_zorg_copy
end_of_from_cf_to_zorg equ start_of_from_cf_to_zorg+(fin_from_cf_to_zorg-from_cf_to_zorg)
call_far_location equ end_of_from_cf_to_zorg+2h
end_of_callfar equ call_far_location+4h
_cmd equ 0A5h
loc_18D:
regular_zorg_copy:
;bobming zorg opcodes into es
xchg	ax, bx
mov	ax, 0A552h ; PUSH DX. MOVSW.
mov	dx, ax 
int	86h		; Heavy Bombing with opcodes
int	86h	
xchg	ax, bx
fin_regular_zorg_copy:

saving_our_address:
;saving our address in our external segment 
mov	di, end_of_from_cf_to_zorg
stosw ;[es:di]<--ax PRIVATE 
fin_saving_our_address:

massive_copy:
;Copy "copy1+copy2" to private segmant
mov	di, 200h ;because of heavy bombing
mov	si, ax
add	si, zorg_copy
;db ((fin_from_cf_to_zorg-zorg_copy)/2) dup _cmd
mov	cx, ((fin_from_cf_to_zorg-zorg_copy)/2)
cf2zorg_and_zorg_copy: rep movsw
fin_massive_copy:

bomb1:
;
mov dx,ax 
; save begining position
;
push ds
push es
pop ds
pop es
push cs
pop ss
;SS,ES <- Public.    DS<-Private
;
mov si,ax
add si,call_far ;READY TO COPY 
mov bx, call_far_location ;a place in our private segment. in this location the address of the call far is loaded
add ax,300h ;3 rows down
mov al,0A3h ;change to A3 colomn, so we run over are selves with A5
mov sp,ax 
;sub sp,0A904h ; adjust this number to run over self with 0A5h. puts the stack-pointer. exactly half of screen from us
sub sp,0A8F4h ;0A904-10h
mov word [bx+2], 1001h ;puts the call far address to our place in the private segment.
mov word [bx], ax
add ax,10h
push ds
push es
pop ds ; (!!!)done in public
;DS <-public - in order to copy the call.
mov di,ax ;so we copy from si to AZ
movsw ;Copying the FF1F (call far) to the arena, 3 lines under the begining of the code. column of 0A3. voulnerable!
dec di ;re-adujst in order to run over ourself
mov si,start_of_from_cf_to_zorg ;Private Segmant
pop ds ;DS<-Private
jmp ax  ;to the copied call far
call_far:call dword [bx] ;40
bomb1_end:
;After running over ourself, will execute Copy2 (once in the entire round).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zorg_copy:
db ((label2 - label1 )) dup _cmd   
label1:
add	bx, bp ;even - t
label2:
db ((label4 - label3 )) dup _cmd 
label3:
add	sp, cx
label4:
db ((label6 - label5 )) dup _cmd
label5:
xor	si, si ;optional:make it mov si,X. than in the beginning to put stuff that will allow to combine "try"
mov	di, bx; will look like: es-> combiniing "try"(will happen once)...BOMBING ZORG STYLE (will happen everytime)...some important addresses
sub bx,10h
movsw
call	bx 
label6:
fin_zorg_copy:

from_cf_to_zorg:
;'a movsw bomb' that lets us become zorg. runs only one time
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
mov	dx, 0CCCCh
;mov dx, 26ffh ; the actual attack. we throw it as the backwords garabage. this is opcode for :jmp[0]
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
sub bx,10h ;because CS changed
xor	si, si ;si->0A552h   in the private segmant
movsw ; copy the first 0A552h
call bx ;start runnig 0A552h
label18:
fin_from_cf_to_zorg:

fin_code:
