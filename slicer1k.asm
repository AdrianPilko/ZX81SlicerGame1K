
;;; Slicer game for zx81, can run in 1k ram
;;; by Adrian Pilkington 2023, (byteforever)
;;; https://youtube.com/@byteforever7829

;some #defines for compatibility with other assemblers
#define         DEFB .byte 
#define         DEFW .word
#define         EQU  .equ
#define         ORG  .org

; character set definition/helpers
__:				EQU	$00	;spacja
_QT:			EQU	$0B	;"
_PD:			EQU	$0C	;funt 
_SD:			EQU	$0D	;$
_CL:			EQU	$0E	;:
_QM:			EQU	$0F	;?
_OP:			EQU	$10	;(
_CP:			EQU	$11	;)
_GT:			EQU	$12	;>
_LT:			EQU	$13	;<
_EQ:			EQU	$14	;=
_PL:			EQU	$15	;+
_MI:			EQU	$16	;-
_AS:			EQU	$17	;*
_SL:			EQU	$18	;/
_SC:			EQU	$19	;;
_CM:			EQU	$1A	;,
_DT:			EQU	$1B	;.
_NL:			EQU	$76	;NEWLINE

_0				EQU $1C
_1				EQU $1D
_2				EQU $1E
_3				EQU $1F
_4				EQU $20
_5				EQU $21
_6				EQU $22
_7				EQU $23
_8				EQU $24
_9				EQU $25
_A				EQU $26
_B				EQU $27
_C				EQU $28
_D				EQU $29
_E				EQU $2A
_F				EQU $2B
_G				EQU $2C
_H				EQU $2D
_I				EQU $2E
_J				EQU $2F
_K				EQU $30
_L				EQU $31
_M				EQU $32
_N				EQU $33
_O				EQU $34
_P				EQU $35
_Q				EQU $36
_R				EQU $37
_S				EQU $38
_T				EQU $39
_U				EQU $3A
_V				EQU $3B
_W				EQU $3C
_X				EQU $3D
_Y				EQU $3E
_Z				EQU $3F


;;;; this is the whole ZX81 runtime system and gets assembled and 
;;;; loads as it would if we just powered/booted into basic

           ORG  $4009             ; assemble to this address
                                                                
VERSN:          DEFB 0
E_PPC:          DEFW 2
D_FILE:         DEFW Display
DF_CC:          DEFW Display+1                  ; First character of display
VARS:           DEFW Variables
DEST:           DEFW 0
E_LINE:         DEFW BasicEnd 
CH_ADD:         DEFW BasicEnd+4                 ; Simulate SAVE "X"
X_PTR:          DEFW 0
STKBOT:         DEFW BasicEnd+5
STKEND:         DEFW BasicEnd+5                 ; Empty stack
BREG:           DEFB 0
MEM:            DEFW MEMBOT
UNUSED1:        DEFB 0
DF_SZ:          DEFB 2
S_TOP:          DEFW $0002                      ; Top program line number
LAST_K:         DEFW $fdbf
DEBOUN:         DEFB 15
MARGIN:         DEFB 55
NXTLIN:         DEFW Line2                      ; Next line address
OLDPPC:         DEFW 0
FLAGX:          DEFB 0
STRLEN:         DEFW 0
T_ADDR:         DEFW $0c8d
SEED:           DEFW 0
FRAMES:         DEFW $f5a3
COORDS:         DEFW 0
PR_CC:          DEFB $bc
S_POSN:         DEFW $1821
CDFLAG:         DEFB $40
PRBUFF:         DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$76 ; 32 Spaces + Newline
MEMBOT:         DEFB 0,0,0,0,0,0,0,0,0,0,$84,$20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 30 zeros
UNUNSED2:       DEFW 0

Line1:          DEFB $00,$0a                    ; Line 10
                DEFW Line1End-Line1Text         ; Line 10 length
Line1Text:      DEFB $ea                        ; REM
                                                                

	ld bc,2
	ld de,gameName
	ld hl,(DF_CC)
	add hl,bc	
printstring_loop
	ld a,(de)
	cp $ff
	jp z,printstring_end
	ld (hl),a
	inc hl
	inc de
	jr printstring_loop
printstring_end	

   
gameLoop
    ; scroll first line of slicer     
    ld de, 22       ; start of first row to be shifted    
    ld hl,(DF_CC)
    add hl,de
    ld (firstCharFirstRow), hl
    
    ld de, 31 
    ld hl,(DF_CC)
    add hl,de
    ld (lastCharFirstRow), hl           
        
    call scrollARowLeft_DE_BC
    

    ld bc, $1fff
waitloop1
    dec bc
    ld a,b
    or c
    jr nz, waitloop1
    
    jp gameLoop
    ret          

scrollARowLeft_DE_BC    ;;; de to contain the display location of first character in row, bc the last
                        ;;; also uses 
    
    ld hl, (firstCharFirstRow)
    ld a, (hl)  ; store the current character that gets wrapped around to right
    ld (tempChar), a    
    ld bc,$0900    
scrollLeft       
    inc hl
    push hl
    ld a, (hl)  ; store the current character to be shifted left
    dec hl
    ld (hl), a  ; now store it!
    pop hl
    djnz scrollLeft

    ld hl, (lastCharFirstRow)
    ld a, (tempChar)  
    ld (hl),a  ; store the current character that gets wrapped around to right
    ret                
    
scrollARowRight_DE_BC    ;;; de to contain the display location of first character in row, bc the last
    ret   
                DEFB $76                        ; Newline        
Line1End
Line2			DEFB $00,$14
                DEFW Line2End-Line2Text
Line2Text     	DEFB $F9,$D4                    ; RAND USR
				DEFB $1D,$22,$21,$1D,$20        ; 16514                
                DEFB $7E                        ; Number
                DEFB $8F,$01,$04,$00,$00        ; Numeric encoding
                DEFB $76                        ; Newline
Line2End            
endBasic
                                                                
Display        	DEFB $76     
                DEFB 8,9,0,0,0,0,0,0,9,8,$76 ; Line 0
                DEFB 0,0,0,0,0,0,0,0,0,0,$76 ; Line 1
                DEFB 128,0,0,128,128,128,128,128,128,128,$76 ; Line 2
                ;DEFB 28,29,30,31,32,33,34,35,36,37,$76 ; Line 2  (debug)
                DEFB 0,0,0,0,0,0,0,0,0,0,$76 ; Line 3
                DEFB 128,128,128,128,0,0,128,128,128,128,$76 ; Line 4
                DEFB 0,0,0,0,0,0,0,0,0,0,$76 ; Line 5
                DEFB 0,0,128,128,128,128,128,128,128,128,$76 ; Line 6
                DEFB 0,0,0,0,0,0,0,0,0,0,$76 ; Line 7
                DEFB 128,128,128,0,0,128,128,128,128,128,$76 ; Line 8
                DEFB 0,0,0,0,0,0,0,0,0,0,$76 ; Line 9
                DEFB $76 ; Line 10
                DEFB $76 ; Line 11
                DEFB $76 ; Line 12
                DEFB $76 ; Line 13
                DEFB $76 ; Line 14
                DEFB $76 ; Line 15
                DEFB $76 ; Line 16
                DEFB $76 ; Line 17
                DEFB $76 ; Line 18
                DEFB $76 ; Line 19
                DEFB $76 ; Line 20
                DEFB $76 ; Line 21
                DEFB $76 ; Line 22
                DEFB $76 ; Line 23
                                 
                                                                
Variables:      
gameName
	DEFB	_S,_L,_I,_C,_E,_R,$ff
tempChar
    DEFB 0
padding
    DEFB 0
firstCharFirstRow
    DEFB 0,0
lastCharFirstRow    
    DEFB 0,0
VariablesEnd:   DEFB $80
BasicEnd: 
#END
