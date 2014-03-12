;addresses
end_of_zorg_copy equ 200h+(fin_zorg_copy-zorg_copy)
special_opcode equ 4289h
larry1_address equ (special_opcode-3)
PS_larry2_sp_address equ 320h
PS_larry2_call_far_address equ 310h

;lengths
_cmd equ 0A5h

;constants
zorg_cs equ 1000h
half_screen equ 8000h
stack_jump_constant equ 19AAh
forward_jump_constant equ 17CCh
minmize_sp2_gap equ 1Ch

;new_cs
new_cs equ 1051h
cs_offset equ ((new_cs-1000h)*10h)

push es
push ax
add ax,Zombie
mov [0BEEFh],ax
mov cx,0BEEFh
mov bx,026FFh
mov ax,02688h
mov dx,0C4DDh
push ds
pop es
int 87h
pop ax
pop es

regular_zorg_copy:
;bobming zorg opcodes into es
xchg	ax, bx
mov	ax, 0A552h ; PUSH DX. MOVSW.
mov	dx, ax 
int	86h		; Heavy Bombing with opcodes
int	86h	
xchg	ax, bx
fin_regular_zorg_copy:

zorg_es_parts:
mov di, (200h+fin_zorg_copy-zorg_copy)
mov si, ax
add si,from_cf_to_zorg
mov	cx, ((fin_from_cf_to_zorg-from_cf_to_zorg+1)/2)
copy1_2_start: rep movsw
fin_zorg_es_parts:

push es
push ds
push ds
push es
pop ds ;ds<=es

mov dx, ax
mov ax, larry1_address
mov al,0A3h
add ax, half_screen
mov word [PS_larry2_sp_address], ax ;ax will become sp.save it somewhere in Private segmeant so we can still push and pop not on arena
add word [PS_larry2_sp_address], (half_screen+cs_offset-minmize_sp2_gap)

address_for_call_far:
mov bx,PS_larry2_call_far_address
mov word [bx+2], new_cs ;puts the call far address to our place in the private segment.
mov word [bx], ax
add ax, cs_offset
fin_address_for_call_far:

pop es ;es<=ds
pop ds ;DS<=DS

opcode_copy:
mov si, dx
add si, call_far
mov di, ax
; mov	cx, stack_jump_constant
movsw
dec di
fin_opcode_copy:

pop ds ; DS<=es
push cs
pop ss ; ss<=cs

mov word sp, [PS_larry2_sp_address]

prepare_to_jump:
mov si, end_of_zorg_copy ;the length of the place in the private segment that after zorg regular copies
jmp word ax
fin_prepare_to_jump:

call_far:
call dword [bx]
fin_call_far:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zorg_copy:
db ((label2 - label1 )) dup _cmd   ;was ((label2 - label1 )+1)
label1:
add	bp, dx
label2:
db ((label4 - label3 )) dup _cmd 
label3:
add	sp, cx
label4:
db ((label6 - label5 )) dup _cmd
label5:
xor	si, si ;optional:make it mov si,X. than in the beginning to put stuff that will allow to combine "try"
mov	di, bp; will look like: es-> combiniing "try"(will happen once)...BOMBING ZORG STYLE (will happen everytime)...some important addresses
movsw
call	bp 
label6:
fin_zorg_copy:

from_cf_to_zorg:
;'a movsw bomb' that lets us become zorg. runs only one time
db ((label8 - label7 +3)) dup _cmd
label7:
mov	bp, di
add bp, 500h 
label8:
db ((label10 - label9 )) dup _cmd
label9:
mov	dx, forward_jump_constant ;forword jump constant. determins how lower will this bombing be.
label10:
db ((label12 - label11 )) dup _cmd
label11:
mov word [bx+2],zorg_cs
label12:
db ((label14 - label13 )) dup _cmd
label13:
mov	cx, stack_jump_constant ;stack-jump constant
label14:
db ((label16 - label15 )) dup _cmd
label15:
lea	sp, [bp-500h]            
label16:
db ((label18 - label17 )) dup _cmd
label17:
mov	di, bp ;the place to where we copy our new bombing
xor	si, si ;si->0A552h   in the private segmant
mov word [bx],bp
movsw ; copy the first 0A552h
call dword [bx] ;start runnig 0A552h
label18:
fin_from_cf_to_zorg: 

Zombie:
call here
here: pop ax
push cs
pop ss
mov cx,ax
add cx,(_loop-here)
inc ah
mov al, 0xa2
mov sp, ax
mov dx, 0104h
mov bx,0DEADh
mov word [bx+2], es ;puts the address to our place in the private segment. Pay attention that we put es in here, whch contains 1001h
mov word [bx], cx

_loop:
add sp, dx
call_far_zombie:call dword [bx]

fin_code: