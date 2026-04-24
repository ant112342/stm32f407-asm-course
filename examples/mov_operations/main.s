        .syntax unified
        .cpu cortex-m4
        .thumb
        .global main

        .text

main:
        mov     r0, #42        @ R0 = 42
        mov     r1, #5         @ R1 = 5
        mov     r2, #10        @ R2 = 10

stop:
         nop
        b       stop