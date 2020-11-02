TITLE Combinations Quiz     (program6b_Nguyen_Richard.asm)

; Author: Richard Nguyen
; Last Modified: 12/8/19
; OSU email address: nguyeric@oregonstate.edu
; Course number/section:CS_271_400_F2019
; Project Number: 6B                 Due Date: 12/8/2019
; Description:	Asks User to calculate the number of combinations of r items from set of n items.
;				System generates problems with n in [3..12] and r in [1..n]. User answers answer
;				and system reports correct answer and evaluation of User's answer. Process repeats
;				until user quits.

INCLUDE Irvine32.inc

; (insert constant definitions here)
; min and max of n, in range 3 to 12
NMIN=3
NMAX=12
; min and max of r, in range of 1 to n
RMIN = 2

.data
; (insert variable definitions here)
;*****introduction
intro_1				BYTE	"Program #6b: Combinations Calculator/Practice Problems by Richard Nguyen ", 0
intro_2				BYTE	"I will generate a combinations problem for you.", 0
intro_3				BYTE	"Enter your answer and I'll tell you if you got it right!", 0

;******showProblem
r					DWORD	?					; r to be randomly generated [3..12]
n					DWORD	?					; n to be randomly generated [1..n]
problem_1			BYTE	"Problem: ",0
problem_2			BYTE	"Number of elements in the set: ",0
problem_3			BYTE	"Number of elements to choose from set: ",0

;*****getData
userAnswer			DWORD	?					; variable for user int
userString			BYTE	10 DUP(0)			; variable for user string
prompt				BYTE	"How many ways can you choose?: ",0
error_1				BYTE	"Invalid answer! Please try again. ",0

;*****combinations
result				DWORD	?					; stores correct answer from calculation

;*****showResults
result_1			BYTE	"There are ",0
result_2			BYTE	" ways to choose ",0
result_3			BYTE	" items from a set of ",0
correct				BYTE	"Your answer was correct!", 0
incorrect			BYTE	"Your answer was incorrect!",0
showUserAnswer		BYTE	"You answered: ", 0

;******playAgain
prompt_again		BYTE	"Play again?(y/n): "
choice				BYTE	10 DUP(0)			; variable for choice answer
choiceYes			BYTE	"y",0				; yes string
choiceNo			BYTE	"n",0				; no string


;****goodbye
goodbye_1			BYTE	"Thanks for using the combinatorics practice program! Goodbye! ", 0

; ------------ Macros
;displayString - string argument replaces buffer parameter and is displayed to screen 
displayString	MACRO buffer
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx
ENDM

.code
main PROC
; (insert executable instructions here)

	
	call	Randomize		;initializes sequence based on clock (random seed)
	call	introduction	; call introduction procedure
	
	newGame:				;label to jump back to if user chooses play again

	; generate r and n, display problem
	; pass r and n by reference
	push	offset r
	push	offset n
	call	showProblem			; call showProblem procedure

	;get user answer
	push	offset userAnswer
	call	getData				; call getData procedure

	;calculate combination answer
	; pass r and n by value. pass correctAnswer by reference
	push	r
	push	n
	push	OFFSET result
	call	combinations		; call combinations procedure

	;show results. Pass n, r, userAnswer, and result
	push	r
	push	n
	push	result
	push	userAnswer
	call	showResults

	; if ebx is set to 1, loop and play again
	call	playAgain
	cmp		ebx, 1
	je		newGame

	call	goodbye			; call goodbye procedure

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)
;*************INTRODUCTION*******************************
;**Introduce program.                   			   
;**recieves: intro_1, intro_2, intro_3 string variables
;**returns: nothing
;**preconditions: none
;**registers changed: none
;********************************************************
introduction	PROC
;introduction, display name and program title to output
	displayString	intro_1
	call			CrLf
;Show instructions.
	displayString	intro_2
	call			CrLf

	displayString intro_3
	call			CrLf
	call			crlf
	ret
introduction	ENDP

;*************showProblem*******************************
;** generate random n and r, display problem               			   
;**recieves: OFFSETS of n and r
;**returns: random n and random r within respective ranges
;**preconditions: r and n parameters pushed to stack. (2 items pushed)
;**registers changed: eax, ecx ,edx
;********************************************************
showProblem	PROC
	; set stack frame n is [ebp+8], r is [ebp+12]
	push	ebp				
	mov		ebp, esp		

	; move pushed parameters to registers. 
	mov		edx, [ebp+8]	; move n to edx
	mov		ecx, [ebp+12]	; move r to ecx

	; generate random n within range. REFERENCE: Method implemented from lecture 20
	mov		eax, NMAX		; upper limit of random num
	sub		eax, NMIN		; subtract upper limit by lower limit
	inc		eax				; inc by 1 to get range of random numbers

	call	randomRange		; get random number from range
	add		eax, NMIN		; range of random number [3..12]
	mov		[edx], eax		; store random n, move result from eax to [edx], variable n

	; generate random r within range [1..n]
	;Note: max value is n. REFERENCE: Using random method from lecture 20
	mov		eax, [edx]		; upper limit
	sub		eax, RMIN		; subtract upper limit by lower limit
	inc		eax				; get range of random numbers

	call	randomRange		; get random number in range
	add		eax, RMIN		; range is [1..n]
	mov		[ecx], eax		; store random r, move result from eax to [ecx], variable r

	; ****display problem to screen
	call			CrLf
	displayString	problem_1		;"Problem: "
	call			CrLf

	displayString	problem_2
	mov				eax, [edx]		; move n to eax for display
	call			WriteDec
	call			CrLf

	displayString	problem_3
	mov				eax, [ecx]		;move r to eax for display
	call			WriteDec
	call			CrLf

	pop ebp
	ret 8
showProblem	ENDP

;*************getData*****************************
;**get user's answer. Validates answer								
;**recieves: OFFSETS of userAnswer 
;**returns: instructions to user, read their input answer
;**preconditions: userAnswer pushed on stack
;**registers changed: eax, ebx, ecx, esi
;*************************************************
getData	PROC
	; set stack frame userAnswer is [ebp+8]
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+8]			; address user answer in edi
	mov		eax, 0					; reset registers
	mov		ecx, 0
	mov		edx, 0

	mov		[edi], eax				; reset edi to 0

	jmp		getAnswer		;skip error message if first try

invalid:
	displayString	error_1
	call			CrLf

getAnswer:
	displayString	prompt
	;set conditions for readstring
	mov		edx, OFFSET userString		; move offset of userString to edx
	mov		ecx, 9						; move max non-null chars into ecx
	call	ReadString					; readstring, size of string in eax

	;Note: readstring returns size of input string to eax

	;setting up loop to step through string, REFERENCE: from demo6
	mov		ecx, eax					; size of input string as loop counter
	mov		esi, OFFSET userString		; put userString address in source register
	cld										; clear direction flag

checkValid:
	mov		ebx, [ebp+8]	; userAnswer into ebx register
	mov		eax, [ebx]		; move value of answer into eax

	mov		ebx, 10			; max string size
	mul		ebx				; eax * ebx, value * 10,  result in eax

	mov		ebx, [ebp+8]	;move user answer to ebx
	mov		[ebx], eax
	
	mov			al, [esi]				; userString to al
	
	cmp			al, 48			; compare string byte to 48 (digit 0 on ASCII)
	jb			invalid			; char is not a digit, jump to invalid to display error and get new answer
	cmp			al, 57			; compare string byte to 57 (digit 9 on ASCII)
	ja			invalid			; char is not a digit, jump to invalid to display error and get new answer

	inc			esi				; inc esi to check next 
	sub			al, 48			; convert ASCII char value to digit value (ex. dec 48 is 0)

	mov			ebx, [ebp+8]	; move userAnswer to ebx
	add			[ebx], al		; add digit from al to [ebx]

	loop	checkValid		; step through string
	jmp		inputEnd

inputEnd:
	call	crlf
	pop ebp
	ret 4
getData	ENDP

;*************factorial*****************************
;** sub procedure of combinations. perform calculations of factorial via recursion							
;**recieves: integer values (N) in edx
;**returns: The factorial of argument. N! in eax
;**preconditions: value of N pushed onto stack
;**registers changed: eax, ebx, esi
;*************************************************
factorial	PROC
	; set stack frame. integer N is [ebp+8]
	push		ebp							; store registers
	mov			ebp,esp
	mov			eax, [ebp+8]		; move N to eax

	;factorial of 1 or 0 is 1
	;BASE CASE
	cmp			eax, 1
	jle			factorialDone
	
	;else, perform recursion
	dec			eax					;eax is now N-1
	push		eax
	call		factorial

	mov			esi, [ebp+8]
	mul			esi


factorialDone:
	pop			ebp		; restore registers
	ret			4
factorial	ENDP

;*************combinations*****************************
;** perform calculatons on generated n and r	 						
;**recieves: n, r, address of result 
;**returns: result
;**preconditions: n and r values, OFFSET of result
;				   pushed on stack
;**registers changed: eax, ebx, ecx, edx
; REFERENCE: formula for combination from program 6b pdf
;*************************************************
combinations	PROC
	; set stack frame.
	;r is [ebp+16], 
	;n is [ebp+12], 
	;@result is [ebp+8]

	push		ebp
	mov			ebp,esp

	mov			edx, [ebp+16]		;move r into register
	mov			eax, [ebp+12]		;move n into register

	cmp			eax,edx
	je			nrEqual

	;calculate (n-r)!
	mov			eax, [ebp+12]		; move n to eax
	sub			eax, [ebp+16]		; get n-r, result in eax
	mov			edx, eax			; move result n-r into edx for factorial

	push		edx					;push edx to stack to prep factorial
	call		factorial
	mov			ecx, eax
	
	;calculate r!
	mov			edx, [ebp+16]
	push		edx					;push edx to stack to prep factorial
	call		factorial
	; result of (n-r)! in  now in eax

	; multiply (n-r)! by r!
	;Note: (n-r)! already in eax, r! in ecx
	mul			ecx					; multiply ecx by eax, result in eax
	mov			ecx, eax			; r!(n-r)! in ecx

	;calculate value for n!
	mov			edx, [ebp+12]
	push		edx
	call		factorial			; n! in eax

	;calculate n!/ (r!(n-r)!)
	; prepare division, set edx to 0
	mov			edx,0
	div			ecx					; divide by r!(n-r)!

	; @result at [ebp+8], move to ebx register for storage
	mov			ebx, [ebp+8]
	mov			[ebx], eax			; store answer in result

	jmp			combinationsDone

; n and r are equal ... factorial is 1
nrEqual:
	mov		ebx, [ebp+8]
	mov		ecx, 1
	mov		[ebx], ecx



combinationsDone:
	pop			ebp
	ret			12   ; 3 items were pushed
combinations	ENDP

;*************showResults*****************************
;** show results of combination problem	, note user performance							
;**recieves: goodbye_1 string variable
;**returns: nothing
;**preconditions: none
;**registers changed: none
;*************************************************
showResults	PROC
	;set stack frame
	;[ebp+20] is r
	;[ebp+16] is n
	;[ebp+12] is result
	;[ebp+8]  is userAnswer

	push		ebp
	mov			ebp, esp

	;dispay result
	displayString	result_1
	mov				eax, [ebp+12]		; move result for display
	call			WriteDec
	

	;display random r value
	displayString	result_2
	mov				eax, [ebp+20]		;move r to eax for display
	call			WriteDec


	;display random n value
	displayString	result_3
	mov				eax, [ebp+16]		; move n to eax for display
	call			WriteDec
	call			CrLf
	
	; show user's amser
	displayString	showUserAnswer
	mov				eax, [ebp+8]		; move userAnswer for display
	call			WriteDec
	call			CrLf



	
	; compare user answer to correct answer
	mov				ecx, [ebp+12]		; move result
	mov				edx, [ebp+8]		; move user answer
	cmp				ecx, edx			; if equal jump to correct
	je				userCorrect

	;else display incorrect

	displayString	incorrect
	call			CrLf
	jmp				endDisplay

userCorrect:
	displayString	correct
	call			CrLf

endDisplay:


	pop ebp
	ret	16
showResults	ENDP

;*************playAgain*****************************
;**ask if user wants to play again								
;**recieves: prompt_again string variable
;**returns: ebx as 1 (yes) or 0 (no)
;**preconditions: none
;**registers changed: ecx
;*************************************************
playAgain	PROC
choose:
	mov				ebx, 0
	displayString	prompt_again

	; prep conditions for read string
	mov				edx, OFFSET choice
	mov				ecx, 9
	call			ReadString


	; check if yes
	mov				esi, OFFSET choice
	mov				edi, OFFSET choiceYes
	; compare bytes of string
	cmpsb	
	mov				ebx, 1				; 1 interpreted as yes in main
	je				doneAgain

	; check if no
	mov				esi, OFFSET choice
	mov				edi, OFFSET choiceNo
	; compare bytes of string
	cmpsb	
	mov				ebx, 0				; 0 interpreted as no in main
	je				doneAgain

	; no jump means no valid answer
	displayString	error_1
	call			Crlf
	jmp				choose
	
doneAgain:
	ret
playAgain	ENDP

;*************goodbye*****************************
;**display goodbye						 		
;**recieves: goodbye_1 string variable
;**returns: nothing
;**preconditions: none
;**registers changed: none
;*************************************************
goodbye	PROC
	call			CrLf
	displayString	goodbye_1
	call			CrLf
	call			Crlf

	ret
goodbye	ENDP

END main
