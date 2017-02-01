.global read_input
.global read_input_sz

read_input:
STMFD   SP!, {R4-R6,LR}
MOV     R5, R1
MRC     p15, 0, R4,c13,c0, 3
MOV     R1, #0x10000
STR     R1, [R4,#0x80]!
LDR     R0, [R0]
SVC     0x32
ANDS    R1, R0, #0x80000000
BMI     .ret
PUSH    {r3}
LDR     R3, =0x10df08
LDRD    R0, [R4,#8]
STRD    R0, [R3, #8]
LDRD	  R0, [R3]
STRD	  R0,	[R5]
LDR     R0, [R4,#4]
POP     {R3}

@buttons init
LDR     R0, =0x10df20
LDR     R1, =0xFFF
BL      .init

@touch init
LDR     R0, =0x10df24
LDR     R1, =0x2000000
BL      .init

@cpad init
LDR     R0, =0x10df28
LDR     R1, =0x800800
BL      .init

@buttons copy
LDR     R0, =0x1ec46000
LDR     R1, =0x10df00
BL      .swap

@touch copy
LDR     R0, =0x10df24
LDR     R1, =0x2000000
LDR     R2, =0x10df10
LDR     R3, =0x10df08
BL      .copy

@cpad copy
LDR     R0, =0x10df28
LDR     R1, =0x800800
LDR     R2, =0x10df14
LDR     R3, =0x10df0c
BL      .copy

.ret:
LDMFD   SP!, {R4-R6,PC}

.init:
LDR     R2, [R0]
CMP     R2, #0
STREQ   R1, [R0]
MOV     PC, R14

.copy:
LDR     R4, [R2]
STR     R4, [R3]
MOV     PC, R14

.swap:
LDR     R2, [R0]       // Load HID State
MOV     R6, R2         // R2 = TempHID  R6 = HID State

// A ==> B
MOV     R3, #0x2       // R3 Button mask
MOV     R4, #0x3       // R4 EOR mask
AND     R5, R6, R3     // Extract desired values

// 1:1 Swap (A<==>B)
//CMP     R0, R3       // See if either are pressed: 1:1 swap
//EORNE   R2, R2, R4   // If so, EOR temp HID Register: 1:1 swap

// X:1 Replace (L+B==>R)
CMP     R5, #0         // See if all are pressed: X:1 Replace
EOREQ   R2, R2, R4     // If so, EOR temp HID Register: X:1 Replace

// Y ==> A
MOV     R3, #0x1

MOV     R4, #0x80
LSL     R4, R4, #4
ADD     R4, R4, #1

AND     R5, R6, R3

CMP     R5, #0
EOREQ   R2, R2, R4

// B ==> Y
MOV     R3, #0x800

MOV     R4, #0x80
LSL     R4, R4, #4
ADD     R4, R4, #2

AND     R5, R6, R3

CMP     R5, #0
EOREQ   R2, R2, R4

STR     R2, [R1]         // Move temp HID to RedHID
MOV     PC, R14          // Return

.LTORG # assembles literal pool

read_input_sz:
.4byte  .-read_input
