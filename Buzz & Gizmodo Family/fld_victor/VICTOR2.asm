;buzz and gaywod combined
reset_cf_length equ (end_reset_cf - reset_cf )
reset_all_length equ (end_reset_all-reset_cf)
PS_end_of_zorg equ 200h
PS_end_of_reset_cf equ PS_end_of_zorg+reset_cf_length
PS_end_of_reset_all equ PS_end_of_zorg+reset_all_length
PS_my_bx equ PS_end_of_reset_all+10
PS_other_ax equ PS_my_bx+10
_sw equ 0A5h
_sb equ 0A4h

xchg	ax, bx
mov	ax, 0A552h ; PUSH DX. MOVSW.
mov	dx, ax 
int	86h		; Heavy Bombing with opcodes
int	86h	
xchg	ax, bx

;Copy "copy1+copy2" to private segmant
mov	di, PS_end_of_zorg ;because of heavy bombing
mov	si, ax
add	si, reset_cf
db ((end_reset_all-reset_cf)/2) DUP (_sw)
db ((end_reset_all-reset_cf) mod 2) DUP (_sb)

bomb1:
mov dx,ax ; save begining position
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
add si, call_far
xchg si,di
mov	si, PS_other_ax ;[ds:si]-->ax
lodsw 
xchg si,di
add ax,8300h ;ax<- the place of woodey1's call far + half-screen
mov al,0A3h
mov sp,ax 
sub sp,8104h

mov bx,PS_my_bx   ;a place in our private segment. in this location the address of the call far is loaded
mov word [bx+2], cs ;puts the call far address to our place in the private segment.
mov word [bx], ax
push ds
push es
pop ds
;DS,SS <-public
mov di,ax
;preparations:
mov cx,ax
mov ax,1000h
;;;;;;;;;;;;;;
movsw ;Copying the FF1F (call far) to the arena, 3 lines under the begining of the code. column of 0A3.
mov si,PS_end_of_reset_cf
dec di ;re-adujst in order to run over ourself
;Private Segmant
pop ds ;DS<-Private
jmp cx  ;to the copied call far
call_far:call dword [bx]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_cf:
db ((lbl2-lbl1)) DUP (_sw)
db ((lbl2-lbl1) mod 2) DUP (_sb)
lbl1:
add cx, 1FEh+reset_cf_length
lbl2:
db ((lbl4-lbl3)) DUP (_sw)
db ((lbl4-lbl3) mod 2) DUP (_sb)
lbl3:
mov word[bx],cx
lbl4:
db ((lbl6-lbl5)/2) DUP (_sw)
db ((lbl6-lbl5) mod 2) DUP (_sb)
lbl5:
dec di
call dword [bx]
lbl6:
end_reset_cf:
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
db ((lbl8-lbl7)/2) DUP (_sw)
db ((lbl8-lbl7) mod 2) DUP (_sb)
lbl7:
add sp,ax
lbl8:
db ((lbl10-lbl9)) DUP (_sw)
db ((lbl10-lbl9) mod 2) DUP (_sb)
lbl9:
add sp,600h
lbl10:
db ((lbl12-lbl11)) DUP (_sw)
db ((lbl12-lbl11) mod 2) DUP (_sb)
lbl11:
mov cx,di ;make it somehow connected to our current position.
; add cx, (end_reset_all-lbl12) ;;this line is not needed! it always affects CL but CL is changed later anyway
lbl12:
db ((lbl14-lbl13)) DUP (_sw)
db ((lbl14-lbl13) mod 2) DUP (_sb)
lbl13:
add cx,ax ;jumping gap
lbl14:
db ((lbl16-lbl15)) DUP (_sw)
db ((lbl16-lbl15) mod 2) DUP (_sb)
lbl15:
;don't forget! if we want to run over ourself with 0A5 we must start at the right column.
mov cl,094h  ;CHANGE WHEN YOU CHANGE THE RESET METHODS
lbl16:
db ((end_reset_all-lbl17)) DUP (_sw)
;db ((end_reset_all-lbl17) mod 2) DUP (_sb)
lbl17:
mov di,cx
xor si,si
movsw ;copy the attack to the arena
mov bp,di
sub bp,2
jmp bp
end_reset_all: