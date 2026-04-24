        .syntax unified
        .cpu cortex-m4
        .thumb
        .global main

        .text

main:
        mov     r0, #10        @ R0 = 10
        mov     r1, #3         @ R1 = 3

        add     r2, r0, r1     @ R2 = R0 + R1 = 13
        sub     r3, r0, r1     @ R3 = R0 - R1 = 7

stop:
        nop
        b       stop