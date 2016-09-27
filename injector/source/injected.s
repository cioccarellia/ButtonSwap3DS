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
LDR     R2, [R0]         // Load HID State

MOV     R3, #0x20
LSL     R3, R3, #4
ADD     R3, R3, #2       // R3 Button mask

MOV     R4, #0x30
LSL     R4, R4, #4
ADD     R4, R4, #2       // R3 XOR mask

AND     R0, R2, R3       // Extract desired values
CMP     R0, #0           // See if either are pressed
EOREQ   R2, R2, R4       // If so, xor HID Register
STR     R2, [R1]         // Store R4 at *R3
MOV     PC, R14          // Return

.LTORG # assembles literal pool

read_input_sz:
.4byte  .-read_input
