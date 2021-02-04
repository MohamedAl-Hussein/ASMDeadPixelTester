TITLE ASMDeadPixelTester (main.asm)

; Author: Mohamed Al-Hussein
; Last Modified: 02/04/2021
; A simple dead pixel tester that runs on the windows console.
; NOTE: changing window size causes weird overlay effect where the edges of the screen retain the color before changing window size.

INCLUDE Irvine32.inc

REFRESH_INTERVAL = 2000d				; screen refresh delay in miliseconds
BACKGROUND_MULTIPLIER = 16d				; multiplier to set high bits of AL register for background color

.STACK		1024
.DATA
	color	DWORD	0					; color multiplicand: black = 0, blue = 1, green = 2, cyan = 3, red = 4, magenta = 5,
										;					brown = 6, lightGray = 7, gray = 8, lightBlue = 9, lightGreen = 10,
										;					lightCyan = 11, lightRed = 12, lightMagenta = 13, yellow = 14, white = 15

.CODE
main PROC
	MOV		EAX, color
	XOR		ECX, ECX
_loop:
	; update color
	PUSH	EAX
	PUSH	OFFSET color
	CALL	nextColor	
	MOV		EAX, color

	; change screen color
	CALL	SetTextColor
	CALL	Clrscr

	; wait a bit 
	PUSH	EAX
	MOV		EAX, REFRESH_INTERVAL
	CALL	Delay
	POP		EAX

	; set eax to next color multiplicand
	INC		ECX
	MOV		EAX, ECX

	; reset if max color value
	CMP		EAX, BACKGROUND_MULTIPLIER 
	JGE		_reset

	; go again
	JMP		_loop

_reset:
	MOV		EAX, color
	XOR		ECX, ECX
	JMP		_loop

	INVOKE ExitProcess, 0				; exit to operating system
main ENDP

;------------------------------------------------------------------------------
; Name: nextColor
;
; Calculates the next color value for background.
;
; Receives:
;	[EBP + 12] = color multiplicand 
;   [EBP + 8] = return address
;	BACKGROUND_MULTIPLIER is a global constant
;------------------------------------------------------------------------------
nextColor PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX							; save registers
	PUSH	EBX
	PUSH	EDX

	MOV		EAX, [EBP + 12]				; color multiplicand 
	MOV		EBX, BACKGROUND_MULTIPLIER 
	MUL		EBX							; get next color
	MOV		EDX, [EBP + 8]				; return address
	MOV		[EDX], EAX					; set color at return address

	POP		EDX							; restore registers
	POP		EBX							
	POP		EAX
	POP		EBP
	RET		8							; clean up stack
nextColor ENDP

END main
