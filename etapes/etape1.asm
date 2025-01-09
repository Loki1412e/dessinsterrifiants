;##################################################
;###########       Etape 1       ##################
;##################################################

; my external functions from ./functions/
extern random_number
extern draw_circle
extern distance_points

;##################################################

%include "etapes/common.asm"

%define NB_CERCLES 2
%define COLUMN_CIRCLES 3 ; { r , x , y }

;##################################################

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    width:         	resd	1
    height:        	resd	1
    window:         resq	1
    gc:             resq	1

    i:              resb    1
    j:              resb    1
    circles_rxy:    resw    NB_CERCLES * COLUMN_CIRCLES   ; nb de cercles * { r , x , y }
    tmp_circle_rxy: resw    COLUMN_CIRCLES

    test:           resb    1

;##################################################

section .data
    event:		times	24 dq 0

    msg_start:  db  "--- DEBUT ---", 10, 10, 0
    msg_end:    db  "--- FIN ---", 10, 10, 0
    int_msg:    db  "%d : %d // %d", 10, 10, 0
    msg_aled:   db  "ALED", 10, 10, 0

;##################################################

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################
global main
main:
;###########################################################
; Mettez ici votre code qui devra s'exécuter avant le dessin
;###########################################################

    mov rdi, msg_start
    mov rax, 0
    call printf

mov byte[i], 0
boucle_rand:

    ;=====================================

    ; Calcul d'un cercle aléatoire

    ;=====================================

    mov byte[test], 0

    mov byte[j], 0
    boucle_rand__tmp_cricle:

        ;///////////
        inc byte[test]
        ;///////////

        cmp byte[j], 0
        jne boucle_rand__tmp_cricle__coord

        mov edi, WIDTH / 2  ; Maximum du rayon
        jmp boucle_rand__tmp_cricle__calcul

        boucle_rand__tmp_cricle__coord:
        mov edi, WIDTH  ; Maximum pour x et y

        boucle_rand__tmp_cricle__calcul:
        
        call random_number  ; retrun nb aléatoire dans ax
        mov r8w, ax  ; On save nb aleatoire dans r8w

        mov rcx, tmp_circle_rxy
        movzx rax, byte[i]
        mov rbx, COLUMN_CIRCLES
        mul rbx             ; rax = i * COLUMN_CIRCLES

        movzx rbx, byte[j]
        add rax, rbx        ; rax = i * COLUMN_CIRCLES + j
        
        mov word[rcx + WORD * rax], r8w   ; On stock le nb aleatoire dans tmp_circle_rxy[i][j]

    inc byte[j]
    cmp byte[j], COLUMN_CIRCLES  ; max d'iterations (3 : r, x, y)
    jne boucle_rand__tmp_cricle

    ; =====================================

    ; On vérifie si [tmp_circle_rxy] ne rentre pas en collision avec un des cercles déjà calculés
    ; Sinon on renvoie vers boucle_rand__tmp_cricle

    ; =====================================

;     mov byte[j], 0

;     cmp byte[i], 0
;     je boucle_rand__add_cricle

;     boucle_rand__distance:
        
;         ;-------------------------------------
        
;         movzx rax, byte[j]
;         mov rbx, COLUMN_CIRCLES
;         mul rbx     ; rax = j * COLUMN_CIRCLES

;         mov rbx, rax    ; rbx = j * COLUMN_CIRCLES
        
;         ; (rax + k) <=> (j * COLUMN_CIRCLES + k)
;         movzx rdi, word[circles_rxy + WORD * (rbx + 1)]   ; circle[j][x]
;         movzx rsi, word[circles_rxy + WORD * (rbx + 2)]   ; circle[j][y]
;         movzx rdx, word[tmp_circle_rxy + WORD * 1]        ; tmp[x]
;         movzx rcx, word[tmp_circle_rxy + WORD * 2]        ; tmp[y]
;         call distance_points    ; rax = la distance entre les deux points

;         ;-------------------------------------
        
;         ; Sommes des rayons des 2 cercles
;         mov bx, word[tmp_circle_rxy]
;         mov cx, word[circles_rxy + WORD * (rbx + 0)]
;         add rbx, rcx    ; rbx = tmp[r] + circle[j][r]

; ; ;///////////////////////////
; ; push rax
; ; mov rdi, int_msg
; ; mov rsi, rbx
; ; mov rdx, rax
; ; movzx rcx, byte[test]
; ; mov rax, 0
; ; call printf
; ; pop rax
; ; ;///////////////////////////
        
;         ;-------------------------------------
        
;         ; Si rax (distance) > rbx (sum des rayons) alors les cercles ne se touchent pas
;         cmp rax, rbx
;         ja mov byte[test], 0

        
;         ; Sinon on calcul un nouveau tmp_circle
;         mov byte[j], 0

; ;///////////////////////////
; mov rdi, int_msg
; mov rsi, rax
; mov rdx, rbx
; movzx rcx, byte[i]
; mov rax, 0
; call printf

; ; mov rdi, 0
; ; mov rax, 60
; ; syscall
; ;///////////////////////////
;         jmp boucle_rand__tmp_cricle

;         boucle_rand__distance__success:

;         ;-------------------------------------

;     inc byte[j]
;     ; Si j == i alors tout les cercles ont été vérifiés
;     mov al, byte[i]
;     cmp al, byte[j]
;     jne boucle_rand__distance

    ;=====================================

    ; On ajoute le tmp_cricle dans le tableau des cercles

    ;=====================================
    
    mov byte[j], 0
    boucle_rand__add_cricle:
        
        movzx rax, byte[i]
        mov rbx, COLUMN_CIRCLES
        mul rbx             ; rax = i * COLUMN_CIRCLES
        movzx rbx, byte[j]  ; rbx = j
        add rax, rbx        ; rax = i * COLUMN_CIRCLES + j

        mov cx, word[tmp_circle_rxy + WORD * rbx]  ; cx = tmp_circle[j][i]
        
        mov word[circles_rxy + WORD * rax], cx   ; On stock le nb aleatoire dans circles[i][j]

; ///////////////////////////
mov rdi, int_msg
movzx rsi, word[tmp_circle_rxy + WORD * rbx]
movzx rdx, word[circles_rxy + WORD * rax]
movzx rcx, byte[test]
mov rax, 0
call printf
; //////////////////////////

    inc byte[j]
    cmp byte[j], COLUMN_CIRCLES
    jne boucle_rand__add_cricle

    ;=====================================

inc byte[i]
cmp byte[i], NB_CERCLES
jne boucle_rand

; ///////////////////////////
mov rdi, msg_end
mov rax, 0
call printf
; ///////////////////////////


;###############################
; Code de création de la fenêtre
;###############################
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,WIDTH	; largeur
mov r9,HEIGHT	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
;jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################

dessin:

    mov rdi, msg_aled
    mov rax, 0
    call printf

mov byte[i], 0
boucle_dessin:

    ; mul utilise rdx:rax
    movzx rax, byte[i]
    mov rbx, COLUMN_CIRCLES
    mul rbx             ; rax = i * COLUMN_CIRCLES

    mov rdi, qword[display_name]
    mov rsi, qword[window]
    mov rdx, qword[gc]
    
    mov cx, word[circles_rxy + WORD * (rax + 0)]  ; circles_rxy[i][0] : RAYON du CERCLE (word)
    mov r8w, word[circles_rxy + WORD * (rax + 1)] ; circles_rxy[i][1] : COORDONNEE en X DU CERCLE (word)
    mov r9w, word[circles_rxy + WORD * (rax + 2)] ; circles_rxy[i][2] : COORDONNEE en Y DU CERCLE (word)
    
    push 0xFFFFFF   ; COULEUR du crayon en hexa (dword mais en vrai -> 3 octets : 0xRRGGBB)
    
    call draw_circle

; ///////////////////////////
mov rdi, int_msg
movzx rsi, word[circles_rxy + WORD * (rax + 1)]
movzx rdx, word[circles_rxy + WORD * (rax + 2)]
movzx rcx, word[circles_rxy + WORD * (rax + 0)]
mov rax, 0
call printf
; //////////////////////////

inc byte[i]
cmp byte[i], NB_CERCLES
jne boucle_dessin


; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
;jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit