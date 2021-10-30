$NOMOD51
$INCLUDE (8051.MCU)

ORG 0H
RS EQU P2.3
RW EQU P2.4
E EQU P2.5

MOV A, #0FFH
MOV P0, A
MOV A, 0H
MOV P2,A

MAIN:
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT1
ACALL SEND_DATA
ACALL DELAY

MOV DPTR, #COMAND2
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT2
ACALL SEND_DATA
ACALL DELAY

MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT4
ACALL SEND_DATA
ACALL DELAY

;KEYPAD ENTER PASS
MOV DPTR, #COMAND2
ACALL SEND_CMD
ACALL DELAY
MOV R2, #4
MOV R0, #40H
LOOP1:
CLR A
LJMP KEYPAD
VAL_KEYPAD:
MOV @R0,A
MOV A,#42
ACALL DATAWRITE
ACALL DELAY
INC R0
DJNZ R2,LOOP1
;END

;CHECKING PASS
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #CHKMSG
ACALL SEND_DATA
ACALL DELAY
CLR A
MOV R1, #40H
MOV R2, #4
MOV DPTR, #PASS1
PLOOP1:
CLR A
MOVC A, @A+DPTR
MOV B ,@R1
CJNE A,B,INVALID1
INC DPTR
INC R1
DJNZ R2, PLOOP1
SJMP MATCHED1

INVALID1:
CLR A
MOV R1,#40H
MOV R2,#4
MOV DPTR, #PASS2
PLOOP2:
CLR A
MOVC A, @A+DPTR
MOV B ,@R1
CJNE A,B,INVALID2
INC DPTR
INC R1
DJNZ R2, PLOOP2
SJMP MATCHED2

INVALID2:
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_F1
ACALL SEND_DATA
ACALL DELAY
MOV DPTR, #COMAND2
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_F2
ACALL SEND_DATA
ACALL DELAY
CLR P3.1
CLR P3.0
LJMP MAIN

;LOCKED
MATCHED1:
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_S1
ACALL SEND_DATA
ACALL DELAY
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_S2
ACALL SEND_DATA
ACALL DELAY
SETB P3.0
CLR P3.1
SJMP LOOP

;ANTI LOCKED
MATCHED2:
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_S1
ACALL SEND_DATA
ACALL DELAY
MOV DPTR, #COMAND1
ACALL SEND_CMD
ACALL DELAY
MOV DPTR, #TEXT_S3
ACALL SEND_DATA
ACALL DELAY
CLR P3.0
SETB P3.1
SJMP LOOP

LOOP: SJMP LOOP

KEYPAD: ;COLOM 1
	SETB P2.0
	SETB P2.1
	SETB P2.2
	ACALL DELAY_15
	CLR P2.0
	SETB P2.1
	SETB P2.2
	JB P0.0, W1
	LCALL DETECTED_1
	LJMP VAL_KEYPAD
W1: JB P0.1, X1
	LCALL DETECTED_4
	LJMP VAL_KEYPAD
X1: JB P0.2, Z1
	LCALL DETECTED_7
	LJMP VAL_KEYPAD
	
Z1: SETB P2.0
	CLR P2.1
	SETB P2.2
	JB P0.0, W2
	LCALL DETECTED_2
	LJMP VAL_KEYPAD
W2: JB P0.1, X2
	LCALL DETECTED_5
	LJMP VAL_KEYPAD
X2: JB P0.2, Y2
	LCALL DETECTED_8
	LJMP VAL_KEYPAD
Y2: JB P0.3, Z2
	LCALL DETECTED_0
	LJMP VAL_KEYPAD
	;chek kol 3
Z2: SETB P2.0
	SETB P2.1
	CLR P2.2
	JB P0.0, W3
	LCALL DETECTED_3
	LJMP VAL_KEYPAD
W3: JB P0.1, X3
	LCALL DETECTED_6
	LJMP VAL_KEYPAD
X3: JB P0.2, Z3
	LCALL DETECTED_9
	LJMP VAL_KEYPAD

Z3: LJMP KEYPAD
DETECTED_0:
CLR A 
MOV A, #0
	LCALL DELAY_15
	RET
DETECTED_1:
CLR A
	MOV A,#1
	LCALL DELAY_15
RET
DETECTED_2:
CLR A
	MOV A,#2
	LCALL DELAY_15
RET
DETECTED_3:
CLR A
	MOV A,#3
	LCALL DELAY_15
	RET
DETECTED_4:
CLR A
	MOV A,#4
	LCALL DELAY_15
	RET
DETECTED_5:
CLR A
	MOV A,#5
	LCALL DELAY_15
	RET
DETECTED_6:
	MOV A,#6
LCALL DELAY_15
	RET
DETECTED_7:
CLR A
	MOV A,#7
LCALL DELAY_15
	RET
DETECTED_8:
	CLR A
	MOV A,#8
LCALL DELAY_15
	RET
DETECTED_9:
	CLR A
	MOV A,#9
LCALL DELAY_15
	RET
	
DELAY_15: MOV R3,#200
HERE2: MOV R4, #150
HERE: DJNZ R4, HERE
DJNZ R3, HERE2
RET

SEND_CMD:
GO2:CLR A
	MOVC A, @A+DPTR
	ACALL COMWRITE
	ACALL DELAY
	INC DPTR
	JZ OUT
	SJMP GO2
	OUT:
RET

SEND_DATA:
GO3:CLR A
	MOVC A, @A+DPTR
	ACALL DATAWRITE
	ACALL DELAY
	INC DPTR
	JZ HERE1
	SJMP GO3
HERE1:
RET
;LCD CODE
COMWRITE:
	MOV P1, A
	CLR RS
	CLR RW
	SETB E
	ACALL DELAY
	CLR E
	RET
DATAWRITE:
	MOV P1, A
	SETB RS
	CLR RW
	SETB E
	ACALL DELAY
	CLR E
	RET	
DELAY:
	MOV R3,#200
	XX2: MOV R4,#150
	XX1: DJNZ R4,XX1
	DJNZ R3,XX2
	RET

ORG 400H
COMAND1: DB 38H,0EH,01H,06H,0
COMAND2: DB 38H,0EH,06H,0C0H,0
TEXT1: DB "DOOR LOCK", 0
TEXT2: DB "MECHANICAL SYS",0
TEXT4: DB "PASSWORD:",0
CHKMSG: DB "TUNGGU...",0
TEXT_S1: DB "HALO FADLI!!",0
TEXT_S2: DB "Pintu Terkunci",0
TEXT_S3: DB "Pintu Terbuka",0
TEXT_F1: DB "Password Salah ",0
TEXT_F2: DB "ACCESSING",0
PASS1: DB 1,2,3,4
PASS2: DB 4,3,2,1
 
 END
