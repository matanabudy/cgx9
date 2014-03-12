reset_cf_length equ ((end_reset_cf - reset_cf ))
reset_all_length equ (end_reset_all-reset_cf)
PS_end_of_heavy_bombing equ 200h
PS_start_of_reset_cf equ PS_end_of_heavy_bombing
PS_end_of_reset_all equ PS_start_of_reset_cf+reset_all_length
PS_1_ax equ PS_end_of_reset_all+5h
_sw equ 0A5h
_sb equ 0A4h
;heavy bombing of private segmant
xchg	ax, bx
mov	ax, 0A552h ; PUSH DX. MOVSW. AL->AH->DL-DH
mov	dx, ax 
int	86h		; Heavy Bombing with opcodes
int	86h	
xchg	ax, bx
;copy the INTIATE code to private segmant
mov	di, PS_start_of_reset_cf
mov	si, ax
add	si, reset_cf
db ((end_reset_all-reset_cf)/2) DUP (_sw)
db ((end_reset_all-reset_cf) mod 2) DUP (_sb)
;db ((end_reset_all-reset_cf)/2) dup _sw ;movsw [ds:si]->[es:di]
;prepartions
push ds;move stack,ES to arena and DS to private
push ds
push es
pop ds
pop es
pop ss ;after here should not use the stack since it will be on the arena

; mov si, PS_1_ax
; lodsw
; add ax, 8300h

mov bx,PS_end_of_reset_all+9h ;a place where it doesnt bother to anything
mov word[bx+2],cs ;store the segmant for the call far.

mov dx, ax
; add dx,200h
mov dl,(0A5h-reset_cf_length) ; if we start in a3 so we will end in a2 we want to start in a4 so we finish in a3
;from now on dl is preservng the exact address from which we should run in order to begin the call far in 0A3
;parameters to define the jumping gap
mov cx,dx ;cx will cahnge the word[bx], since we want to keep DX unchanged through out the session.
mov ax,1000h
mov sp,dx
add sp,8FFh ;lower the stack so we will run over our self when we do call far. no particular reason for 900-1 ;so we run over ourself
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start ZORGing
xor si,si
mov di,dx ;so when we call far we run over our self with 0A5
mov dx,0CCCCh
start_bomb: movsw ;write 052A5 on screen
mov bp,di
sub bp,2
jmp bp ;jmp to where we've just written 052A5

;;;;;the following is copied to private segmant:

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
mov cl,094h ;don't forget! if we want to run over ourself with 0A5 we must start at the right column
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


; reset_cf:  ;prepare to start call far after finishing ZORGing
; db ((end_reset_cf-lbl1)-2) dup _cmd ;I DO NOT NOW WHY -2 but it works
; lbl1:
; add cx, 1FEh+reset_cf_length ;200h-2h = 1FE. we subtruct 2 because its the length of the call far opcode
; mov word[bx],cx ;pay attention that we use cx to point at the place the call far is located
; dec di
; call dword [bx]

;;after the call far we want to start ZORGing again. lets prpare!
;;remember that we ran over our self with 0A5
; end_reset_cf:
; db (lbl4-lbl3) dup _cmd
; lbl3:
; xor si,si ;si points to the first 052A5 in private segmant
; mov cx,di ;make it somehow connected to our current position.
; add cx,ax ;jumping gap
; mov cl,dl ;don't forget! if we want to run over ourself with 0A5 we must start at the right column
; mov di,cx ;where to put the first MOVSW on the screen
; add sp,ax
; add sp,ax ;create distance from forward attack to backwards attack/
; movsw ;copy the attack to the arena
; mov bp,di
; sub bp,2
; jmp bp ;jump there and atart ZORGing
; lbl4:



