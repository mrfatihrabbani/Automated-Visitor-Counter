#define __SFR_OFFSET 0
#define ENTRY_FLAG      0x0200
#define EXIT_FLAG       0x0201
#define OCCUPANCY_COUNT 0x0202
#define ALARM_ACTIVE    0x0203
#define EEP_PTR         0x0100 

#include "avr/io.h"

.extern INT0_vect
.extern INT1_vect
.extern TIMER0_OVF_vect
.extern interrupt_init
.extern display_timer_init
.extern data_init
.extern process_flags
.extern EEPROM_restore           
.extern lcd_init                 
.extern lcd_refresh     

.global main

.org 0x0000
    rjmp main
    nop                     
    
    rjmp INT0_vect
    nop                     
    
    rjmp INT1_vect
    nop                     

    .rept 11
    rjmp dummy
    nop
    .endr

    rjmp TIMER0_OVF_vect    
    nop                     

    .rept 9
    rjmp dummy
    nop
    .endr

dummy:
    reti    

main:
    ldi   r16, hi8(RAMEND)
    out   SPH, r16
    ldi   r16, lo8(RAMEND)
    out   SPL, r16

    clr   r16
    sts   ENTRY_FLAG,      r16
    sts   EXIT_FLAG,       r16
    sts   OCCUPANCY_COUNT, r16
    sts   ALARM_ACTIVE,    r16

    rcall EEPROM_restore          

    rcall interrupt_init
    rcall display_timer_init
    rcall data_init
    
    rcall lcd_init            
    rcall lcd_refresh         

    sei

loop:
    rcall process_flags
    rjmp  loop
