Tiny CPU
========

A simple 8085 like / inspired CPU written in `Verilog` as a way to learn
fundamental workings of CPU.

Spec
----

The core working is one instruction at a time using a small `FSM`. Data path
of `8 bit`, Memory of `256 bytes` i.e. (8 bit address), and Registers include:

| `A`         | `B`     | `PC`            | `IR`                 | `Z`       | `C`        |
| ----------- | ------- | --------------- | -------------------- | --------- | ---------- |
| accumulator | general | program counter | instruction register | zero flag | carry flag |

All instructions are 1 byte except ones that need an address or immediate.

```assembly
; 0000xxxx = ALU ops
; 0001xxxx = register ops
; 0010xxxx = immediate ops
; 0011xxxx = jumps
; 11111111 = halt

;; Instruction set:

; Arithmetic
        00 ADD B                       ; A = A + B
        01 SUB B                       ; A = A - B
        02 AND B
        03 OR B
        04 XOR B

; Data Movement
        10 MOV A, B
        11 MOV B, A
        12 MVI A, imm                  ; (next byte)
        13 MVI B, imm

; Memory
        20 LDA addr                    ; (next byte)
        21 STA addr

; Control flow
        30 JMP addr
        31 JZ addr
        32 JNZ addr
        FF HLT
```

Resource
--------

- <https://unidel.edu.ng/focelibrary/books/Digital%20Design%20and%20Computer%20Architecture%20(Harris,%20Sarah,%20Harris,%20David)%20(Z-Library).pdf>
