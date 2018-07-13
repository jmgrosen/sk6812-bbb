DELAY_FOR .macro scratch,cycles
  ldi :scratch:, (:cycles: / 2)
$1:
  sub :scratch:, :scratch:, 1
  qblt $1, :scratch:, 0
  .endm

PRU0_ARM_SYSEVT .set 19
ARM_PRU0_SYSEVT .set 21
PRU0_IRQ_BIT .set 30
SICR_OFFSET .set 0x24
CONST_INTC .set c0

CONTROL_PTR .set 0
OUTPUT_BIT .set 0

T0H_WAIT .set 60                ; in cycles
T0L_WAIT .set 180
T1H_WAIT .set 120
T1L_WAIT .set 120
RESET_WAIT .set 16000


  .global _c_int00

_c_int00:
  ldi r10, CONTROL_PTR

wait_for_command:
  wbs r31, PRU0_IRQ_BIT
  ldi r11, ARM_PRU0_SYSEVT
  sbco &r11, CONST_INTC, SICR_OFFSET, 2 ; clear system event triggered by host
  lbbo &r1, r10, 0, 4           ; the command to execute
  qbne unknown_command, r1, 0

set_leds:
  lbbo &r1, r10, 4, 4           ; LED count
  lbbo &r2, r10, 8, 4           ; LED data pointer
  ldi r3, 0                     ; current LED index
  set r30, r30, OUTPUT_BIT

pixel_loop:
  ;; 6 cycles
  qbge pixel_loop_end, r1, r3   ; branch if LED index >= LED count
  lsl r4, r3, 2
  lbbo &r4, r2, r4, 4           ; load this LED data
  ldi r5, 0                     ; bit index counter

pixel_inner_loop:
  qble pixel_loop_bottom, r5, 32  ; if we're done with this LED
  qbbs pixel_bit_one, r4, r5.b0

pixel_bit_zero:
  set r30, r30, OUTPUT_BIT
  DELAY_FOR r29, T0H_WAIT
  clr r30, r30, OUTPUT_BIT
  DELAY_FOR r29, T0L_WAIT
  add r5, r5, 1
  qba pixel_inner_loop

pixel_bit_one:
  set r30, r30, OUTPUT_BIT
  DELAY_FOR r29, T1H_WAIT
  clr r30, r30, OUTPUT_BIT
  DELAY_FOR r29, T1L_WAIT
  add r5, r5, 1
  qba pixel_inner_loop

pixel_loop_bottom:
  add r3, r3, 1
  qba pixel_loop

pixel_loop_end:
  DELAY_FOR r29, RESET_WAIT
  ldi r31.b0, 32 | (PRU0_ARM_SYSEVT - 16) ; notify completion
  qba wait_for_command

unknown_command:
  halt
