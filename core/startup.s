        .syntax unified
        .cpu cortex-m4
        .thumb

        .section .vectors, "a"
        .word __StackTop              @ Initial Stack Pointer
        .word Reset_Handler + 1       @ Reset
        .word Default_Handler + 1     @ NMI
        .word Default_Handler + 1     @ HardFault
        .word Default_Handler + 1     @ MemManage
        .word Default_Handler + 1     @ BusFault
        .word Default_Handler + 1     @ UsageFault
        .space 16                     @ Reserved (4 words)
        .word Default_Handler         @ SVCall
        .word Default_Handler         @ Debug Monitor
        .space 4                      @ Reserved
        .word Default_Handler         @ PendSV
        .word Default_Handler         @ SysTick

        .text

        .global Reset_Handler
        .type Reset_Handler, %function
Reset_Handler:
        bl main
        b .

        .global Default_Handler
        .type Default_Handler, %function
Default_Handler:
        b Default_Handler
