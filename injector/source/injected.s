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
push {r3}
ldr r3, =0x10df08
LDRD    R0, [R4,#8]
STRD    R0, [R3, #8]
LDRD	r0, [R3]
STRD	r0,	[R5]
LDR     R0, [R4,#4]
pop {r3}

@buttons init
ldr r0, =0x10df20
ldr r1, =0xFFF
bl .init

@touch init
ldr r0, =0x10df24
ldr r1, =0x2000000
bl .init

@cpad init
ldr r0, =0x10df28
ldr r1, =0x800800
bl .init

@buttons copy
ldr r0, =0x10df20
ldr r1, =0xFFF
ldr r2, =0x1ec46000
ldr r3, =0x10df00
bl .swap

@touch copy
ldr r0, =0x10df24
ldr r1, =0x2000000
ldr r2, =0x10df10
ldr r3, =0x10df08
bl .copy

@cpad copy
ldr r0, =0x10df28
ldr r1, =0x800800
ldr r2, =0x10df14
ldr r3, =0x10df0c
bl .copy

.ret:
LDMFD   SP!, {R4-R6,PC}

.init:
ldr r2, [r0]
cmp r2, #0
streq r1, [r0]
mov pc, r14

.copy:
ldr r4, [r2]
str r4, [r3]
mov pc, r14

.swap:
LDR     R4, [R2]         // Load HID State

// ARM ASM doesn't allow us to directly load a big enough
// bitmask.  These load them into registers manually.

MOV     R5, #0x30
LSL     R6, R5, #4
ADD     R5, R6, #2       // R5 XOR mask

MOV     R6, #0x20
LSL     R7, R6, #4
ADD     R6, R7, #2       // R6 Button mask

AND     R0, R4, R6       // Extract desired values
CMP     R0, #1           // See if either are pressed
EORMI   R1, R4, R5       // If so, xor HID Register
MOVMI   R4, R1
STR     R4, [R3]         // Store R4 at *R3
MOV     PC, R14          // Return

.LTORG # assembles literal pool

read_input_sz:
.4byte .-read_input
