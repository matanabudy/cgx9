end_of_zorg_copy equ 200h+(fin_zorg_copy-zorg_copy)
_cmd equ 0A5h
new_cs equ 1051h
cs_offset equ ((new_cs-1000h)*10h)
PS_sue1_call_far_address equ 300h
zorg_cs equ 1000h
stack_jump_constant equ 19AAh
forward_jump_constant equ 17CCh
minimize_gap_offset equ 0BDh
half_screen equ 8000h
sue1_address equ 286h

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
mov si, ax
add si,zorg_copy
mov	cx, ((fin_from_cf_to_zorg-zorg_copy+1)/2)
copy1_2_start: rep movsw
fin_zorg_es_parts:

push es
push ds
push ds
push es
pop ds ;ds<=es

mov dx, (sue1_address+1h) ;to run on our self with the special opcode

address_for_call_far:
mov bx,PS_sue1_call_far_address
mov word [bx+2], new_cs ;puts the call far address to our place in the private segment.
mov word [bx], dx
add dx,cs_offset
fin_address_for_call_far:

pop es ;es<=ds
pop ds ;DS<=DS

opcode_copy:
mov si, ax
add si, call_far
mov di, dx
movsw
fin_opcode_copy:

pop ds ; DS<=es
push cs
pop ss ; ss<=cs

prepare_to_jump:
mov ax, 0a5a5h ;so we will write a5a5 after we run our self - becaue we write ax
mov si, end_of_zorg_copy ;the length of the place in the private segment that after zorg regular copies
mov bp, (sue1_address+3);78h ;289h(our place - [bp+si] si=0) |-211h (our copy size - our si size)
sub bp, si
add bp,cs_offset ;CS reasons
mov sp, (sue1_address+3)
add sp,(half_screen+cs_offset) ;7D00h  ; half screen
sub sp, minimize_gap_offset
dec sp ;so we will run over ourself well
jmp dx
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
db ((label8 - label7 +2)) dup _cmd
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
;making our cs back to 1000h so we won't run into problems with IP's not in the arena 
;(for example, CS-1001h, IP-FFF1 is actually address: 10001 which does not exist)
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

fin_code: